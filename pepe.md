%{

/*     pepe.md: backend code generation for the 'lcc' compiler */

#define ACC 0
#include "c.h"
#define NODEPTR_TYPE Node
#define OP_LABEL(p) ((p)->op)
#define LEFT_CHILD(p) ((p)->kids[0])
#define RIGHT_CHILD(p) ((p)->kids[1])
#define STATE_LABEL(p) ((p)->x.state)
static void address(Symbol, Symbol, long);
static void blkfetch(int, int, int, int);
static void blkloop(int, int, int, int, int, int[]);
static void blkstore(int, int, int, int);
static void defaddress(Symbol);
static void defconst(int, int, Value);
static void defstring(int, char *);
static void defsymbol(Symbol);
static void doarg(Node);
static void emit2(Node);
static void export(Symbol);
static void clobber(Node);
static void function(Symbol, Symbol [], Symbol [], int);
static void global(Symbol);
static void import(Symbol);
static void local(Symbol);
static void progbeg(int, char **);
static void progend(void);
static void segment(int);
static void space(int);
static void target(Node);
extern int ckstack(Node, int);
extern int memop(Node);
extern int sametree(Node, Node);
static int hasargs(Node);
static int smallargs(Node);
static Symbol intregw, intreg[32];
static int cseg;

%}
%start stmt
%term CNSTI1=1045
%term CNSTI2=2069
%term CNSTU2=2070
%term CNSTP2=2071
 
%term ARGB=41
%term ARGI2=2085
%term ARGP2=2087

%term ASGNB=57
%term ASGNI1=1077
%term ASGNI2=2101
%term ASGNU2=2102
%term ASGNP2=2103

%term INDIRB=73
%term INDIRI1=1093
%term INDIRI2=2117
%term INDIRU2=2118
%term INDIRP2=2119

%term CVII1=1157
%term CVII2=2181
%term CVPP2=2199
%term CVUI2=2229
%term CVIU2=2182
%term CVUU2=2230
%term CVUI4=4277

%term NEGI2=2245

%term CALLB=217
%term CALLI2=2261
%term CALLP2=2263
%term CALLV=216
%term RETI2=2293
%term RETP2=2295
%term RETV=248

%term ADDRGP2=2311
%term ADDRFP2=2327
%term ADDRLP2=2343

%term ADDI2=2357
%term ADDP2=2359
%term SUBI2=2373
%term SUBU2=2374
%term SUBP2=2375
%term LSHI2=2389
%term MODI2=2405
%term RSHI2=2421
%term BANDI2=2437
%term BCOMI2=2453
%term BORI2=2469
%term BXORI2=2485
%term DIVI2=2501
%term MULI2=2517

%term EQI2=2533
%term GEI2=2549
%term GTI2=2565
%term LEI2=2581
%term LTI2=2597
%term NEI2=2613
%term EQU2=2534
%term GEU2=2550
%term GTU2=2566
%term LEU2=2582
%term LTU2=2598
%term NEU2=2614

%term JUMPV=584
%term LABELV=600

%term LOADB=233
%term LOADI1=1253
%term LOADI2=2277
%term LOADP2=2279
%term LOADU2=2278

%term VREGP=711
%%
reg:  INDIRI1(VREGP)     "# read register\n"
reg:  INDIRI2(VREGP)     "# read register\n"
reg:  INDIRU2(VREGP)     "# read register\n"
reg:  INDIRP2(VREGP)     "# read register\n"

stmt: ASGNI1(VREGP,reg)  "# write register\n"
stmt: ASGNI2(VREGP,reg)  "# write register\n"
stmt: ASGNU2(VREGP,reg)  "# write register\n"
stmt: ASGNP2(VREGP,reg)  "# write register\n"
stmt: reg  ""

con1: CNSTI1  "%a" range(a, -8, 7)
con1: CNSTI2  "%a" range(a, -8, 7)

con: CNSTI1  "%a"
con: CNSTI2  "%a"
con: CNSTU2  "%a"
con: CNSTP2  "%a"

fp4: ADDRFP2 "# arg" range(a, -16, 14)
fp4: ADDRLP2 "# arg" range(a, -16, 14)
fpN: ADDRFP2 "# arg" 1
fpN: ADDRLP2 "# arg" 1

reg: fp4 "MOV %c, %0\nADD %c, rl\n"
reg: fpN "MOV %c, %0\nADD %c, rl\n" 1
reg: INDIRI2(fp4) "MOV %c, [rl + %0]\n"
reg: INDIRI2(fpN) "MOV %c, %0\nMOV %c, [rl + %c]\n" 1
reg: INDIRU2(fp4) "MOV %c, [rl + %0]\n"
reg: INDIRU2(fpN) "MOV %c, %0\nMOV %c, [rl + %c]\n" 1
stmt: ASGNI2(fp4,reg)  "MOV [rl + %0],%1\n"
stmt: ASGNI2(fpN,reg)  "MOV r0, %0\nMOV [rl + r0],%1\n" 1
stmt: ASGNI2(fp4,reg)  "MOV [rl + %0],%1\n"
stmt: ASGNI2(fpN,reg)  "MOV r0, %0\nMOV [rl + r0],%1\n" 1

reg: INDIRI1(fpN) "MOV %c, %0\nADD %c, rl\nMOVB %c, [%c]\n" 1
stmt: ASGNI1(fpN,reg)  "MOV r0, %0\nADD %c, rl\nMOVB [r0],%1\n" 1

reg: INDIRI2(ADDRGP2) "MOV r0, %a\nMOV %c, [r0]\n"
stmt: ASGNI2(ADDRGP2,reg)  "MOV r0, %0\nMOV [r0],%0\n" 1

addr: reg "%0"
addr: ADDI2(reg,rc1)  "%0 + %1"
addr: ADDP2(reg,rc1)  "%0 + %1"

mem: INDIRI1(addr)  "[%0]"
mem: INDIRI2(addr)  "[%0]"
mem: INDIRU2(addr)  "[%0]"
mem: INDIRP2(addr)  "[%0]"

rc:   reg  "%0"
rc:   con  "%0"
rc1:  reg  "%0"
rc1:  con1 "%0"

reg: rc		"MOV %c,%0\n"  1
reg: mem	"MOV %c,%0\n"  1
reg: ADDRGP2	"MOV %c,%a\n"
reg: LOADI1(reg)  "# move\n"  1
reg: LOADI2(reg)  "# move\n"  1
reg: LOADU2(reg)  "# move\n"  1
reg: LOADI2(reg)  "# move\n"  move(a)
reg: LOADP2(reg)  "# move\n"  move(a)

reg: ADDI2(reg,rc1)	"?MOV %c,%0\nADD %c,%1\n"  1
reg: ADDP2(reg,rc1)	"?MOV %c,%0\nADD %c,%1\n"  1
reg: SUBI2(reg,rc1)	"?MOV %c,%0\nSUB %c,%1\n"  1
reg: SUBP2(reg,rc1)	"?MOV %c,%0\nSUB %c,%1\n"  1
reg: SUBU2(reg,rc1)	"?MOV %c,%0\nSUB %c,%1\n"  1

reg: BANDI2(reg,reg)	"?MOV %c,%0\nAND %c,%1\n"  1
reg: BORI2(reg,reg)	"?MOV %c,%0\nOR %c,%1\n"   1
reg: BXORI2(reg,reg)	"?MOV %c,%0\nXOR %c,%1\n"  1
reg: BCOMI2(reg)	"?MOV %c,%0\nNOT %c\n"  2

reg: NEGI2(reg)		"?MOV %c,%0\nNEG %c\n"  2
reg: LSHI2(reg,con5)	"?MOV %c,%0\nSHLA %c,%1\n"  2
reg: RSHI2(reg,con5)	"?MOV %c,%0\nSHRA %c,%1\n"  2

con5: CNSTI2  "%a"  range(a, 0, 16)

reg: MULI2(reg,reg)  "?MOV %c,%0\nMUL %c,%1\n"
reg: DIVI2(reg,reg)  "?MOV %c,%0\nDIV %c,%1\n"
reg: MODI2(reg,reg)  "?MOV %c,%0\nMOD %c,%1\n"
reg: CVII2(INDIRI1(addr))  "MOVBS %c, %0\n"  3
reg: CVII2(INDIRI2(addr))  "MOV %c, %0\n"  3
reg: CVII2(reg)  "# extend\n"  3
reg: CVIU2(reg)  "# extend\n"  3
reg: CVUI2(reg)  "# extend\n"  3
reg: CVUI4(reg)  "# extend\n"  3
reg: CVUU2(reg)  "# extend\n"  3

reg: CVII1(reg)  "# truncate\n"  1
stmt: ASGNI1(addr,reg)  "MOVB [%0],%1\n"   1
stmt: ASGNI2(addr,reg)  "MOV [%0],%1\n"   1
stmt: ASGNU2(addr,reg)  "MOV [%0],%1\n"  1
stmt: ASGNP2(addr,reg)  "MOV [%0],%1\n"  1
stmt: ARGI2(reg)  "PUSH %0\n"  1
stmt: ARGP2(reg)  "PUSH %0\n"  1

addrj: ADDRGP2  "%a"
addrj: reg      "%0"  2
addrj: mem      "%0"  2

stmt:  JUMPV(addrj)  "JMP %0\n"  3
stmt:  LABELV        "%a:\n"

stmt: EQI2(reg,rc1)  "CMP %0,%1\nJEQ %a\n" 5
stmt: GEI2(reg,rc1)  "CMP %0,%1\nJGE %a\n" 5
stmt: GTI2(reg,rc1)  "CMP %0,%1\nJGT %a\n" 5
stmt: LEI2(reg,rc1)  "CMP %0,%1\nJLE %a\n" 5
stmt: LTI2(reg,rc1)  "CMP %0,%1\nJLT %a\n" 5
stmt: NEI2(reg,rc1)  "CMP %0,%1\nJNE %a\n" 5
stmt: EQU2(reg,rc1)  "CMP %0,%1\nJEQ %a\n" 5
stmt: NEU2(reg,rc1)  "CMP %0,%1\nJNE %a\n" 5
stmt: GEU2(reg,rc1)  "CMP %0,%1\nJNC %a\n" 5
stmt: GTU2(reg,rc1)  "CMP %0,%1\nJA  %a\n" 5
stmt: LEU2(reg,rc1)  "CMP %0,%1\nJBE %a\n" 5
stmt: LTU2(reg,rc1)  "CMP %0,%1\nJC  %a\n" 5

reg:  CALLI2(addrj)  "CALL %0\nMOV r10,%a\nADD sp,r10\n"	hasargs(a)
reg:  CALLI2(addrj)  "CALL %0\nADD sp,%a\n"	smallargs(a)
reg:  CALLI2(addrj)  "CALL %0\n"			1
reg:  CALLP2(addrj)  "CALL %0\nMOV r10,%a\nADD sp,r10\n"	hasargs(a)
reg:  CALLP2(addrj)  "CALL %0\nADD sp,%a\n"	smallargs(a)
reg:  CALLP2(addrj)  "CALL %0\n"			1
stmt: CALLV(addrj)   "CALL %0\nMOV r10,%s\nADD sp,r10\n"	hasargs(a)
stmt: CALLV(addrj)   "CALL %0\nADD sp,%a\n"	smallargs(a)
stmt: CALLV(addrj)   "CALL %0\n"			1

stmt: RETI2(reg)  "# ret\n"
stmt: RETP2(reg)  "# ret\n"
%%
static void progbeg(int argc, char *argv[]) {
        int i;

        {
                union {
                        char c;
                        int i;
                } u;
                u.i = 0;
                u.c = 1;
                swap = ((int)(u.i == 1)) != IR->little_endian;
        }
        parseflags(argc, argv);
        for (i = 0; i < 11; i++)
                intreg[i]  = mkreg("r%d", i, 1, IREG);
        intregw = mkwildcard(intreg);

        tmask[IREG] = 0x000007fe;
        vmask[IREG] = 0;
        cseg = 0;
	print("; PEPE gerado por 'lcc' (IST: prs 2005, 2009)\n");
	print("; 'rl' serve como frame-pointer e 'r0' como acumulador\n");
	print("; os registos 'r1' a 'r10' sao preservados nas chamadas\n");
}
static Symbol rmap(int opk) {
        switch (optype(opk)) {
        case B: case P: case I: case U:
                return intregw;
        default:
                return 0;
        }
}
static void segment(int n) {
        if (n == cseg)
                return;
        cseg = n;
        if (cseg == CODE)
                print("; TEXT\n");
        else if (cseg == DATA)
                print("; DATA\n");
        else if (cseg == LIT)
                print("; RODATA\n");
        else if (cseg == BSS)
                print("; BSS\n");
}
static void progend(void) {
}

/* CALL e RET no 'r0'(ACC) */
static void target(Node p) {
        assert(p);
        switch (specific(p->op)) {
        case CALL+I: case CALL+U: case CALL+P: case CALL+V:
                setreg(p, intreg[ACC]);
                break;
        case RET+I: case RET+U: case RET+P:
                rtarget(p, 0, intreg[ACC]);
                break;
        }
}

/* spill the clobbered registers before the instruction */
static void clobber(Node p) {
        static int nstack = 0;

        assert(p);
        nstack = ckstack(p, nstack);
        switch (specific(p->op)) {
        case ASGN+B: case ARG+B:
                spill(ACC, IREG, p);
                break;
        case CALL+I: case CALL+U: case CALL+P: case CALL+V:
                spill(0, IREG, p); /* all regs: 0x7fe */
                break;
        }
}
#define preg(f) ((f)[getregnum(p->x.kids[0])]->x.name)
static void emit2(Node p) {
        int op = specific(p->op);
	if (generic(op) == ADDRF) print("%d", p->syms[0]->x.offset);
	if (generic(op) == ADDRL) print("%d", p->syms[0]->x.offset);
        if (generic(op) == CVI)
                print("MOVBS %s,%s\n", p->syms[RX]->x.name, preg(intreg));
        else if (generic(op) == CVU)
                print("MOVBS %s,%s\n", p->syms[RX]->x.name, preg(intreg));
        else if (generic(op) == LOAD) {
                char *dst = intreg[getregnum(p)]->x.name;
                char *src = preg(intreg);
                assert(opsize(p->op) <= opsize(p->x.kids[0]->op));
                if (dst != src)
                        print("MOV %s,%s\n", dst, src);
        }
}
static int hasargs(Node p) {
        assert(p);
        assert(generic(p->op) == CALL);
        assert(p->syms[0]);
        if (p->syms[0]->u.c.v.i >= 8) 
                return 0;
        return LBURG_MAX;
}
static int smallargs(Node p) {
        assert(p);
        assert(generic(p->op) == CALL);
        assert(p->syms[0]);
        if (p->syms[0]->u.c.v.i > 0 && p->syms[0]->u.c.v.i < 8) 
                return 0;
        return LBURG_MAX;
}
static void doarg(Node p) {
        assert(p && p->syms[0]);
        mkactual(2, p->syms[0]->u.c.v.i);
}
static void blkfetch(int k, int off, int reg, int tmp) {}
static void blkstore(int k, int off, int reg, int tmp) {}
static void blkloop(int dreg, int doff, int sreg, int soff,
        int size, int tmps[]) {}
static void local(Symbol p) {
        if (isfloat(p->type))
                p->sclass = AUTO;
        if (askregvar(p, (*IR->x.rmap)(ttob(p->type))) == 0)
                mkauto(p);
}
static void function(Symbol f, Symbol caller[], Symbol callee[], int ncalls) {
	int i;
	int dont_opt = 0;

	usedmask[0] = usedmask[1] = 0;
	freemask[0] = freemask[1] = ~(unsigned)0;
	offset = 2 + 2;
	for (i = 0; callee[i]; i++) {
		Symbol p = callee[i];
		Symbol q = caller[i];
		assert(q);
		p->x.offset = q->x.offset = offset;
		p->x.name = q->x.name = stringf("P_%s", q->name);
		p->sclass = q->sclass = AUTO;
		offset += roundup(q->type->size, 2);
		if (isstruct(p->type))
			dont_opt = 1;
	}
	assert(caller[i] == 0);
	dont_opt |= variadic(f->type)
		|| (i > 0 && strcmp(callee[i-1]->name, "va_alist") == 0)
		|| isstruct(freturn(f->type));
	offset = maxoffset = 0;
	gencode(caller, callee);

	print("%s: ; ncalls=%d\n", f->x.name, ncalls);
	offset = 2 + 2;
        for (i = 1; i <= 10; i++)
                if (usedmask[IREG]&(1<<i)) {
                        print("PUSH r%d\n", i);
                        offset += 2;
                }
	print("PUSH rl\n");
	print("MOV rl, sp\n");

	for (i = 0; callee[i]; i++) {
		Symbol p = callee[i];
		Symbol q = caller[i];
		assert(q);
		p->x.offset = q->x.offset = offset;
		print("; %s EQU %d\n", p->x.name, p->x.offset);
		offset += roundup(q->type->size, 2);
	}
	framesize = roundup(maxoffset, 2);
	if (framesize > 0) {
		if (framesize > 7)
			print("MOV r0, %d\nSUB sp, r0\n", framesize);
		else
			print("SUB sp, %d\n", framesize);
	}
	emitcode();
	print("MOV sp, rl\n");
	print("POP rl\n");
        for (i = 10; i >= 1; i--)
                if (usedmask[IREG]&(1<<i))
                        print("POP r%d\n", i);
	print("RET\n");
}
static void defsymbol(Symbol p) {
        if (p->scope >= LOCAL && p->sclass == STATIC)
		  p->x.name = stringf("L%d", genlabel(1));
        else if (p->generated)
		  p->x.name = stringf("L%s", p->name);
        else if (p->scope == GLOBAL || p->sclass == EXTERN)
		  p->x.name = stringf("%s", p->name);
        else if (p->scope == CONSTANTS
		&& (isint(p->type) || isptr(p->type))
		&& p->name[0] == '0' && p->name[1] == 'x')
		  p->x.name = stringf("%sh", &p->name[2]);
        else
                p->x.name = p->name;
}
static void address(Symbol q, Symbol p, long n) {
        if (p->scope == GLOBAL
        || p->sclass == STATIC || p->sclass == EXTERN)
                q->x.name = stringf("%s%s%D",
                        p->x.name, n >= 0 ? "+" : "", n);
        else {
                assert(n <= INT_MAX && n >= INT_MIN);
                q->x.offset = p->x.offset + n;
                q->x.name = stringd(q->x.offset);
        }
}
static void defconst(int suffix, int size, Value v) {
        if (suffix == I && size == 1)
                print("STRING %d\n",   v.u);
        else if (suffix == I)
                print("WORD %d\n",   v.i);
        else if (suffix == U && size == 1)
                print("STRING %xh\n", v.u);
        else if (suffix == U || suffix == P)
                print("WORD %xh\n", v.u);
        else assert(0);
}
static void defaddress(Symbol p) {
        print("WORD %s\n", p->x.name);
}
static void defstring(int n, char *str) {
        char *s;
        int inquote = 1;

        print("STRING \"");

        for (s = str; s < str + n; s++)
        {
                if ((*s & 0x7F) == *s && *s >= ' ' && *s != '\'') {
                        if (!inquote){
                                print(", \"");
                                inquote = 1;
                        }
                        print("%c",*s);
                }
                else
                {
                        if (inquote){
                                 print("\", ");
                                 inquote = 0;
                        }
                        else
                                 print(", ");
                        print("%d",*s);
                }
        }
        if (inquote) 
                 print("\"");
        print("\n");
}
static void export(Symbol p) {
        print("; global %s\n", p->x.name);
}
static void import(Symbol p) {
        if (p->ref > 0) {
                print("; extern %s\n", p->x.name);
        }
}
static void global(Symbol p) {
	print("%s:\n", p->x.name);
	if (p->u.seg == BSS)
		print("TABLE %d\n", p->type->size);
}
static void space(int n) {
        if (cseg != BSS)
                print("TABLE %d\n", n);
}
Interface pepeIR = {
        1, 1, 0,  /* char */
        2, 2, 0,  /* short */
        2, 2, 0,  /* int */
        4, 4, 0,  /* long */
        4, 4, 0,  /* long long */
        4, 4, 1,  /* float */
        8, 4, 1,  /* double */
        8, 4, 1,  /* long double */
        2, 2, 0,  /* T * */
        0, 2, 0,  /* struct; so that ARGB keeps stack aligned */
        1,        /* little_endian */
        0,        /* mulops_calls */
        0,        /* wants_callb */
        1,        /* wants_argb */
        0,        /* left_to_right */
        0,        /* wants_dag */
        0,        /* unsigned_char */
        address,
        blockbeg,
        blockend,
        defaddress,
        defconst,
        defstring,
        defsymbol,
        emit,
        export,
        function,
        gen,
        global,
        import,
        local,
        progbeg,
        progend,
        segment,
        space,
        0, 0, 0, 0, 0, 0, 0,
        {1, rmap,
            blkfetch, blkstore, blkloop,
            _label,
            _rule,
            _nts,
            _kids,
            _string,
            _templates,
            _isinstruction,
            _ntname,
            emit2,
            doarg,
            target,
            clobber,
}
};
static char rcsid[] = "$Id: pepe.md,v 1.01 2009/11/04 17:34:23 prs Exp $";
