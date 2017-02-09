#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "y.tab.h"
#include "pepe.h"

/* [label[:]] [{instruction | pseudo instruction | directive | macro call}] [; comment] */

void yyerror(char *s);
int yyparse(void);
char *filename = "<<stdin>>";
int newops; /* v3 flag */
int flags;

static char ops[16][16][8] = {
/* 0:CODE */	{ "tNOP", "lSWE", "sCALL", "sCALLF", "wRET", "tRETF", "tRFE", "sJMP",
	 	  "yJMP", "yCALL", "yCALLF", "xRET", "tNOP", "tNOP", "tNOP", "tNOP" },
/* 1:COND */	{ "qJZ", "qJNZ", "qJN", "qJNN", "qJC", "qJP", "qJNP", "qJNC",
		  "qJV", "qJNV", "qJA", "qJNA", "qJLT", "qJLE", "qJGT", "qJGE"},
/* 2:JMP */	{ "rJMP" },
/* 3:CALL */	{ "rCALL" },
/* 4:CALLF */	{ "rCALLF" },
/* 5:ARIT */	{ "aADD", "bADD", "aADDC", "aSUB", "bSUB", "aSUBB", "aCMP", "bCMP",
		  "aMUL", "aDIV", "aMOD", "cNEG", "dSHRA", "dSHLA", "aSHRA", "aSHLA" },
/* 6:BIT */	{ "aAND", "aOR", "cNOT", "aXOR", "aTEST", "dBIT", "dSET", "dCLR",
		  "dCPL", "dSHR", "dSHL", "aSHR", "dROR", "dROL", "dRORC", "dROLC", },
/* 7:LDO */	{ "eMOV" },
/* 8:LDR */	{ "hMOV" },
/* 9:STO */	{ "fMOV" },
/* a:STR */	{ "iMOV" },        
/* b:XFER */	{ "gMOVB", "jMOVB", "gMOVBS", "aMOV", "mMOV", "nMOV", "oMOV", "pMOV",
		  "aSWAP", "gSWAP", "dPUSH", "dPOP", "tPUSHC", "tPOPC", "xEXTEND", "aBOUND"},
/* c:MOVL */	{ "kMOVL" },
/* d:MOVH */	{ "uMOVH" },
		{ "vERR" }, { "vERR" }
};

#define u1(x) ((x[0]&0xf0)>>4)
#define u2(x) (x[0]&0xf)
#define u3(x) ((x[1]&0xf0)>>4)
#define u4(x) (x[1]&0xf)
#define s4(x) extendNibble(x[1])
#define s34(x) extendByte(x[1])
#define u34(x) (x[1])
#define s234(x) extendSmall(x[0] << 8 | x[1])
#define op12(x) (ops[u1(x)][u2(x)]+1)
#define op1(x) (ops[u1(x)][0]+1)

static void RdRs(int i, unsigned char *x) { printf("%s r%d, r%d\n", op12(x), u3(x), u4(x)); }
static void RdK(int i, unsigned char *x) { printf("%s r%d, %d\n", op12(x), u3(x), s4(x)); }
static void Rd(int i, unsigned char *x) { printf("%s r%d\n", op12(x), u3(x)); }
static void RdN(int i, unsigned char *x) { printf("%s r%d, %d\n", op12(x), u3(x), u4(x)); }
static void RdRsOff(int i, unsigned char *x) { printf("%s r%d, [r%d + %d]\n", op1(x), u2(x), u3(x), s4(x)*2); }
static void RdOffRs(int i, unsigned char *x) { printf("%s [r%d + %d], r%d\n", op1(x), u3(x), s4(x)*2, u2(x)); }
static void RdRsInd(int i, unsigned char *x) { printf("%s r%d, [r%d]\n", op12(x), u3(x), u4(x)); }
static void RdRsRi(int i, unsigned char *x) { printf("%s r%d, [r%d + r%d]\n", op1(x), u2(x), u3(x), u4(x)); }
static void RdRiRs(int i, unsigned char *x) { printf("%s [r%d + r%d], r%d\n", op1(x), u3(x), u4(x), u2(x)); }
static void RdIndRs(int i, unsigned char *x) { printf("%s [r%d], r%d\n", op12(x), u3(x), u4(x)); }
static void RdK2(int i, unsigned char *x) { printf("%s r%d, %d\n", op1(x), u2(x), s34(x)); }
static void RdK2u(int i, unsigned char *x) { printf("%s r%d, %d\n", op1(x), u2(x), u34(x)); }
static void RdK3(int i, unsigned char *x) { printf("%s %d\n", op12(x), u34(x)); }
static void AdRs(int i, unsigned char *x) { printf("%s a%d, r%d\n", op12(x), u3(x), u4(x)); }
static void RdAs(int i, unsigned char *x) { printf("%s r%d, a%d\n", op12(x), u3(x), u4(x)); }
static void RsUsp(int i, unsigned char *x) { printf("%s r%d, USP\n", op12(x), u3(x)); }
static void UspRs(int i, unsigned char *x) { printf("%s USP, r%d\n", op12(x), u4(x)); }
static void Et2(int i, unsigned char *x) { char *lbl=""; int addr = s34(x) * 2 + i + 2;
  if (symbaddr(addr, &lbl) != -1)
    printf("%s %d  (%s)\n", op12(x), addr, lbl);
  else
    printf("%s %d\n", op12(x), addr);
}
static void Et3(int i, unsigned char *x) { char *lbl=""; int addr = s234(x) * 2 + i + 2;
  if (symbaddr(addr, &lbl) != -1)
    printf("%s %d (%s)\n", op1(x), addr, lbl);
  else
    printf("%s %d\n", op1(x), addr);
}
static void RsN(int i, unsigned char *x) { printf("%s r%d + %d\n", op12(x), u4(x), u3(x)); }
static void Nop(int i, unsigned char *x) { printf("%s\n", op12(x)); }
static void Err(int i, unsigned char *x) { printf("%s\n", op1(x)); }
static void Rd2K(int i, unsigned char *x) { printf("%s %d\n", op12(x), 2*u34(x)); }
static void RdPlusRs(int i, unsigned char *x) { printf("%s r%d + r%d\n", op12(x), u3(x), u4(x)); }
static void (*fmt[])(int i, unsigned char*) = { RdRs /* a */, RdK /* b */, Rd /* c */, RdN /* d */,
  RdRsOff /* e */, RdOffRs /* f */, RdRsInd /* g */, RdRsRi /* h */, RdRiRs /* i */,
  RdIndRs /* j */, RdK2 /* k */, RdK3 /* l */, AdRs /* m */, RdAs /* n */, RsUsp /* o */,
  UspRs /* p */, Et2 /* q */, Et3 /* r */, RsN /* s */, Nop /* t */, RdK2u /* u */, Err /* v */,
  Rd2K /* w */, RsN /* x */, RdPlusRs /* y */
};

/*
static char *setInst[16] = {"","","SETC","","","","","","EI","EI0","EI1","EI2","EI3","EDMA" };
static char *clrInst[16] = {"","","CLRC","","","","","","DI","DI0","DI1","DI2","DI3", "DDMA" };
*/

void disasm(int addr, int end)
{
  int i, in, nop = -1;

  if (end < 0 || addr < 0 || addr >= PEPMEM) {
    printf("address out of bounds.\n");
    return;
  }
 
  if (end >= PEPMEM) end = PEPMEM;
  for (i = addr; i < end; i += 2)
    /* if (((short*)mem)[i/2] != 0) */ {
      int op1 = mem[i] >> 4;
      // unsigned int val = mem[i] << 8 | mem[i+1];
      char *lbl;
      switch (symbaddr(i, &lbl)) {
	case LAB_STRING:
	  if (lbl != 0) printf("%5d:      %s:\n", i, lbl);
	  lbl = 0;
	  printf("%5d:        STRING ", i); in = 0;
	  do {
	    if (isprint(mem[i]))
	      printf("%s%c", in ? "" : ", \"", mem[i]), in = 1;
	    else printf("%s, %d", in ? "\"" : "", mem[i]), in = 0;
	    if (mem[i] == 0) break;
	    i++;
	  } while (i < end && symbaddr(i, 0) < 0);
	  printf("%s\n", in ? "\"" : "");
	  if (i % 2 != 0) i++; /* align */
	  i -= 2;
	  break;
	case LAB_TABLE:
	case LAB_WORD:
	  do {
	    if (lbl != 0) printf("%5d:      %s:\n", i, lbl);
	    lbl = 0;
	    printf("%5d:        WORD %d\n", i, (mem[i+1]<<8) | mem[i]);
	    i += 2;
	  } while (i < end && symbaddr(i, 0) < 0);
	  i -= 2;
	  break;
	case LAB_CODE:
	  printf("%5d:      %s:\n", i, lbl);
	  /* fallthrough */
	default:
	  if (((short*)mem)[i/2] == 0)
	    if (nop >= 0)
	      continue;
	    else
	      nop = i;
	  else
	    if (nop >= 0) {
	      if (nop != i-4) printf("       ....   ...\n");
	      printf("%5d: 0000   NOP\n", i-2);
	      nop = -1;
	    }
	  if (ops[op1][1][0] != 0) {
	    in = ops[op1][ ((unsigned char*)mem)[i] & 0xF ][0] - 'a';
	    // printf("%5d:   %s %2.2xX\n", i, ops[op1][ mem[i] & 0xF ]+1, val & 0xFF);
	  } else {
	    in = ops[op1][0][0] - 'a';
	    // printf("%5d:   %s %3.3x\n", i, ops[op1][0]+1, val & 0xFFF);
          }
          printf("%5d: %2.2X%2.2X   ", i, mem[i], mem[i+1]);
	  (*fmt[in])(i, &mem[i]);
	break;
      }
    }
  if (nop >= 0 && nop != i-2) {
    if (nop != i-4) printf("       ....   ...\n");
    printf("%5d: 0000   NOP\n", i-2);
  }
}

int pepeLoad(char *filename, int *start, int ignoreSymbols)
{
  FILE *fp;
  unsigned char buf[4];
  char name[128];
  int len, addr;

  if ((fp = fopen(filename, "rb")) == 0) {
    perror(filename);
    return 1;
  }
  if (fread(PEPEheader, 1, 8, fp) < 8 || fread(buf, 1, 4, fp) < 4)
    return perror(filename), 2;

  *start = (buf[2] << 8) & buf[3];
  len = (buf[2] << 8) & buf[3];
  if (len > 0 || ignoreSymbols != 0) {
    while (len > 0) {
      if (fread(buf, 1, 4, fp) < 4)
        return perror(filename), 2;
      addr = (buf[2] << 8) & buf[3];
      if (fread(name, 1, buf[0], fp) < buf[0]) return perror(filename), 2;
      symtab(name, addr, 0, buf[1], filename, 0);
      len -= buf[0];
    }
  }

  if (fread(mem, 1, PEPMEM, yyin) < PEPMEM)
    return perror(filename), 2;
  fclose(fp);

  return 0;
}

int pepeSave(const char *filename, int start, int ignoreSymbols)
{
  FILE *fp;
  Label *scout;
  char buf[4];
  int len = 0;

  if ((fp = fopen(filename, "wb")) == 0) {
    perror(filename);
    return 1;
  }
  if (fwrite(PEPEheader, 1, 8, fp) < 8) return perror(filename), 2;
  if (ignoreSymbols == 0)
    for (scout = symbtab; scout != 0; scout = scout->next)
      len += strlen(scout->name) + 5;
  buf[0] = (start >> 8) & 0xFF;
  buf[1] = start & 0xFF;
  buf[2] = (len >> 8) & 0xFF;
  buf[3] = len & 0xFF;
  if (fwrite(buf, 1, 4, fp) < 4) return perror(filename), 2;
  if (ignoreSymbols == 0)
    for (scout = symbtab; scout != 0; scout = scout->next) {
      buf[0] = strlen(scout->name) + 5;
      buf[1] = scout->type;
      buf[2] = (scout->addr >> 8) & 0xFF;
      buf[3] = scout->addr & 0xFF;
      if (fwrite(buf, 1, 4, fp) < 4) return perror(filename), 2;
      if (fwrite(scout->name, 1, strlen(scout->name)+1, fp) < strlen(scout->name)+1)
        return perror(filename), 2;
    }

  if (fwrite(mem, 1, PEPMEM, fp) < PEPMEM) {
    perror(filename);
    return 2;
  }
  fclose(fp);

  return 0;
}

int main(int argc, char *argv[])
{
  char *ptr, *opt, *out = 0, *arg0 = argv[0], *start_lbl = 0, *prog = 0;
  int i, files = 0, start = -1, ignore = 0, errors = 0;
  int args[100], argn = 0;
#ifdef YYDEBUG
  extern int yydebug;
  yydebug = getenv("YYDEBUG") ? 1 : 0;
#endif

  flags = PEPEdebug;
  while (*++argv) {
    opt = argv[0];
    if (opt[0] == '-')
      while (*++opt)
	switch (*opt) {
	  case 'i':
	    ignore = 1;
	    break;
	  case 'd':
	    flags ^= PEPEdebug;
	    break;
	  case 'e':
	    flags ^= PEPEexcept;
	    break;
	  case 'n':
	    flags ^= PEPEnewops;
	    break;
	  case 't':
	    newops |= PEPEtrace;
	    break;
	  case 'q':
	    flags = PEPEquiet;
	    break;
	  case 'r':
	    flags |= PEPEresults;
	    break;
	  case 's':
	    if (argv[1] != 0)
	      if ('0' <= argv[1][0] && argv[1][0] <= '9')
	        start = atoi(*++argv);
	      else
	        start_lbl = *++argv;
	    else
	      printf("Usage: -s <addr> (to start at given address)\n");
	    break;
	  case 'o':
	    if (argv[1] != 0)
	      out = *++argv;
	    else
	      printf("Usage: -o <file> (to save the memory to file)\n");
	    break;
	  case 'v':
	    printf("%s\n", version);
	    return 0;
	  case 'h': printf("PEPE (%s) interpreter (and debugger)\n"
	  		   "  USAGE: %s [options] [files] [-- program-arguments]\n"
	  		   "  Files can be assembler (.asm) or memory (.mem)\n"
	  		   "  Available options:\n"
	      		   "\t-o <file> (to save the memory to file)\n"
			   "\t-s <addr> (symbol name or address to start)\n"
			   "\t-d (toogle the debug flag)\n"
			   "\t-n (allow new operations)\n"
			   "\t-e (toogle the excptions flag)\n"
			   "\t-t (toogle the trace flag)\n"
			   "\t-q (quiet mode, no debug or trace)\n"
			   "\t-r (results, includes time in quiet mode)\n"
			   "\t-i (ignore errors and continue)\n"
			   "\t-v (print software version and exit)\n"
			   "\t-h (this help)\n", lblver, arg0);
	    break;
	  case '-':
	    while (opt[1] != 0) opt++; /* avoid any pending options */
	    ptr = prog;
	    args[argn++] = i = r[12] -= strlen(ptr) + 1;
	    do mem[i++] = *ptr; while (*ptr++ != 0);
	    while (*++argv) {
	      // printf("arg 0 %s\n", argv[0]);
	      ptr = argv[0];
	      args[argn++] = i = r[12] -= strlen(ptr) + 1;
	      do mem[i++] = *ptr; while (*ptr++ != 0);
	    }
	    i = argn;
	    r[12] &= 0xFFFE; /* align */
	    mw[(r[12]-=2)/2] = 0; /* agv[argc] = 0 */
	    while (i > 0) mw[(r[12]-=2)/2] = args[--i];
	    mw[(r[12]-=2)/2] = r[12]+2;
	    mw[(r[12]-=2)/2] = argn;
	    argv--; /* reprocess NULL arg in outside while */
	    break;
	  default:
	    printf("%c: unknown option (use -h for help)\n" , *opt);
	    break;
	}
    else {
      if ((ptr = strrchr(filename = argv[0], '.')) == 0) ptr = filename;
      if (strcmp(ptr, ".mem") == 0) {
	if (pepeLoad(filename, &start, 0) > 0) {
	  if (!ignore) return printf("Quiting...\n"), 2;
	}
      }
      else {
        if ((yyin = fopen(filename, "r")) == 0) {
	  perror(filename);
	  break;
        } 
	errors += yynerrs;
	yylineno = 1;
	yynerrs = 0;
	yyparse();
      }
      if (prog == 0) prog = filename;
      files++;
    }
  }
  if (files == 0) {
    printf("reading from stdin...   (type EOF to end)\n");
    errors += yynerrs;
    yynerrs = 0;
    yyparse();
  }
  errors += yynerrs;
  if (errors > 0) {
    printf("There were %d syntax errors.\n", errors);
    if (!ignore) return printf("Quiting...\n"), 2;
  }
  yynerrs = 0;

  if ((i = relocate()) > 0) {
    symbols();
    printf("There were %d undefined symbols.\n", i);
    if (!ignore) return printf("Quiting...\n"), 2;
  }
  if (start_lbl != 0)
    if ((start = symfind(start_lbl, &i)) < 0) {
      printf("Can not find start symbol \"%s\"\n", start_lbl);
      yynerrs++;
    }
    else
      if (i != LAB_CODE) {
        printf("Start symbol \"%s\" is not a CODE symbol\n", start_lbl);
	yynerrs++;
      }
  if (yynerrs > 0) {
    printf("There were %d relocation errors.\n", yynerrs);
    if (!ignore) return printf("Quiting...\n"), 2;
  }

  if (out != 0) {
    if (pepeSave(out, start, 0) > 0) {
      if (!ignore) return printf("Quiting...\n"), 1;
    }
  }
  else
    interp(flags, start);

  return 0;
}
