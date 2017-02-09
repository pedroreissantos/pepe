%{
/* $Id: gram.y,v 1.2 2009/01/13 00:54:55 prs Exp $ */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pepe.h"

#define out2(a,b) outb((a<<4)|(b&0xF))
/*
#define outb(b)	  mem[pos++] = (b)
#define outs(s)	  while (*s != 0) outb((unsigned char)*s++)
*/
#define TEMP  15

static void outb(unsigned char), outs(char*);

static int auxop, pos;
unsigned char mem[0x10000];
Label *symbtab;
%}

%union {
	int i;			/* integer value */
	char *s;		/* symbol name or string literal */
};

%token <i> INTEGER CHAR REG REGAUX
%token <s> IDENT CHARS
%token NL PLACE EQU WORD STRING TABLE
%token ADD ADDC SUB SUBB CMP MUL DIV MOD NEG
%token SHRA SHLA INC DEC AND OR NOT XOR BOUND
%token TEST BIT SET EI EI0 EI1 EI2 EI3 EXTEND
%token SETC EDMA CLR DI DI0 DI1 DI2 DI3 CLRC DDMA
%token CPL CPLC SHR SHL ROR ROL RORC ROLC
%token MOVB MOVBS MOVL MOVH MOV PUSH POP PUSHC POPC
%token JV JNV JZ JNZ JN JNN JC JNC JP JNP JA JAE
%token JB JBE JEQ JNE JLT JLE JGT JGE JMP SWAP
%token CALL CALLF RET RETF SWE RFE USP NOP

%type <i> posint ivalue intval string pm
%type <i> reg2 reg1 nop jump flow baseopt regopt
%type <i> aritop2 aritop bitop2 bitop cntopt
%type <i> bitopcte bitopnop longcte cond codenop longjmp
%type <s> label
%%

program	:
	| nl
	| program stmt nl
	| program error nl
	| program label nl
	| program label stmt nl
	;

label	: IDENT ':'			{ symtab($$=$1, pos, 0, LAB_CODE, filename, yylineno); }
	;

stmt	: IDENT EQU intval		{ symtab($1, $3, 0, LAB_EQU, filename, yylineno); }
	| WORD ivalue	{ char *lbl; if (symbaddr(pos, &lbl)!=-1) symrep(lbl, LAB_WORD); outb($2 & 0xFF); outb($2 >> 8); }
	| STRING string	{ char *lbl; if (symbaddr(pos, &lbl)!=-1) symrep(lbl, LAB_STRING); if ($2 % 2 != 0) pos++; /* align */ }
	| TABLE intval	{ char *lbl; if (symbaddr(pos, &lbl)!=-1) symrep(lbl, LAB_TABLE); pos += $2; }
	| PLACE INTEGER			{ pos = $2; }
	| reg2 REG ',' REG		{ outb($1); out2($2, $4); }
	| bitopcte REG ',' posint	{
		if ($4 == UNDEF) $4 = 0;
		if ($4 > 0xF) yyerror("Constant out of bounds ");
		out2(OP_BITOP, $1); out2($2, $4 & 0xF);
	    }
	| reg1 REG			{
			outb($1); out2($2, auxop == 0 ? $2 : auxop);
	    }
	| nop				{ outb($1); outb(auxop); }
	| regmem REG ',' '[' REG ']'	{ out2($2,$5); }
	| memreg '[' REG ']' ',' REG	{ out2($3,$6); }
	| longcte REG ',' ivalue	{
		if ($4 == UNDEF) $4 = 0;
		if ($4 > 0xFF) yyerror("Constant out of bounds ");
		out2($1, $2); outb($4 & 0xFF);
	    }
	| jump ivalue			{ /* was: jump posint */
		int k = ($2  - (pos+2)) >> 1;
		if ($2 == UNDEF) k = 0;
		if(k > 127 || k < -128) yyerror("Constant out of bounds ");
		outb($1); outb(k);
	    }
	| SWE posint			{
		if ($2 == UNDEF) $2 = 0;
		if ($2 > 0xFF) yyerror("Constant out of bounds ");
		out2(OP_CODE, OP_SWE); outb($2 & 0xFF);
	    }
	| ldst
	| flow
        | PUSH REG cntopt		{ if($2 > 15) yyerror("Constant out of bounds ");
					  out2(OP_XFER, OP_PUSH); out2($2, $3); }
        | POP REG cntopt		{ if($2 > 15) yyerror("Constant out of bounds ");
					  out2(OP_XFER, OP_POP); out2($2, $3); }
        | PUSHC				{ out2(OP_XFER, OP_PUSHC); out2(0, 0); }
        | POPC				{ out2(OP_XFER, OP_POPC); out2(0, 0); }
	| CLR REG ',' posint	{
		if ($4 == UNDEF) $4 = 0;
		if ($4 > 0xF) yyerror("Constant out of bounds ");
		out2(OP_BITOP, OP_CLRBIT); out2($2, $4 & 0xF);
	    }
	| EXTEND REG		{ out2(OP_XFER, OP_EXTND); out2($2, $2); }
	| BOUND REG ',' REG	{ out2(OP_XFER, OP_BOUND); out2($2, $4); }
	| CLR REG		{ out2(OP_ARITOP, OP_SUB); out2($2, $2); }
	| ADD REG ',' REG	{ out2(OP_ARITOP, OP_ADD); out2($2, $4); }
	| SUB REG ',' REG	{ out2(OP_ARITOP, OP_SUB); out2($2, $4); }
	| CMP REG ',' REG	{ out2(OP_ARITOP, OP_CMP); out2($2, $4); }
	| SHRA REG ',' REG	{ out2(OP_ARITOP, OP_SHRAR); out2($2, $4);
				  if (newops == 0) yyerror("Invalid operand (use -n)"); }
	| SHLA REG ',' REG	{ out2(OP_ARITOP, OP_SHLR); out2($2, $4);
				  if (newops == 0) yyerror("Invalid operand (use -n)"); }
	| SHR REG ',' REG	{ out2(OP_ARITOP, OP_SHRR); out2($2, $4);
				  if (newops == 0) yyerror("Invalid operand (use -n)"); }
	| SHL REG ',' REG	{ out2(OP_ARITOP, OP_SHLR); out2($2, $4);
				  if (newops == 0) yyerror("Invalid operand (use -n)"); }
	| ADD REG ',' ivalue	{
		if ($4 == UNDEF) $4 = 0;
		if ($4 > 7 || $4 < -8) yyerror("Constant out of bounds ");
		out2(OP_ARITOP, OP_ADDI); out2($2, $4 & 0xF);
	    }
	| SUB REG ',' ivalue	{
		if ($4 == UNDEF) $4 = 0;
		if ($4 > 7 || $4 < -8) yyerror("Constant out of bounds ");
		out2(OP_ARITOP, OP_SUBI); out2($2, $4 & 0xF);
	    }
	| CMP REG ',' ivalue	{
		if ($4 == UNDEF) $4 = 0;
		if ($4 > 7 || $4 < -8) yyerror("Constant out of bounds ");
		out2(OP_ARITOP, OP_CMPI); out2($2, $4 & 0xF);
	    }
	| SHRA REG ',' ivalue	{
		if ($4 == UNDEF) $4 = 0;
		if ($4 > 7 || $4 < -8) yyerror("Constant out of bounds ");
		out2(OP_ARITOP, OP_SHRA); out2($2, $4 & 0xF);
	    }
	| SHLA REG ',' ivalue	{
		if ($4 == UNDEF) $4 = 0;
		if ($4 > 7 || $4 < -8) yyerror("Constant out of bounds ");
		out2(OP_ARITOP, OP_SHLA); out2($2, $4 & 0xF);
	    }
	| SHL REG ',' posint	{
		if ($4 == UNDEF) $4 = 0;
		if ($4 > 0xF) yyerror("Constant out of bounds ");
		out2(OP_BITOP, OP_SHL); out2($2, $4 & 0xF);
	    }
	| SHR REG ',' posint	{
		if ($4 == UNDEF) $4 = 0;
		if ($4 > 0xF) yyerror("Constant out of bounds ");
		out2(OP_BITOP, OP_SHR); out2($2, $4 & 0xF);
	    }
	;

reg2	: aritop2			{ $$ |= OP_ARITOP << 4; }
	| bitop2			{ $$ |= OP_BITOP << 4; }
	;

reg1	: aritop			{ $$ |= OP_ARITOP << 4; }
	| bitop				{ $$ |= OP_BITOP << 4; }
	;

nop	: NOP				{ $$ = (OP_XFER << 4) | OP_MOVRR; }
	| bitopnop			{ $$ |= OP_BITOP << 4; }
	| codenop			{ $$ |= OP_CODE << 4; }
	;  

regmem	: MOVB				{ out2(OP_XFER, OP_LDB); }
	| MOVBS				{ out2(OP_XFER, OP_MOVBS); }
	;

memreg	: MOVB				{ out2(OP_XFER, OP_STB); }
	;

pm	: '+' { $$ = 0; }
	| '-' { $$ = 1; }
	;

ldst	: MOV REG ',' '[' REG ']'	{ out2(OP_LDO, $2); out2($5, 0); }
	| MOV REG ',' '[' REG pm ivalue ']'	{
		if ($7 == UNDEF) $7 = 0;
		if ($6) $7 = - $7;
		if($7 > 14 || $7 < -16) yyerror("Constant out of bounds ");
		out2(OP_LDO, $2); out2($5, $7 >> 1);
	      }
	| MOV REG ',' '[' REG '+' REG ']' {
		out2(OP_LDR, $2); out2($5, $7);
	      }
	| MOV '[' REG pm ivalue ']' ',' REG	{
		if ($5 == UNDEF) $5 = 0;
		if ($4 == 1) $5 = - $5;
		if($5 > 14 || $5 < -16) yyerror("Constant out of bounds ");
		out2(OP_STO, $8); out2($3, $5 >> 1);
	      }
	| MOV '[' REG ']' ',' REG		{
		out2(OP_STO, $6); out2($3, 0);
	      }
	| MOV '[' REG '+' REG ']' ',' REG	{
		out2(OP_STR, $8); out2($3, $5);
	      }
	| MOV REG ',' ivalue 			{ int x = $4;
		    if ($4 == UNDEF) x = 0x800;
		    if (x > 0xffff || x < -32768)
			    yyerror("Constant OUT of bounds ");
		    if ((x & 0xFF80) == 0 ) { /* positive byte constant */
			    out2(OP_MOVL, $2);
			    outb(x & 0xFF);
		    } else if ((x & 0xFF80) == 0xFF80) {
			    /* negative byte constant */
			    out2(OP_MOVL, $2);
			    outb(x & 0xFF);
		    } else { /* positive or negative word constant */
			    if ($4 == UNDEF) x = 0;
			    out2(OP_MOVL,$2);
			    outb((x & 0xFF));
			    out2(OP_MOVH,$2);
			    outb(((x >> 8) & 0xFF));
		    }
		}
	| MOV REG ',' REG	    { out2(OP_XFER, OP_MOVRR); out2($2, $4); }
	| MOV REGAUX ',' REG	    { out2(OP_XFER, OP_MOVAR); out2($2, $4); }
	| MOV REG ',' REGAUX	    { out2(OP_XFER, OP_MOVRA); out2($2, $4); }
	| MOV REG ',' USP	    { out2(OP_XFER, OP_MOVRU); out2($2, 0); }
	| MOV USP ',' REG	    { out2(OP_XFER, OP_MOVUR); out2(0, $4); }
	| SWAP REG ',' REG	    { out2(OP_XFER, OP_SWAPR); out2($2, $4); }
	| SWAP REG ',' '[' REG ']'  { out2(OP_XFER, OP_SWAPM); out2($2, $5); }
	| SWAP '[' REG ']' ',' REG  { out2(OP_XFER, OP_SWAPM); out2($6, $3); }
	;	

jump	: cond			{ $$ |= OP_COND << 4; }
	;

cntopt	: ',' intval		{ if (newops == 0) yyerror("Invalid operand (use -n)"); $$ = $2; }
	|			{ $$ = 0; }
	;

regopt	: '+' REG		{ if (newops == 0) yyerror("Invalid operand (use -n)"); $$ = $2; }
	;

baseopt	: '+' intval		{ if (newops == 0) yyerror("Invalid operand (use -n)");
				  if($2 > 30) yyerror("Constant out of bounds ");
				  $$ = $2/2;
				}
	|			{ $$ = 0; }
	;

flow	: JMP REG baseopt		{ out2(OP_CODE, OP_JMPR); out2($3, $2); }
	| CALL REG baseopt		{ out2(OP_CODE, OP_CR); out2($3, $2); }
        | CALLF REG baseopt		{ out2(OP_CODE, OP_CRF); out2($3, $2); }
	| JMP REG regopt		{ out2(OP_CODE, OP_JMPI); out2($3, $2); }
	| CALL REG regopt		{ out2(OP_CODE, OP_CI); out2($3, $2); }
        | CALLF REG regopt		{ out2(OP_CODE, OP_CIF); out2($3, $2); }
	| longjmp posint	{
		    int k = ($2 - (pos+2)) >> 1;
		    if ($2 == UNDEF) k = 0;
		    if (k > 2047 || k < -2048) {
		    	if (newops == 0) yyerror("Constant out of bounds (use -n)");
			out2(OP_MOVL,TEMP);
			outb((k & 0xFF));
			out2(OP_MOVH,TEMP);
			outb(((k >> 8) & 0xFF));
			if ($1 == OP_JMP) out2(OP_CODE, OP_JMPR);
			if ($1 == OP_CALL) out2(OP_CODE, OP_CR);
			if ($1 == OP_CALLF) out2(OP_CODE, OP_CRF);
			out2(0, TEMP);
		    } else {
		    	out2($1, k >> 8); outb(k);
		    }
		}
	;

longjmp	: JMP	{ $$ = OP_JMP; }
	| CALL	{ $$ = OP_CALL; }
	| CALLF	{ $$ = OP_CALLF; }
	;

aritop2	:  ADDC	{ $$ = OP_ADDC; }
	|  SUBB	{ $$ = OP_SUBB; }
	|  MUL	{ $$ = OP_MUL; }
	|  DIV	{ $$ = OP_DIV; }
	|  MOD	{ $$ = OP_MOD; }
	;

aritop	: NEG	{ $$ = OP_NEG; }
	| INC 	{ $$ = OP_ADDI; auxop = 1; }
	| DEC 	{ $$ = OP_ADDI; auxop = 0xF; }
	;

bitop2	:  AND	{ $$ = OP_AND; }
	|  OR	{ $$ = OP_OR; }
	|  XOR	{ $$ = OP_XOR; }
	|  TEST	{ $$ = OP_TEST; }
	;

bitop	: NOT	{ $$ = OP_NOT; }
	;

bitopcte: BIT	{ $$ = OP_BIT; }
 	| SET	{ $$ = OP_SETBIT; }
 	| CPL	{ $$ = OP_CPLBIT; }
 	| ROR	{ $$ = OP_ROR; }
 	| ROL	{ $$ = OP_ROL; }
 	| RORC	{ $$ = OP_RORC; }
 	| ROLC	{ $$ = OP_ROLC; }
	;

bitopnop: EI	{ $$ = OP_SETBIT; auxop = OP_RE << 4 | OP_IE_idx; }
 	| EI0	{ $$ = OP_SETBIT; auxop = OP_RE << 4 | OP_IE0_idx; }
 	| EI1	{ $$ = OP_SETBIT; auxop = OP_RE << 4 | OP_IE1_idx; }
 	| EI2	{ $$ = OP_SETBIT; auxop = OP_RE << 4 | OP_IE2_idx; }
 	| EI3	{ $$ = OP_SETBIT; auxop = OP_RE << 4 | OP_IE3_idx; }
 	| SETC	{ $$ = OP_SETBIT; auxop = OP_RE << 4 | OP_C_idx; }
 	| EDMA	{ $$ = OP_SETBIT; auxop = OP_RE << 4 | OP_D_idx; }
 	| DI	{ $$ = OP_CLRBIT; auxop = OP_RE << 4 | OP_IE_idx; }
 	| DI0	{ $$ = OP_CLRBIT; auxop = OP_RE << 4 | OP_IE0_idx; }
 	| DI1	{ $$ = OP_CLRBIT; auxop = OP_RE << 4 | OP_IE1_idx; }
 	| DI2	{ $$ = OP_CLRBIT; auxop = OP_RE << 4 | OP_IE2_idx; }
 	| DI3	{ $$ = OP_CLRBIT; auxop = OP_RE << 4 | OP_IE3_idx; }
 	| CLRC	{ $$ = OP_CLRBIT; auxop = OP_RE << 4 | OP_C_idx; }
  	| DDMA	{ $$ = OP_CLRBIT; auxop = OP_RE << 4 | OP_D_idx; }
 	| CPLC	{ $$ = OP_CPLBIT; auxop = OP_RE << 4 | OP_C_idx; }
	;

longcte : MOVL	{ $$ = OP_MOVL; }
	| MOVH	{ $$ = OP_MOVH; }
	;

cond	: JZ	{ $$ = OP_JZ; }
	| JNZ	{ $$ = OP_JNZ; }
	| JN	{ $$ = OP_JN; }
	| JNN	{ $$ = OP_JNN; }
	| JC	{ $$ = OP_JC; }
	| JNC	{ $$ = OP_JNC; }
	| JP	{ $$ = OP_JP; }
	| JNP	{ $$ = OP_JNP; }
	| JA	{ $$ = OP_JA; }
	| JAE	{ $$ = OP_JNC; }
	| JB	{ $$ = OP_JC; }
	| JBE	{ $$ = OP_JNA; }
	| JV	{ $$ = OP_JV; }
	| JNV	{ $$ = OP_JNV; }        
	| JEQ	{ $$ = OP_JZ; }
	| JNE	{ $$ = OP_JNZ; }
	| JLT	{ $$ = OP_JLT; }
	| JLE	{ $$ = OP_JLE; }
	| JGT	{ $$ = OP_JGT; }
	| JGE	{ $$ = OP_JGE; }
	;

codenop	: RET		{ $$ = OP_RET; auxop = 0; }
	| RETF		{ $$ = OP_RETF; auxop = 0; }
	| RFE		{ $$ = OP_RFE; auxop = 0; }
	| RET intval	{ if (newops == 0) yyerror("Invalid operand (use -n)");
			  if($2 > 510) yyerror("Constant out of bounds ");
			  $$ = OP_RET; auxop = $2/2; }
	| RET REG	{ if (newops == 0) yyerror("Invalid operand (use -n)");
			  $$ = OP_RETN; auxop = $2; }
	;

nl	: NL			;
	| nl NL			;
	;

string	: CHARS			{ $$ = strlen($1); outs($1); }
	| ivalue		{ $$ = 1; outb($1); }
	| string ',' CHARS	{ $$ = $1 + strlen($3); outs($3); }
	| string ',' ivalue	{ $$ = $1 + 1; outb($3); }
	;

intval	: INTEGER
	| CHAR
	;

posint	: IDENT		{ $$ = symtab($1, UNDEF, pos, 0, filename, yylineno); }
       	| '.'		{ $$ = pos; }
	| intval
	;

ivalue	: posint
	| '-' posint	{ $$ = - $2; }
	| '+' posint	{ $$ = $2; }
	| '.' '-' posint	{ $$ = pos - $3; }
	| '.' '+' posint	{ $$ = pos + $3; }
	;
%%
static void outb(unsigned char b)
{
  mem[pos++] = b;
}

static void outs(char *s)
{
  while (*s != 0) outb(*s++);
}

void yyerror(char *s)
{
  fprintf(stderr, "%s: %d: %s\n", filename, yylineno, s);
}
