%{
#include <stdio.h>
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
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
//this goes in the .h
%code requires {
#include "SyntaxTree.h"
#include "TreeNode.h"
extern SyntaxTree syntax_tree;
}

//this goes in the .cpp
%code top {
#include "SyntaxTree.h"
SyntaxTree syntax_tree;
}

%define parse.error verbose

%union {
	int ival;
	float fval;
	const char * charp;
	bool bval;
	TreeNode* node;
	OperatorNode* opNode;
	ReservedWordNode* rwNode;
	std::list<std::string>* string_list;
	std::list<const VariableNode*>* variable_list;
	std::list<const TreeNode*>* node_list;
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
%type <node_list> args
%type <node_list> argList
%type <node_list> statementList
%type <node> statement
%type <rwNode> loopStatement
%type <rwNode> breakStatement
%type <rwNode> returnStatement
%type <rwNode> expressionStatement
%type <rwNode> conditionalStatement
%type <rwNode> conditionalStatement1
%type <rwNode> conditionalStatement2
%type <node> variableAttrOrDecla
%type <opNode> variableAttribution
%type <opNode> variableAttribution1
%type <node> variableDeclaration
%type <opNode> variableDeclaration1
%type <node> expression
%type <opNode> booleanExpression
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
		| {$$ = new std::list<const VariableNode*>();}
		;

paramList:
		paramList COMMA typeSpecifier ID {$1->push_back(new VariableNode($3, $4)); $$ = $1;}
		| typeSpecifier ID {auto list = new std::list<const VariableNode*>(); list->push_back(new VariableNode($1, $2)); $$ = list;}
		;

main:
		NUM MAIN OP_PARENS mainParameters CL_PARENS OP_CURLY statementList CL_CURLY {$$ = new FunctionDeclarationNode($2, $1, *$4);}
		| error OP_CURLY statementList CL_CURLY {print_error("Main declaration: Before '{'");}
		;

mainParameters:
		NUM ID COMMA CHAR OP_SQUARE CL_SQUARE ID {$$ = new std::list<const VariableNode*>({new VariableNode($1, $2), new VariableNode("char[]", $7)});}
		/* empty */
		| {$$ = new std::list<const VariableNode*>();}
		;

statementList:
		statementList statement {$1->push_back($2); $$ = $1;}
		/* empty */
		| {auto list = new std::list<const TreeNode*>(); $$ = list;}
		;

statement:
		variableDeclaration SEMICOLON {$$ = $1;}
		| variableAttribution SEMICOLON {$$ = $1;}
		| loopStatement {$$ = $1;}
		| breakStatement {$$ = $1;}
		| returnStatement {$$ = $1;}
		| structDeclaration {$$ = $1;}
		| conditionalStatement {$$ = $1;}
		| expressionStatement {$$ = $1;}
		| error SEMICOLON {print_error("statement error");}
		;

variableDeclaration:
		typeSpecifier ID variableDeclaration1 {$$ = $3 ? $3->set_left_child(new VariableNode($1, $2)) : (TreeNode*)new VariableNode($1, $2);}
		;

/*created to remove ambiguity*/
variableDeclaration1:
		ATTRIBUTION expression {OperatorNode *op = new OperatorNode(TreeNode::Operator::ATTRIBUTION); $$ = op->set_right_child($2);}
		| {$$ = false;}
		;

variableAttribution:
		ID variableAttribution1 {$2->set_left_child(new IdNode($1)); $$ = $2;}
		;

variableAttribution1:
		ATTRIBUTION expression {OperatorNode *op = new OperatorNode(TreeNode::Operator::ATTRIBUTION); $$ = op->set_right_child($2);}
		| arrayAccess ATTRIBUTION expression {/*TODO*/}

variableAttrOrDecla:
		variableDeclaration {$$ = $1;}
		| variableAttribution {$$ = $1;}
		;

loopStatement:
		FOR OP_PARENS variableAttrOrDecla SEMICOLON booleanExpression SEMICOLON variableAttribution CL_PARENS OP_CURLY statementList CL_CURLY {
			ReservedWordNode *forNode = new ReservedWordNode(TreeNode::FOR);
			forNode->insert_child($3)->insert_child($5)->insert_child($7)->insert_child($10);
			$$ = forNode;
		}
		| WHILE OP_PARENS booleanExpression CL_PARENS OP_CURLY statementList CL_CURLY {
			ReservedWordNode *whileNode = new ReservedWordNode(TreeNode::WHILE);
			whileNode->insert_child($3)->insert_child($6);
			$$ = whileNode;
		}
		;

args:
		argList {$$ = $1;}
		| {$$ = new std::list<const TreeNode*>();}
		;

argList:
		argList COMMA expression {$$ = $1;}
		| expression {auto list = new std::list<const TreeNode*>(); list->push_back($1); $$ = list;}
		;

breakStatement:
		BREAK SEMICOLON {$$ = new ReservedWordNode(TreeNode::BREAK);}
		;

returnStatement:
		RETURN returnExpression {/*TODO returnExpression*/$$ = new ReservedWordNode(TreeNode::BREAK);}
		;

returnExpression:
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
		IF OP_PARENS booleanExpression CL_PARENS OP_CURLY statementList CL_CURLY conditionalStatement1 {
			ReservedWordNode *ifNode = new ReservedWordNode(TreeNode::IF);
			ifNode->insert_child($3)->insert_child($6);
			if ($1) {
				ifNode->insert_child($8);
			}
			$$ = ifNode; 
		}
		;

conditionalStatement1:
		ELSE conditionalStatement2 {$$ = $2;}
		| {$$ = false;}
		;

conditionalStatement2:
		conditionalStatement {
			ReservedWordNode *elseNode = new ReservedWordNode(TreeNode::ELSE);
			elseNode->insert_child($1);
			$$ = elseNode; 
		}
		| OP_CURLY statementList CL_CURLY {
			ReservedWordNode *elseNode = new ReservedWordNode(TreeNode::ELSE);
			elseNode->insert_child($2);
			$$ = elseNode; 
		}
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
| INTLITERAL CL_SQUARE {std::ostringstream convert; convert << $1; $$ = (convert.str() + std::string("]")).c_str();}
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
