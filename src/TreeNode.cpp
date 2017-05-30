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

OperatorNode::OperatorNode(const Operator& op) {
	this->_operator = op;
}
OperatorNode::~OperatorNode(){}
OperatorNode* OperatorNode::set_left_child(const TreeNode* node) {
	this->_left = node;
	return this; 
}
OperatorNode* OperatorNode::set_right_child(const TreeNode* node) {
	this->_right = node;
	return this;
}
OperatorNode* OperatorNode::set_children(const TreeNode* node1, const TreeNode* node2) {
	this->_left = node1;
	this->_right = node2;
	return this;
}

UnaryOperatorNode::UnaryOperatorNode(const UnaryOperator& op) {
	this->_operator = op;
}
UnaryOperatorNode::~UnaryOperatorNode(){}
UnaryOperatorNode* UnaryOperatorNode::set_child(const TreeNode* node) {
	this->_child = node;
	return this;
}

FunctionDeclarationNode::FunctionDeclarationNode(const char* name, const char* return_type, const std::deque<const VariableNode*>& parameters, const std::deque<const TreeNode*>* statements) {
	this-> _name = name;
	this-> _return_type = return_type;
	this->_parameters = parameters;
	this->_statements = statements;
}
FunctionDeclarationNode::~FunctionDeclarationNode(){}

FunctionCallNode::FunctionCallNode(const IdNode* name, const std::deque<const TreeNode*>* parameters) {
	this->_name = name->_name;
	this->_parameters = parameters;
}
FunctionCallNode::FunctionCallNode(const std::deque<const TreeNode*>* parameters) {
	this->_parameters = parameters;	
}
FunctionCallNode::~FunctionCallNode(){}

StructNode::StructNode(const char* name, const std::deque<const VariableNode*>& variables) {
	this-> _name = name;
	this->_variables = variables;
}
StructNode::~StructNode(){}

AccessNode::AccessNode(){}
AccessNode::~AccessNode(){}
AccessNode* AccessNode::set_child(const AccessNode* acsNode) {
	this->_name = acsNode->_name;
	return this;
}

IdNode::IdNode(const char* name) {
	this->_name = name;
}
IdNode::~IdNode(){}

ArrayAccessNode::ArrayAccessNode(const IdNode* idArray, const TreeNode* idxExpression) {
	this->_name = idArray->_name;
	this->_index_expression = idxExpression;
}
ArrayAccessNode::ArrayAccessNode(const TreeNode* idxExpression) {
	this->_index_expression = idxExpression;
}
ArrayAccessNode::~ArrayAccessNode(){}

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
