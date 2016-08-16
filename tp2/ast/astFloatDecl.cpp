#include "astFloatDecl.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTFloatDecl::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTFloatValue\n", 4*indent, "");
    if(value!=NULL)
    	value->show(indent+1);

}

void ASTFloatDecl::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::DATA){
		ASTNode::cur_segm = ASTNode::DATA;
		fprintf(fout, "\n\t.data\n");
	}
	fprintf(fout, "\n%s:\t.space 1\n", name.c_str());
	if(value!=NULL){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
		fprintf(fout, "\t\tlaload %s\n", name.c_str());
		fprintf(fout, "\t\tbipush 0\n");
		value->generateLSM(fout);
		fprintf(fout, "\t\tfastore\n");
	}
}

////////////////////////////////////////////////////
