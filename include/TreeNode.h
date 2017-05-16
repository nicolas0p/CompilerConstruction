#ifndef TREENODE_H
#define TREENODE_H

#include <list>
#include <string>

class TreeNode
{
	public:
		TreeNode();
		virtual ~TreeNode(){};
enum Operator {
	PLUS, MINUS, MULTIPLICATION, DIVISION, MOD, AND, OR, ATTRIBUTION, EQUAL, NOT_EQUAL, GREATER, LESS, GREATER_EQ, LESS_EQ};

enum reservedWord {
	RETURN, FOR, WHILE, IF, ELSE, BREAK};
};

class VariableNode : public TreeNode {
	public:
		VariableNode(const char* type, const char* name);
		~VariableNode();

	private:
		std::string _name;
		std::string _type;
};

class TypeNode : public TreeNode {
	public:
		TypeNode(const char* type);
		~TypeNode();
	private:
		std::string _type;
};

class LiteralNode : public TreeNode {
	public:
		LiteralNode(const char* type, const char* value);
		~LiteralNode();
	private:
		std::string _type;
		std::string _value;
};

class OperatorNode : public TreeNode {
	public:
		OperatorNode(const Operator& op);
		~OperatorNode();
	private:
		Operator _operator;
};

class FunctionDeclarationNode : public TreeNode {
	public:
		FunctionDeclarationNode(const char* name, const char* return_type, const std::list<VariableNode*>& parameters);
		~FunctionDeclarationNode();
	private:
		std::string _name;
		std::string _return_type;
		std::list<std::string> _parameters;
};

class FunctionCallNode : public TreeNode {
	public:
		FunctionCallNode(const char* name);
		~FunctionCallNode();
	private:
		std::string _name;
};

class StructNode : public TreeNode {
	public:
		StructNode(const char* name);
		~StructNode();
	private:
		std::string _name;
};

class ReservedWordNode : public TreeNode {
	public:
		ReservedWordNode(const reservedWord& word);
		~ReservedWordNode();
	private:
		reservedWord _word;
};

#endif /* TREENODE_H */
