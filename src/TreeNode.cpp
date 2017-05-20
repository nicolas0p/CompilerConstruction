#include "TreeNode.h"

TreeNode::TreeNode(){}

VariableNode::VariableNode(const char* type, const char* name){}
VariableNode::~VariableNode(){}

TypeNode::TypeNode(const char* type){}
TypeNode::~TypeNode(){}

LiteralNode::LiteralNode(const char* type, const char* value){}
LiteralNode::~LiteralNode(){}

OperatorNode::OperatorNode(const Operator& op){}
OperatorNode::~OperatorNode(){}

FunctionDeclarationNode::FunctionDeclarationNode(const char* name, const char* return_type, const std::list<const VariableNode*>& parameters){}
FunctionDeclarationNode::~FunctionDeclarationNode(){}

FunctionCallNode::FunctionCallNode(const char* name, const std::list<const VariableNode*>& parameters){}
FunctionCallNode::~FunctionCallNode(){}

StructNode::StructNode(const char* name){}
StructNode::~StructNode(){}

ReservedWordNode::ReservedWordNode(const reservedWord& word){}
ReservedWordNode::~ReservedWordNode(){}
