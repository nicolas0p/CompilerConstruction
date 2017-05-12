#include "SyntaxTree.h"

SyntaxTree::SyntaxTree() : _nodes{std::list<TreeNode*>()}{
}

SyntaxTree::~SyntaxTree(){}

void SyntaxTree::insertNode(TreeNode* node) {
	_nodes.push_back(node);
}
