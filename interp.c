#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <setjmp.h>
#include <signal.h>
#include "y.tab.h"
#include "pepe.h"

static char *excpt[] = { "INT0", "INT1", "INT2", "INT3", "EXCESS", "DIV0",
			 "SWE", "OPC", "DALIGN", "IALIGN", "DPAG", "IPAG",
			 "DPROT", "IPROT", "READ", "DFAIL", "IFAIL",
			 "DTLB", "ITLB" };
#define RL    11
#define SP    12
#define RE    13
#define BTE   14
#define TEMP  15

unsigned short r[16], ra[16], ip, usp, ssp, rer, exceptions, bkpt = 1;
unsigned short *mw = (unsigned short*)mem; /* 16 bit operations */
#define MW(x) mw[(x)/2]

#define isprt(x) ((x)>=' '&(x)<='~')

static jmp_buf jmpenv;
static int quiet;
static long ninstrs;
static void intr(int sig)
{
  int no = fINT0;
  signal(sig,intr); /* re-arm signal for next call */
  if (sig == SIGABRT) no = fINT0;
  if (sig == SIGINT) no = fINT1;

#ifndef _WIN32
  if (sig == SIGHUP) no = fINT2;
  if (sig == SIGALRM) no = fINT3;
#endif
  if (r[RE] & (fIE | (sig << 9))) {
    exceptions |= no;
    longjmp(jmpenv, 1);
  }
}

#if defined(_WIN32) || defined(__WIN32__)
#include <sys/timeb.h>
static struct _timeb tbuf;
static long tics, telapsed;
#ifdef _WIN32
#define GETIME(tbuf) { telapsed = tics; _ftime(&tbuf); tics= tbuf.time * 1000 + tbuf.millitm; telapsed = tics-telapsed; }
#define PRINTIME(tbuf) fprintf(stderr, "elapsed=%ldmsec\n", telapsed)
#else
#define GETIME(tbuf) { telapsed = tics; tics=GetTickCount(); telapsed = tics-telapsed; _ftime(&buf); }
#define PRINTIME(tbuf) fprintf(stderr, "elapsed=%ldtics time=%d.%dsec\n", GetTickCount(), buf.time, buf.millitm)
#endif
#else
#include <sys/times.h>
static struct tms tbuf;
static time_t tics;
static int telapsed;
#define GETIME(tbuf) { telapsed = tics; tics=times(&tbuf); telapsed = tics-telapsed; }
#define PRINTIME(tbuf) fprintf(stderr, "elapsed=%dtics user=%dmsec system=%dmsec\n", telapsed, tbuf.tms_utime, tbuf.tms_stime)
#endif

/* Push address to the stack and SWE 240..251 */
static void Exit(void) {
  if (!quiet) {
    printf("Exiting simulator...(%d)\n", r[0]);
  } else if (tics != 0) {
    GETIME(tbuf);
    printf("Exiting simulator...(%d)   ", r[0]);
    PRINTIME(tbuf);
    if (telapsed == 0) telapsed++; /* to avoid divisions by zero on very small examples */
    if (ninstrs >= 0)
      printf("Performance: %d instructions por second.\n", (int)(1000.0*ninstrs/telapsed));
  }
  if (ninstrs >= 0) printf("Executed %d instructions.\n", ninstrs);
  if (!quiet) {
    printf("Press <Enter> to exit...\n"); getchar();
  }
  exit(r[0]);
}
static void readINT(void) {
  char buf[80]; 
  fgets(buf, 80, stdin);
  r[0] = atoi(buf);
  /* scanf("%h%*[^\n]\n", &r[0]); */
}
static void readBYTE(void) { char ch; scanf("%c%*[^\n]\n", &ch); r[0] = ch; } 
static void readSTRING(void) { r[0] = scanf("%[^\n]\n", &mem[r[0]]); }
static void writeHEX(void) { r[0] = printf("%hx", r[0]); }
static void writeINT(void) { r[0] = printf("%d", (short)r[0]); }
static void writeBYTE(void) { r[0] = printf("%c", r[0]); } 
static void writeSTRING(void) { r[0] = printf("%s", &mem[r[0]]); } 
static void writeNL(void) { r[0] = printf("\n"); } 
static void sigALARM(void) {
#ifndef _WIN32
	if (r[0] == 0) signal(SIGALRM, SIG_IGN);
	else { signal(SIGALRM, intr); alarm(r[0]); }
#endif
} 
static void noint(void) { printf("invalid software interrup: %d\n", mem[ip-1]); } 
static void brkpt(void) { /* find instruction and replace, decrement ip, warn user */ longjmp(jmpenv, 1); } 
void (*swe[])(void) = {		/* 240 */ Exit,
	/* 241 */ readINT,	/* 242 */ readBYTE,	/* 243 */ readSTRING,
	/* 244 */ writeINT,	/* 245 */ writeBYTE,	/* 246 */ writeSTRING,
	/* 247 */ writeNL,	/* 248 */ writeHEX,	/* 249 */ sigALARM,
	/* 250 */ noint,	/* 251 */ noint,	/* 252 */ noint,
	/* 253 */ noint,	/* 254 */ noint ,	/* 255 */ brkpt };

static int logicalFlags(int res)
{
  if (res == 0) {r[RE] |= fZ; r[RE] &= ~fN;} else r[RE] &= ~fZ;
  if ((res & 0x8000) > 0) {r[RE] |= fN;} else r[RE] &= ~fN;
  return res;
}
    
static void aritmeticFlags(int a, int b, int res)
{
  if ((res & 0x10000) > 0) r[RE] |= fC;
  else r[RE] &= ~fC;
  if ((((a & b & ~res) | (~a & ~b & res)) & 0x8000) > 0) r[RE] |= fV;
  else r[RE] &= ~fV;
}

static int sum(int a, int b, int carry, int uflags)
{
  int res = a + b + carry;
  if (uflags) {
    aritmeticFlags(a, b, res);
    return logicalFlags(res & 0xFFFF);
  }
  return res & 0xFFFF;
}

static int sub(int a, int b, int carry, int uflags)
{
  int res = a - b - carry;
  if (uflags) {
    if ((((a & ~res) | ((~a | b) & res)) & 0x8000) > 0) r[RE] |= fC;
    else r[RE] &= ~fC;
    if ((((a & ~b & ~res) | (~a & b & res)) & 0x8000) > 0) r[RE] |= fV;
    else r[RE] &= ~fV;
    return logicalFlags(res & 0xFFFF);
  }
  return res & 0xFFFF;
}

static int mult(int a, int b)
{
  int res = a * b;
  /* aritmeticFlags(a, b, res); */
  logicalFlags(res & 0xFFFF);
  return res;
}

static int divide(int a, int b)
{
  int res;
  if ((r[RE] & fA) != 0) a = (r[TEMP] << 16) | (a & 0xFFFF);
  res = a / b;
  /* aritmeticFlags(a, b, res); */
  return logicalFlags(res & 0xFFFF);
}

static int remain(int a, int b)
{
  int res;
  if ((r[RE] & fA) != 0) a = (r[TEMP] << 16) | (a & 0xFFFF);
  res = a % b;
  /* aritmeticFlags(a, b, res); */
  return logicalFlags(res & 0xFFFF);
}

void aritop(unsigned int val)
{
  int a, res, oper1 = (val >> 4) & 0xF, oper2 = val & 0xF;
  switch ((val & 0x0F00) >> 8) {
    case OP_ADD:
      r[oper1] = sum(r[oper1], r[oper2], 0, oper1 != RE);
      break;
    case OP_ADDC:
      r[oper1] = sum(r[oper1], r[oper2], (r[RE] & fC) == 0 ? 0 : 1, oper1 != RE);
      break;
    case OP_ADDI:
      r[oper1] = sum(r[oper1], extendNibble(oper2), 0, oper1 != RE);
      break;
    case OP_SUB:
      r[oper1] = sub(r[oper1], r[oper2], 0, oper1 != RE);
      break;
    case OP_SUBB:
      r[oper1] = sub(r[oper1], r[oper2], (r[RE] & fC) == 0 ? 0 : 1, oper1 != RE );
      break;
    case OP_SUBI:
      r[oper1] = sub(r[oper1], extendNibble(oper2),0, oper1 != RE);
      break;
    case OP_CMP:
      sub(r[oper1], r[oper2], 0, 1);
      break;
    case OP_CMPI:
      sub(r[oper1],extendNibble(oper2), 0, 1);
      break;
    case OP_MUL:
      res = mult(extendShort(r[oper1]),extendShort(r[oper2]));
      r[TEMP] = (res >> 16) & 0xFFFF;
      r[oper1] = res & 0xFFFF;
      break;
    case OP_DIV:
      if (r[oper2] == 0) exceptions |= fDIV0;
      else r[oper1] = divide(r[oper1], r[oper2]);
      /* else { res = divide(r[oper1], r[oper2]);
       *        r[oper2] = mod(r[oper1], r[oper2]);
       *        r[oper1] = res;
       *      }
       */
      break;
    case OP_NEG:
      r[oper1] = sub(0, r[oper1], 0, oper1 != RE);
      break;
    case OP_MOD:
      if (r[oper2] == 0) exceptions |= fDIV0;
      else r[oper1] = remain(r[oper1], r[oper2]);
      break;
    case OP_SHRAR:
      oper2 = r[oper2] & 0xF;
      /* fallthrough */
    case OP_SHRA:
      a = r[oper1];
      r[oper1] = logicalFlags((extendShort(r[oper1]) >> oper2) & 0xFFFF);
      if (oper2 > 0) {
	if ((a & (1 << (oper2 - 1))) != 0) r[RE] |= fC; 
	else r[RE] &= ~fC;
      }
      break;
    case OP_SHLR:
      oper2 = r[oper2] & 0xF;
      res = ((long)r[oper1]) << oper2;
      r[oper1] = (int)(res & 0xFFFF);
      if (oper1 != RE) {
	logicalFlags(r[oper1]);
	if (oper2 > 0) {
	  if ((res & 0x10000) != 0) r[RE] |= fC;
	  else r[RE] &= ~fC;
	}
      }
      break;
    case OP_SHLA:
      res = r[oper1] << oper2;
      a = (1 << (oper2))-1;
      r[oper1] = logicalFlags(res & 0xFFFF);
      if (oper2 > 0) {
	if ((res & 0x10000) != 0) r[RE] |= fC;
	else r[RE] &= ~fC;
      }
      if ((res & 0x8000) != 0) {
	if (((res >> 16) & a) == a) r[RE] &= ~fV;
	else r[RE] |= fV;
      }
      else
	if ((res >> 16) != 0) r[RE] |= fV;
	else r[RE] &= ~fV;
      break;
    default:
      exceptions |= fINV_OPC;
      break;
  }
}

void bitop(unsigned int val)
{
  long a, res;
  int oper1 = (val >> 4) & 0xF, oper2 = val & 0xF;
  switch ((val & 0x0F00) >> 8) {
    case OP_AND:
      r[oper1] = r[oper1] & r[oper2];
      if (oper1 != RE) logicalFlags(r[oper1]);
      break;
    case OP_OR:
      r[oper1] = r[oper1] | r[oper2];
      if (oper1 != RE) logicalFlags(r[oper1]);
      break;
    case OP_NOT:
      r[oper1] = ~r[oper1] & 0xFFFF;
      if (oper1 != RE) logicalFlags(r[oper1]);
      break;
    case OP_XOR:
      r[oper1] = r[oper1] ^ r[oper2];
      if (oper1 != RE) logicalFlags(r[oper1]);
      break;
    case OP_TEST:
      logicalFlags(r[oper1] & r[oper2]);
      break;
    case OP_BIT:
      logicalFlags(r[oper1] & (1 << oper2));
      break;
    case OP_SETBIT:
      r[oper1] = r[oper1] | (1 << oper2);
      if (oper1 != RE) logicalFlags(r[oper1]);
      break;
    case OP_CLRBIT:
      r[oper1] = r[oper1] & ~(1 << oper2) & 0xFFFF;
      if (oper1 != RE) logicalFlags(r[oper1]);
      break;
    case OP_CPLBIT:
      r[oper1] = r[oper1] ^ (1 << oper2);
      if (oper1 != RE) logicalFlags(r[oper1]);
      break;
    case OP_SHRR:
      oper2 = r[oper2] & 0xF;
      /* fallthrough */
    case OP_SHR:
      a = ((long)r[oper1]) << 16;
      res = a >> oper2;
      r[oper1] = (int)(res >> 16) ;
      if (oper1 != RE) {
	logicalFlags(r[oper1]);
	if (oper2 > 0) {
	  if ((res & 0x8000) != 0) r[RE] |= fC;
	  else r[RE] &= ~fC;
	}
      }
      break;
    case OP_SHL:
      res = ((long)r[oper1]) << oper2;
      r[oper1] = (int)(res & 0xFFFF);
      if (oper1 != RE) {
	logicalFlags(r[oper1]);
	if (oper2 > 0) {
	  if ((res & 0x10000) != 0) r[RE] |= fC;
	  else r[RE] &= ~fC;
	}
      }
      break;
    case OP_ROR:
      a = (((long)r[oper1]) << 16) | r[oper1];
      res = a >> oper2;
      r[oper1] = (int)(res & 0xFFFF);
      if (oper1 != RE) {
	logicalFlags(r[oper1]);
	if (oper2 > 0) {
	  if ((res & 0x8000) != 0) r[RE] |= fC;
	  else r[RE] &= ~fC;
	}
      }
      break;
    case OP_ROL:
      a = ((long)r[oper1]) << 16 | r[oper1];
      res = a >> (16 - oper2);
      r[oper1] = (int)(res & 0xFFFF);
      if (oper1 != RE) {
	logicalFlags(r[oper1]);
	if (oper2 > 0) {
	  if ((res & 0x1) != 0) r[RE] |= fC;
	  else r[RE] &= ~fC;
	}
      }
      break;
    case OP_RORC:
      a = ((long)r[oper1]) << 17 | r[oper1];
      if ((r[RE] & fC) != 0) a |= 0x10000;
      res = a >> oper2;
      r[oper1] = (int)(res  & 0xFFFF);
      if (oper1 != RE) {
	logicalFlags(r[oper1]);
	if (oper2 > 0) {
	  if ((res & 0x10000) != 0) r[RE] |= fC;
	  else r[RE] &= ~fC;
	}
      }
      break;
    case OP_ROLC:
      a = ((long)r[oper1]) << 16 | r[oper1] >> 1;
      if ((r[RE] & fC) != 0) a |= 0x8000;
      res = a << oper2;
      r[oper1] = (int)((res >> 16)  & 0xFFFF);
      if (oper1 != RE) {
	logicalFlags(r[oper1]);
	if (oper2 > 0) {
	  // if ((res & 0x100000000l) != 0) r[RE] |= fC;
	  res = 0x80000000L;
	  if (((res >> (oper2-1)) & res) != 0) r[RE] |= fC;
	  else r[RE] &= ~fC;
	}
      }
      break;
    default:
      exceptions |= fINV_OPC;
      break;
  }
}

void xfer(unsigned int val)
{
  int oper1 = (val >> 4) & 0xF, oper2 = val & 0xF;
  switch ((val & 0x0F00) >> 8) {
    case OP_LDB:
      r[oper1] = mem[r[oper2]]; /* load byte */
      break;
    case OP_STB:
      mem[r[oper1]] = r[oper2];
      break;
#ifdef PEPE1
    case OP_LDP:
      if ((r[oper2] & 1) != 0) exceptions |= fD_UNALIGNED;
      else r[oper1] = mem[r[oper2]] | (mem[r[oper2]+1] << 8);
      break;
    case OP_STP:
      if ((r[oper1] & 1) != 0) exceptions |= fD_UNALIGNED;
      else {
	mem[r[oper1]] = r[oper2] >> 8;
	mem[r[oper1]+1] = r[oper2] & 0xF;
      }
      break;
#endif
    case OP_MOVBS:
      r[oper1] = extendByte(mem[r[oper2]]);
      break;
    case OP_MOVRR:
      r[oper1] = r[oper2];
      break;
    case OP_MOVAR:
      ra[oper1] = r[oper2];
      break;
    case OP_MOVRA:
      r[oper1] = ra[oper2];
      break;
    case OP_MOVRU:
      r[oper1] = usp;
      break;
    case OP_MOVUR:
      usp = r[oper2];
      break;
    case OP_SWAPR:
      r[TEMP] = r[oper2];
      r[oper2] = r[oper1];
      r[oper1] = r[TEMP];
      break;
    case OP_SWAPM:
      if ((r[oper2] & 1) != 0) exceptions |= fD_UNALIGNED;
      else {
	r[TEMP] = MW(r[oper2]);
	MW(r[oper2]) = r[oper1];
	r[oper1] = r[TEMP];
      }
      break;
    case OP_PUSH:
      if ((r[SP] & 1) != 0) exceptions |= fD_UNALIGNED;
      else do {
	r[SP] = (r[SP] - 2) & 0xFFFF;
	MW(r[SP]) = r[oper1++];
      } while (oper2-- > 0);
      break;
    case OP_POP:
      if ((r[SP] & 1) != 0) exceptions |= fD_UNALIGNED;
      else do {
	r[oper1+oper2] = MW(r[SP]);
	r[SP] = (r[SP] + 2) & 0xFFFF;
      } while (oper2-- > 0);
      break;
    case OP_PUSHC:
      if ((r[SP] & 1) != 0) exceptions |= fD_UNALIGNED;
      else {
	for (oper1 = 0; oper1 < SP; oper1++) {
	  if (oper1 == SP) continue;
	  r[SP] = (r[SP] - 2) & 0xFFFF;
	  MW(r[SP]) = r[oper1];
	}
      }
      break;
    case OP_POPC:
      if ((r[SP] & 1) != 0) exceptions |= fD_UNALIGNED;
      else {
	for (oper1 = 0; oper1 < SP; oper1++) {
	  if (oper1 == SP) continue;
	  r[oper1] = MW(r[SP]);
	  r[SP] = (r[SP] + 2) & 0xFFFF;
	}
      }
      break;
    case OP_EXTND:
      if ((r[oper1] & 0x80) == 0) r[oper1] &= 0xFF;
      else r[oper1] |= 0xFF00;
      break;
    case OP_BOUND:
      if ((r[oper1] & 1) != 0) exceptions |= fD_UNALIGNED;
      if (MW(r[oper1]-2) < r[oper2]) exceptions |= fBOUND;
      break;
    default:
      exceptions |= fINV_OPC;
      break;
  }
}

void cond(unsigned int val)
{
  switch ((val & 0x0F00) >> 8) {
    case OP_JZ:
      if ((r[RE] & fZ) != 0) ip += 2 * extendByte(val);
      break;
    case OP_JNZ:
      if ((r[RE] & fZ) == 0) ip += 2 * extendByte(val);
      break;
    case OP_JN:
      if ((r[RE] & fN) != 0) ip += 2 * extendByte(val);
      break;
    case OP_JNN:
      if ((r[RE] & fN) == 0) ip += 2 * extendByte(val);
      break;
    case OP_JP:
      if ((r[RE] & fZ) == 0 && (r[RE] & fN) == 0) ip += 2 * extendByte(val);
      break;
    case OP_JNP:
      if ((r[RE] & fZ) != 0 || (r[RE] & fN) != 0) ip += 2 * extendByte(val);
      break;
    case OP_JC:
      if ((r[RE] & fC) != 0) ip += 2 * extendByte(val);
      break;
    case OP_JNC:
      if ((r[RE] & fC) == 0) ip += 2 * extendByte(val);
      break;
    case OP_JV:
      if ((r[RE] & fV) != 0) ip += 2 * extendByte(val);
      break;
    case OP_JNV:
      if ((r[RE] & fV) != 0) ip += 2 * extendByte(val);
      break;
    case OP_JA:
      if ((r[RE] & fC) == 0 && (r[RE] & fZ) == 0) ip += 2 * extendByte(val);
      break;
    case OP_JBE:
      if ((r[RE] & fC) != 0 || (r[RE] & fZ) != 0) ip += 2 * extendByte(val);
      break;
    case OP_JLT:
      if (((r[RE] & fN) ^ (r[RE] & fV)) != 0) ip += 2 * extendByte(val);
      break;
    case OP_JLE:
      if ((((r[RE] & fN) ^ (r[RE] & fV)) | (r[RE] & fZ)) != 0)
	ip += 2 * extendByte(val);
      break;
    case OP_JGT:
      if ((((r[RE] & fN) ^ (r[RE] & fV)) | (r[RE] & fZ)) == 0)
	ip += 2 * extendByte(val);
      break;
    case OP_JGE:
      if (((r[RE] & fN) ^ (r[RE] & fV)) == 0 ) ip += 2 * extendByte(val);
      break;
  }
}

void code(unsigned int val)
{
  int oper2 = val & 0xF, oper = val & 0xFF, k = (val & 0xF0) >> 3;
  switch ((val & 0x0F00) >> 8) {
    case OP_JMPR:
      if ((r[oper2] & 1) != 0) exceptions |= fI_UNALIGNED;
      ip = r[oper2] + k;
      break;
    case OP_CR:
      if ((r[SP] & 1) != 0) exceptions |= fD_UNALIGNED;
      if ((r[oper2] & 1) != 0) exceptions |= fI_UNALIGNED;
      r[SP] -= 2;
      MW(r[SP]) = ip;
      ip = r[oper2] + k;
      break;
    case OP_CRF:
      if ((r[oper2] & 1) != 0) exceptions |= fI_UNALIGNED;
      r[RL] = ip;
      ip = r[oper2] + k;
      break;
    case OP_RET:
      if ((r[SP] & 1) != 0) exceptions |= fD_UNALIGNED;
      ip = MW(r[SP]);
      r[SP] = (r[SP] + 2 + oper * 2) & 0xFFFF;
      break;
    case  OP_RETF:
      if ((r[RL] & 1) != 0) exceptions |= fI_UNALIGNED;
      ip = r[RL];
      r[SP] = (r[SP] + oper * 2) & 0xFFFF;
      break;
    case OP_SWE:
      if (oper >= 240) { swe[oper-240](); break; } /* prs: interp */
      if ((r[SP] & 1) != 0) exceptions |= fD_UNALIGNED;
      r[TEMP] = r[RE];
      r[RE] = 0;
      MW(r[SP]-2) = rer = ip;
      MW(r[SP]-4) = r[TEMP];
      ip = MW(r[BTE] + 2 * oper /* prs: SWE_index */ );
      r[SP] = (r[SP] - 4) & 0xFFFF;
      break;
    case OP_RFE:
      if ((r[SP] & 1) != 0) exceptions |= fD_UNALIGNED;
      r[TEMP] = MW(r[SP]);
      ip = MW(r[SP]+2);
      r[SP] = (r[SP] + 4) & 0xFFFF;
      r[RE] = r[TEMP];
      break;
    case OP_JMPI:
      if ((r[oper2] & 1) != 0) exceptions |= fI_UNALIGNED;
      ip = r[oper2] + r[k/2];
      break;
    case OP_CI:
      if ((r[SP] & 1) != 0) exceptions |= fD_UNALIGNED;
      if ((r[oper2] & 1) != 0) exceptions |= fI_UNALIGNED;
      r[SP] -= 2;
      MW(r[SP]) = ip;
      ip = r[oper2] + r[k/2];
      break;
    case OP_CIF:
      if ((r[oper2] & 1) != 0) exceptions |= fI_UNALIGNED;
      r[RL] = ip;
      ip = r[oper2] + r[k/2];
      break;
    case OP_RETN:
      if ((r[SP] & 1) != 0 || (r[oper2] & 1) != 0) exceptions |= fD_UNALIGNED;
      ip = MW(r[SP]);
      r[SP] = (r[SP] + 2 + r[oper2]) & 0xFFFF;
      break;
    case OP_NOP: break;
    default:
      exceptions |= fINV_OPC;
      break;
  }
}

void execute(int val)
{
  int addr, op2 = (val >> 8) & 0xF;
  int oper1 = (val >> 4) & 0xF, oper2 = val & 0xF, oper = val & 0xFF;
  switch ((val >> 12) & 0xF) {
    case OP_ARITOP:
      aritop(val);
      break;
    case OP_BITOP:
      bitop(val);
      break;
    case OP_LDO:
      addr = r[oper1] + 2 * extendNibble(oper2);
      if ((addr & 1) != 0) exceptions |= fD_UNALIGNED;
      else r[op2] = MW(addr);
      break;
    case OP_LDR:
      addr = r[oper1] + r[oper2];
      if ((addr & 1) != 0) exceptions |= fD_UNALIGNED;
      else r[op2] = MW(addr);
      break;
    case OP_STO:
      addr = r[oper1] + 2 * extendNibble(oper2);
      if ((addr & 1) != 0) exceptions |= fD_UNALIGNED;
      else MW(addr) = r[op2];
      break;
    case OP_STR:
      addr = r[oper1] + r[oper2];
      if ((addr & 1) != 0) exceptions |= fD_UNALIGNED;
      else MW(addr) = r[op2];
      break;
    case OP_XFER:
      xfer(val);
      break;
    case OP_MOVL:
      r[op2] = extendByte(oper);
      break;
    case OP_MOVH:
      r[op2] = (oper << 8) | (r[op2] & 0xff);
      break;
    case OP_COND:
      cond(val);
      break;
    case OP_JMP:
      ip += 2 * extendSmall(val);
      break;
    case OP_CODE:
      code(val);
      break;
    case OP_CALL:
      r[SP] -= 2;
      MW(r[SP]) = rer = ip;
      ip += 2 * extendSmall(val);
      break;
    case OP_CALLF:
      r[RL] = rer = ip;
      ip += 2 * extendSmall(val);
      break;
    default:
      exceptions |= fINV_OPC;
      break;
  }
}

static char *labels[] = { "CODE", "WORD", "TABLE", "STRING", "EQU" };

int prompt(void)
{
  char buf[80], *lbl;

  do {
    int a, b;
    printf("ip=%d> ", ip);
    if (fgets(buf, 80, stdin) == 0 || buf[0] == 'q') exit(0);
    buf[strlen(buf)-1] = 0;
    if (buf[0] == '?' || buf[0] == 'h' || buf[0] == 'H')
      printf("Command help:\n\tq (quit)\n\tx<addr> (examine)\n"
      	     "\tp<val> (print in decimal and hex)\n\tm <hex-mem> <hex-val> (memory set)\n"
      	     "\td<start> [<end>] (disasm)\n\ts (symbols)\n"
	     "\ts<name> (symbol by name)\n\ts<addr> (symbol at address)\n"
	     "\tr<num> <value> (set register <num> to <value>)\n"
	     "\tc<addr> (continue up to <addr>)\n"
	 /* "\tb<addr> (insert breakpoint at <addr>)\n" */
	     "\t<pos_number> (step <pos_number> instructions)\n"
	     "\t<neg_number> (continue)\n\t<return> (step. Same as 0)\n"
	     "Only non zero (0) registers are shown.\n");
    /* memory set ; examine [start [end]] (hex+ascii) */
    if (buf[0] == 'p') { a = strtol(buf+1, 0, 0); printf("%d 0x%x\n", a, a*2); }
    if (buf[0] == 'm') {
      if (sscanf(buf+1, "%x %x", &a, &b) == 2)
	MW(a)= (b<<8) | ((b>>8)&255);
    }
    if (buf[0] == 'x') {
      a = b = ip;
      /* a = atoi(buf+1); */
      if (sscanf(buf+1, "%d %d", &a, &b) == 1) {
	b = MW(a);
	printf("[%d] = %d 0x%x %d '%c' \"%s\"\n", a, b, b, mem[a], mem[a], mem+a);
      } else {
	int i, v;
	char s[20];
	while (a <= b) {
	  printf("%4.4x: ", a);
	  for (i = 0; i < 16; i+=2) {
	    printf(" %4.4x", v = MW(a+i));
	    s[i] = isprt(v&255) ? (v&255) : '.';
	    s[i+1] = isprt(v>>8&255) ? (v>>8&255) : '.';
	  }
	  s[16] = 0;
	  printf("  %s\n", s);
	  a += 16;
	}
      }
    }
    if (buf[0] == 'c') {
      bkpt = ip + 2; /* step to next instruction (over call, etc) */
      sscanf(buf+1, "%d", &bkpt);
      if (bkpt < 65535 && (bkpt & 1) == 0) return 1;
      printf("Invalid address (%d).\n", bkpt);
      bkpt = 1;
    }
    if (buf[0] == 'd') {
      a = b = ip;
      sscanf(buf+1, "%d %d", &a, &b);
      disasm(a, b+2);
    }
    if (buf[0] == 'r') {
      if (sscanf(buf+1, "%d %d", &a, &b) == 2)
	if (a < 0 || a > 15)
	  printf("Invalid register (%d).\n", a);
	else
	  r[a] = b;
    }
    if (buf[0] == 's') {
      if (buf[1] == 0) symbols();
      else
	if (isdigit(buf[1]))
	  if ((a = symbaddr(atoi(buf+1), &lbl)) != -1)
	    printf("%s is a %s at %d\n", lbl, labels[a], atoi(buf+1));
	  else printf("No symbol at %d.\n", atoi(buf+1));
	else
	  if ((a = symfind(buf+1, &b)) != -1)
	    printf("%s is a %s at %d\n", buf+1, labels[b], a);
	  else printf("No symbol %s.\n", buf+1);
    }
  } while (buf[0] != 0 && buf[0] != '-' && !isdigit(buf[0]));

  return atoi(buf);
}

void step(int val)
{
  int i, type, cnt = 0;
  char *lbl;

  printf("\n");
  for (i = 0; i < 16; i++)
    if (r[i] != 0)
      cnt += printf("%s r%d=%d", cnt>65?"\n":"", i, r[i]);
  for (i = 0; i < 16; i++)
    if (ra[i] != 0)
      cnt += printf("%s ra%d=%d", cnt>65?"\n":"", i, r[i]);
  if (usp != 0) cnt += printf("%s usp=%d", cnt>65?"\n":"", usp);
  if (ssp != 0) cnt += printf("%s ssp=%d", cnt>65?"\n":"", ssp);
  if (rer != 0) cnt += printf("%s rer=%d", cnt>65?"\n":"", rer);

  if (cnt) printf("\n");
  if ((type = symbaddr(ip, &lbl)) != -1)
    printf("%s: ; is a %s symbol.\n", lbl, labels[type]);
  disasm(ip, ip+2);
}

static void quietExec(void)
{
  while (1) {
    register unsigned int val = mem[ip] << 8 | mem[ip+1];
    ip += 2;
    if (ninstrs >= 0) ninstrs++;
    execute(val);
  }
}

void interp(int flags, int start)
{
  int debug = flags & PEPEdebug ? 0 : -1;
  int trace = flags & PEPEtrace;
  quiet = flags & PEPEquiet;
  if (quiet && (flags & PEPEresults)) GETIME(tbuf);
  if ((flags & PEPEresults) == 0) ninstrs = -1;
  if ((flags & PEPEexcept) != 0) signal(SIGINT, intr), signal(SIGABRT, intr);
  if (start < 0) start = symfind("start", 0);
  if (start < 0) start = 0;

  ip = start;
  if ((flags & PEPEquiet) != 0) { quietExec(); return; }
  printf("%s\n", version);
  if (debug >= 0) printf("? for help\n");

  while (1) {
    unsigned int val = mem[ip] << 8 | mem[ip+1];
    int except = exceptions;
    if ((bkpt & 1) == 0) { /* breakpoint set (even address) */
      if (ip == bkpt) {
	bkpt = 1;
        debug = 0;
      }
      else
        debug++;
    }
    if (debug > 0) debug--;
    if (trace != 0 || debug == 0) step(val);
    if (debug == 0) debug = prompt();
    ip += 2;
    if (ninstrs >= 0) ninstrs++;
    if (setjmp(jmpenv) == 0)
      execute(val);
    else
      debug = 1;
    if (except != exceptions) {
      int i;
      printf("CHKEXCEPTIONS = %x (", except ^ exceptions);
      for (i = 0; i < 19; i++)
        if ((except ^ exceptions) & (1 << i))
	  printf(" %s ", excpt[i]);
      printf(")\n");
      /* processar as excepções */
      /* if (r[BTE] != 0 e *(r[BTE]+offset) != 0) pc = *(bte+offset) */
    }
  }
}
