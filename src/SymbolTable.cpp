#include "SymbolTable.h"

SymbolTable::SymbolTable()
{

}

SymbolTable::SymbolTable(ScopeType scope) : scope(scope)
{

}

bool SymbolTable::addStructure(structure s)
{
    if (tables.empty()) {
        return structs.insert(std::make_pair(s._name, s)).second;
    } else {
        return tables.front().addStructure(s);
    }
}

bool SymbolTable::addFunction(function f)
{
    return funcs.insert(std::make_pair(f.name, f)).second;
}

bool SymbolTable::addVariable(variable v)
{
    if (tables.empty()) {
        return vars.insert(std::make_pair(v.name, v)).second;
    } else {
        return tables.front().addVariable(v);
    }
}

structure* SymbolTable::findStructure(std::string name)
{
    if (tables.empty()) {
        std::map<std::string, structure>::iterator it = structs.find(name);

        if (it != structs.end()) {
            return &(it->second);
        } else {
            return nullptr;
        }
    } else {
        std::deque<SymbolTable>::iterator it = tables.begin();
        while (true) {
            structure* struc = it->findStructure(name);
            if (struc) {
                return struc;
            } else if (it->scope == ScopeType::blockScope) {
                it++;
            } else {
                std::map<std::string, structure>::iterator it = structs.find(name);
                if (it != structs.end()) {
                    return &(it->second);
                } else {
                    return nullptr;
                }
            }
        }
    }
}

function* SymbolTable::findFunction(std::string name)
{
    std::map<std::string, function>::iterator it = funcs.find(name);
    if (it != funcs.end()) {
        return &(it->second);
    } else {
        return nullptr;
    }
}

variable* SymbolTable::findVariable(std::string name)
{
    if (tables.empty()) {
        std::map<std::string, variable>::iterator it = vars.find(name);

        if (it != vars.end()) {
            return &(it->second);
        } else {
            return nullptr;
        }
    } else {
        std::deque<SymbolTable>::iterator it = tables.begin();

        while (true) {
            variable* var = it->findVariable(name);
            if (var) {
                return var;
            } else if (it->scope == ScopeType::blockScope) {
                it++;
            } else {
                return nullptr;
            }
        }
    }
}

SymbolTable::id_type SymbolTable::find(std::string name)
{
    if(this->findStructure(name))
        return STRUCTURE;
    if(this->findFunction(name))
        return FUNCTION;
    if(this->findVariable(name))
        return VARIABLE;
    return NONE;
}

bool SymbolTable::typeExists(type t)
{
    t = t.substr(0, t.find_first_of('['));

    return t == "num" || t == "char" || t == "bool" || structs.count(t);
}

void SymbolTable::openBlockScope()
{
    tables.push_front(SymbolTable(ScopeType::blockScope));
}

void SymbolTable::openFunctionScope()
{
    tables.push_front(SymbolTable(ScopeType::functionScope));
}

void SymbolTable::closeScope()
{
    tables.pop_front();
}

