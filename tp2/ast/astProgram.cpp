#include "astProgram.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTProgram::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTProgram:\n", 4*indent, "");
    indent++;
    program->show(indent);
}

void ASTProgram::generateLSM(FILE* fout)
{
	ASTNode::cur_segm = ASTNode::TEXT;
	fprintf(fout, "\n\t.text\n");
	fprintf(fout,"\n%s:\n",name.c_str());
	if(program!=NULL)
		program->generateLSM(fout);
}

////////////////////////////////////////////////////
