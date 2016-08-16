#ifndef __LSM_LABEL_TABLE__
#define __LSM_LABEL_TABLE__

#include <map>
#include <string>
#include "label.h"

using namespace std;

class LabelTable{
public:

public:
    LabelTable() {}
    ~LabelTable() {}

    void add(const char* label, Label *l);
    int checkExists(const char* label);
    Type getType(const char* label);
    uint16_t getAddress(const char* label);
    Label* getLast();
	inline	map<string, Label*> getTable(){return table;};

private:
    map<string, Label*> table;
    Label* last;
};

#endif