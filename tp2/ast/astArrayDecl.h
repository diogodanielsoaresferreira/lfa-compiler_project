#ifndef __S16_AST_ARRAY_DECL__
#define __S16_AST_ARRAY_DECL__

#include "astValue.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

/** \brief A node representing an Array declaration
 */
class ASTArrayDecl : public ASTNode
{
private:
	int type;
    std::string name;   ///< the name of the variable
    ASTValue* value;      ///< its initial value
    int length;

public:
    ASTArrayDecl(int t, const char* n, ASTValue* v, int l) 
        : type(t), name(n), value(v), length(l) {}

    ~ASTArrayDecl() {}

    /** show AST tree */
    void show(uint32_t indent);

    /** Generate LSM code */
    void generateLSM(FILE* fout);
};

////////////////////////////////////////////////////

#endif
