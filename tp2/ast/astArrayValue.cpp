#include "astArrayValue.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

void ASTArrayValue::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTArrayValue\n", 4*indent, "");

    if (offset != NULL)
    {
    	offset->show(indent+1);
    }
}

void ASTArrayValue::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	fprintf(fout, "\t\tlaload %s\n", name.c_str());
	offset->generateLSM(fout);
	if(type==ASTNode::FLOAT)
		fprintf(fout, "\t\tfaload\n");
	else if(type==ASTNode::INT)
		fprintf(fout, "\t\tiaload\n");
	else if(type==ASTNode::BYTE)
		fprintf(fout, "\t\tbaload\n");
}

////////////////////////////////////////////////////
