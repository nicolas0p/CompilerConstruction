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
		| variableAttribution SEMICOLON
		| loopStatement
		| mutableOrFunctionCall
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

args:
		argList
		/* empty */
		|
		;

argList:
		argList COMMA expression
		| expression
		;

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
		IF OP_PARENS booleanExpression CL_PARENS OP_CURLY statementList CL_CURLY conditionalStatement1
		;

conditionalStatement1:
		ELSE conditionalStatement2
		/* empty */
		|
		;

conditionalStatement2:
		conditionalStatement
		| OP_CURLY statementList CL_CURLY
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

mutableOrFunctionCall:
		ID mutableOrFunctionCall1
		;

mutableOrFunctionCall1:
		OP_PARENS args CL_PARENS
		| access
		|
		;

access:
		structAccess
		| arrayAccess
		;

arrayAccess:
		OP_SQUARE numExpression CL_SQUARE structAccess
		;

structAccess:
		PERIOD ID access
		|
		;

expression:
		booleanExpression boolOp NOT booleanExpression
		| booleanExpression boolOp relExpression
		| booleanExpression boolOp mutableOrFunctionCall
		| booleanExpression boolOp OP_PARENS booleanExpression CL_PARENS
		| booleanExpression boolOp TRUE
		| booleanExpression boolOp FALSE
		| NOT booleanExpression
		| relExpression
		| OP_PARENS booleanExpression CL_PARENS
		| TRUE
		| FALSE
		| numExpression numOp unaryNumOp unaryNumExpression
		| numExpression numOp mutableOrFunctionCall
		| numExpression numOp OP_PARENS numExpression CL_PARENS
		| numExpression numOp numLiteral
		| unaryNumOp unaryNumExpression
		| mutableOrFunctionCall
		| OP_PARENS numExpression CL_PARENS
		| numLiteral
		| STRINGLITERAL
		| CHARLITERAL
		;

booleanExpression:
		booleanExpression boolOp NOT booleanExpression
		| booleanExpression boolOp relExpression
		| booleanExpression boolOp mutableOrFunctionCall
		| booleanExpression boolOp OP_PARENS booleanExpression CL_PARENS
		| booleanExpression boolOp TRUE
		| booleanExpression boolOp FALSE
		| NOT booleanExpression
		| relExpression
		| mutableOrFunctionCall
		| OP_PARENS booleanExpression CL_PARENS
		| TRUE
		| FALSE
		;

boolOp:
		AND
		| OR
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
		numExpression numOp unaryNumOp unaryNumExpression
		| numExpression numOp mutableOrFunctionCall
		| numExpression numOp OP_PARENS numExpression CL_PARENS
		| numExpression numOp numLiteral
		| unaryNumOp unaryNumExpression
		| mutableOrFunctionCall
		| OP_PARENS numExpression CL_PARENS
		| numLiteral
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
		| mutableOrFunctionCall
		| OP_PARENS numExpression CL_PARENS
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
