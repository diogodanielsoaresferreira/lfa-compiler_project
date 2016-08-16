#include "astCast.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////
int ASTCast::cnt = 0;
void ASTCast::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTCast\n", indent, "");
    indent++;
    opnd->show(indent);
}

void ASTCast::generateLSM(FILE* fout)
{	cnt++;
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	opnd->generateLSM(fout);
	if(type==2){
		fprintf(fout,"\t\tf2i\n");
	}
	else if(type==3){
		fprintf(fout,"\t\ti2f\n");
	}
	else if(type==ASTNode::BYTE){
		if(opnd->getType()==ASTNode::FLOAT){
			fprintf(fout,"\t\tf2i\n");
		}
		fprintf(fout, "\t\tdup\n");
		fprintf(fout, "\t\tiflt cast_byte_neg_%03d\n", ASTCast::cnt);
		fprintf(fout, "\t\tipush 255\n");
		fprintf(fout, "\t\tiand\n");
		fprintf(fout, "\t\tgoto end_cast_byte_%03d\n", ASTCast::cnt);
		fprintf(fout, "cast_byte_neg_%03d:\n", ASTCast::cnt);
		fprintf(fout, "\t\tineg\n");
		fprintf(fout, "\t\tipush 255\n");
		fprintf(fout, "\t\tiand\n");
		fprintf(fout, "\t\tineg\n");
		fprintf(fout, "end_cast_byte_%03d:\n", ASTCast::cnt);
	}
}

////////////////////////////////////////////////////
