#ifndef __S16_AST_BYTE_DECL__
#define __S16_AST_BYTE_DECL__

#include "astValue.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

/** \brief A node representing a BYTE declaration
 */
class ASTByteDecl : public ASTNode
{
private:
    std::string name;   ///< the name of the variable
    ASTValue* value;      ///< its initial value

public:
    ASTByteDecl(const char* n, ASTValue* v) 
        : name(n), value(v) {}

    ~ASTByteDecl() {}

    /** show AST tree */
    void show(uint32_t indent);

    /** Generate LSM code */
    void generateLSM(FILE* fout);
};

////////////////////////////////////////////////////

#endif
