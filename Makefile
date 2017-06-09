CC=g++
CFLAGS=-Wall -std=c++11 -lfl
DEBUGFLAGS=-g -DYYDEBUG=1
EXEC=parser

FLEX= flex
BISON= bison -d -v

SOURCE_DIR=src
HEADERS_DIR = include

SOURCE_FILES=$(wildcard $(SOURCE_DIR)/*.ccp)
SCANNER_FILE=$(SOURCE_DIR)/lex.l
PARSER_FILE=$(SOURCE_DIR)/parser.y

make: $(SCANNER_FILE) $(PARSER_FILE) $(SOURCE_FILES)
	$(FLEX) $(SCANNER_FILE)
	$(BISON) $(PARSER_FILE)
	$(CC) -o $(EXEC) lex.yy.c parser.tab.c $(SOURCE_DIR)/*.cpp $(CFLAGS) -I$(HEADERS_DIR)

debug: $(SCANNER_FILE) $(PARSER_FILE) $(SOURCE_FILES)
	$(FLEX) $(SCANNER_FILE)
	$(BISON) $(PARSER_FILE)
	$(CC) -Og -o $(EXEC) lex.yy.c parser.tab.c $(SOURCE_DIR)/*.cpp $(CFLAGS) $(DEBUGFLAGS) -I$(HEADERS_DIR)

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h parser.output $(EXEC) include/*.h.gch
