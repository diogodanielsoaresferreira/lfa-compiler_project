#ifndef __S16_AST_BYTE_VALUE__
#define __S16_AST_BYTE_VALUE__

#include "astValue.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

/** \brief A node representing a byte numeric constant */
class ASTByteValue : public ASTValue
{
private:
    int8_t value;

public:
    ASTByteValue(int8_t v)
        : value(v) { type = INT; }

    ~ASTByteValue() {}
    
    /** show AST tree */
    void show(uint32_t indent);

    /** Generate LSM code */
    void generateLSM(FILE* fout);
};

////////////////////////////////////////////////////

#endif
