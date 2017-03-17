CC=g++
CFLAGS=-Wall -g
EXEC=parser

make: $(EXEC)
	flex lex.l
	bison -d parser.y
	$(CC) $(CFLAGS) -o $(EXEC) lex.yy.c parse.tab.c

clean:
	rm $(EXEC)
