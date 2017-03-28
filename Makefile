CC=g++
CFLAGS=-Wall -g -lfl
EXEC=final

make: lex.l
	flex lex.l
	$(CC) -o $(EXEC) lex.yy.c $(CFLAGS)

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h parser.output $(EXEC)
