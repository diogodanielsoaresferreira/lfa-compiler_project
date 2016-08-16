#include "astArrayDecl.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTArrayDecl::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTArrayDecl\n", 4*indent, "");

	if (value != NULL)
	{
		value->show(indent+1);
	}
}

void ASTArrayDecl::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::DATA){
		ASTNode::cur_segm = ASTNode::DATA;
		fprintf(fout, "\n\t.data\n");
	}
	if(value==NULL)
		fprintf(fout, "%s:\t.space %d\n", name.c_str(), length);
	else if(type==ASTNode::INTARRAY || type==ASTNode::BYTEARRAY){
		fprintf(fout, "%s:\t.word ", name.c_str());
		value->generateLSM(fout);
		fprintf(fout, "\n");
	}
	else if(type==ASTNode::FLOATARRAY){
		fprintf(fout, "%s:\t.float ", name.c_str());
		value->generateLSM(fout);
		fprintf(fout, "\n");
	}
}

////////////////////////////////////////////////////
