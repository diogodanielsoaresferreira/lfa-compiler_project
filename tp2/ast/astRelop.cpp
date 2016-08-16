#include "astRelop.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

int ASTRelop::gcnt = 0;

void ASTRelop::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTRelop\n", 4*indent, "");
    indent++;
    left->show(indent);
    right->show(indent);
}

void ASTRelop::generateLSM(FILE* fout)
{
	left->generateLSM(fout);
	right->generateLSM(fout);
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	if((right->getType()==2 && left->getType()==2) || (right->getType()==ASTNode::BYTE && left->getType()==ASTNode::BYTE))
		fprintf(fout,"\t\tisub\n");
	else
		fprintf(fout,"\t\tfcmpg\n");

	switch(op){
		case EQ:
			fprintf(fout,"\t\tifeq true_%03d\n",cnt);
			fprintf(fout,"\t\tgoto false_%03d\n",cnt);
			break;
		case NE:
			fprintf(fout,"\t\tifne true_%03d\n",cnt);
			fprintf(fout,"\t\tgoto false_%03d\n",cnt);
			break;
		case LT:
			fprintf(fout,"\t\tiflt true_%03d\n",cnt);
			fprintf(fout,"\t\tgoto false_%03d\n",cnt);
			break;
		case LE:
			fprintf(fout,"\t\tifle true_%03d\n",cnt);
			fprintf(fout,"\t\tgoto false_%03d\n",cnt);
			break;
		case GT:
			fprintf(fout,"\t\tifgt true_%03d\n",cnt);
			fprintf(fout,"\t\tgoto false_%03d\n",cnt);
			break;
		case GE:
			fprintf(fout,"\t\tifge true_%03d\n",cnt);
			fprintf(fout,"\t\tgoto false_%03d\n",cnt);
			break;
	}
	fprintf(fout,"\ntrue_%03d:\n\t\tipush 1\n\t\tgoto end_relop_%03d\n",cnt, cnt);
	fprintf(fout,"\nfalse_%03d:\n\t\tipush 0\n",cnt);
	fprintf(fout, "\nend_relop_%03d:\n", cnt);
}

////////////////////////////////////////////////////
