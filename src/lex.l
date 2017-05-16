%{
#include <iostream>
#include <fstream>
#include <string>
using namespace std;
#define YY_DECL extern "C" int yylex()

#include "parser.tab.h" //token types

extern ifstream open_file;

void yyerror(const char *str)
{
	cout << "<Line " << yylineno << "> "<< "Error: "<< str << endl;
	//exit(-1);
}

string trim(string to_trim) {
	size_t first = to_trim.find_first_not_of(' ');
	return to_trim.substr(first, to_trim.length());
}

string get_line(ifstream& file, int line_number) {
	int i = 1;
	string line;
	while(getline(file, line)) {
		if(i == line_number){
			return trim(line);
		}
		++i;
	}
	return string("");
}

void print_error(const char *str)
{
	//print the actual line of the file too
	open_file.seekg(0, ios::beg); //resets location to beginning of the file
	string line = get_line(open_file, yylineno);
	cout << "<Line " << yylineno << "> " << line << " : " << str << endl;
}

%}
%option yylineno
%%
[ \t\n]				;
"true"				{yylval.bval = true; return TRUE;}
"false"				{yylval.bval = false; return FALSE;}
"for"				{yylval.charp = strdup(yytext);return FOR;}
"if"				{yylval.charp = strdup(yytext);return IF;}
"else"				{yylval.charp = strdup(yytext);return ELSE;}
"while"				{yylval.charp = strdup(yytext);return WHILE;}
"return"			{yylval.charp = strdup(yytext);return RETURN;}
"break"				{yylval.charp = strdup(yytext);return BREAK;}
"struct"			{yylval.charp = strdup(yytext);return STRUCT;}
"void"				{yylval.charp = strdup(yytext);return VOID;}
"main"				{yylval.charp = strdup(yytext);return MAIN;}
"num"				{yylval.charp = strdup(yytext); return NUM;}
"boolean"			{yylval.charp = strdup(yytext); return BOOLEAN;}
"char"				{yylval.charp = strdup(yytext); return CHAR;}

[0-9]+\.[0-9]+  	{yylval.fval = atof(yytext); return FLOATLITERAL;}
[0-9]+          	{yylval.ival = atoi(yytext); return INTLITERAL;}
\"(\\.|[^\\"])*\" 	{yylval.charp = strdup(yytext); return STRINGLITERAL;}
'(\\.|[^\\'])'		{yylval.charp = strdup(yytext); return CHARLITERAL;}
[a-zA-Z]+			{yylval.charp = strdup(yytext); return ID;}

">="				{return GREATER_EQ;}
"<="				{return LESS_EQ;}
"=="				{return EQUAL;}
"!="				{return NOT_EQUAL;}
";"					{return SEMICOLON;}
","					{return COMMA;}
"."					{return PERIOD;}
"("					{return OP_PARENS;}
")"					{return CL_PARENS;}
"["					{yylval.charp = strdup(yytext); return OP_SQUARE;}
"]"					{yylval.charp = strdup(yytext); return CL_SQUARE;}
"{"					{return OP_CURLY;}
"}"					{return CL_CURLY;}
"="					{return ATTRIBUTION;}
"!"					{return NOT;}
">"					{return GREATER;}
"<"					{return LESS;}
"&&"				{return AND;}
"||"				{return OR;}
"+"					{return PLUS;}
"-"					{return MINUS;}
"*"					{return TIMES;}
"/"					{return DIVIDE;}
"%"					{return MOD;}

%%
