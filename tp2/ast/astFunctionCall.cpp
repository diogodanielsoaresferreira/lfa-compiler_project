#include "astFunctionCall.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

int ASTFunctionCall::cnt=0;

void ASTFunctionCall::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTFunctionCall\n", 4*indent, "");
}

void ASTFunctionCall::generateLSM(FILE* fout)
{
	ASTFunctionCall::cnt++;
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
	
	if(func_id==ASTNode::READCHAR){
		fprintf(fout, "\t\tread\n");
	}
	else if(func_id==ASTNode::READINT){

		fprintf(fout, "\t.data\n");
        fprintf(fout, "func_%03d_n:\t.word 0\n", ASTFunctionCall::cnt);
        fprintf(fout, "func_%03d_b:\t.word 0\n", ASTFunctionCall::cnt);
        fprintf(fout, "func_%03d_f:\t.word 0\n", ASTFunctionCall::cnt);
        fprintf(fout, "func_%03d_i:\t.word 0\n", ASTFunctionCall::cnt);
        fprintf(fout, "\t.text\n");
        fprintf(fout, "\t\tipush 0\n");
        fprintf(fout, "\t\tdup\n");
        fprintf(fout, "\t\tdup\n");
        fprintf(fout, "\t\tdup\n");
        fprintf(fout, "\t\tstore func_%03d_n\n", cnt);
        fprintf(fout, "\t\tstore func_%03d_b\n", cnt);
        fprintf(fout, "\t\tstore func_%03d_f\n", cnt);
        fprintf(fout, "\t\tstore func_%03d_i\n", cnt);
		fprintf(fout, "\t\tfunc_%03d_loop:\n", ASTFunctionCall::cnt);

		// Início do loop

		fprintf(fout, "\t\tlaload func_%03d_b\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tbipush 0\n");
		fprintf(fout, "\t\tread\n");
		fprintf(fout, "\t\tiastore\n");

		// 1º IF

		fprintf(fout, "\t\tload func_%03d_i\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tifne func_%03d_e1\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tload func_%03d_b\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tbipush '-'\n");
		fprintf(fout, "\t\tisub\n");
		fprintf(fout, "\t\tifne func_%03d_e1\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tlaload func_%03d_f\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tbipush 0\n");
		fprintf(fout, "\t\tbipush 1\n");
		fprintf(fout, "\t\tiastore\n");
		fprintf(fout, "\t\tgoto func_%03d_endif\n", ASTFunctionCall::cnt);

		// 2º IF
		fprintf(fout, "func_%03d_e1:\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tload func_%03d_b\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tbipush '0'\n");
		fprintf(fout, "\t\tisub\n");;
		fprintf(fout, "\t\tiflt func_%03d_loop_end\n", ASTFunctionCall::cnt);

		fprintf(fout, "\t\tload func_%03d_b\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tbipush '9'\n");
		fprintf(fout, "\t\tisub\n");
		fprintf(fout, "\t\tifgt func_%03d_loop_end\n", ASTFunctionCall::cnt);


		// 3º IF
		// Atribuição a n
		fprintf(fout, "func_%03d_att:\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tlaload func_%03d_n\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tbipush 0\n");


		// Expressão para guardar em n
		fprintf(fout, "\t\tload func_%03d_b\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tbipush '0'\n");
		fprintf(fout, "\t\tisub\n");
		fprintf(fout, "\t\tipush 10\n");
		fprintf(fout, "\t\tload func_%03d_n\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\timul\n");
		fprintf(fout, "\t\tiadd\n");

		fprintf(fout, "\t\tiastore\n");

		// Final de loop
		fprintf(fout, "func_%03d_endif:\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tlaload func_%03d_i\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tbipush 0\n");
		fprintf(fout, "\t\tbipush 1\n");
		fprintf(fout, "\t\tiastore\n");
		fprintf(fout, "\t\tgoto func_%03d_loop\n", ASTFunctionCall::cnt);
		fprintf(fout, "func_%03d_loop_end:\n", ASTFunctionCall::cnt);
		
		fprintf(fout, "\t\tload func_%03d_f\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tifeq func_%03d_end_print\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tlaload func_%03d_n\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tbipush 0\n");

		fprintf(fout, "\t\tload func_%03d_n\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tbipush -1\n");
		fprintf(fout, "\t\timul\n");

		fprintf(fout, "\t\tiastore\n");
		fprintf(fout, "func_%03d_end_print:\n", ASTFunctionCall::cnt);
		fprintf(fout, "\t\tload func_%03d_n\n", ASTFunctionCall::cnt);
	}

}

////////////////////////////////////////////////////
