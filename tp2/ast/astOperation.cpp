#include "astOperation.h"

#include <stdint.h>
#include <stdio.h>

////////////////////////////////////////////////////

void ASTOperation::show(uint32_t indent)
{
    fprintf(stdout, ";%*s ASTOperation\n", 4*indent, "");
    indent++;
    left->show(indent);
    if(right!=NULL)
    	right->show(indent);
}

void ASTOperation::generateLSM(FILE* fout)
{
	left->generateLSM(fout);
	if(right!=NULL){
  		right->generateLSM(fout);
	}
	if(ASTNode::cur_segm!=ASTNode::TEXT){
		ASTNode::cur_segm = ASTNode::TEXT;
		fprintf(fout, "\n\t.text\n");
	}
  	switch(op){
	    case ADD: if(left->getType()==3 && right->getType()==3)
	              	fprintf(fout,"\t\tfadd\n");
	          	  else
	          	  	fprintf(fout, "\t\tiadd\n");
	              break;
	    case SUB: if(left->getType()==3 && right->getType()==3)
	              	fprintf(fout,"\t\tfsub\n");
	              else
	              	fprintf(fout,"\t\tisub\n");
	              break;
	    case MUL: if(left->getType()==3 && right->getType()==3)
	              	fprintf(fout,"\t\tfmul\n");
	              else
	              	fprintf(fout,"\t\timul\n");
	              break;
	    case DIV: if(left->getType()==3 && right->getType()==3)
	              	fprintf(fout,"\t\tfdiv\n");
	              else
	              	fprintf(fout,"\t\tidiv\n");
	              break;
	    case REM: if(left->getType()==3 && right->getType()==3)
	              	fprintf(fout,"\t\tfrem\n");
	              else
	              	fprintf(fout,"\t\tirem\n");
	              break;
	    case OR:  	fprintf(fout,"\t\tior\n");
	    		  break;
	    case XOR: 	fprintf(fout,"\t\tixor\n");
	    		  break;
	    case AND: 	fprintf(fout,"\t\tiand\n");
	    		  break;
	    case NOT: 	fprintf(fout,"\t\tipush 1\n\t\tixor\n");
	    		  break;
	    case BAND:
	    		  	fprintf(fout, "\t\tiand\n");
	    		  break;
	   	case BOR:
	   			  	fprintf(fout, "\t\tior\n");
	    		  break;
	    case BXOR:
	    	   	  	fprintf(fout, "\t\tixor\n");
	    		  break;
	    case BSL:
	    		  	fprintf(fout, "\t\tishl\n");
	    		  break;
	    case BSR:
	    		  	fprintf(fout, "\t\tishr\n");
	    		  break;
	    case BNOT:
	    		  	fprintf(fout, "\t\tipush 0xFFFFFFFFFFFFFFFF\n");
	    		  	fprintf(fout, "\t\tixor\n");
	    		  break;
  	}
}

////////////////////////////////////////////////////
