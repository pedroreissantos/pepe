%{ 
/* $Id: token.l,v 1.2 2009/01/13 00:54:55 prs Exp $ */
#include <stdlib.h> 
#include <string.h> 
#include "y.tab.h" 
#include "pepe.h" 
#define INCMAX 10
static void include(char*);
void yyerror(char *s);
int yylex(void);
int yyparse(void);
int filenum = 1; /* the sequence number of the file being processed */
static int lastfilenum = 1;
%} 
%option caseless 8bit lex-compat
%%
"EOF"			return 0;
^"help"$		fprintf(stderr, "I need somebody: HELP!\n");
^"version"$		fprintf(stderr, "%s\n", version);
^"exit"$		exit(0);
^"include"[^\n]+	include(yytext+7);
";".*			; /* comment */
[ \t\f]+		; /* white space */
("\r\n"|"\n"|"\r")+	return NL;
"place"			return PLACE; 
"equ"			return EQU; 
"word"			return WORD; 
"string"		return STRING; 
"table"			return TABLE; 
"add"			return ADD;
"addc"			return ADDC;
"sub"			return SUB;
"subb"			return SUBB;
"cmp"			return CMP;
"mul"			return MUL;
"div"			return DIV;
"mod"			return MOD;
"neg"			return NEG;
"shra"			return SHRA;
"shla"			return SHLA;
"inc"			return INC;
"dec"			return DEC;
"and"			return AND;
"or"			return OR;
"not"			return NOT;
"xor"			return XOR;
"test"			return TEST;
"bit"			return BIT;
"set"			return SET;
"ei"			return EI;
"ei0"			return EI0;
"ei1"			return EI1;
"ei2"			return EI2;
"ei3"			return EI3;
"setc"			return SETC;
"edma"			return EDMA;
"clr"			return CLR;
"di"			return DI;
"di0"			return DI0;
"di1"			return DI1;
"di2"			return DI2;
"di3"			return DI3;
"clrc"			return CLRC;
"ddma"			return DDMA;
"cpl"			return CPL;
"cplc"			return CPLC;
"shr"			return SHR;
"shl"			return SHL;
"ror"			return ROR;
"rol"			return ROL;
"rorc"			return RORC;
"rolc"			return ROLC;
"movb"			return MOVB;
"movbs"			return MOVBS;
"movl"			return MOVL;
"movh"			return MOVH;
"mov"			return MOV;
"bound"			return BOUND;
"extend"		return EXTEND;
"nop"			return NOP;
"swap"			return SWAP;
"push"			return PUSH;
"pop"			return POP;
"pushc"			return PUSHC;
"popc"			return POPC;
"jv"			return JV;
"jnv"			return JNV;
"jz"			return JZ;
"jnz"			return JNZ;
"jn"			return JN;
"jnn"			return JNN;
"jc"			return JC;
"jnc"			return JNC;
"jp"			return JP;
"jnp"			return JNP;
"ja"			return JA;
"jae"			return JAE;
"jb"			return JB;
"jbe"			return JBE;
"jeq"			return JEQ;
"jne"			return JNE;
"jlt"			return JLT;
"jle"			return JLE;
"jgt"			return JGT;
"jge"			return JGE;
"jmp"			return JMP;
"call"			return CALL;
"callf"			return CALLF;
"ret"			return RET;
"retf"			return RETF;
"swe"			return SWE;
"rfe"			return RFE;
"usp"			return USP;
"r0"			{ yylval.i =  0; return REG; }
"r1"			{ yylval.i =  1; return REG; }
"r2" 			{ yylval.i =  2; return REG; }
"r3"			{ yylval.i =  3; return REG; }
"r4"			{ yylval.i =  4; return REG; }
"r5" 			{ yylval.i =  5; return REG; }
"r6"			{ yylval.i =  6; return REG; }
"r7" 			{ yylval.i =  7; return REG; }
"r8"			{ yylval.i =  8; return REG; }
"r9"			{ yylval.i =  9; return REG; }
"r10" 			{ yylval.i = 10; return REG; }
"r11"			{ yylval.i = 11; return REG; }
"r12"			{ yylval.i = 12; return REG; }
"r13" 			{ yylval.i = 13; return REG; }
"r14"			{ yylval.i = 14; return REG; }
"r15" 			{ yylval.i = 15; return REG; }
"sp"			{ yylval.i = 12; return REG; }
"rl"			{ yylval.i = 11; return REG; }
"re"			{ yylval.i = 13; return REG; }
"bte"			{ yylval.i = 14; return REG; }
"temp"			{ yylval.i = 15; return REG; }
"a0"			{ yylval.i =  0; return REGAUX; }
"a1"			{ yylval.i =  1; return REGAUX; }
"a2" 			{ yylval.i =  2; return REGAUX; }
"a3"			{ yylval.i =  3; return REGAUX; }
"a4"			{ yylval.i =  4; return REGAUX; }
"a5" 			{ yylval.i =  5; return REGAUX; }
"a6"			{ yylval.i =  6; return REGAUX; }
"a7" 			{ yylval.i =  7; return REGAUX; }
"a8"			{ yylval.i =  8; return REGAUX; }
"a9"			{ yylval.i =  9; return REGAUX; }
"a10" 			{ yylval.i = 10; return REGAUX; }
"a11"			{ yylval.i = 11; return REGAUX; }
"a12"			{ yylval.i = 12; return REGAUX; }
"a13" 			{ yylval.i = 13; return REGAUX; }
"a14"			{ yylval.i = 14; return REGAUX; }
"a15"			{ yylval.i = 15; return REGAUX; }

[-+()\[\]:,*/%;{}.\$]	return *yytext; 
[A-Za-z_.][A-Za-z0-9_]*	{ yylval.s = strdup(yytext); return IDENT; } 
\"([^\\\"]|\\.)*\"	{ yytext[yyleng-1] = 0; yylval.s = strdup(yytext+1); return CHARS; }
\'[^']*\'		{ yylval.i = yytext[1]; return CHAR; }
[01]+"b"		{ char *endp; yylval.i = strtol(yytext, &endp, 2); return INTEGER; } 
[0-7]+"o"		{ char *endp; yylval.i = strtol(yytext, &endp, 8); return INTEGER; } 
[0-9a-fA-F]+"h"		{ char *endp; yylval.i = strtol(yytext, &endp, 16); return INTEGER; } 
[0-9]+"d"?		{ char *endp; yylval.i = strtol(yytext, &endp, 10); return INTEGER; } 
 
.			yyerror("Unknown character"); 
%% 
static struct {
  FILE *fp;
  char *name;
  int line;
  int filenum;
  YY_BUFFER_STATE buf;
} inc[INCMAX];
static int incn;
extern char *filename;
extern int yylineno;
#include <ctype.h>
static void include(char *name) {
  char buf[BUFSIZ], *ptr;
  if (incn < INCMAX) {
    while (isspace(*name)) name++;
    inc[incn].fp = yyin;
    inc[incn].name = filename;
    inc[incn].line = yylineno;
    inc[incn].filenum = filenum;
    inc[incn].buf = YY_CURRENT_BUFFER;
    strcpy(buf, filename);
    if ((ptr = strrchr(buf, '/')) == 0) ptr = buf; else ptr++;
    strcpy(ptr, name);
    if ((yyin = fopen(buf, "r")) != 0) {
      incn++;
      filenum = ++lastfilenum;
      filename = strdup(buf);
      yylineno = 1;
      yy_switch_to_buffer(yy_create_buffer(yyin, YY_BUF_SIZE));
      return;
    }
    perror(name);
    yyerror("Could not open include file.");
  }
  else
    yyerror("Too many included files.");
}

int yywrap(void) {
  extern int flags;
  if (incn == 0) {
    filenum = ++lastfilenum;
    return 1;
  }
  fclose(yyin);
  if ((flags & PEPEquiet) == 0)
    printf("load %s: %d lines\n", filename, yylineno);
  yyin = inc[--incn].fp;
  free(filename);
  filename = inc[incn].name;
  yylineno = inc[incn].line;
  filenum = inc[incn].filenum;
  yy_delete_buffer(YY_CURRENT_BUFFER);
  yy_switch_to_buffer(inc[incn].buf);
  return 0;
} 
