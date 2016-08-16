#ifndef __S16_AST_SEQ_VALUE__
#define __S16_AST_SEQ_VALUE__

#include "astValue.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

/** \brief A node representing a sequence of nodes
 */
class ASTSeqValue : public ASTValue
{
private:
    ASTValue *head, *tail;

public:
    ASTSeqValue(ASTValue* h, ASTValue* t)
        : head(h), tail(t) {}

    ~ASTSeqValue() {}

    /** show AST tree */
    void show(uint32_t indent);

    /** Generate LSM code */
    void generateLSM(FILE* fout);
};

////////////////////////////////////////////////////

#endif
