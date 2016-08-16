#ifndef __S16_AST_NODE__
#define __S16_AST_NODE__

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

/** \brief The base class for all AST nodes */
class ASTNode
{
public:
    enum { TEXT, DATA };

    enum { NONE=0, STRING, INT, FLOAT, 
        INTARRAY, BYTEARRAY, FLOATARRAY,
        PROGRAM, BYTE, BOOLEAN };

    enum { EQ, NE, LE, LT, GE, GT };

    enum { ADD, SUB, MUL, DIV, REM, NEG, AND, OR, XOR, NOT, BAND, BOR, BXOR, BSL, BSR, BNOT };

    enum { READCHAR, READINT };

    enum { PRINTCHAR, PRINTINT };

    static int cur_segm;

public:
    ASTNode() {}
    virtual ~ASTNode() {}

    /** show AST tree */
    virtual void show(uint32_t indent) = 0;

    /** Generate code for an if-then-else instruction */
    virtual void generateLSM(FILE* fout) = 0;
};

////////////////////////////////////////////////////

#endif
