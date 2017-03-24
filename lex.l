%{
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()

//#include "parser.tab.h" //token types

%}
%%
[ \t\n]			;
[0-9]+\.[0-9]+    {yylval.fval = atof(yytext); return FLOAT;}
[0-9]+            {yylval.ival = atoi(yytext); return INT;}
\"[a-zA-Z0-9]+\"  {yylval.sval = strdup(yytext); return STRING;}
\'[a-zA-Z]\'	  {yylval.sval = strdup(yytext); return CHAR;}
[a-zA-Z]+	  {yylval.sval = strdup(yytext); return ID;}
%%
