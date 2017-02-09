/* Opcodes 1st nibble */
#define OP_CODE   0x0
#define OP_COND   0x1
#define OP_JMP    0x2
#define OP_CALL   0x3
#define OP_CALLF  0x4
#define OP_ARITOP 0x5
#define OP_BITOP  0x6
#define OP_LDO    0x7
#define OP_LDR    0x8
#define OP_STO    0x9
#define OP_STR    0xA
#define OP_XFER   0xB
#define OP_MOVL   0xC
#define OP_MOVH   0xD
#define OP_MOVI   0xE /* pepe64 (e pepe32) */

/* Opcodes 2nd nibble */
#define OP_ADD    0x0
#define OP_ADDI   0x1
#define OP_ADDC   0x2
#define OP_SUB    0x3
#define OP_SUBI   0x4
#define OP_SUBB   0x5
#define OP_CMP    0x6
#define OP_CMPI   0x7
#define OP_MUL    0x8
#define OP_DIV    0x9
#define OP_MOD    0xA
#define OP_NEG    0xB
#define OP_SHRA   0xC
#define OP_SHLA   0xD
#define OP_SHRAR  0xE /* v3 */
#define OP_SHLR   0xF /* v3 */

#define OP_AND    0x0
#define OP_OR     0x1
#define OP_NOT    0x2
#define OP_XOR    0x3
#define OP_TEST   0x4
#define OP_BIT    0x5
#define OP_SETBIT 0x6
#define OP_CLRBIT 0x7
#define OP_CPLBIT 0x8
#define OP_SHR    0x9
#define OP_SHL    0xA
#define OP_SHRR   0xB /* v3 */
#define OP_ROR    0xC
#define OP_ROL    0xD
#define OP_RORC   0xE
#define OP_ROLC   0xF

#define OP_LDB    0x0
#define OP_STB    0x1
#define OP_LDP    0x2 /* old */
#define OP_STP    0x3 /* old */
#define OP_MOVBS  0x2 /* new */
#define OP_MOVRR  0x3
#define OP_MOVAR  0x4
#define OP_MOVRA  0x5
#define OP_MOVRU  0x6
#define OP_MOVUR  0x7
#define OP_SWAPR  0x8
#define OP_SWAPM  0x9
#define OP_PUSH   0xA
#define OP_POP    0xB
#define OP_PUSHC  0xC /* new */
#define OP_POPC   0xD /* new */
#define OP_EXTND  0xE /* v3 */
#define OP_BOUND  0xF /* v3 */

#define OP_JZ     0x0
#define OP_JNZ    0x1
#define OP_JN     0x2
#define OP_JNN    0x3
#define OP_JP     0x4
#define OP_JNP    0x5
#define OP_JC     0x6
#define OP_JNC    0x7
#define OP_JV     0x8
#define OP_JNV    0x9
#define OP_JA     0xA /* old -> new */
#define OP_JNA    0xB /* old */
#define OP_JBE    0xB /* new */
#define OP_JLT    0xC
#define OP_JLE    0xD
#define OP_JGT    0xE
#define OP_JGE    0xF

#define OP_NOP    0x0
#define OP_SWE    0x1
#define OP_CR     0x2
#define OP_CRF    0x3
#define OP_RET    0x4
#define OP_RETF   0x5
#define OP_RFE    0x6
#define OP_JMPR   0x7
#define OP_JMPI   0x8 /* v3 */
#define OP_CI     0x9 /* v3 */
#define OP_CIF    0xA /* v3 */
#define OP_RETN   0xB /* v3 */

/* Registers */
#define OP_RE  13
#define OP_SP  12
#define OP_RL  11
#define OP_BTE  14
#define OP_TEMP  15

/* Flags */
#define fZ 0x0001
#define fN 0x0002
#define fC 0x0004
#define fV 0x0008
#define fA 0x0010
#define fTV 0x0020
#define fTD 0x0040
#define fIE 0x0080
#define fIE0 0x0100
#define fIE1 0x0200
#define fIE2 0x0400
#define fIE3 0x0800
#define fDE 0x1000
#define fNP 0x2000
#define fR0 0x4000
#define fR1 0x8000
#define MASK_IE_NP ~(fIE | fNP | fDE)

/* Exceptions */
#define fINT0 0x1
#define fINT1 0x2
#define fINT2 0x4
#define fINT3 0x8
#define fEXCESS 0x10
#define fDIV0 0x20
#define fSOFTWARE 0x40
#define eSOFTWARE 0x6
#define fINV_OPC 0x80
#define fD_UNALIGNED 0x100
#define fI_UNALIGNED 0x200
#define fD_PAG_FAULT 0x400
#define fI_PAG_FAULT 0x800
#define fD_PROT 0x1000
#define fI_PROT 0x2000
#define fSO_READ 0x4000
#define fD_FAIL 0x8000
#define fI_FAIL 0x10000
#define fD_TLB_FAIL 0x20000
#define fI_TLB_FAIL 0x40000
#define fBOUND 0x80000

/* Flag Tests */
#define OP_IE_idx  0x7
#define OP_IE0_idx  0x8
#define OP_IE1_idx  0x9
#define OP_IE2_idx  0xA
#define OP_IE3_idx  0xB
#define OP_C_idx  0x2
#define OP_D_idx  0xC

#define OP_CODE_1(x) ((x & 0xF0)>>4)
#define OP_CODE_2(x) ((x & 0xF))

#define PEPMEM 0x10000
#define UNDEF 0x87654321

#define LAB_CODE   0
#define LAB_WORD   1
#define LAB_TABLE  2
#define LAB_STRING 3
#define LAB_EQU    4

typedef struct undef {
	int addr;
	int line;
	char *file;
	struct undef *next;
} Undef;
typedef struct label {
	int addr;
	int type;
	int old; /* mark as 'old' at the end of a file */
	struct label *next;
	Undef *undef;
	char name[1];
} Label;

/* globals */
extern Label *symbtab;
extern char *filename;
extern char *version, *lblver;
extern unsigned char mem[PEPMEM];
extern unsigned short r[], *mw;
extern int newops;

/* parsing variables (lexical+syntactical) */
extern int yynerrs;
extern int yylineno;
extern FILE *yyin;
extern void yyerror(char *s);
extern int yylex(void);


/* functions */
int symtab(char *name, int addr, int ip, int type, char *file, int line);
int symrep(char *name, int type);
int symbaddr(int addr, char **label);
int symfind(char *label, int *type);
void symbols(void);
int relocate(void);
void interp(int flags, int start);
void disasm(int addr, int end);

#define extendNibble(ch) (((ch)&0x8)?((ch)&0xF)-16:(ch)&0xF)
#define extendByte(ch) (((ch)&0x80)?((ch)&0xFF)-256:(ch)&0xFF)
#define extendSmall(ch) (((ch)&0x800)?((ch)&0xFFF)-4096:(ch)&0xFFF)
#define extendShort(ch) (((ch)&0x8000)?((ch)&0xFFFF)-65536:(ch)&0xFFFF)

#define PEPEdebug 1
#define PEPEtrace 2
#define PEPEquiet 4
#define PEPEresults 8 /* No of executed instructions (and time, if in quiet mode) */
#define PEPEexcept 16 /* Use exceptions */
#define PEPEnewops 32 /* new operations */

#define PEPEheader "\xFE\xFEpepe1"
