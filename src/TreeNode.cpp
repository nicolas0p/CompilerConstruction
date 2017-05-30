#include "../include/TreeNode.h"

TreeNode::TreeNode(){}
TreeNode::~TreeNode(){}

VariableNode::VariableNode(const char* type, const char* name) {
	this->_type = type;
	this->_name = name;
}
VariableNode::~VariableNode(){}

TypeNode::TypeNode(const char* type){}
TypeNode::~TypeNode(){}

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
OperatorNode* OperatorNode::set_left_child(TreeNode* node) {
	this->_left = node;
	return this; 
}
bool OperatorNode::has_left() {
	return this->_left != nullptr;
}

BinaryOperatorNode::BinaryOperatorNode(const Operator& op) {
	this->_operator = op;
}
BinaryOperatorNode::~BinaryOperatorNode(){}
BinaryOperatorNode* BinaryOperatorNode::set_right_child(const TreeNode* node) {
	this->_right = node;
	return this;
}
BinaryOperatorNode* BinaryOperatorNode::set_children(TreeNode* node1, const TreeNode* node2) {
	this->_left = node1;
	this->_right = node2;
	return this;
}

UnaryOperatorNode::UnaryOperatorNode(const UnaryOperator& op) {
	this->_operator = op;
}
UnaryOperatorNode::~UnaryOperatorNode(){}

CallOperatorNode::CallOperatorNode(const Operator& op) {
	this->_operator = op;	
}
CallOperatorNode::~CallOperatorNode(){}
OperatorNode* CallOperatorNode::set_right_child(const std::deque<const TreeNode*>* parameters) {
	this->_parameters = parameters;
	return this;
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
