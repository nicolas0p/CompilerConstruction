#include "../include/TreeNode.h"

TreeNode::TreeNode(){}

VariableNode::VariableNode(const char* type, const char* name){}
VariableNode::~VariableNode(){}

TypeNode::TypeNode(const char* type){}
TypeNode::~TypeNode(){}

LiteralNode::LiteralNode(const char* type, const char* value){}
LiteralNode::LiteralNode(const char* type, int value){}
LiteralNode::LiteralNode(const char* type, bool value){}
LiteralNode::LiteralNode(const char* type, float value){}
LiteralNode::~LiteralNode(){}

OperatorNode::OperatorNode(const Operator& op){}
OperatorNode::~OperatorNode(){}
OperatorNode* OperatorNode::set_left_child(const TreeNode* node) { return this; }
OperatorNode* OperatorNode::set_right_child(const TreeNode* node) { return this; }
OperatorNode* OperatorNode::set_children(const TreeNode* node1, const TreeNode* node2) { return this; }

UnaryOperatorNode::UnaryOperatorNode(const UnaryOperator& op){}
UnaryOperatorNode::~UnaryOperatorNode(){}
UnaryOperatorNode* UnaryOperatorNode::set_child(const TreeNode* node) { return this; }

FunctionDeclarationNode::FunctionDeclarationNode(const char* name, const char* return_type, const std::list<const VariableNode*>& parameters){}
FunctionDeclarationNode::~FunctionDeclarationNode(){}

FunctionCallNode::FunctionCallNode(const IdNode* name, const std::list<const TreeNode*>& parameters){}
FunctionCallNode::FunctionCallNode(const std::list<const TreeNode*>* parameters){}
FunctionCallNode::~FunctionCallNode(){}
FunctionCallNode* FunctionCallNode::set_child(const IdNode* name){ return this; }

StructNode::StructNode(const char* name, const std::list<const VariableNode*>& variables){}
StructNode::~StructNode(){}

AccessNode::AccessNode(){}
AccessNode::~AccessNode(){}
AccessNode* AccessNode::set_child(const AccessNode* acsNode) { return this; }


IdNode::IdNode(const char* name){}
IdNode::~IdNode(){}
IdNode* IdNode::set_child(const AccessNode* acsNode) { return this; }

ArrayAccessNode::ArrayAccessNode(const IdNode* idArray, const TreeNode* idxExpression){}
ArrayAccessNode::ArrayAccessNode(const TreeNode* idxExpression){}
ArrayAccessNode::~ArrayAccessNode(){}
ArrayAccessNode* ArrayAccessNode::set_child(const AccessNode* acsNode) { return this; }

ReservedWordNode::ReservedWordNode(const ReservedWord& word){}
ReservedWordNode::~ReservedWordNode(){}
ReservedWordNode* ReservedWordNode::insert_child(const TreeNode* node) { return this; };
ReservedWordNode* ReservedWordNode::insert_child(std::list<const TreeNode*>* nodeList) { return this; };
