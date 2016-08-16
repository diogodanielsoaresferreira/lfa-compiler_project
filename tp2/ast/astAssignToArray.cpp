#include "astAssignToArray.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

void ASTAssignToArray::show(uint32_t indent){
    fprintf(stdout, ";%*s ASTAssignToArray\n", 4*indent, "");
    indent++;

    if (value != NULL)
    {
    	value->show(indent);
    }
    if (idx != NULL)
    {
    	idx->show(indent);
    }
}

void ASTAssignToArray::generateLSM(FILE* fout){
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	fprintf(fout, "\t\tlaload %s\n", name.c_str());
	idx->generateLSM(fout);
	value->generateLSM(fout);
	if(type==ASTNode::FLOAT)
		fprintf(fout, "\t\tfastore\n");
	else if(type==ASTNode::INT)
		fprintf(fout, "\t\tiastore\n");
	else if(type==ASTNode::BYTE)
		fprintf(fout, "\t\tbastore\n");
}

////////////////////////////////////////////////////
