#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "pepe.h"

extern int filenum; /* the sequence number of the file being processed */

char *types[] = { "code", "word", "table", "string", "equ", 0 };

/* symtab("symbol", 0xDEF1, ip) : defines a symbol at a given address
 * symtab("symbol", 0x0000, ip) : return the address of the symbol or
 *			       if does not exist insert an undefined symbol
 * flags is in/out: defines type of address patching (rel/abs, 16b/12b/8b)
 */
int symtab(char *name, int addr, int ip, int type, char *file, int line)
{
  Label *scout;
  Undef *u;
  
  for (scout = symbtab; scout != 0; scout = scout->next)
    if ((scout->old == 0 || scout->old == filenum) &&
        strcmp(scout->name, name) == 0) { /* the label exists */
      if (scout->addr == addr) addr = UNDEF;
      if (addr != UNDEF && scout->addr != UNDEF) {
	char buf[BUFSIZ];
	sprintf(buf, "%s: label redefined.", name);
	yyerror(buf);
	exit(2);
      }
      if (scout->addr != UNDEF) return scout->addr;
      /* scout->addr == 0 */
      if (addr != UNDEF) scout->addr = addr;
      break;
    }
  if (scout == 0) {
    scout = (Label*)malloc(sizeof(Label)+strlen(name));
    if (scout == 0) { yyerror("No memory."); exit(2); }
    strcpy(scout->name, name);
    scout->addr = UNDEF;
    scout->type = type;
    scout->old = name[0] == '.' ? filenum : 0;
    scout->undef = 0;
    scout->next = symbtab;
    symbtab = scout;
  }
  if (addr != UNDEF) return scout->addr = addr;
  if ((u = (Undef*)malloc(sizeof(Undef))) == 0) {
    yyerror("No memory.");
    exit(2);
  }
  u->next = scout->undef;
  u->line = line;
  u->file = file;
  scout->undef = u;
  u->addr = ip;
  return UNDEF;
}

/* fixup a relocation: [addr] = val */
void fixup(int addr, int val)
{
  int op1 = OP_CODE_1(mem[addr]), op2 = OP_CODE_2(mem[addr]);

  if (op1 == OP_JMP || op1 == OP_CALL || op1 == OP_CALLF) {
    int k = (val - (addr+2)) >> 1;
    if (k > 2047 || k < -2048) yynerrs++, yyerror("Constant out of bounds ");
    mem[addr] = (mem[addr] & 0xF0) | ((k >> 8) & 0xF); mem[addr+1] = k & 0xFF;
    return;
  }
  if (op1 == OP_COND) {
    int k = (val  - (addr+2)) >> 1;
    if(k > 127 || k < -128) yynerrs++, yyerror("Constant out of bounds ");
    mem[addr+1] = k;
    return;
  }
  if (op1 == OP_MOVL && OP_CODE_1(mem[addr+2]) == OP_MOVH) {
    mem[addr+1] = val & 0xFF;
    mem[addr+3] = (val >> 8) & 0xFF;
    return;
  }
  if (op1 == OP_MOVL || op1 == OP_MOVH || (op1 == OP_CODE && op2 == OP_SWE)) {
    if (val > 0xFF) yynerrs++, yyerror("Constant out of bounds ");
    mem[addr+1] = val & 0xFF;
    return;
  }
  if (op1 == OP_ARITOP && (op2 == OP_SHRA || op2 == OP_SHLA || op2 == OP_ADD ||
			   op2 == OP_SUB || op2 == OP_CMP)) {
    if (val > 7 || val < -8) yynerrs++, yyerror("Constant out of bounds ");
    mem[addr+1] = (mem[addr+1] & 0xF0) | (val & 0xF);
    return;
  }
  if (op1 == OP_ARITOP && op2 >= OP_SETBIT) {
    if (val > 0xF) yynerrs++, yyerror("Constant out of bounds ");
    mem[addr+1] = (mem[addr+1] & 0xF0) | (val & 0xF);
    return;
  }
}

int symrep(char *label, int type)
{
  Label *scout;

  for (scout = symbtab; scout != 0; scout = scout->next)
    if (strcmp(scout->name, label) == 0) {
      scout->type = type;
      return 1;
    }
  return 0;
}

int symfind(char *label, int *type)
{
  Label *scout;

  for (scout = symbtab; scout != 0; scout = scout->next)
    if (strcmp(scout->name, label) == 0) {
      if (type != 0) *type = scout->type;
      return scout->addr;
    }
  return -1;
}

int relocate(void)
{
  Label *scout;
  Undef *u;
  int err = 0;
  
  for (scout = symbtab; scout != 0; scout = scout->next)
    if (scout->addr == UNDEF)
      err++;
    else {
      for (u = scout->undef; u != 0; u = u->next) {
        yylineno = u->line;
	filename = u->file;
        fixup(u->addr, scout->addr);
      }
    }
  return err;
}

/* is there a symbol at this address?
 * -1 NO
 * >0 symbol type
 */
int symbaddr(int addr, char **label)
{
  Label *scout;
  for (scout = symbtab; scout != 0; scout = scout->next)
    if (scout->addr == addr) {
      if (label != 0) *label = scout->name;
      return scout->type;
    }
  return -1;
}

void symbols(void)
{
  Label *scout;
  Undef *u;
  int cnt = 0;
  
  for (scout = symbtab; scout != 0; scout = scout->next, cnt++)
    if (scout->addr == UNDEF)
      printf("%s undefined (%s).\n", scout->name, types[scout->type]);
    else {
      printf("%s = %d%s (%s)", scout->name, scout->addr,
      				scout->undef ? ":" : "", types[scout->type]);
      for (u = scout->undef; u != 0; u = u->next)
        printf(" %d", u->addr);
      printf(".\n");
    }
  printf("symbol table: %d symbols\n", cnt);
}
