.SUFFIXES: .asm .mem
LOADLIBS=
CC=gcc
CFLAGS=-g -DYYDEBUG $(EXTRA)
EXTRA=
#EXTRA=-Wall -ansi -pedantic
#CFLAGS=-O2 -I$(LIB)
LEX=flex
LFLAGS=-l
YACC=byacc
YFLAGS=-dv
DESTDIR=$$HOME/bin

ID=pepe
VER=1f4
BID=$(ID)-$(VER)
BIN=$(ID)
COPYWRITE=$(BID) (C)prs IST,2012 # use with ident

all: $(BIN)

.asm.mem:
	pepe $< -o $@

BASE= y.tab.o lex.yy.o code.o ver.o
$(ID): $(BASE) main.o interp.o
	echo "char *build = \"(#)$(COPYWRITE) `uname -n`@`date "+%Y%m%d%H%M%S"`\";" > build.c
	$(LINK.c) -o $@ $^ build.c $(LOADLIBS)

ver.c: Makefile
	echo "char *version = \"\$$"Id": $(COPYWRITE) \$$\";" > $@
	echo "char *lblver = \"$(ID)_$(VER)\";" >> $@

lex.yy.c: token.l y.tab.c
	$(LEX) $(LFLAGS) $<

y.tab.c: gram.y
	$(YACC) $(YFLAGS) $<

install:
	strip $(ID)
	cp $(ID) $(DESTDIR)

clean:
	rm -f *.o core a.out $(BIN) y.tab.* lex.yy.* y.output *.mem ver.c
	# for i in *.cpt; do rm -f `basename $$i .cpt`; done

backup: clean
	PWD=`pwd`; CWD=`basename $$PWD`; cd ..; tar cf - $$CWD | gzip -9 > $@/$(BID).tgz

.PHONY: all clean backup install
