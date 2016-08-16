#include "astSpaceDecl.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

void ASTSpaceDecl::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTSpaceDecl\n", 4*indent, "");
}

void ASTSpaceDecl::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::DATA){
		ASTNode::cur_segm = ASTNode::DATA;
		fprintf(fout, "\n\t.data\n");
	}
	fprintf(fout,"%s:\t.space %d\n",name.c_str(), size);
}

////////////////////////////////////////////////////
