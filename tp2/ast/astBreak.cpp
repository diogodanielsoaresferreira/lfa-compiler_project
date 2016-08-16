#include "astBreak.h"

#include <stdint.h>
#include <stdio.h>

#include "astLoop.h"

////////////////////////////////////////////////////

void ASTBreak::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTBreak\n", indent, "");
}

void ASTBreak::generateLSM(FILE* fout){
	if(ASTLoop::cur_scope!=0){
		if(ASTNode::cur_segm!=ASTNode::TEXT){
			ASTNode::cur_segm = ASTNode::TEXT;
			fprintf(fout, "\n\t.text\n");
		}
    	fprintf(fout, "\t\tgoto loop_%03d_end\n", ASTLoop::cur_scope);
	}
}

////////////////////////////////////////////////////
