#include "astSeq.h"

#include <stdint.h>
#include <stdio.h>

void ASTSeq::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTSeq\n", 4*indent, "");
    indent++;
    if(head!=NULL)
    	head->show(indent);
    if(tail!=NULL)
    	tail->show(indent);
}


void ASTSeq::generateLSM(FILE* fout)
{
	if(head!=NULL)
		head->generateLSM(fout);
	if(tail!=NULL)
		tail->generateLSM(fout);
}

////////////////////////////////////////////////////
