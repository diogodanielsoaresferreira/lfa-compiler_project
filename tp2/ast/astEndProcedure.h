#ifndef __S16_AST_END_PROCEDUTE__
#define __S16_AST_END_PROCEDURE__

#include "astValue.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

/** \brief A node representing the end of a procedure call */
class ASTEndProcedure : public ASTValue
{
public:

public:
    ASTEndProcedure() { type = ASTNode::PROGRAM; }

    ~ASTEndProcedure() {}
    
    /** show AST tree */
    void show(uint32_t indent);

    /** Generate LSM code */
    void generateLSM(FILE* fout);
};

////////////////////////////////////////////////////

#endif
