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
	//exit(-1);
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

%token <ival> INTLITERAL
%token <fval> FLOATLITERAL
%token <sval> STRINGLITERAL
%token <sval> ID
%token <sval> CHARLITERAL
%token <bval> BOOLEANLITERAL
%token NUM BOOLEAN CHAR
%token TRUE FALSE FOR IF ELSE WHILE RETURN BREAK STRUCT VOID MAIN
%token SEMICOLON COMMA PERIOD
%token OP_PARENS CL_PARENS OP_SQUARE CL_SQUARE OP_CURLY CL_CURLY
%token EQUAL NOT_EQUAL NOT GREATER LESS AND OR GREATER_EQ LESS_EQ
%token ATTRIBUTION
%token PLUS MINUS TIMES DIVIDE MOD

%left PLUS MINUS
%left TIMES DIVIDE MOD

%%
program:
		declarations main
		;

declarations:
		declarations functionDeclaration
		/* empty */
		|
		;

functionDeclaration:
		returnType ID OP_PARENS parameters CL_PARENS OP_CURLY statementList CL_CURLY
		;

parameters:
		paramList
		/* empty */
		|
		;

paramList:
		paramList COMMA typeSpecifier ID
		| typeSpecifier ID
		;

main:
		NUM MAIN OP_PARENS mainParameters CL_PARENS OP_CURLY statementList CL_CURLY
		;

mainParameters:
		NUM ID COMMA CHAR OP_SQUARE CL_SQUARE ID
		/* empty */
		|
		;

statementList:
		statementList statement
		/* empty */
		|
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
		typeSpecifier ID variableDeclaration1
		;

/*created to remove ambiguity*/
variableDeclaration1:
		SEMICOLON
		| ATTRIBUTION expression SEMICOLON
		;

variableAttribution:
		ID ATTRIBUTION expression
		;

loopStatement:
		FOR OP_PARENS variableAttribution SEMICOLON booleanExpression SEMICOLON variableAttribution CL_PARENS OP_CURLY statementList CL_CURLY
		| WHILE OP_PARENS booleanExpression CL_PARENS OP_CURLY statementList CL_CURLY
		;

functionCall:
		ID OP_PARENS args CL_PARENS SEMICOLON
		;

args:
		argList
		/* empty */
		|
		;

argList:
		argList COMMA expression
		| expression

breakStatement:
		BREAK SEMICOLON
		;

returnStatement:
		RETURN returnStatement1
		;

returnStatement1:
		SEMICOLON
		| expression SEMICOLON
		;

structDeclaration:
		STRUCT ID OP_CURLY variableDeclarationNoValueList CL_CURLY SEMICOLON
		;

variableDeclarationNoValueList:
		variableDeclarationNoValueList typeSpecifier ID SEMICOLON
		| typeSpecifier ID SEMICOLON
		;

conditionalStatement:
		IF OP_PARENS booleanExpression CL_PARENS OP_CURLY statementList CL_CURLY
		| IF OP_PARENS booleanExpression CL_PARENS OP_CURLY statementList CL_CURLY ELSE conditionalStatement
		| IF OP_PARENS booleanExpression CL_PARENS OP_CURLY statementList CL_CURLY ELSE OP_CURLY statementList CL_CURLY
		;

expressionStatement:
		expression SEMICOLON
		| SEMICOLON
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
		;

mutable:
		ID
		| mutable mutable1
		;

mutable1:
		OP_SQUARE numExpression CL_SQUARE
		| PERIOD ID
		;

expression:
		booleanExpression
		| numExpression
		| STRINGLITERAL
		| CHARLITERAL
		;

booleanExpression:
		booleanExpression boolOp unaryBoolExpression
		| unaryBoolExpression
		;

boolOp:
		AND
		| OR
		;

unaryBoolExpression:
		NOT booleanExpression
		| relExpression
		| mutable
		| OP_PARENS booleanExpression CL_PARENS
		| functionCall
		| TRUE
		| FALSE
		;

relExpression:
		numExpression relOp numExpression
		;

relOp:
		EQUAL
		| NOT_EQUAL
		| GREATER
		| GREATER_EQ
		| LESS
		| LESS_EQ
		;

numExpression:
		numExpression numOp unaryNumExpression
		| unaryNumExpression
		;

numOp:
		PLUS
		| MINUS
		| TIMES
		| DIVIDE
		| MOD
		;

unaryNumExpression:
		unaryNumOp unaryNumExpression
		| mutable
		| OP_PARENS numExpression CL_PARENS
		| functionCall
		| numLiteral
		;

numLiteral:
		INTLITERAL
		| FLOATLITERAL
		;

unaryNumOp:
		PLUS
		| MINUS
		;

%%

int main(int argc, char** argv) {
#if YYDEBUG == 1
yydebug = 1;
#endif
	// open a file handle to a particular file:
	if (argc < 2){
		cout << "No file specified."<< endl;
		return 1;
	}
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
		yyparse();
	} while (!feof(yyin));
}
