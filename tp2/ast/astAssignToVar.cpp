#include "astAssignToVar.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

void ASTAssignToVar::show(uint32_t indent){
    fprintf(stdout, ";%*s ASTAssignToVar\n", 4*indent, "");

    if (value != NULL)
    {
    	 value->show(indent+1);
    }

}

void ASTAssignToVar::generateLSM(FILE* fout){
	if(ASTNode::cur_segm!=ASTNode::TEXT){
        ASTNode::cur_segm = ASTNode::TEXT;
        fprintf(fout, "\n\t.text\n");
    }
	fprintf(fout, "\t\tlaload %s\n",name.c_str());
	fprintf(fout, "\t\tbipush 0\n");
	value->generateLSM(fout);
	fprintf(fout, "\t\tiastore\n");
}

////////////////////////////////////////////////////
