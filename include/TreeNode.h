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
			PLUS, MINUS, MULTIPLICATION, DIVISION, MOD, AND, OR, ATTRIBUTION, EQUAL, NOT_EQUAL, GREATER, LESS, GREATER_EQ, LESS_EQ
		};

		enum UnaryOperator {
			NOT, UN_PLUS, UN_MINUS
		};

		enum reservedWord {
			RETURN, FOR, WHILE, IF, ELSE, BREAK
		};
};

class TypedNode : virtual public TreeNode {
	public:
		TypedNode();
		virtual ~TypedNode();
	private:
		std::string _type;
};

class NamedNode : virtual public TreeNode {
	public:
		NamedNode();
		virtual ~NamedNode();
	private:
		std::string _name;
};

class VariableNode : public NamedNode, public TypedNode {
	public:
		VariableNode(const char* type, const char* name);
		~VariableNode();
};

class TypeNode : public TypedNode {
	public:
		TypeNode(const char* type);
		~TypeNode();
};

class IdNode : public NamedNode {
	public:
		IdNode(const char* name);
		~IdNode();
};

class LiteralNode : public TypedNode {
	public:
		LiteralNode(const char* type, const char* value);
		~LiteralNode();
	private:
		std::string _value;
};

class OperatorNode : public TreeNode {
	public:
		OperatorNode(const Operator& op);
		~OperatorNode();

		OperatorNode* set_children(TreeNode* node1, TreeNode* node2);
		OperatorNode* set_left_child(TreeNode* node);
		OperatorNode* set_right_child(TreeNode* node);
	private:
		Operator _operator;
		TreeNode* _left;
		TreeNode* _right;
};

class UnaryOperatorNode : public TreeNode {
	public:
		UnaryOperatorNode(const UnaryOperator& op);
		~UnaryOperatorNode();

		UnaryOperatorNode* set_children(TreeNode* node);
	private:
		Operator _operator;
};

class FunctionDeclarationNode : public NamedNode {
	public:
		FunctionDeclarationNode(const char* name, const char* return_type, const std::list<const VariableNode*>& parameters);
		~FunctionDeclarationNode();

		FunctionDeclarationNode* set_children(std::list<const TreeNode*>& statements);
	private:
		std::string _return_type;
		std::list<std::string> _parameters;
};

class FunctionCallNode : public NamedNode {
	public:
		FunctionCallNode(const char* name, const std::list<const VariableNode*>& parameters);
		~FunctionCallNode();
	private:
		std::list<std::string> _parameters;
};

class StructNode : public NamedNode {
	public:
		StructNode(const char* name);
		~StructNode();
};

class ReservedWordNode : public TreeNode {
	public:
		ReservedWordNode(const reservedWord& word);
		~ReservedWordNode();

		ReservedWordNode* insert_child(const TreeNode*);
		ReservedWordNode* insert_child(std::list<const TreeNode*>*);
	private:
		reservedWord _word;
		std::list<const TreeNode*> _nodes;
};

#endif /* TREENODE_H */
