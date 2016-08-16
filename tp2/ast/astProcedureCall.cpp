#include "astProcedureCall.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTProcedureCall::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTProcedureCall\n", 4*indent, "");
}

void ASTProcedureCall::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	fprintf(fout, "\t\tjsr %s\n", proc_call.c_str());

}

////////////////////////////////////////////////////
