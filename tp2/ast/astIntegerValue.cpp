#include "astIntegerValue.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTIntegerValue::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTIntegerValue\n", 4*indent, "");
}

void ASTIntegerValue::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	fprintf(fout,"\t\tipush %d\n", value);
}

////////////////////////////////////////////////////
