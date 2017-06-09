#include "../include/TreeNode.h"
#include "../include/SymbolTable.h"
#include <iostream>


extern std::deque<std::pair<int, std::string>> error_list;
extern int yylineno;
extern SymbolTable symbol_table;

TreeNode::TreeNode(){}
TreeNode::~TreeNode(){}

//Standard definition for all nodes. Will be overridden by the needed nodes
std::string TreeNode::type() const {
	return "void";
}

std::string OperatorNode::type() const {
	return "void";
}

VariableNode::VariableNode(const char* type, const char* name) {
	this->_type = type;
	this->_name = name;
}
VariableNode::~VariableNode(){}

LiteralNode::LiteralNode(const char* type, const char* value) {
	this->_type = type;
	this->_s_value = value;
}
LiteralNode::LiteralNode(const char* type, int value) {
	this->_type = type;
	this->_i_value = value;
}
LiteralNode::LiteralNode(const char* type, bool value) {
	this->_type = type;
	this->_b_value = value;
}
LiteralNode::LiteralNode(const char* type, float value) {
	this->_type = type;
	this->_f_value = value;
}
LiteralNode::~LiteralNode(){}

OperatorNode::OperatorNode(){}
OperatorNode::~OperatorNode(){}
OperatorNode* OperatorNode::set_left_child(const TreeNode* node) {
	this->_left = node;
	return this;
}

BinaryOperatorNode::BinaryOperatorNode(const Operator& op) {
	this->_operator = op;
}
BinaryOperatorNode::~BinaryOperatorNode(){}
// BinaryOperatorNode* BinaryOperatorNode::set_left_child(const TreeNode* node) {
// 	this->_left = node;
// 	return this;
// }
BinaryOperatorNode* BinaryOperatorNode::set_right_child(const TreeNode* node) {
	this->_right = node;
	return this;
}
BinaryOperatorNode* BinaryOperatorNode::set_children(const TreeNode* node1, const TreeNode* node2) {
	this->_left = node1;
	this->_right = node2;
	return this;
}
std::string BinaryOperatorNode::type() const {
	if (_left->type() == _right->type()) {
		return _left->type();
	}
	error_list.push_back(std::pair<int, std::string>(yylineno, "Binary operation with two different types."));
	return "error";
}

UnaryOperatorNode::UnaryOperatorNode(const UnaryOperator& op) {
	this->_operator = op;
}
UnaryOperatorNode::~UnaryOperatorNode(){}
UnaryOperatorNode* UnaryOperatorNode::set_left_child(const TreeNode* node) {
	this->_left = node;
	return this;
}
std::string UnaryOperatorNode::type() const {
	return _left->type();
}

AccessOperatorNode::AccessOperatorNode(const AccessOperator& op) {
	this->_operator = op;
	this->_leftLeaf = false;
}
AccessOperatorNode::~AccessOperatorNode(){}
AccessOperatorNode* AccessOperatorNode::set_left_child(const IdNode* node) {
	this->_left = node;
	this->_leftLeaf = true;
	this->_leftId = node->_name;
	this->check_type();
	return this;
}
AccessOperatorNode* AccessOperatorNode::set_left_child(const AccessOperatorNode* node) {
	this->_left = node;
	this->check_type();
	return this;
}
AccessOperatorNode* AccessOperatorNode::set_right_child(const IdNode* node) {
	this->_right = node;
	this->_rightId = node->_name;
	return this;
}
AccessOperatorNode* AccessOperatorNode::set_right_child(const TreeNode* numExpression) {
	this->_right = numExpression;
	return this;
}
AccessOperatorNode* AccessOperatorNode::set_right_child(const std::deque<const TreeNode*>* parameters) {
	this->_parameters = parameters;
	return this;
}
std::string AccessOperatorNode::type() const {
	return this->_type;
}
std::string AccessOperatorNode::check_type() {
	switch(this->_operator) {
		case TreeNode::ID :
			return this->_type = this->_left->type();
			break;
		case TreeNode::ARRAY : {
			std::cout << "array" << std::endl;
			if (this->_leftLeaf) {
				if(!symbol_table.isArray(this->_leftId)) {
					error_list.push_back(std::pair<int, std::string>(yylineno, "Variable \"" + this->_leftId + "\" is not an array."));
					return this->_type = "error";
				}
				return this->_type = symbol_table.findVariable(this->_leftId)->varType;
			} 
			auto type = this->_left->type();
			auto struc = symbol_table.findStructure(type);
			if(struc == nullptr) {
				error_list.push_back(std::pair<int, std::string>(yylineno, "Invalid access."));
				return this->_type = "error";
			}
			return this->_type = symbol_table.findStructure(type)->find_member(this->_rightId);
			break;
		}
		case TreeNode::STRUCT : {
			auto struct_type = this->_leftLeaf ? symbol_table.findVariable(this->_leftId)->varType : this->_left->type();
			auto struc = symbol_table.findStructure(struct_type);
			if(struc == nullptr) {
				auto erromsg = this->_leftLeaf ? "Variable \"" + this->_leftId + "\" is not a struct." : "Invalid access to a non Struct.";
				error_list.push_back(std::pair<int, std::string>(yylineno, erromsg));
				return this->_type = "error";
			}
			auto typeMember = struc->find_member(this->_rightId);
			if(typeMember == "") {
				error_list.push_back(std::pair<int, std::string>(yylineno, "\"" + this->_rightId + "\" is not a member of \"" + struct_type + "\"."));
				return this->_type = "error";
			}
			return this->_type = typeMember;
			break;
		}
		case TreeNode::CALL :
			if (this->_leftLeaf) {
				return this->_type = symbol_table.findFunction(this->_leftId)->returnType;
			} else {
				error_list.push_back(std::pair<int, std::string>(yylineno, "Identifier \"" + this->_leftId + "\" is not a function."));
				return this->_type = "error";
			}
			break;
	}
	return this->_type = "error";
}

FunctionDeclarationNode::FunctionDeclarationNode(const char* name, const char* return_type, const std::deque<const VariableNode*>& parameters, const std::deque<const TreeNode*>* statements) {
	this-> _name = name;
	this-> _return_type = return_type;
	this->_parameters = parameters;
	this->_statements = statements;
}
FunctionDeclarationNode::~FunctionDeclarationNode(){}

StructNode::StructNode(const char* name, const std::deque<const VariableNode*>& variables) {
	this-> _name = name;
	this->_variables = variables;
}
StructNode::~StructNode(){}
IdNode::IdNode(const char* name) {
	this->_name = name;
}
std::string IdNode::type() const {
	auto var = symbol_table.findVariable(this->_name);
	if(var == nullptr) {
		return "error";
	}
	return var->varType;
}
IdNode::~IdNode(){}

ReservedWordNode::ReservedWordNode(const ReservedWord& word) {
	this->_word = word;
	this->_nodes = std::deque<const TreeNode*>();
}
ReservedWordNode::~ReservedWordNode(){}
ReservedWordNode* ReservedWordNode::insert_child(const TreeNode* node) {
	this->_nodes.push_back(node);
	return this;
}
ReservedWordNode* ReservedWordNode::insert_child(std::deque<const TreeNode*>* nodeList) {
	for (auto i : *nodeList) {
        this->_nodes.push_back(i);
    }
    return this;
}
