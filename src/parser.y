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
extern int yylineno;

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
#include "SymbolTable.h"

using std::string;

SyntaxTree syntax_tree;
SymbolTable symbol_table;

std::deque<std::pair<int, string>> error_list;

type current_return_type;
}

%define parse.error verbose

%union {
	int ival;
	float fval;
	const char * charp;
	bool bval;
	TreeNode* node;
	OperatorNode* opNode;
	AccessOperatorNode* acsOpNode;
	BinaryOperatorNode* biOpNode;
	UnaryOperatorNode* unOpNode;
	ReservedWordNode* rwNode;
	LiteralNode* litNode;
	std::deque<std::string>* string_list;
	std::deque<const VariableNode*>* variable_list;
	std::deque<const TreeNode*>* node_list;
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
%type <node> variableAttrOrDecla
%type <opNode> variableAttribution
%type <node> variableDeclaration
%type <node> expression
%type <node> returnExpression
%type <node> booleanExpression
%type <node> numExpression
%type <node> unaryNumExpression
%type <opNode> boolRelOp
%type <opNode> boolRelOp2
%type <node> boolRelOp1
%type <opNode> numRelOp
%type <opNode> numRelOp1
%type <opNode> expOp
%type <biOpNode> boolOp
%type <biOpNode> boolOp1
%type <biOpNode> numOp
%type <biOpNode> numOp1
%type <biOpNode> relOp
%type <biOpNode> relOpNum
%type <unOpNode> unaryNumOp
%type <variable_list> parameters
%type <variable_list> paramList
%type <variable_list> mainParameters
%type <charp> returnType
%type <charp> typeSpecifier
%type <charp> arrayDef
%type <litNode> numLiteral
%type <acsOpNode> mutableOrFunctionCall
%type <acsOpNode> access
%type <acsOpNode> arrayAccess
%type <acsOpNode> structAccess


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
		returnType[ret] ID[name] OP_PARENS {symbol_table.openScope();} parameters[params] CL_PARENS OP_CURLY {current_return_type = $[ret];} statementList[statements] {symbol_table.closeScope();} CL_CURLY {
			//returnType must be valid. ID must be unique
			bool type_exists = true, valid_id = true;
			if(!symbol_table.returnTypeExists($1)) {
				error_list.push_back(std::pair<int, std::string>(yylineno, "Return type \"" + std::string($1) + "\" is not valid."));
				type_exists = false;
			}
			auto tp = symbol_table.find($2);
			if(tp == SymbolTable::VARIABLE || tp == SymbolTable::STRUCTURE || tp == SymbolTable::FUNCTION) {
				error_list.push_back(std::pair<int, std::string>(yylineno, "Identifier \"" + std::string($2) + "\" not unique, already used as function, variable or structure."));
				valid_id = false;
			}
			if(type_exists && valid_id){ //everything is fine
				symbol_table.addFunction(function($[name], $[ret], *$[params]));
			}
			$$ = new FunctionDeclarationNode($[name], $[ret], *$[params], $[statements]);
		}
		| error OP_CURLY statementList CL_CURLY {print_error("Function declaration: Before '{'");}
		;

parameters:
		paramList {$$ = $1;} // {$$ = $1;} is the default action
		/* empty */
		| {
			$$ = new std::deque<const VariableNode*>();
			//symbol_table.openScope();
			//You can't define a function inside another, so no problem with block scope
		}
		;

paramList:
		paramList COMMA typeSpecifier ID {$1->push_back(new VariableNode($3, $4)); $$ = $1;}
		| typeSpecifier ID {
			//symbol_table.openScope();
			auto list = new std::deque<const VariableNode*>({new VariableNode($1, $2)}); $$ = list;}
		;

main:
		NUM[ret] MAIN[name] OP_PARENS {symbol_table.openScope();} mainParameters[params] CL_PARENS OP_CURLY {current_return_type = $[ret];} statementList[statements] {symbol_table.closeScope();} CL_CURLY {
			$$ = new FunctionDeclarationNode($[name], $[ret], *$[params], $[statements]);
			symbol_table.addFunction(function($[name], $[ret], *$[params]));
		}
		| error OP_CURLY statementList CL_CURLY {print_error("Main declaration: Before '{'");}
		;

mainParameters:
		NUM ID COMMA CHAR OP_SQUARE CL_SQUARE ID {
			SymbolTable::id_type id_type = symbol_table.find($2);
			if(id_type == SymbolTable::VARIABLE || id_type == SymbolTable::FUNCTION) {
				//already exists or with same name as function
				error_list.push_back(std::pair<int, std::string>(yylineno, "A variable or function with the same name as \"" + std::string($2) + "\" was already defined."));
			} else{ //everything is good with num
				symbol_table.addVariable(variable($2, $1));
			}
			id_type = symbol_table.find($7);
			if(id_type == SymbolTable::VARIABLE || id_type == SymbolTable::FUNCTION) {
				//already exists or with same name as function
				error_list.push_back(std::pair<int, std::string>(yylineno, "A variable or function with the same name as \"" + std::string($7) + "\" was already defined."));
			} else{ //everything is good with char[]
				symbol_table.addVariable(variable($7, "char[]"));
			}
			$$ = new std::deque<const VariableNode*>({new VariableNode($1, $2), new VariableNode("char[]", $7)});
		}
		/* empty */
		| {$$ = new std::deque<const VariableNode*>();}
		;

statementList:
		statementList statement {
			if ($2 != nullptr) {
				$1->push_back($2);
			}
			$$ = $1;
		}
		/* empty */
		| {auto list = new std::deque<const TreeNode*>(); $$ = list;}
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
		typeSpecifier ID ATTRIBUTION expression {
			if(!symbol_table.typeExists($1)) {
				//type doesnt exist
				error_list.push_back(std::pair<int, std::string>(yylineno, "Type \"" + std::string($1) + "\" doesn't exist."));
			} else {
				SymbolTable::id_type id_type = symbol_table.find($2);
				if(id_type == SymbolTable::VARIABLE || id_type == SymbolTable::FUNCTION) {
					//already exists or with same name as function
					error_list.push_back(std::pair<int, std::string>(yylineno, "A variable or function with the same name as \"" + std::string($2) + "\" was already defined."));
				} else{ //everything is good
					variable var($2, $1);
					symbol_table.addVariable(var);
				}
			}
			auto op = new BinaryOperatorNode(TreeNode::Operator::ATTRIBUTION);
			$$ = op->set_children(new VariableNode($1, $2), $4);
		}
		| typeSpecifier ID {
			if(!symbol_table.typeExists($1)) {
				//type doesnt exist
				error_list.push_back(std::pair<int, std::string>(yylineno, "Type \"" + std::string($1) + "\" doesn't exist."));
			} else {
				SymbolTable::id_type id_type = symbol_table.find($2);
				if(id_type == SymbolTable::VARIABLE || id_type == SymbolTable::FUNCTION) {
					//already exists or with same name as function
					error_list.push_back(std::pair<int, std::string>(yylineno, "A variable or function with the same name as \"" + std::string($2) + "\" was already defined."));
				} else{ //everything is good
					symbol_table.addVariable(variable($2, $1));
				}
			}
			$$ = new VariableNode($1, $2);
		}
		;

variableAttribution:
		ID access ATTRIBUTION expression {
			//check if 'access' accesses valid members and if expression.type == ID access type
			auto bOp = new BinaryOperatorNode(TreeNode::Operator::ATTRIBUTION);
			bOp->set_children($2->set_left_child(new IdNode($1)), $4);
			$$ = bOp;
		}
		| ID ATTRIBUTION expression {
			auto var = symbol_table.findVariable($1);
			if(var != nullptr) {
				string type = var->varType;
				if(type != $3->type(&symbol_table)) {
					error_list.push_back(std::pair<int, std::string>(yylineno, "Variable \"" + std::string($1) + "\" of type \"" + type + "\" cannot receive value of type \"" + $3->type(&symbol_table) + "\"."));
				}
			} else {
				error_list.push_back(std::pair<int, std::string>(yylineno, "Variable \"" + std::string($1) + "\" was not declared."));
			}
			auto bOp = new BinaryOperatorNode(TreeNode::Operator::ATTRIBUTION);
			bOp->set_children(new IdNode($1), $3);
			$$ = bOp;
		}
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
		| {$$ = new std::deque<const TreeNode*>();}
		;

argList:
		argList COMMA expression {$$ = $1;}
		| expression {auto list = new std::deque<const TreeNode*>({$1}); $$ = list;}
		;

breakStatement:
		BREAK SEMICOLON {$$ = new ReservedWordNode(TreeNode::BREAK);}
		;

returnStatement:
		RETURN returnExpression[exp] {
			if($[exp]->type(&symbol_table) != current_return_type) {
				error_list.push_back(std::pair<int, std::string>(yylineno, "Return type \"" + std::string($[exp]->type(&symbol_table)) + "\" does not match function's declaration \"" + current_return_type + "\"."));
			}
			auto ret = new ReservedWordNode(TreeNode::RETURN);
			$$ = $2 != nullptr ? ret->insert_child($2) : ret;
		}
		;

returnExpression:
		SEMICOLON {$$ = nullptr;}
		| expression SEMICOLON {$$ = $1;}
		;

structDeclaration:
		STRUCT ID OP_CURLY variableDeclarationNoValueList CL_CURLY SEMICOLON {
			symbol_table.closeScope();
			SymbolTable::id_type defined_type = symbol_table.find($2);
			if (defined_type != SymbolTable::NONE) {
				switch(defined_type) {
				case SymbolTable::STRUCTURE:
					error_list.push_back(std::pair<int, std::string>(yylineno, "A struct with name \"" + std::string($2) + "\" was already defined."));
					break;
				case SymbolTable::FUNCTION:
					error_list.push_back(std::pair<int, std::string>(yylineno, "A function with name \"" + std::string($2) + "\" was already defined."));
					break;
				case SymbolTable::VARIABLE:
					error_list.push_back(std::pair<int, std::string>(yylineno, "A variable with name \"" + std::string($2) + "\" was already defined."));
					break;
				default:
					break;
				}
			} else {
				symbol_table.addStructure(structure(string($2), *$4));
			}
			//ads scructure even if there are semantic errors, but no code will be generated in the end
			$$ = new StructNode($2, *$4);
		}
		| STRUCT error SEMICOLON {print_error("Struct declaration: Before ';'");}
		;

variableDeclarationNoValueList:
		variableDeclarationNoValueList typeSpecifier ID SEMICOLON {
			if(!symbol_table.typeExists($2)) {
				error_list.push_back(std::pair<int, std::string>(yylineno, "Type \"" + std::string($2) + "\" does not name a type."));
			} else { //everything is fine
				$1->push_back(new VariableNode($2, $3));
			}
		}
		| typeSpecifier ID SEMICOLON {
			symbol_table.openScope();
			if(!symbol_table.typeExists($1)) {
				error_list.push_back(std::pair<int, std::string>(yylineno, "Type \"" + std::string($1) + "\" does not name a type."));
				auto list = new std::deque<const VariableNode*>(); $$ = list;
			} else { //everything is fine
				auto list = new std::deque<const VariableNode*>({new VariableNode($1, $2)}); $$ = list;
			}
		}
		;

conditionalStatement:
		IF OP_PARENS booleanExpression CL_PARENS OP_CURLY statementList CL_CURLY conditionalStatement1 {
			auto ifNode = new ReservedWordNode(TreeNode::IF);
			ifNode->insert_child($3)->insert_child($6);
			$$ = $8 != nullptr ? ifNode->insert_child($8) : ifNode;
		}
		;

conditionalStatement1:
		ELSE conditionalStatement {
			ReservedWordNode *elseNode = new ReservedWordNode(TreeNode::ELSE);
			$$ = elseNode->insert_child($2);
		}
		| ELSE OP_CURLY statementList CL_CURLY {
			ReservedWordNode *elseNode = new ReservedWordNode(TreeNode::ELSE);
			$$ = elseNode->insert_child($3); 
		}
		| {$$ = nullptr;}
		;

expressionStatement:
		expression SEMICOLON {$$ = $1;}
		| SEMICOLON {$$ = nullptr;}
		;

returnType:
		typeSpecifier {$$ = $1;}
		| VOID {$$ = $1;}
		;

typeSpecifier:
		NUM arrayDef {$$ = ($2 != nullptr ? (std::string($1) + std::string($2)).c_str() : std::string($1).c_str());}
		| BOOLEAN arrayDef {$$ = ($2 != nullptr ? (std::string($1) + std::string($2)).c_str() : std::string($1).c_str());}
		| CHAR arrayDef {$$ = ($2 != nullptr ? (std::string($1) + std::string($2)).c_str() : std::string($1).c_str());}
		| ID {$$ = $1;}
		;

arrayDef:
		OP_SQUARE INTLITERAL CL_SQUARE {$$ = (std::string("[") + std::to_string($2) + std::string("]")).c_str();}
		| OP_SQUARE CL_SQUARE {$$ = (std::string("[") + std::string("]")).c_str();}
		| {$$ = nullptr;}
		;

mutableOrFunctionCall:
		ID OP_PARENS args CL_PARENS access {
			auto cOp = new AccessOperatorNode(TreeNode::CALL);
			cOp->set_right_child($3)->set_left_child(new IdNode($1));
			$$ = $5 != nullptr ? $5->set_left_child(cOp) : cOp;
		}
		| ID access {
			$$ = $2 != nullptr ? $2->set_left_child(new IdNode($1)) : (new AccessOperatorNode(TreeNode::ID))->set_left_child(new IdNode($1));
		}
		;

access:
		structAccess {$$ = $1;}
		| arrayAccess {$$ = $1;}
		;

arrayAccess:
		OP_SQUARE numExpression CL_SQUARE structAccess {
			auto bOp = new AccessOperatorNode(TreeNode::ARRAY);
			bOp->set_right_child($2);
			if ($4 != nullptr) {
				$4->set_left_child(bOp);
				$$ = $4;
			} else {
				$$ = bOp;
			}
		}
		;

structAccess:
		PERIOD ID access {
			auto bOp = new AccessOperatorNode(TreeNode::STRUCT);
			if ($3 != nullptr) {
				$3->set_left_child(bOp->set_right_child(new IdNode($2)));
				$$ = $3;
			} else {
				$$ = bOp->set_right_child(new IdNode($2));
			}
		}
		| {$$ = nullptr;}
		;

expression:
		NOT booleanExpression {auto unOp = new UnaryOperatorNode(TreeNode::NOT); $$ = unOp->set_left_child($2);}
		| OP_PARENS expression CL_PARENS {$$ = $2;}
		| TRUE boolRelOp2 {$$ = $2 != nullptr ? $2->set_left_child(new LiteralNode("BOOLEAN", true)) : dynamic_cast<TreeNode*>(new LiteralNode("BOOLEAN", true));}
		| FALSE boolRelOp2 {$$ = $2 != nullptr ? $2->set_left_child(new LiteralNode("BOOLEAN", false)) : dynamic_cast<TreeNode*>(new LiteralNode("BOOLEAN", false));}
		| mutableOrFunctionCall expOp {$$ = $2 != nullptr ? $2->set_left_child($1) : $1;}
		| numLiteral numRelOp {$$ = $2 != nullptr ? $2->set_left_child($1) : (TreeNode*)$1;}
		| unaryNumOp numLiteral numRelOp {$$ = $3 != nullptr ? $3->set_left_child($1->set_left_child($2)) : (TreeNode*)$1->set_left_child($2);}
		| STRINGLITERAL {$$ = new LiteralNode("CHAR", $1);} //TODO remove ""
		| CHARLITERAL {$$ = new LiteralNode("CHAR", $1);} //TODO remove ''
		;

expOp:
		numOp1 {$$ = $1;}
		| boolOp1 {$$ = $1;}
		| relOpNum numExpression boolOp {
			$1->set_right_child($2);
			$$ = $3 != nullptr ? $3->set_left_child($1) : $1;
		}
		| relOp expression boolOp {
			$1->set_right_child($2);
			$$ = $3 != nullptr ? $3->set_left_child($1) : $1;
		}
		| {$$ = nullptr;}
		;

numRelOp:
		numOp1 {$$ = $1;}
		| numRelOp1 {$$ = $1;}
		| {$$ = nullptr;}
		;

numRelOp1:
		relOpNum numExpression boolOp {$1->set_right_child($2); $$ = $3 != nullptr ? $3->set_left_child($1) : dynamic_cast<OperatorNode*>($1);}
		| relOp expression boolOp {$1->set_right_child($2); $$ = $3 != nullptr ? $3->set_left_child($1) : dynamic_cast<OperatorNode*>($1);}
		;

booleanExpression:
		NOT booleanExpression boolOp {auto unOp = new UnaryOperatorNode(TreeNode::NOT); unOp->set_left_child($2); $$ = $3 != nullptr ? $3->set_left_child(unOp) : dynamic_cast<TreeNode*>(unOp);}
		| mutableOrFunctionCall boolRelOp {$$ = $2 != nullptr ? $2->set_left_child($1) : $1;}
		| numLiteral numOp numRelOp1 {$$ = $2 != nullptr ? $3->set_left_child($2->set_left_child($1)) : $3->set_left_child($1);}
		| OP_PARENS booleanExpression CL_PARENS boolOp {$$ = $4 != nullptr ? $4->set_left_child($2) : $2;}
		| TRUE boolOp {$$ = $2 != nullptr ? $2->set_left_child(new LiteralNode("BOOLEAN", true)) : (TreeNode*)new LiteralNode("BOOLEAN", true);}
		| FALSE boolOp {$$ = $2 != nullptr ? $2->set_left_child(new LiteralNode("BOOLEAN", false)) : (TreeNode*)new LiteralNode("BOOLEAN", false);}
		;

boolOp:
		boolOp1 {$$ = $1;}
		| {$$ = nullptr;}
		;

boolOp1:
		AND booleanExpression {auto opNode = new BinaryOperatorNode(TreeNode::AND); $$ = opNode->set_right_child($2);}
		| OR booleanExpression {auto opNode = new BinaryOperatorNode(TreeNode::OR); $$ = opNode->set_right_child($2);}
		;

boolRelOp:
		boolRelOp2 {$$ = $1;}
		| relOpNum numExpression boolOp {$1->set_right_child($2); $$ = $3 != nullptr ? $3->set_left_child($1) : $1;}
		;

boolRelOp1:
		numExpression boolOp {$$ = $2 != nullptr ? $2->set_left_child($1) : $1;}
		| TRUE boolOp {$$ = $2 != nullptr ? $2->set_left_child(new LiteralNode("BOOLEAN", true)) : (TreeNode*)new LiteralNode("BOOLEAN", true);}
		| FALSE boolOp {$$ = $2 != nullptr ? $2->set_left_child(new LiteralNode("BOOLEAN", false)) : (TreeNode*)new LiteralNode("BOOLEAN", false);}
		;

boolRelOp2:
		boolOp {$$ = $1;}
		| relOp boolRelOp1 {$$ = $1->set_right_child($2);}
		;

relOp:
		EQUAL {$$ = new BinaryOperatorNode(TreeNode::EQUAL);}
		| NOT_EQUAL {$$ = new BinaryOperatorNode(TreeNode::NOT_EQUAL);}
		;

relOpNum:
		GREATER {$$ = new BinaryOperatorNode(TreeNode::GREATER);}
		| GREATER_EQ {$$ = new BinaryOperatorNode(TreeNode::GREATER_EQ);}
		| LESS {$$ = new BinaryOperatorNode(TreeNode::LESS);}
		| LESS_EQ {$$ = new BinaryOperatorNode(TreeNode::LESS_EQ);}
		;

numExpression:
		unaryNumOp unaryNumExpression numOp {$1->set_left_child($2); $$ = $3 != nullptr ? (TreeNode*)$3->set_left_child($1) : $1;}
		| mutableOrFunctionCall numOp {$$ = $2 != nullptr ? $2->set_left_child($1) : $1;}
		| OP_PARENS numExpression CL_PARENS numOp {$$ = $4 != nullptr ? $4->set_left_child($2) : $2;}
		| numLiteral numOp {$$ = $2 != nullptr ? $2->set_left_child($1) : (TreeNode*)$1;}
		;

numOp:
		numOp1 {$$ = $1;}
		| {$$ = nullptr;}
		;

numOp1:
		PLUS numExpression {auto opNode = new BinaryOperatorNode(TreeNode::PLUS); $$ = opNode->set_right_child($2);}
		| MINUS numExpression {auto opNode = new BinaryOperatorNode(TreeNode::MINUS); $$ = opNode->set_right_child($2);}
		| TIMES numExpression {auto opNode = new BinaryOperatorNode(TreeNode::TIMES); $$ = opNode->set_right_child($2);}
		| DIVIDE numExpression {auto opNode = new BinaryOperatorNode(TreeNode::DIVIDE); $$ = opNode->set_right_child($2);}
		| MOD numExpression {auto opNode = new BinaryOperatorNode(TreeNode::MOD); $$ = opNode->set_right_child($2);}
		;


unaryNumExpression:
		mutableOrFunctionCall {$$ = $1;}
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
		cout << "I can't open the file! :( " << endl;
		return -1;
	}
	open_file.open(argv[1], ios::in);
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));
	for (std::pair<int, string> i : error_list) {
		std::cout << "<Line " << std::to_string(i.first) << "> error: " << i.second << std::endl;
	}
}
