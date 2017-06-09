#include "../include/TreeNode.h"
#include "../include/SymbolTable.h"

extern std::deque<std::pair<int, std::string>> error_list;
extern int yylineno;

TreeNode::TreeNode(){}
TreeNode::~TreeNode(){}

//Standard definition for all nodes. Will be overridden by the needed nodes
std::string TreeNode::type(SymbolTable* symT) const {
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
std::string BinaryOperatorNode::type(SymbolTable* symT) const {
	if (_left->type(symT) == _right->type(symT)) {
		return _left->type(symT);
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
std::string UnaryOperatorNode::type(SymbolTable* symT) const {
	return _left->type(symT);
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
	return this;
}
AccessOperatorNode* AccessOperatorNode::set_left_child(const AccessOperatorNode* node) {
	this->_left = node;
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
std::string AccessOperatorNode::type(SymbolTable* symT) const {
	switch(this->_operator) {
		case TreeNode::ID :
			return this->_left->type(symT);
			break;
		case TreeNode::ARRAY :
			if (this->_leftLeaf) {
				if(!symT->isArray(this->_leftId)) {
					error_list.push_back(std::pair<int, std::string>(yylineno, "Variable \"" + this->_leftId + "\" is not an array."));
					return "error";
				}
				return symT->findVariable(this->_leftId)->varType;
			} else {
				auto type = this->_left->type(symT);
				if (symT->find(type) == SymbolTable::VARIABLE /*&& symT->findVariable(type).isArray()*/) {
					return symT->findStructure(type)->find_member(this->_rightId);
				}
			}
			break;
		case TreeNode::STRUCT : {
			auto struct_type = this->_leftLeaf ? symT->findVariable(this->_leftId)->varType : this->_left->type(symT);
			auto struc = symT->findStructure(struct_type);
			if(struc == nullptr) {
				auto erromsg = this->_leftLeaf ? "Variable \"" + this->_leftId + "\" is not a struct." : "Invalid access to a non Struct.";
				error_list.push_back(std::pair<int, std::string>(yylineno, erromsg));
				return "error";
			}
			auto typeMember = struc->find_member(this->_rightId);
			if(typeMember == "") {
				error_list.push_back(std::pair<int, std::string>(yylineno, "\"" + this->_rightId + "\" is not a member of \"" + struct_type + "\"."));
				return "error";
			}
			return typeMember;
			break;
		}
		case TreeNode::CALL :
			if (this->_leftLeaf) {
				return symT->findFunction(this->_leftId)->returnType;
			} else {
				error_list.push_back(std::pair<int, std::string>(yylineno, "Identifier \"" + this->_leftId + "\" is not a function."));
				return "error";
			}
			break;
	}
	return "error";
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
std::string IdNode::type(SymbolTable* symT) const {
	return symT->findVariable(this->_name)->varType;
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
