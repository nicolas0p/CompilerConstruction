#ifndef TREENODE_H
#define TREENODE_H

#include <deque>
#include <string>

class TreeNode
{
	public:
		TreeNode();
		virtual ~TreeNode();
		
		enum Operator {
			PLUS, MINUS, TIMES, DIVIDE, MOD, AND, OR, ATTRIBUTION, EQUAL, NOT_EQUAL, GREATER, LESS, GREATER_EQ, LESS_EQ
		};

		enum UnaryOperator {
			NOT, UN_PLUS, UN_MINUS
		};

		enum ReservedWord {
			RETURN, FOR, WHILE, IF, ELSE, BREAK
		};
};

class VariableNode : public TreeNode {
	public:
		VariableNode(const char* type, const char* name);
		~VariableNode();

        std::string name() const {return std::string{_name};};
        std::string type() const {return std::string{_type};};

	private:
		std::string _type;
		std::string _name;
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
		LiteralNode(const char* type, bool value);
		LiteralNode(const char* type, int value);
		LiteralNode(const char* type, float value);
		~LiteralNode();
	private:
		std::string _type;
		std::string _s_value;
		bool _b_value;
		int _i_value;
		float _f_value;
};

class OperatorNode : public TreeNode {
	public:
		OperatorNode(const Operator& op);
		~OperatorNode();

		OperatorNode* set_children(const TreeNode* node1, const TreeNode* node2);
		OperatorNode* set_left_child(const TreeNode* node);
		OperatorNode* set_right_child(const TreeNode* node);
	private:
		Operator _operator;
		const TreeNode* _left;
		const TreeNode* _right;
};

class UnaryOperatorNode : public TreeNode {
	public:
		UnaryOperatorNode(const UnaryOperator& op);
		~UnaryOperatorNode();

		UnaryOperatorNode* set_child(const TreeNode* node);
	private:
		UnaryOperator _operator;
		const TreeNode* _child;
};

class FunctionDeclarationNode : public TreeNode {
	public:
		FunctionDeclarationNode(const char* name, const char* return_type, const std::deque<const VariableNode*>& parameters, const std::deque<const TreeNode*>* statements);
		~FunctionDeclarationNode();

	private:
		std::string _name;
		std::string _return_type;
		std::deque<const VariableNode*> _parameters;
		const std::deque<const TreeNode*>* _statements;
};

class StructNode : public TreeNode {
	public:
		StructNode(const char* name, const std::deque<const VariableNode*>& variables);
		~StructNode();
	private:
		std::string _name;
		std::deque<const VariableNode*> _variables;
};

class AccessNode : public TreeNode {
	public:
		AccessNode();
		virtual ~AccessNode();

		AccessNode* set_child(const AccessNode* name);
		std::string _name;	
};

class IdNode : public AccessNode {
	public:
		IdNode(const char* name);
		~IdNode();
};

class FunctionCallNode : public AccessNode {
	public:
		FunctionCallNode(const IdNode* name, const std::deque<const TreeNode*>* parameters);
		FunctionCallNode(const std::deque<const TreeNode*>* parameters);
		~FunctionCallNode();

	private:
		const std::deque<const TreeNode*>* _parameters;
};

class ArrayAccessNode : public AccessNode {
	public:
		ArrayAccessNode(const IdNode* idArray, const TreeNode* idxExpression);
		ArrayAccessNode(const TreeNode* idxExpression);
		~ArrayAccessNode();

	private:
		const TreeNode* _index_expression;
};

class ReservedWordNode : public TreeNode {
	public:
		ReservedWordNode(const ReservedWord& word);
		~ReservedWordNode();

		ReservedWordNode* insert_child(const TreeNode*);
		ReservedWordNode* insert_child(std::deque<const TreeNode*>*);
	private:
		ReservedWord _word;
		std::deque<const TreeNode*> _nodes;
};

#endif /* TREENODE_H */
