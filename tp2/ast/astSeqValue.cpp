#include "astSeqValue.h"

#include <stdint.h>
#include <stdio.h>

void ASTSeqValue::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTSeqValue\n", 4*indent, "");
    indent++;
    if(head!=NULL)
    	head->show(indent);
    if(tail!=NULL)
    	tail->show(indent);
}


void ASTSeqValue::generateLSM(FILE* fout)
{
	if(head!=NULL)
		head->generateLSM(fout);
	if(tail!=NULL)
		tail->generateLSM(fout);
}

////////////////////////////////////////////////////
