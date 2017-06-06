#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include <map>
#include <deque>
#include <string>
#include <tuple>

#include "TreeNode.h"

typedef std::string type;

struct structure {
    std::string _name;
    std::deque<std::pair<std::string, type>> _members;

    structure(std::string nm, std::deque<const VariableNode*> mmbs) : _name(nm)
    {
        for(const VariableNode* i : mmbs) {
            std::pair<std::string, type> to_add(i->name(), i->type());
            _members.push_back(to_add);
        }
    }

    std::string name(){return _name;}

    // type eh std::string, por que retornar ponteiro? - arthur
    type* find_member(std::string name)
    {
        for(auto i : _members) {
            if(i.second == name) {
                return new type(i.first); //who deletes this?
            }
        }
        return nullptr;
    }
};

struct function {
    std::string _name;
    type returnType;
    std::deque<std::pair<std::string, type>> parameters;

    function(std::string name, type ret, std::deque<const VariableNode*> params) : _name(name), returnType(ret) {
            for(const VariableNode* i : params) {
                    _parameters.push_back(std::pair<std::string, type>(i->name(), i->type()));
                    //does this preserve the order of the parameters?
            }
    }
};

struct variable {
    std::string name;
    type varType;

    variable(std::string nm, type tp) : _name(nm), varType(tp){}
};

class ScopeSymbolTable
{
public:
    bool addStructure(structure s);
    bool addFunction(function f);
    bool addVariable(variable v);

    structure* findStructure(std::string name);
    function* findFunction(std::string name);
    variable* findVariable(std::string name);

private:
    std::map<std::string, structure> structs;
    std::map<std::string, function> funcs;
    std::map<std::string, variable> vars;
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

    enum id_type{STRUCTURE, FUNCTION, VARIABLE, NONE};

    id_type find(std::string name); //returns if an ID is already defined as a struct, function or variable

    bool typeExists(type t);

    // whats the purpose of this function?
    bool returnTypeExists(type t);

    void openScope();
    void closeScope();

private:
    std::deque<ScopeSymbolTable> scopeTables;
};

#endif // SYMBOLTABLE_H
