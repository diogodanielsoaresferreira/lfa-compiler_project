#ifndef __S16_AST_ARRAY_VALUE__
#define __S16_AST_ARRAY_VALUE__

#include "astValue.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

/** \brief A node representing an array value */
class ASTArrayValue : public ASTValue
{
private:
    std::string name;
    ASTValue* offset;

public:
    ASTArrayValue(const char* n, ASTValue *v, int t)
        : name(n), offset(v) { type = t; }

    ~ASTArrayValue() {}
    
    /** show AST tree */
    void show(uint32_t indent);

    /** Generate LSM code */
    void generateLSM(FILE* fout);
};

////////////////////////////////////////////////////

#endif
