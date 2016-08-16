#ifndef __S16_AST_PRINT_STR__
#define __S16_AST_PRINT_STR__

#include "astNode.h"
#include "astStringValue.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

/** \brief A node representing a printStr instruction */
class ASTPrintStr : public ASTNode
{
public:
    static int gcnt;
    int cnt;
    ASTStringValue* str;
    int isId;   // If is ID, loads from data. If it's not, prints value.

public:
    ASTPrintStr(ASTStringValue* s, int isid) : str(s), isId(isid)
    {
        gcnt++;
        cnt = gcnt;
    }

    ~ASTPrintStr() {}
    
    /** show AST tree */
    void show(uint32_t indent);

    /** Generate LSM code */
    void generateLSM(FILE* fout);
};

////////////////////////////////////////////////////

#endif
