%{
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <fstream>
#include <list>


using namespace std;

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

extern void yyerror(const char* s);
extern void print_error(const char* s);

ifstream open_file;

int yywrap()
{
    return 1;
}


%}
%code requires {
#include "SyntaxTree.h"
#include "TreeNode.h"
SyntaxTree syntax_tree;
}

%define parse.error verbose

%union {
	int ival;
	float fval;
	const char * charp;
	bool bval;
	TreeNode* node;
	std::list<std::string>* string_list;
	std::list<VariableNode*>* variable_list;
}

%token <ival> INTLITERAL
%token <fval> FLOATLITERAL
%token <charp> STRINGLITERAL
%token <charp> ID
%token <charp> CHARLITERAL
%token <charp> NUM BOOLEAN CHAR
%token <bool> TRUE FALSE
%token <charp> FOR IF ELSE WHILE RETURN BREAK STRUCT VOID MAIN
%token SEMICOLON COMMA PERIOD
%token OP_PARENS CL_PARENS OP_CURLY CL_CURLY
%token <charp> OP_SQUARE CL_SQUARE
%token EQUAL NOT_EQUAL NOT GREATER LESS AND OR GREATER_EQ LESS_EQ
%token ATTRIBUTION
%token PLUS MINUS TIMES DIVIDE MOD

%left PLUS MINUS OR
%left TIMES DIVIDE MOD AND

%type <node> functionDeclaration
%type <node> main
%type <node> structDeclaration
%type <variable_list> parameters
%type <variable_list> paramList
%type <variable_list> mainParameters
%type <charp> returnType
%type <charp> typeSpecifier
%type <charp> arrayDef
%type <charp> arrayDef1

%%
program:
		declarations main {syntax_tree.insert_node($2);}
		;

declarations:
		declarations functionDeclaration {syntax_tree.insert_node($2);}
		| declarations structDeclaration {syntax_tree.insert_node($2);}
		/* empty */
		|
		;

functionDeclaration:
		returnType ID OP_PARENS parameters CL_PARENS OP_CURLY statementList CL_CURLY {$$ = new FunctionDeclarationNode($2, $1, *$4);}
		| error OP_CURLY statementList CL_CURLY {print_error("Function declaration: Before '{'");}
		;

parameters:
		paramList {$$ = $1;}
		/* empty */
		| {$$ = new std::list<VariableNode*>();}
		;

paramList:
		paramList COMMA typeSpecifier ID {$1->push_back(new VariableNode($3, $4)); $$ = $1;}
		| typeSpecifier ID {auto list = new std::list<VariableNode*>(); list->push_back(new VariableNode($1, $2)); $$ = list;}
		;

main:
		NUM MAIN OP_PARENS mainParameters CL_PARENS OP_CURLY statementList CL_CURLY {$$ = new FunctionDeclarationNode($2, $1, *$4);}
		| error OP_CURLY statementList CL_CURLY {print_error("Main declaration: Before '{'");}
		;

mainParameters:
		NUM ID COMMA CHAR OP_SQUARE CL_SQUARE ID {$$ = new std::list<VariableNode*>({new VariableNode($1, $2), new VariableNode("char[]", $7)});}
		/* empty */
		| {$$ = new std::list<VariableNode*>();}
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
		| error SEMICOLON {print_error("statement error");}
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
		STRUCT ID OP_CURLY variableDeclarationNoValueList CL_CURLY SEMICOLON {$$ = new StructNode($2);}
		| STRUCT error SEMICOLON {print_error("Struct declaration: Before ';'");}
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
		NUM arrayDef {$$ = (std::string($1) + std::string($2)).c_str();}
		| BOOLEAN arrayDef {$$ = (std::string($1) + std::string($2)).c_str();}
		| CHAR arrayDef {$$ = (std::string($1) + std::string($2)).c_str();}
		| ID {$$ = $1;}
		;

arrayDef:
		OP_SQUARE arrayDef1 {$$ = (std::string($1) + std::string($2)).c_str();}
		| {$$ = (const char*) new char(' ');}
		;

arrayDef1:
		CL_SQUARE {$$ = (const char*) new char(']');}
		| INTLITERAL CL_SQUARE {$$ = (std::string($1) + std::string("]")).c_str();}
		;

mutableOrFunctionCall:
		ID mutableOrFunctionCall1
		;

mutableOrFunctionCall1:
		OP_PARENS args CL_PARENS access
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
	open_file.open(argv[1], ios::in);
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));
}
