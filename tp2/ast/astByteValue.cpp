#include "astByteValue.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTByteValue::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTByteValue\n", 4*indent, "");
}

void ASTByteValue::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	fprintf(fout,"\t\tbipush %d\n", value);
}

////////////////////////////////////////////////////
