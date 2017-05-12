#ifndef TREENODE_H
#define TREENODE_H

#include <list>
#include <string>

class TreeNode
{
	TreeNode();
	virtual ~TreeNode();
};

class VariableNode : public TreeNode {
	public:
		VariableNode(std::string name);
		~VariableNode();

	private:
		std::string _name;
};

class TypeNode : public TreeNode {
	public:
		TypeNode(std::string type);
		~TypeNode();
	private:
		std::string _type;
};

class LiteralNode : public TreeNode {
	public:
		LiteralNode(std::string type, std::string value);
		~LiteralNode();
	private:
		std::string _type;
		std::string _value;
};

enum Operator {
	PLUS, MINUS, MULTIPLICATION, DIVISION, MOD, AND, OR, ATTRIBUTION, EQUAL, NOT_EQUAL, GREATER, LESS, GREATER_EQ, LESS_EQ
};

class OperatorNode : public TreeNode {
	public:
		OperatorNode(Operator op);
		~OperatorNode();
	private:
		Operator _operator;
};

class FunctionDeclarationNode : public TreeNode {
	public:
		FunctionDeclarationNode(std::string name, std::string return_type, std::list<std::string> parameters);
		~FunctionDeclarationNode();
	private:
		std::string _name;
		std::string _return_type;
		std::list<std::string> _parameters;
};

class FunctionCallNode : public TreeNode {
	public:
		FunctionCallNode(std::string name);
		~FunctionCallNode();
	private:
		std::string _name;
};

class StructNode : public TreeNode {
	public:
		StructNode(std::string name);
		~StructNode();
	private:
		std::string _name;
};

enum reservedWord {
	RETURN, FOR, WHILE, IF, ELSE, BREAK
};

class ReservedWordNode : public TreeNode {
	public:
		ReservedWordNode(reservedWord word);
		~ReservedWordNode();
	private:
		reservedWord _word;
};

#endif /* TREENODE_H */
