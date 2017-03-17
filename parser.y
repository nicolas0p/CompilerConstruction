%{
#include <stdio.h>
#include <string.h>
#include <iostream>
using namespace std;

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *str)
{
	cout << "EEK, parse error! Message: " << str << endl;
	exit(-1);
}

int yywrap()
{
    return 1;
}

%}

%union {
	int ival;
	float fval;
	char *sval;
}

%token <ival> INT
%token <fval> FLOAT
%token <sval> STRING

%%
expression:
		  expression INT { cout << "INT: " << $2 << endl; }
		  | expression FLOAT { cout << "FLOAT: " << $2 << endl; }
		  | expression STRING { cout << "STRING: " << $2 << endl; }
		  | INT { cout << "INT: " << $1 << endl; }
		  | FLOAT { cout << "FLOAT: " << $1 << endl; }
		  | STRING { cout << "STRING: " << $1 << endl; }
		  ;
%%

int main(int, char**) {
	// open a file handle to a particular file:
	FILE *myfile = fopen("teste.cy", "r");
	// make sure it is valid:
	if (!myfile) {
		cout << "I can't open the file!" << endl;
		return -1;
	}
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));
}
