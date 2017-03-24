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
	bool bval;
}

%token <ival> INT
%token <fval> FLOAT
%token <sval> STRING
%token <sval> ID
%token <sval> CHAR
%token <bval> BOOLEAN
%token TRUE FALSE FOR IF ELSE WHILE RETURN BREAK STRUCT VOID MAIN NUM


%%
program:
		declarations main
		;

declarations:
		declarations functionDeclaration
		/* empty */
		| ";"
		;

functionDeclaration:
		returnType ID '('parameters')' '{'statementList'}'
		;

parameters:
		paramList
		/* empty */
		| ";"
		;

paramList:
		paramList ',' typeSpecifier ID
		| typeSpecifier ID
		;

main:
		NUM MAIN '('mainParameters')' '{'statementList'}' 
		;

mainParameters:
		NUM ID ',' CHAR'['']' ID
		/* empty */
		| ";"
		;

statementList:
		statementList statement
		/* empty */
		| ";"
		;

statement:
		variableDeclaration
		| variableAttribution
		| loopStatement
		| functionCall
		| breakStatement
		| returnStatement
		| structDeclaration
		| conditionalStatement
		| expressionStatement
		;

variableDeclaration:
		typeSpecifier ID';'
		| typeSpecifier variableAttribution';'
		;

variableAttribution:
		ID '=' expression
		;

loopStatement:
		FOR'('variableAttribution';'booleanExpression';'variableAttribution')''{'statementList'}'
		| WHILE'('booleanExpression')''{'statementList'}'
		;

functionCall:
		ID'('args')'':'
		;

args:
		argList
		/* empty */
		| ";"
		;

argList:
		argList',' expression
		| expression

breakStatement:
		BREAK';'
		;

returnStatement:
		RETURN';'
		| RETURN expression';'
		;

structDeclaration:
		STRUCT ID'{'variableDeclarationNoValueList'}'';'
		;

variableDeclarationNoValueList:
		variableDeclarationNoValueList typeSpecifier ID';'
		| typeSpecifier ID ';'
		;

conditionalStatement:
		IF '('booleanExpression')''{'statementList'}'
		| IF '('booleanExpression')''{'statementList'}' ELSE conditionalStatement
		| IF '('booleanExpression')''{'statementList'}' ELSE '{'statementList'}'
		;

expressionStatement:
		expression';'
		| ';'
		;

returnType:
		typeSpecifier
		| VOID
		;

typeSpecifier:
		NUM
		| BOOLEAN
		| CHAR
		| ID

mutable:
		ID
		| mutable'['numExpression']'
		| mutable'.'ID

expression:
		booleanExpression
		| numExpression

booleanExpression:
		booleanExpression boolOp unaryBoolExpression
		| unaryBoolExpression
		;

boolOp:
		'&''&'
		| '|''|'
		;

unaryBoolExpression:
		'!'booleanExpression
		| relExpression
		| mutable
		| '('booleanExpression')'
		| functionCall
		| TRUE
		| FALSE
		;

relExpression:
		numExpression relOp numExpression
		;

relOp:
		'=''='
		| '!''='
		| '>'
		| '>''='
		| '<'
		| '<''='
		;

numExpression:
		numExpression numOp unaryNumExpression
		| unaryNumExpression
		;

numOp:
		'+'
		| '-'
		| '*'
		| '/'
		| '%'
		;

unaryNumExpression:
		unaryNumOp unaryNumExpression
		| mutable
		| '('numExpression')'
		| functionCall
		| NUMLITERAL
		;

unaryNumOp:
		'+'
		| '-'
		;

NUMLITERAL:
		INT
		| FLOAT
		;

/*VVVVVV EXEMPLO! VVVVVVV
expression:
		  expression INT { cout << "INT: " << $2 << endl; }
		  | expression FLOAT { cout << "FLOAT: " << $2 << endl; }
		  | expression STRING { cout << "STRING: " << $2 << endl; }
		  | INT { cout << "INT: " << $1 << endl; }
		  | FLOAT { cout << "FLOAT: " << $1 << endl; }
		  | STRING { cout << "STRING: " << $1 << endl; }
		  ;
*/
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
