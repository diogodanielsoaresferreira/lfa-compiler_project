#include "astLoop.h"

#include <math.h>
#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

int ASTLoop::gcnt = 0;
int ASTLoop::cur_scope = 0;

void ASTLoop::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTLoop\n", 4*indent, "");
    indent++;
    loop_block->show(indent);
}

void ASTLoop::generateLSM(FILE* fout){

    prev_scope = cur_scope;
    cur_scope = cnt;
    if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	fprintf(fout, "loop_%03d:\n",cnt);
	loop_block->generateLSM(fout);
	fprintf(fout, "\t\tgoto loop_%03d\n", cnt);
	fprintf(fout, "\nloop_%03d_end:\n", cnt);
	cur_scope = prev_scope;
}

////////////////////////////////////////////////////
