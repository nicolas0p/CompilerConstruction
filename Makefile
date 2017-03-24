CC=g++
CFLAGS=-Wall -g -lfl
EXEC=final

make: lex.l parser.y
	flex lex.l
	bison -d parser.y -v
	$(CC) -o $(EXEC) lex.yy.c parser.tab.c $(CFLAGS)

clean:
	rm lex.yy.c parser.tab.c parser.tab.h $(EXEC)
