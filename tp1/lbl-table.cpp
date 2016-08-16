#include "lbl-table.h"
#include <math.h>
#include <stdio.h>
#include <string>

using namespace std;

int LabelTable::checkExists(const char* label){
	return table.end() != table.find(string(label));
}

void LabelTable::add(const char* label, Label *l){
	if(checkExists(label))
    	table.erase(table.find(string(label)));
    last = l;
    table.insert(pair<string,Label*>(string(label),l));
}

uint16_t LabelTable::getAddress(const char* label){
	if(!checkExists(label)) return 0;
    	return table.find(string(label))->second->address;
}

Type LabelTable::getType(const char* label){
	return table.find(string(label))->second->t;
}

Label* LabelTable::getLast(){
	return last;
}
