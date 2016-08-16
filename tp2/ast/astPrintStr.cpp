#include "astPrintStr.h"

#include <stdint.h>
#include <stdio.h>
#include <string>

////////////////////////////////////////////////////

int ASTPrintStr::gcnt = 0;

void ASTPrintStr::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTPrintStr\n", 4*indent, "");
    if(str!=NULL)
    	str->show(indent+1);
}

void ASTPrintStr::generateLSM(FILE* fout)
{
	if(ASTNode::cur_segm!=ASTNode::DATA){
		ASTNode::cur_segm = ASTNode::DATA;
		fprintf(fout, "\n\t.data\n");
	}
	if(!isId){
		fprintf(fout, "\nstr_%03d: .string \"%s\"\n",cnt,str->getS().c_str());
		str->generateLSM(fout);
		fprintf(fout, "\n\t.text\n");
		fprintf(fout, "\t\tlaload str_%03d\n",cnt);
	}
	else{
		fprintf(fout, "\n\t.text\n");
		fprintf(fout, "\t\tlaload %s\n",str->getS().c_str());
	}
	fprintf(fout, "\t\tsaload\n");
	fprintf(fout, "\t\twrites\n");
	ASTNode::cur_segm = ASTNode::TEXT;
}

////////////////////////////////////////////////////
