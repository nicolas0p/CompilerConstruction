#include "SymbolTable.h"

SymbolTable::SymbolTable()
{
    this->openScope();
}

bool SymbolTable::addStructure(structure s)
{
    return scopeTables.front().addStructure(s);
}

bool SymbolTable::addFunction(function f)
{
    return scopeTables.front().addFunction(f);
}

bool SymbolTable::addVariable(variable v)
{
    return scopeTables.front().addVariable(v);
}

bool SymbolTable::isArray(std::string name)
{
	variable *var = this->findVariable(name);
	if(var == nullptr) {
		return false;
	}
	return var->varType.find('[') && var->varType.find(']');
}

structure* SymbolTable::findStructure(std::string name)
{
    std::deque<ScopeSymbolTable>::iterator it = scopeTables.begin();

    while (it != scopeTables.end()) {
        structure* struc = it->findStructure(name);
        if (struc) {
            return struc;
        } else {
            ++it;
        }
    }

    return nullptr;
}

function* SymbolTable::findFunction(std::string name)
{
    std::deque<ScopeSymbolTable>::iterator it = scopeTables.begin();

    while (it != scopeTables.end()) {
        function* func = it->findFunction(name);
        if (func) {
            return func;
        } else {
            ++it;
        }
    }

    return nullptr;
}

variable* SymbolTable::findVariable(std::string name)
{
    std::deque<ScopeSymbolTable>::iterator it = scopeTables.begin();

    while (it != scopeTables.end()) {
        variable* var = it->findVariable(name);
        if (var) {
            return var;
        } else {
            ++it;
        }
    }

    return nullptr;
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

    return t == "num" || t == "char" || t == "boolean" || this->findStructure(t);
}

bool SymbolTable::returnTypeExists(type t)
{
    return typeExists(t) || t == "void";
}

void SymbolTable::openScope()
{
    scopeTables.push_front(ScopeSymbolTable());
}

void SymbolTable::closeScope()
{
    scopeTables.pop_front();
}

bool ScopeSymbolTable::addStructure(structure s)
{
    return structs.insert(std::make_pair(s._name, s)).second;
}

bool ScopeSymbolTable::addFunction(function f)
{
    return funcs.insert(std::make_pair(f.name, f)).second;
}

bool ScopeSymbolTable::addVariable(variable v)
{
    return vars.insert(std::make_pair(v.name, v)).second;
}

structure* ScopeSymbolTable::findStructure(std::string name)
{
    std::map<std::string, structure>::iterator it = structs.find(name);

    if (it != structs.end()) {
        return &(it->second);
    } else {
        return nullptr;
    }
}

function* ScopeSymbolTable::findFunction(std::string name)
{
    std::map<std::string, function>::iterator it = funcs.find(name);
    if (it != funcs.end()) {
        return &(it->second);
    } else {
        return nullptr;
    }
}

variable* ScopeSymbolTable::findVariable(std::string name)
{
    std::map<std::string, variable>::iterator it = vars.find(name);

    if (it != vars.end()) {
        return &(it->second);
    } else {
        return nullptr;
    }
}

