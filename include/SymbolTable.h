#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <map>
#include <deque>
#include <string>
#include <tuple>

#include "TreeNode.h"

typedef std::string type;

struct structure {
    std::string name;
    std::deque<std::pair<std::string, type>> members;

    structure(std::string nm, std::deque<const VariableNode*> mmbs) : name(nm)
    {
        for(const VariableNode* i : mmbs) {
            std::pair<std::string, type> to_add(i->name(), i->type());
            members.push_back(to_add);
        }
    }
};

struct function {
    std::string name;
    type returnType;
    std::deque<std::pair<std::string, type>> parameters;
};

struct variable {
    std::string name;
    type varType;
};

enum ScopeType
{
    blockScope,
    functionScope
};

class SymbolTable
{
public:
    SymbolTable();

    bool addStructure(structure s);
    bool addFunction(function f);
    bool addVariable(variable v);

    structure* findStructure(std::string name);
    function* findFunction(std::string name);
    variable* findVariable(std::string name);

    bool typeExists(type t);

    void openBlockScope();
    void openFunctionScope();
    void closeScope();

private:
    SymbolTable(ScopeType scope);

    std::map<std::string, structure> structs;
    std::map<std::string, function> funcs;
    std::map<std::string, variable> vars;

    ScopeType scope;

    std::deque<SymbolTable> tables;
};

#endif // SYMBOLTABLE_H
