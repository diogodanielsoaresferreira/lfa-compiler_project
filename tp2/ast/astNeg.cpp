#include "astNeg.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTNeg::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTNeg\n", 4*indent, "");
    if(value!=NULL)
    	value->show(indent+1);
}

void ASTNeg::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	value->generateLSM(fout);
	if(type==ASTNode::INT || type==ASTNode::BYTE)
		fprintf(fout, "\t\tineg\n");
	else if(type==ASTNode::FLOAT){
		fprintf(fout, "\t\tfpush -1\n");
		fprintf(fout, "\t\tfmul\n");
	}
}

////////////////////////////////////////////////////
