#include "astEndProcedure.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTEndProcedure::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTEndProcedure\n", 4*indent, "");
}

void ASTEndProcedure::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	fprintf(fout, "\t\tret\n");
}

////////////////////////////////////////////////////
