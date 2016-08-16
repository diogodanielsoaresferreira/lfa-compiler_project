#include "astIf.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

int ASTIf::gcnt = 0;

void ASTIf::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTIf\n", 4*indent, "");
    indent++;
    cond->show(indent);
    if(then_block!=NULL) then_block->show(indent);
    if (else_block) else_block->show(indent);
}

void ASTIf::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	fprintf(fout, "\nif_%03d:\n", cnt);
	cond->generateLSM(fout);

	if(else_block == NULL)
		fprintf(fout, "\t\tifeq endif_%03d\n", cnt);
	else
		fprintf(fout, "\t\tifeq else_%03d\n", cnt);
	
	if(then_block!=NULL)
		then_block->generateLSM(fout);
	if(else_block!=NULL){
		fprintf(fout, "\t\tgoto endif_%03d\n", cnt);
		fprintf(fout, "\nelse_%03d:\n", cnt);
		else_block->generateLSM(fout);
	}
	fprintf(fout, "\nendif_%03d:\n", cnt);

}

////////////////////////////////////////////////////
