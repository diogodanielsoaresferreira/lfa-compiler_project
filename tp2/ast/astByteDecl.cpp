#include "astByteDecl.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTByteDecl::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTByteDecl\n", 4*indent, "");
    if(value!=NULL){
    	value->show(indent+1);
    }
}

void ASTByteDecl::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::DATA){
		ASTNode::cur_segm = ASTNode::DATA;
		fprintf(fout, "\n\t.data\n");
	}
	fprintf(fout, "\n%s:\t.space 1\n", name.c_str());
	if(value!=NULL){
		fprintf(fout, "\t.text\n");
		fprintf(fout, "\t\tlaload %s\n", name.c_str());
		fprintf(fout, "\t\tbipush 0\n");
		ASTNode::cur_segm = ASTNode::TEXT;
		value->generateLSM(fout);
		fprintf(fout, "\t\tbastore\n");
	}
}

////////////////////////////////////////////////////
