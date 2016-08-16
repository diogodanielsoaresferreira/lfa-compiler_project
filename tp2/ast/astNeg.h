#ifndef __S16_AST_NEG
#define __S16_AST_NEG

#include "astValue.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

/** \brief A node representing a integer numeric constant */
class ASTNeg : public ASTValue
{
private:
    ASTValue* value;

public:
    ASTNeg(ASTValue* v, int t)
        : value(v) { type = t; }

    ~ASTNeg() {}
    
    /** show AST tree */
    void show(uint32_t indent);

    /** Generate LSM code */
    void generateLSM(FILE* fout);
};

////////////////////////////////////////////////////

#endif
