#ifndef SYNTAX_TREE_H
#define SYNTAX_TREE_H

#include <list>

#include "TreeNode.h"

class SyntaxTree
{
	public:
		SyntaxTree();
		virtual ~SyntaxTree();

		void insert_node(TreeNode* node);

	private:
		std::list<TreeNode*> _nodes; //Will contain function definitions, struct definitions and the main only
};

#endif /* SYNTAX_TREE_H */
