#include "astFloatValue.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTFloatValue::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTFloatValue\n", 4*indent, "");
}

void ASTFloatValue::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	fprintf(fout, "\t\tfpush %f\n", value);
}

////////////////////////////////////////////////////
