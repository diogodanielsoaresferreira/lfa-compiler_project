#ifndef __S16_AST_PROCEDURE_CALL__
#define __S16_AST_FROCEDURE_CALL__

#include "astValue.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

/** \brief A node representing a procedure call */
class ASTProcedureCall : public ASTValue
{
public:
    std::string proc_call;

public:
    ASTProcedureCall(const char *proc) : proc_call(proc) { type = ASTNode::PROGRAM; }

    ~ASTProcedureCall() {}
    
    /** show AST tree */
    void show(uint32_t indent);

    /** Generate LSM code */
    void generateLSM(FILE* fout);
};

////////////////////////////////////////////////////

#endif
