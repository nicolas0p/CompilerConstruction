%{
#include <iostream>
#include <stdio.h>
#include <stdarg.h>
using namespace std;
#define YY_DECL extern "C" int yylex()

//#include "parser.tab.h"
#include <iostream>

extern int yylineno;

using namespace std;
void yyerror(const char* s, ...);
%}

%option noyywrap nodefault yylineno

%%
[ \t]			{cout << " ";}
[\n]			{cout << endl;}
"true"			{cout << "TRUE";}
"false"			{cout << "FALSE";}
"for"			{cout << "FOR";}
"if"			{cout << "IF";}
"else"			{cout << "ELSE";}
"while"			{cout << "WHILE";}
"return"		{cout << "RETURN";}
"break"			{cout << "BREAK";}
"struct"		{cout << "STRUCT";}
"void"			{cout << "VOID";}
"main"			{cout << "MAIN";}
"num"			{cout << "NUM";}
"char"			{cout << "CHAR";}
"boolean"		{cout << "BOOLEAN";}

[0-9]+\.[0-9]+  	{cout << "FLOATLITERAL(" << yytext << ")";}
[0-9]+          	{cout << "INTLITERAL(" << yytext << ")";}
\"(\\.|[^\\"])*\" 	{cout << "STRINGLITERAL(" << yytext << ")";}
'(\\.|[^\\'])'		{cout << "CHARLITERAL(" << yytext << ")";}
[a-zA-Z]+		{cout << "ID";}

">="				{cout << "GREATER_EQ";}
"<="				{cout << "LESS_EQ";}
"=="				{cout << "EQUAL";}
"!="				{cout << "NOT_EQUAL";}
";"				{cout << "SEMICOLON";}
","				{cout << "COMMA";}
"."				{cout << "PERIOD";}
"("				{cout << "OP_PARENS";}
")"				{cout << "CL_PARENS";}
"["				{cout << "OP_SQUARE";}
"]"				{cout << "CL_SQUARE";}
"{"				{cout << "OP_CURLY";}
"}"				{cout << "CL_CURLY";}
"="				{cout << "EQUAL";}
"!"				{cout << "NOT";}
">"				{cout << "GREATER";}
"<"				{cout << "LESS";}
"&&"				{cout << "AND";}
"||"				{cout << "OR";}
"+"				{cout << "PLUS";}
"-"				{cout << "MINUS";}
"*"				{cout << "TIMES";}
"/"				{cout << "DIVIDED";}
"%"				{cout << "MOD";}

.				{yyerror("Unknown token! %c\n", *yytext);}
%%

void yyerror(const char* s, ...) {
	va_list ap;
	va_start(ap, s);
	fprintf(stderr, "Line %d: error ", yylineno);
	vfprintf(stderr, s, ap);
}

int main(int argc, char** argv) {
	// open a file handle to a particular file:
	if (argc < 2){
		cout << "No file specified. Entering interactive mode:"<< endl;
		yylex();
	}
	else {
		FILE *myfile = fopen(argv[1], "r");
		// make sure it is valid:
		if (!myfile) {
			cout << "I can't open the file!" << endl;
			return -1;
		}
		// set flex to read from it instead of defaulting to STDIN:
		yyin = myfile;
		// parse through the input until there is no more:
		do {
			yylex();
		} while (!feof(yyin));
	}
}
