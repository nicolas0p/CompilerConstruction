%{
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()

//#include "parser.tab.h"
#include <iostream>
using namespace std;
%}
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

[0-9]+\.[0-9]+  {cout << "FLOATLITERAL";}
[0-9]+          {cout << "INTLITERAL";}
\"[a-zA-Z0-9]+\" {cout << "STRINGLITERAL";}
\'[a-zA-Z]\'	{cout << "CHARLITERAL";}
[a-zA-Z]+		{cout << "ID";}

">="				{cout << "GREATER_EQ";}
"<="				{cout << "LESS_EQ";}
"=="
"!="
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

%%
