%{
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()

#include "parser.tab.h" //token types

%}
%%
[ \t\n]			;

"true"			{yylval.bval = true; return TRUE;}
"false"			{yylval.bval = false; return FALSE;}
"for"			{return FOR;}
"if"			{return IF;}
"else"			{return ELSE;}
"while"			{return WHILE;}
"return"		{return RETURN;}
"break"			{return BREAK;}
"struct"		{return STRUCT;}
"void"			{return VOID;}
"main"			{return MAIN;}

[0-9]+\.[0-9]+  {yylval.fval = atof(yytext); return FLOAT;}
[0-9]+          {yylval.ival = atoi(yytext); return INT;}
\"[a-zA-Z0-9]+\" {yylval.sval = strdup(yytext); return STRING;}
\'[a-zA-Z]\'	{yylval.sval = strdup(yytext); return CHAR;}
[a-zA-Z]+		{yylval.sval = strdup(yytext); return ID;}

";"				{return SEMICOLON;}
","				{return COMMA;}
"."				{return PERIOD;}
"("				{return OP_PARENS;}
")"				{return CL_PARENS;}
"["				{return OP_SQUARE;}
"]"				{return CL_SQUARE;}
"{"				{return OP_CURLY;}
"}"				{return CL_CURLY;}
"="				{return EQUAL;}
"!"				{return NOT;}
">"				{return GREATER;}
"<"				{return LESS;}
"&"				{return AND;}
"|"				{return OR;}
"+"				{return PLUS;}
"-"				{return MINUS;}
"*"				{return TIMES;}
"/"				{return DIVIDED;}
"%"				{return MOD;}

%%
