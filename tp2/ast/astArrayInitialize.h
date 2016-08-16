#ifndef __S16_AST_ARRAY_INIT__
#define __S16_AST_ARRAY_INIT__

#include "astValue.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

/** \brief A node representing an Array initialization
 */
class ASTArrayInit : public ASTValue
{
private:
	int type;
    float val;
    ASTValue *next;

public:
    ASTArrayInit(int t, float v, ASTValue *n) 
        : type(t), val(v), next(n) {}

    ~ASTArrayInit() {}

    /** show AST tree */
    void show(uint32_t indent);

    /** Generate LSM code */
    void generateLSM(FILE* fout);
};

////////////////////////////////////////////////////

#endif
