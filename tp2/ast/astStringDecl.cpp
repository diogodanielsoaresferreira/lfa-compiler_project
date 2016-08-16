#include "astStringDecl.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTStringDecl::show(uint32_t indent)
{
	fprintf(stdout, ";%*s ASTStringDecl\n", 4*indent, "");
}

void ASTStringDecl::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::DATA){
		ASTNode::cur_segm = ASTNode::DATA;
		fprintf(fout, "\n\t.data\n");
	}
	fprintf(fout, "\n%s:\t.string \" %s\"\n",name.c_str(), value.c_str());
}

////////////////////////////////////////////////////
