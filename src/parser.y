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
	UnaryOperatorNode* unOpNode;
	ReservedWordNode* rwNode;
	LiteralNode* litNode;
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
%type <variable_list> variableDeclarationNoValueList
%type <node_list> args
%type <node_list> argList
%type <node_list> statementList
%type <node> statement
%type <rwNode> loopStatement
%type <rwNode> breakStatement
%type <rwNode> returnStatement
%type <node> expressionStatement
%type <rwNode> conditionalStatement
%type <rwNode> conditionalStatement1
%type <rwNode> conditionalStatement2
%type <node> variableAttrOrDecla
%type <opNode> variableAttribution
%type <opNode> variableAttribution1
%type <node> variableDeclaration
%type <opNode> variableDeclaration1
%type <node> expression
%type <node> returnExpression
%type <node> booleanExpression
%type <opNode> booleanExpression1
%type <node> numExpression
%type <node> unaryNumExpression
%type <opNode> boolRelOp
%type <node> boolRelOp1
%type <opNode> numRelOp
%type <opNode> expOp
%type <opNode> boolOp
%type <opNode> boolOp1
%type <opNode> numOp
%type <opNode> numOp1
%type <opNode> relOp
%type <opNode> relOpNum
%type <unOpNode> unaryNumOp
%type <variable_list> parameters
%type <variable_list> paramList
%type <variable_list> mainParameters
%type <charp> returnType
%type <charp> typeSpecifier
%type <charp> arrayDef
%type <charp> arrayDef1
%type <litNode> numLiteral
%type <node> mutableOrFunctionCall


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
		paramList {$$ = $1;} // {$$ = $1;} is the default action
		/* empty */
		| {$$ = new std::list<const VariableNode*>();}
		;

paramList:
		paramList COMMA typeSpecifier ID {$1->push_back(new VariableNode($3, $4)); $$ = $1;}
		| typeSpecifier ID {auto list = new std::list<const VariableNode*>({new VariableNode($1, $2)}); $$ = list;}
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
		statementList statement {
			if ($2 != NULL) {
				$1->push_back($2);
			}
			$$ = $1;
		}
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
		typeSpecifier ID variableDeclaration1 {$$ = $3 != NULL ? $3->set_left_child(new VariableNode($1, $2)) : (TreeNode*)new VariableNode($1, $2);}
		;

/*created to remove ambiguity*/
variableDeclaration1:
		ATTRIBUTION expression {OperatorNode *op = new OperatorNode(TreeNode::Operator::ATTRIBUTION); $$ = op->set_right_child($2);}
		| {$$ = NULL;}
		;

variableAttribution:
		ID variableAttribution1 {$2->set_left_child(new IdNode($1)); $$ = $2;}
		;

variableAttribution1:
		ATTRIBUTION expression {OperatorNode *op = new OperatorNode(TreeNode::Operator::ATTRIBUTION); $$ = op->set_right_child($2);}
		| arrayAccess ATTRIBUTION expression {/*TODO*/}
		;

variableAttrOrDecla:
		variableDeclaration {$$ = $1;}
		| variableAttribution {$$ = $1;}
		;

loopStatement:
		FOR OP_PARENS variableAttrOrDecla SEMICOLON booleanExpression SEMICOLON variableAttribution CL_PARENS OP_CURLY statementList CL_CURLY {
			auto forNode = new ReservedWordNode(TreeNode::FOR);
			forNode->insert_child($3)->insert_child($5)->insert_child($7)->insert_child($10);
			$$ = forNode;
		}
		| WHILE OP_PARENS booleanExpression CL_PARENS OP_CURLY statementList CL_CURLY {
			auto whileNode = new ReservedWordNode(TreeNode::WHILE);
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
		| expression {auto list = new std::list<const TreeNode*>({$1}); $$ = list;}
		;

breakStatement:
		BREAK SEMICOLON {$$ = new ReservedWordNode(TreeNode::BREAK);}
		;

returnStatement:
		RETURN returnExpression {auto ret = new ReservedWordNode(TreeNode::RETURN); $$ = $2 != NULL ? ret->insert_child($2) : ret;} //TODO
		;

returnExpression:
		SEMICOLON {$$ = NULL;}
		| expression SEMICOLON {$$ = $1;}
		;

structDeclaration:
		STRUCT ID OP_CURLY variableDeclarationNoValueList CL_CURLY SEMICOLON {$$ = new StructNode($2, *$4);}
		| STRUCT error SEMICOLON {print_error("Struct declaration: Before ';'");}
		;

variableDeclarationNoValueList:
		variableDeclarationNoValueList typeSpecifier ID SEMICOLON {$1->push_back(new VariableNode($2, $3));}
		| typeSpecifier ID SEMICOLON {auto list = new std::list<const VariableNode*>({new VariableNode($1, $2)}); $$ = list;}
		;

conditionalStatement:
		IF OP_PARENS booleanExpression CL_PARENS OP_CURLY statementList CL_CURLY conditionalStatement1 {
			auto ifNode = new ReservedWordNode(TreeNode::IF);
			ifNode->insert_child($3)->insert_child($6);
			$$ = $1 != NULL ? ifNode->insert_child($8) : ifNode; 
		}
		;

conditionalStatement1:
		ELSE conditionalStatement2 {$$ = $2;}
		| {$$ = NULL;}
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
		expression SEMICOLON {$$ = $1;}
		| SEMICOLON {$$ = NULL;}
		;

returnType:
		typeSpecifier {$$ = $1;}
		| VOID {$$ = $1;}
		;

typeSpecifier:
		NUM arrayDef {$$ = (std::string($1) + std::string($2)).c_str();}
		| BOOLEAN arrayDef {$$ = (std::string($1) + std::string($2)).c_str();}
		| CHAR arrayDef {$$ = (std::string($1) + std::string($2)).c_str();}
		| ID {$$ = $1;}
		;

arrayDef:
		OP_SQUARE arrayDef1 {$$ = (std::string("[") + std::string($2)).c_str();}
		| {$$ = (const char*) new char(' ');}
		;

arrayDef1:
		CL_SQUARE {$$ = "]";}
		| INTLITERAL CL_SQUARE {$$ = (std::to_string($1) + std::string("]")).c_str();}
		;

mutableOrFunctionCall:
		ID mutableOrFunctionCall1 {$$ = new TreeNode();} //TODO
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
		NOT booleanExpression {auto unOp = new UnaryOperatorNode(TreeNode::NOT); $$ = unOp->set_child($2);}
		| OP_PARENS expression CL_PARENS {$$ = $2;}
		| TRUE boolRelOp {$$ = $2->set_left_child(new LiteralNode("BOOLEAN", true));}
		| FALSE boolRelOp {$$ = $2->set_left_child(new LiteralNode("BOOLEAN", false));}
		| mutableOrFunctionCall expOp {$$ = $2 != NULL ? $2->set_left_child($1) : $1;}
		| numLiteral numRelOp {$$ = $2 != NULL ? $2->set_left_child($1) : (TreeNode*)$1;}
		| unaryNumOp numLiteral numRelOp {$$ = $3 != NULL ? $3->set_left_child($1->set_child($2)) : (TreeNode*)$1->set_child($2);}
		| STRINGLITERAL {$$ = new LiteralNode("CHAR", $1);} //TODO remove ""
		| CHARLITERAL {$$ = new LiteralNode("CHAR", $1);} //TODO remove ''
		;

expOp:
		numOp1 {$$ = $1;}
		| boolOp1 {$$ = $1;}
		| relOpNum numExpression boolOp {
			$1->set_right_child($2);
			$$ = $3 != NULL ? $3->set_left_child($1) : $1;
		}
		| relOp expression boolOp {
			$1->set_right_child($2);
			$$ = $3 != NULL ? $3->set_left_child($1) : $1;
		}
		| {$$ = NULL;}
		;

numRelOp:
		numOp1 {$$ = $1;}
		| relOpNum numExpression {$$ = $1->set_right_child($2);}
		| relOp expression {$$ = $1->set_right_child($2);}
		| {$$ = NULL;}
		;

booleanExpression:
		NOT booleanExpression boolOp {auto unOp = new UnaryOperatorNode(TreeNode::NOT); $$ = $3->set_left_child(unOp->set_child($2));}
		| mutableOrFunctionCall boolRelOp {$$ = $2->set_left_child($1);}
		| numLiteral numOp booleanExpression1 {$$ = $2 != NULL ? $3->set_left_child($2->set_left_child($1)) : $3->set_left_child($1);} 
		| OP_PARENS booleanExpression CL_PARENS boolOp {$$ = $2;}
		| TRUE boolOp {$$ = $2 != NULL ? $2->set_left_child(new LiteralNode("BOOLEAN", true)) : (TreeNode*)new LiteralNode("BOOLEAN", true);}
		| FALSE boolOp {$$ = $2 != NULL ? $2->set_left_child(new LiteralNode("BOOLEAN", false)) : (TreeNode*)new LiteralNode("BOOLEAN", false);}
		;

booleanExpression1:
		relOp expression {$$ = $1->set_right_child($2);}
		| relOpNum numExpression {$$ = $1->set_right_child($2);}
		;

boolOp:
		AND booleanExpression {auto opNode = new OperatorNode(TreeNode::AND); $$ = opNode->set_right_child($2);}
		| OR booleanExpression {auto opNode = new OperatorNode(TreeNode::OR); $$ = opNode->set_right_child($2);}
		| {$$ = NULL;}
		;

boolOp1:
		AND booleanExpression {auto opNode = new OperatorNode(TreeNode::AND); $$ = opNode->set_right_child($2);}
		| OR booleanExpression {auto opNode = new OperatorNode(TreeNode::OR); $$ = opNode->set_right_child($2);}
		;

boolRelOp:
		boolOp {$$ = $1;}
		| relOp boolRelOp1 {$$ = $1->set_right_child($2);}
		| relOpNum numExpression boolOp {$1->set_right_child($2); $$ = $3 != NULL ? $3->set_left_child($1) : $1;}
		;

boolRelOp1:
		numExpression boolOp {$$ = $2 != NULL ? $2->set_left_child($1) : $1;}
		| TRUE boolOp {$$ = $2 != NULL ? $2->set_left_child(new LiteralNode("BOOLEAN", true)) : (TreeNode*)new LiteralNode("BOOLEAN", true);}
		| FALSE boolOp {$$ = $2 != NULL ? $2->set_left_child(new LiteralNode("BOOLEAN", false)) : (TreeNode*)new LiteralNode("BOOLEAN", false);}
		;

relOp:
		EQUAL {$$ = new OperatorNode(TreeNode::EQUAL);}
		| NOT_EQUAL {$$ = new OperatorNode(TreeNode::NOT_EQUAL);}
		;

relOpNum:
		GREATER {$$ = new OperatorNode(TreeNode::GREATER);}
		| GREATER_EQ {$$ = new OperatorNode(TreeNode::GREATER_EQ);}
		| LESS {$$ = new OperatorNode(TreeNode::LESS);}
		| LESS_EQ {$$ = new OperatorNode(TreeNode::LESS_EQ);}
		;

numExpression:
		unaryNumOp unaryNumExpression numOp {$1->set_child($2); $$ = $3 != NULL ? (TreeNode*)$3->set_left_child($1) : $1;}
		| mutableOrFunctionCall numOp {$$ = $2 != NULL ? $2->set_left_child($1) : $1;}
		| OP_PARENS numExpression CL_PARENS numOp {$$ = $4 != NULL ? $4->set_left_child($2) : $2;}
		| numLiteral numOp {$$ = $2 != NULL ? $2->set_left_child($1) : (TreeNode*)$1;}
		;

numOp:
		PLUS numExpression {auto opNode = new OperatorNode(TreeNode::PLUS); $$ = opNode->set_right_child($2);}
		| MINUS numExpression {auto opNode = new OperatorNode(TreeNode::MINUS); $$ = opNode->set_right_child($2);}
		| TIMES numExpression {auto opNode = new OperatorNode(TreeNode::TIMES); $$ = opNode->set_right_child($2);}
		| DIVIDE numExpression {auto opNode = new OperatorNode(TreeNode::DIVIDE); $$ = opNode->set_right_child($2);}
		| MOD numExpression {auto opNode = new OperatorNode(TreeNode::MOD); $$ = opNode->set_right_child($2);}
		| {$$ = NULL;}
		;

numOp1:
		PLUS numExpression {auto opNode = new OperatorNode(TreeNode::PLUS); $$ = opNode->set_right_child($2);}
		| MINUS numExpression {auto opNode = new OperatorNode(TreeNode::MINUS); $$ = opNode->set_right_child($2);}
		| TIMES numExpression {auto opNode = new OperatorNode(TreeNode::TIMES); $$ = opNode->set_right_child($2);}
		| DIVIDE numExpression {auto opNode = new OperatorNode(TreeNode::DIVIDE); $$ = opNode->set_right_child($2);}
		| MOD numExpression {auto opNode = new OperatorNode(TreeNode::MOD); $$ = opNode->set_right_child($2);}
		;


unaryNumExpression:
		| mutableOrFunctionCall {$$ = $1;}
		| OP_PARENS numExpression CL_PARENS {$$ = $2;}
		| numLiteral {$$ = $1;}
		;

numLiteral:
		INTLITERAL {$$ = new LiteralNode("NUM", $1);}
		| FLOATLITERAL {$$ = new LiteralNode("NUM", $1);}
		;

unaryNumOp:
		PLUS {$$ = new UnaryOperatorNode(TreeNode::UN_PLUS);}
		| MINUS {$$ = new UnaryOperatorNode(TreeNode::UN_MINUS);}
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
