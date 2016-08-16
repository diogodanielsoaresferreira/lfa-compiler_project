#include "astPrint.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

int ASTPrint::gcnt = 0;

void ASTPrint::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTPrint\n", 4*indent, "");
    if(value!=NULL)
        value->show(indent+1);
}

void ASTPrint::generateLSM(FILE* fout)
{
	cnt++;
  	if(proc_id==1){ //Char
  		value->generateLSM(fout);
    	fprintf(fout, "\n\t.text\n");
    	fprintf(fout, "\t\twrite\n" );
  	}
  	else{ //Int

		fprintf(fout, "\n\t.data\n");
		fprintf(fout, "rPrintInt%03d: .space 1\n",cnt);
		fprintf(fout, "bufPrintInt%03d: .space 6\n",cnt);
		fprintf(fout, "iPrintInt%03d: .word 5\n",cnt);
		fprintf(fout, "nPrintInt%03d: .word 0\n",cnt);
		
		fprintf(fout, "\t.text\n");
		fprintf(fout, "\t\tlaload iPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tbipush 0\n");
		fprintf(fout, "\t\tipush 5\n");
		fprintf(fout, "\t\tiastore\n");
		fprintf(fout, "\t\tlaload nPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tbipush 0\n");
		fprintf(fout, "\t\tipush 0\n");
		fprintf(fout, "\t\tiastore\n");
		// 1º IF
		fprintf(fout, "ifPrintInt%03d:\n",cnt);
		value->generateLSM(fout);
		fprintf(fout, "\t\tdup\n");
		fprintf(fout, "\t\tifge elsePrintInt%03d\n",cnt);
		// Apresentar '-' e multiplicar por -1
		fprintf(fout, "\t\tipush '-'\n");
		fprintf(fout, "\t\twrite\n");
		fprintf(fout, "\t\tipush -1\n");
		fprintf(fout, "\t\timul\n");
		
		// Guardar em n
		fprintf(fout, "elsePrintInt%03d:\n",cnt);
		fprintf(fout, "\t\tstore nPrintInt%03d\n",cnt);

		// Primeiro Loop
		fprintf(fout, "loopPrintInt%03d:\n",cnt);
		// Resto
		fprintf(fout, "\t\tload nPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tipush 10\n");
		fprintf(fout, "\t\tirem\n");
		fprintf(fout, "\t\tstore rPrintInt%03d\n",cnt);
		// Guardar valor no array
		fprintf(fout, "\t\tlaload bufPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tload iPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tload rPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tiastore\n");
		// Divisão
		fprintf(fout, "\t\tload nPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tipush 10\n");
		fprintf(fout, "\t\tidiv\n");
		fprintf(fout, "\t\tdup\n");
		fprintf(fout, "\t\tstore nPrintInt%03d\n",cnt);
		// if n==0
		fprintf(fout, "\t\tifeq secondLoopPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tload iPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tipush 1\n");
		fprintf(fout, "\t\tisub\n");
		fprintf(fout, "\t\tstore iPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tgoto loopPrintInt%03d\n",cnt);

		// Segundo Loop
		fprintf(fout, "secondLoopPrintInt%03d:\n",cnt);
		fprintf(fout, "\t\tload iPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tipush 6\n");
		fprintf(fout, "\t\tisub\n");
		fprintf(fout, "\t\tifeq secondLoopPrintIntEnd%03d\n",cnt);

		// Print do array
		fprintf(fout, "\t\tlaload bufPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tload iPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tiaload\n");
		fprintf(fout, "\t\tipush '0'\n");
		fprintf(fout, "\t\tiadd\n");
		fprintf(fout, "\t\twrite\n");

		// Incremento de i
		fprintf(fout, "\t\tload iPrintInt%03d\n",cnt);
		fprintf(fout, "\t\tipush 1\n");
		fprintf(fout, "\t\tiadd\n");
		fprintf(fout, "\t\tstore iPrintInt%03d\n",cnt);

		fprintf(fout, "\t\tgoto secondLoopPrintInt%03d\n",cnt);
		fprintf(fout, "secondLoopPrintIntEnd%03d:\n",cnt);
  	}
  	ASTNode::cur_segm = ASTNode::TEXT;

}

////////////////////////////////////////////////////
