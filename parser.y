%{
#include <stdio.h>
#include <string.h>

void yyerror(const char *str)
{
    fprintf(stderr, "error: %s\n", str);
}

int yywrap()
{
    return 1;
}

int main()
{
    yyparse();
}
%}

%token INT FLOAT AND COMP

%left AND
%left COMP

%%
expression: INT | FLOAT
