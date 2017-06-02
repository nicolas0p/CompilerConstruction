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

		enum AccessOperator {
			STRUCT, ARRAY, CALL, ID
		};

		enum UnaryOperator {
			NOT, UN_PLUS, UN_MINUS
		};

		enum ReservedWord {
			RETURN, FOR, WHILE, IF, ELSE, BREAK
		};

		std::string type();
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

		std::string type();
	private:
		std::string _type;
		std::string _s_value;
		bool _b_value;
		int _i_value;
		float _f_value;
};

class IdNode : public TreeNode {
	public:
		IdNode(const char* name);
		~IdNode();

		std::string _name;
};

class OperatorNode : public TreeNode {
	public:
		OperatorNode();
		~OperatorNode();

		OperatorNode* set_left_child(TreeNode* node);
		std::string type();

		bool has_left();
		const TreeNode* _left;
};

class BinaryOperatorNode : public OperatorNode {
	public:
		BinaryOperatorNode(const Operator& op);
		~BinaryOperatorNode();

		std::string type();

		BinaryOperatorNode* set_children(const TreeNode* node1, const TreeNode* node2);
		BinaryOperatorNode* set_right_child(const TreeNode* node);
	private:
		Operator _operator;
		const TreeNode* _right;
};

class UnaryOperatorNode : public OperatorNode {
	public:
		UnaryOperatorNode(const UnaryOperator& op);
		~UnaryOperatorNode();

		std::string type();

	private:
		UnaryOperator _operator;
};

class AccessOperatorNode : public OperatorNode {
	public:
		AccessOperatorNode(const AccessOperator& op);
		~AccessOperatorNode();

		AccessOperatorNode* set_left_child(const IdNode* node);
		AccessOperatorNode* set_left_child(const AccessOperatorNode* node);
		AccessOperatorNode* set_right_child(const IdNode* node);
		AccessOperatorNode* set_right_child(const TreeNode* numExpression);
		AccessOperatorNode* set_right_child(const std::deque<const TreeNode*>* parameters);

		std::string type();

		std::string id;
	private:
		AccessOperator _operator;
		const TreeNode* _right;
		const std::deque<const TreeNode*>* _parameters;
};

class CallOperatorNode : public OperatorNode {
	public:
		CallOperatorNode(const Operator& op);
		~CallOperatorNode();

		OperatorNode* set_right_child(const std::deque<const TreeNode*>* parameters);
	private:
		Operator _operator;
		const std::deque<const TreeNode*>* _parameters;
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
