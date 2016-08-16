#ifndef __S16_AST_STRING_VALUE__
#define __S16_AST_STRING_VALUE__

#include "astValue.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

/** \brief A node representing a string */
class ASTStringValue : public ASTValue
{
private:
    std::string value;
    
public:
    ASTStringValue(const char* vz) : value(vz)
    { type = STRING; }

    ~ASTStringValue() {}
    
    /** show AST tree */
    void show(uint32_t indent);

    /** Generate LSM code */
    void generateLSM(FILE* fout);

    std::string getS();
};

////////////////////////////////////////////////////

#endif
