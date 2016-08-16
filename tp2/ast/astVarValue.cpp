#include "astVarValue.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

void ASTVarValue::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTVarValue\n", 4*indent, "");
}

void ASTVarValue::generateLSM(FILE* fout)
{
	
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	fprintf(fout, "\t\tload %s\n",name.c_str());
}

////////////////////////////////////////////////////
