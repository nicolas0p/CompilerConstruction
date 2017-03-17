%{
#include <iostream>
#include <stdio.h>
using namespace std;
#define YY_DECL extern "C" int yylex()
%}
%%

%token //tokens go here, e.g. ID INT FLOAT

[ \t\n]		    ; //ignore spaces, tabs and new lines
[0-9]+\.[0-9]+	{cout << "FLOAT";}
[0-9]+          {cout << "INT";}
%%
