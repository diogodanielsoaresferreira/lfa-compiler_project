#include "astArrayInitialize.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTArrayInit::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTArrayInit\n", 4*indent, "");

    if (next!=NULL)
    {
    	next->show(indent+1);
    }
}

void ASTArrayInit::generateLSM(FILE* fout)
{	
	if(next!=NULL){
		next->generateLSM(fout);
		fprintf(fout, ", ");
	}
	if(type==ASTNode::FLOATARRAY)
		fprintf(fout, "%f", val);
	else if(type==ASTNode::INTARRAY || type == ASTNode::BYTEARRAY)
		fprintf(fout, "%d", (int)val);
	
}

////////////////////////////////////////////////////
