#ifndef __S16_AST_ASSIGN_TO_ARRAY__
#define __S16_AST_ASSIGN_TO_ARRAY__

#include "astValue.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

/** \brief A node representing an assignment to an array var
 */
class ASTAssignToArray : public ASTValue
{
private:
    std::string name;    ///< the target var
    ASTValue* value;       ///< the value
    ASTValue* idx;

public:
    ASTAssignToArray(const char* n, int t, ASTValue* i, ASTValue* val)
        : name(n), value(val), idx(i) { type = t; }

    ~ASTAssignToArray() {}

    /** show AST tree */
    void show(uint32_t indent);

    /** Generate LSM code */
    void generateLSM(FILE* fout);
};

////////////////////////////////////////////////////

#endif

