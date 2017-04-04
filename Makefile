CC=g++
CFLAGS=-Wall -g -lfl
DEBUGFLAGS= -DYYDEBUG=1
EXEC=parser

FLEX= flex
BISON= bison -d -v

make: lex.l parser.y
	$(FLEX) lex.l
	$(BISON) parser.y
	$(CC) -o $(EXEC) lex.yy.c parser.tab.c $(CFLAGS)

debug: lex.l parser.y
	$(FLEX) lex.l
	$(BISON) parser.y
	$(CC) -o $(EXEC) lex.yy.c parser.tab.c $(CFLAGS) $(DEBUGFLAGS)

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h parser.output $(EXEC)
