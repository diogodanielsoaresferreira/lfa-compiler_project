#include "symtable.h"

#include <stdio.h>

using namespace std;

bool SymTable::add(const char* key, int type)
{
    if(table.end() != table.find(string(key)))
    	return false;
    if(last!=NULL && last->checkExists(key, type))
        return false;
    table.insert(pair<string,int>(string(key),type));
    return true;
}

bool SymTable::checkExists(const char* key, int type)
{
    if(table.end() != table.find(string(key)))
        return true;
    if(last!=NULL)
        return last->checkExists(key, type);
    return false;
}


bool SymTable::getType(const char* key, int* p_type)
{
    if(table.end() == table.find(string(key))){
        if(last==NULL){
    	   *p_type = NONE;
    	   return false;
        }
        return last->getType(key, p_type);
    }

    *p_type = table.find(string(key))->second;

    return true;
}

