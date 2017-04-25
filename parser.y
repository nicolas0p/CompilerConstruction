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

%left PLUS MINUS OR
%left TIMES DIVIDE MOD AND

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
		variableDeclaration SEMICOLON
		| variableAttribution SEMICOLON
		| loopStatement
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
		ATTRIBUTION expression
		|
		;

variableAttribution:
		ID variableAttribution1
		;

variableAttribution1:
		ATTRIBUTION expression
		| arrayAccess ATTRIBUTION expression

variableAttrOrDecla:
		variableDeclaration
		| variableAttribution
		;

loopStatement:
		FOR OP_PARENS variableAttrOrDecla SEMICOLON booleanExpression SEMICOLON variableAttribution CL_PARENS OP_CURLY statementList CL_CURLY
		| WHILE OP_PARENS booleanExpression CL_PARENS OP_CURLY statementList CL_CURLY
		;

args:
		argList
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
		NUM arrayDef
		| BOOLEAN arrayDef
		| CHAR arrayDef
		| ID
		;

arrayDef:
		OP_SQUARE arrayDef1
		|
		;

arrayDef1:
		CL_SQUARE
		| INTLITERAL CL_SQUARE
		;

mutableOrFunctionCall:
		ID mutableOrFunctionCall1
		;

mutableOrFunctionCall1:
		OP_PARENS args CL_PARENS
		| access
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
		NOT booleanExpression
		| OP_PARENS expression CL_PARENS
		| TRUE boolRelOp
		| FALSE boolRelOp
		| mutableOrFunctionCall expOp
		| numLiteral numRelOp
		| unaryNumOp numLiteral numRelOp
		| STRINGLITERAL
		| CHARLITERAL
		;

expOp:
		numOp1
		| boolOp1
		| relOpNum numExpression boolOp
		| relOp expression boolOp
		|
		;

numRelOp:
		numOp1
		| relOp expression
		| relOpNum numExpression
		|
		;

booleanExpression:
		NOT booleanExpression boolOp
		| mutableOrFunctionCall boolRelOp
		| numLiteral numOp booleanExpression1
		| OP_PARENS booleanExpression CL_PARENS boolOp
		| TRUE boolOp
		| FALSE boolOp
		;

booleanExpression1:
		relOp expression
		| relOpNum numExpression

boolOp:
		AND booleanExpression
		| OR booleanExpression
		|
		;

boolOp1:
		AND booleanExpression
		| OR booleanExpression
		;

boolRelOp:
		boolOp
		| relOp boolRelOp1
		| relOpNum numExpression boolOp
		;

boolRelOp1:
		numExpression boolOp
		| TRUE boolOp
		| FALSE boolOp
		;

relOp:
		EQUAL
		| NOT_EQUAL
		;

relOpNum:
		GREATER
		| GREATER_EQ
		| LESS
		| LESS_EQ
		;

numExpression:
		unaryNumOp unaryNumExpression numOp
		| mutableOrFunctionCall numOp
		| OP_PARENS numExpression CL_PARENS numOp
		| numLiteral numOp
		;

numOp:
		PLUS numExpression
		| MINUS numExpression
		| TIMES numExpression
		| DIVIDE numExpression
		| MOD numExpression
		|
		;

numOp1:
		PLUS numExpression
		| MINUS numExpression
		| TIMES numExpression
		| DIVIDE numExpression
		| MOD numExpression
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
