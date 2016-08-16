#ifndef __SYMTABLE__
#define __SYMTABLE__

#include <map>
#include <string>

using namespace std;

class SymTable
{
public:
    SymTable *last;
    enum { NONE=0, STRING, INT, FLOAT, 
        INTARRAY, BYTEARRAY, FLOATARRAY,
        PROGRAM, BYTE, BOOLEAN };

    SymTable(SymTable *l) { last = l; }
    ~SymTable() {}

    bool add(const char* key, int type);
    bool getType(const char* key, int* p_type);
    bool checkExists(const char* key, int type);

private:
	
    map<string, int > table;
};

#endif
