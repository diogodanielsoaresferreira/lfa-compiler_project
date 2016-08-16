/*
	LFA 2016 - Grupo 3
	Projeto 2
	David Almeida, Diogo Ferreira, Francisco Cunha, José Castanheira
	Parser
*/

%code requires {
    #include <stdio.h>
    #include <stdint.h>
    #include "ast.h"
}
%code {
    #include <stdarg.h>
    #include "symtable.h"
    #include "lexer.h"
    #include "main-data.h"
    void yyerror(YYLTYPE* loc, struct MainData* p, const char*, ...);
    void yywarning(YYLTYPE* loc, struct MainData* p, const char* s, ...);
    #define scan_info p->scaninfo

    static unsigned int type;
    static char* id;

}

%error-verbose
%locations
%verbose
%define api.pure
%defines "parser.h"
%lex-param {scan_info}
%parse-param {struct MainData* p}

%expect 1

%union
{
    int32_t ivalue;
    float fvalue;
    char* svalue;
    ASTNode* node;
    ASTValue* nvalue;
    int relop;

}

%token PROGRAM PROCEDURE TINT TFLOAT TBYTE TSTRING IF ELSE LOOP BREAK EXIT RINT RCHAR PINT PSTR PCHAR LOR LAND XOR EQUAL NEQUAL LT BT LEQ BEQ ADD SUB MUL DIV MOD NOT INCREMENT DECREMENT ADDEQ SUBEQ MULEQ DIVEQ MODEQ BAND BOR BXOR BSL BSR BNOT

%token <svalue> ID
%token <ivalue> INT
%token <fvalue> REAL
%token <svalue> STRING

%type <node> outer_block di_seq
%type <node> decl inst typelist strlist inner_block block_inst func array proc assign assign_block array2
%type <svalue> stratr
%type <ivalue> attfunc
%type <nvalue> condition boolExp mulExp addExp pExp exp boolEq logicOr logicXor logicAnd not atr boolEqpar cast arrayIn pExpn pExpBor pExpXor pExpAnd pExpNot pExpSh

%%


program_file    : {p->symtable = new SymTable(NULL);}  	proc PROGRAM ID '(' ')'
							                        {	p->symtable->add($4, SymTable::PROGRAM);
							                        }
							                            outer_block
							                        {
							                            p->ast = new ASTSeq(new ASTSeq(new ASTProgram($4, $8), new ASTExit()), $2);
							                        	if (p->no_of_errors > 0) return -1;
							                        }
                ;

proc 			:	proc PROCEDURE ID '(' ')'		{
														p->symtable->add($3, SymTable::PROGRAM);
													}
														outer_block
													{	$$ = new ASTSeq($1, new ASTSeq(new ASTProgram($3,$7), new ASTEndProcedure())); }
				|									{	$$ = NULL; }
				;

outer_block     :   '{'                             {   p->symtable = new SymTable(p->symtable);
                                                    }
                            di_seq '}'              {
                                                        p->symtable = p->symtable->last;
                                                        $$ = $3;
                                                    }
                ;

di_seq          :                                   { $$ = NULL; }
                |   di_seq decl                     { $$ = new ASTSeq ($1, $2); }
                |   di_seq inst               		{ $$ = new ASTSeq ($1, $2); }
                |   di_seq error ';'                { $$ = $1; }
                |   di_seq error '}'                { $$ = $1; }
                ;

decl            :   TINT { type = SymTable::INT; } typelist ';'         { $$ = $3; }
                |   TBYTE { type = SymTable::BYTE; } typelist ';'       { $$ = $3; }
                |   TFLOAT { type = SymTable::FLOAT; } typelist   ';'	{ $$ = $3; }
                |   TSTRING { type = SymTable::STRING; } strlist ';'    { $$ = $3; }
                ;

typelist		:	typelist ',' ID atr             {
														if((p->symtable->add($3, type))==false) yyerror(&yyloc,p,"Variable has already been declared.");
														else if($4!=NULL){
															if(type == ASTNode::FLOAT){
																if($4->getType()==ASTNode::FLOAT){
																	$$ = new ASTSeq($1, new ASTFloatDecl($3, $4));
																}
																else{
																	$$ = new ASTSeq($1, new ASTFloatDecl($3, new ASTCast(ASTNode::FLOAT, $4)));
																}
															}
															else if(type == ASTNode::INT){
																if($4->getType()==ASTNode::INT || $4->getType()==ASTNode::BYTE){
																	$$ = new ASTSeq($1, new ASTIntDecl($3, $4));
																}
																else if($4->getType()==ASTNode::FLOAT){
																	yywarning(&yyloc,p,"Assigning float expression to int variable. Cast float to int.");
																	$$ = new ASTSeq($1, new ASTIntDecl($3, new ASTCast(ASTNode::INT, $4)));
																}
															}
                                                            else if(type == ASTNode::BYTE){
                                                                if($4->getType()==ASTNode::FLOAT){
                                                                    yywarning(&yyloc,p,"Assigning float expression to byte variable. Cast float to byte.");
                                                                    $$ = new ASTSeq($1, new ASTByteDecl($3, new ASTCast(ASTNode::BYTE, $4)));
                                                                }
                                                                else if($4->getType()==ASTNode::INT){
                                                                    $$ = new ASTSeq($1, new ASTByteDecl($3, new ASTCast(ASTNode::BYTE, $4)));
                                                                }
                                                            }
															else{
																printf("\n%d\n",type);
																yyerror(&yyloc,p,"Variable of wrong type assigned.");
															}
														}
														else if(type == ASTNode::FLOAT){
															$$ = new ASTSeq($1, new ASTFloatDecl($3, new ASTFloatValue(0)));
														}
														else if(type==ASTNode::INT){
															$$ = new ASTSeq($1, new ASTIntDecl($3, new ASTIntegerValue(0)));
														}
                                                        else if(type==ASTNode::BYTE){
                                                            $$ = new ASTSeq($1, new ASTByteDecl($3, new ASTByteValue(0)));
                                                        }
													}
				|	ID atr                          {
														if((p->symtable->add($1, type))==false) yyerror(&yyloc,p,"Variable has already been declared.");
														else if($2!=NULL){
															if(type == ASTNode::FLOAT){
																if($2->getType()==ASTNode::FLOAT){
																	$$ = new ASTFloatDecl($1, $2);
																}
																else{
																	$$ = new ASTFloatDecl($1, new ASTCast(ASTNode::FLOAT, $2));
																}
															}
															else if(type == ASTNode::INT){
																if($2->getType()==ASTNode::INT || $2->getType()==ASTNode::BYTE){
																	$$ = new ASTIntDecl($1, $2);
																}
																else if($2->getType()==ASTNode::FLOAT){
																	yywarning(&yyloc,p,"Assigning float expression to int variable. Cast float to int.");
																	$$ = new ASTIntDecl($1,new ASTCast(ASTNode::INT, $2));
																}
															}
                                                            else if(type == ASTNode::BYTE){
                                                                if($2->getType()==ASTNode::FLOAT){
                                                                    yywarning(&yyloc,p,"Assigning float expression to byte variable. Cast float to byte.");
                                                                    $$ = new ASTByteDecl($1, new ASTCast(ASTNode::BYTE, $2));
                                                                }
                                                                else if($2->getType()==ASTNode::INT){
                                                                    $$ = new ASTByteDecl($1, new ASTCast(ASTNode::BYTE, $2));
                                                                }
                                                            }
															else{
																yyerror(&yyloc,p,"Variable of wrong type assigned.");
															}
														}
														else if(type==ASTNode::FLOAT){
															$$ = new ASTFloatDecl($1, new ASTFloatValue(0));
														}
														else if(type==ASTNode::INT){
															$$ = new ASTIntDecl($1, new ASTIntegerValue(0));
														}
                                                        else if(type==ASTNode::BYTE){
                                                           $$ = new ASTByteDecl($1, new ASTByteValue(0));
                                                        }
													}
                |  ID 	                            {   id = $1;
                                                		if(type==ASTNode::INT) type = ASTNode::INTARRAY;
                                                		else if(type==ASTNode::FLOAT) type = ASTNode::FLOATARRAY;
                                                        else if(type==ASTNode::BYTE) type = ASTNode::BYTEARRAY;
                                                    }
                        array            			{
                                                        if((p->symtable->add($1,type))==false) yyerror(&yyloc,p,"Variable has already been declared.");
                                                        if(type==ASTNode::INTARRAY) type = ASTNode::INT;
                                                		else if(type==ASTNode::FLOATARRAY) type = ASTNode::FLOAT;
                                                        else if(type==ASTNode::BYTEARRAY) type = ASTNode::BYTE;
                                                        $$ = $3;
                                                    }
                | typelist ',' ID 	                {
                                                		id = $3;
                                                		if(type==ASTNode::INT) type = ASTNode::INTARRAY;
                                                		else if(type==ASTNode::FLOAT) type = ASTNode::FLOATARRAY;
                                                        else if(type==ASTNode::BYTE) type = ASTNode::BYTEARRAY;
                					                }
                                    array
                                                    {
                                                        if((p->symtable->add($3,type))==false) yyerror(&yyloc,p,"Variable has already been declared.");
                                                        if(type==ASTNode::INTARRAY) type = ASTNode::INT;
                                                		else if(type==ASTNode::FLOATARRAY) type = ASTNode::FLOAT;
                                                        else if(type==ASTNode::BYTEARRAY) type = ASTNode::BYTE;
                                                        $$ = new ASTSeq($1, $5);
                                                	}
                |   typelist ',' array2             {
                                                        $$ = new ASTSeq($1, $3);
                                                        if(type==ASTNode::INTARRAY) type = ASTNode::INT;
                                                        else if(type==ASTNode::FLOATARRAY) type = ASTNode::FLOAT;
                                                        else if(type==ASTNode::BYTEARRAY) type = ASTNode::BYTE;
                                                    }
                |   array2                          {
                                                        $$ = $1;
                                                        if(type==ASTNode::INTARRAY) type = ASTNode::INT;
                                                        else if(type==ASTNode::FLOATARRAY) type = ASTNode::FLOAT;
                                                        else if(type==ASTNode::BYTEARRAY) type = ASTNode::BYTE;
                                                    }
                ;

array2          :   '[' ']' ID '='                  {   id = $3;
                                                        if(type==ASTNode::INT) type = ASTNode::INTARRAY;
                                                        else if(type==ASTNode::FLOAT) type = ASTNode::FLOATARRAY;
                                                        else if(type==ASTNode::BYTE) type = ASTNode::BYTEARRAY;
                                                        if((p->symtable->add($3,type))==false) yyerror(&yyloc,p,"Variable has already been declared.");
                                                    }
                                                    '{' arrayIn '}'
                                                    {
                                                        $$ = new ASTArrayDecl(type, $3, $7, 0);
                                                    }
                |   '[' INT ']' ID                  {
                                                        if(type==ASTNode::INT) type = ASTNode::INTARRAY;
                                                        else if(type==ASTNode::FLOAT) type = ASTNode::FLOATARRAY;
                                                        else if(type==ASTNode::BYTE) type = ASTNode::BYTEARRAY;
                                                        if($2<=0)
                                                            yyerror(&yyloc,p,"Array length must be positive.");
                                                        if((p->symtable->add($4,type))==false) yyerror(&yyloc,p,"Variable has already been declared.");
                                                        $$ = new ASTArrayDecl(type, $4, NULL, $2);
                                                    }
                ;

array           :  '[' INT ']'                      {
                                                        if($2<=0)
                                                            yyerror(&yyloc,p,"Array length must be positive.");
                                                        $$ = new ASTArrayDecl(type, id, NULL, $2);
                                                    }
                |  '[' ']' '=' '{' arrayIn '}'      { $$ = new ASTArrayDecl(type, id, $5, 0); }
                ;

arrayIn         :   arrayIn ',' INT                 { $$ = new ASTArrayInit(type, (float)$3, $1); }
                |   arrayIn ',' REAL                {
                										if(type!=ASTNode::FLOATARRAY){
                											yywarning(&yyloc,p,"Variable is of wrong type. Cast to Int.");
                										}
                										$$ = new ASTArrayInit(type, $3, $1);
                									}
                |   INT                             { $$ = new ASTArrayInit(type, (float)$1, NULL); }
                |   REAL                            {
                										if(type!=ASTNode::FLOATARRAY){
                											yywarning(&yyloc,p,"Variable is of wrong type. Cast to Int.");
                										}
                										$$ = new ASTArrayInit(type, $1, NULL);
                									}
                ;

strlist			:	strlist ',' ID stratr           {
														if((p->symtable->add($3, type))==false) yyerror(&yyloc,p,"Variable has already been declared.");
														else if(type==ASTNode::STRING){
                                                            if($4==NULL)
                                                                $$ = new ASTSeq($1, new ASTSpaceDecl($3,100));
                                                            else
                                                                $$ = new ASTSeq($1, new ASTStringDecl($3, $4));
                                                        }
                                                        else
                                                        	yyerror(&yyloc,p,"Variable of wrong type assigning to string type.");
													}
				|	ID stratr                       {
														if((p->symtable->add($1, type))==false) yyerror(&yyloc,p,"Variable has already been declared.");
														else if(type==ASTNode::STRING){
                                                            if($2==NULL)
                                                                $$ = new ASTSpaceDecl($1,100);
                                                            else
                                                                $$ = new ASTStringDecl($1, $2);
                                                        }
                                                        else
                                                        	yyerror(&yyloc,p,"Variable of wrong type assigning to string type.");
													}
				;

atr				:	'=' exp 						{ $$ = $2; }
				|									{ $$ = NULL; }
				;

stratr			:	'=' STRING 						{ $$ = $2; }
				;

inner_block		:	'{'                             { p->symtable = new SymTable(p->symtable); }
                        block_inst '}'				{
                                                        p->symtable = p->symtable->last;
                                                        $$ = $3;
                                                    }
				|	inst 							{ $$ = $1; }
                |   ';'                             { $$ = NULL; }
				;

block_inst      :   block_inst inst                 { $$ = new ASTSeq($1, $2); }
                |   block_inst decl                 { $$ = new ASTSeq($1, $2); }
                |                                   { $$ = new ASTSeq(NULL, NULL); }
                ;

condition       :   '(' boolExp ')'                 { $$ = $2; }
                ;

inst            :   IF condition inner_block        { $$ = new ASTIf($2,$3,NULL); }
                |   IF condition inner_block ELSE inner_block  { $$ = new ASTIf($2,$3,$5); }
                |   LOOP inner_block                { $$ = new ASTLoop($2); }
                |   attfunc ';'                     { $$ = new ASTFunctionCall($1); }
                |   BREAK ';'                       { $$ = new ASTBreak(); }
                |   EXIT '('')' ';'                 { $$ = new ASTExit(); }
                |   func ';'                        { $$ = $1; }
                |	ID '(' ')' ';' 					{ 	int t;
                                                        if(((p->symtable->getType($1,&t))==false)||t!=ASTNode::PROGRAM)
                                                            yyerror(&yyloc,p,"Procedure does not exist.");
                                                        $$ = new ASTProcedureCall($1);
													}
				|	assign_block ';'				{ $$ = $1; }
                ;


assign_block	:	assign_block ',' assign 		{ $$ = new ASTSeq($1, $3); }
				|	assign 							{ $$ = $1; }
				;

assign 			:	ID '=' exp 		                {
                                                        int t;
                                                        if((p->symtable->getType($1,&t))==false)
                                                            yyerror(&yyloc,p,"Variable has not been declared.");
                                                        else if(t!=ASTNode::FLOAT && t!=ASTNode::INT && t!=ASTNode::BYTE)
                                                            yyerror(&yyloc,p,"Variable is of wrong type.");
                                                        else if(t==ASTNode::FLOAT && $3->getType()==ASTNode::INT){
                                                        	$$ = new ASTAssignToVar($1,t,new ASTCast(ASTNode::FLOAT, $3));
                                                        }
                                                        else if(t==ASTNode::INT && $3->getType()==ASTNode::FLOAT){
                                                        	yywarning(&yyloc,p,"Assigning float value to int. Cast float to int.");
                                                        	$$ = new ASTAssignToVar($1,t,new ASTCast(ASTNode::INT, $3));
                                                        }
                                                        else if(t==ASTNode::INT && $3->getType()==ASTNode::BYTE){
                                                            $$ = new ASTAssignToVar($1,t,new ASTCast(ASTNode::INT, $3));
                                                        }
                                                        else if(t==ASTNode::FLOAT && $3->getType()==ASTNode::BYTE){
                                                            $$ = new ASTAssignToVar($1,t,new ASTCast(ASTNode::FLOAT, $3));
                                                        }
                                                        else if(t==ASTNode::BYTE && $3->getType()==ASTNode::INT){
                                                            $$ = new ASTAssignToVar($1,t,new ASTCast(ASTNode::BYTE, $3));
                                                        }
                                                        else if(t==ASTNode::BYTE && $3->getType()==ASTNode::FLOAT){
                                                            yywarning(&yyloc,p,"Assigning float value to byte. Cast float to byte.");
                                                            $$ = new ASTAssignToVar($1,t,new ASTCast(ASTNode::BYTE, $3));
                                                        }
                                                        else
                                                        	$$ = new ASTAssignToVar($1,t,$3);
                                                    }
                |   ID '[' exp ']' '=' exp      	{   int t;
                                                        if((p->symtable->getType($1,&t))==false)
                                                            yyerror(&yyloc,p,"Variable has not been declared.");
                                                        else if(t!=ASTNode::FLOATARRAY && t!=ASTNode::INTARRAY && t!=ASTNode::BYTEARRAY)
                                                            yyerror(&yyloc,p,"Variable is of wrong type.");
                                                        if(t==ASTNode::FLOATARRAY) t = ASTNode::FLOAT;
                                                        else if(t==ASTNode::INTARRAY) t = ASTNode::INT;
                                                        else if(t==ASTNode::BYTEARRAY) t = ASTNode::BYTE;
                                                        $$ = new ASTAssignToArray($1, t, $3, $6);
                                                    }
              	| ID INCREMENT                  	{
	                                                    int t;
	                                                    if((p->symtable->getType($1,&t))==false)
	                                                      yyerror(&yyloc,p,"Variable has not been declared.");
	                                                    if(t!=ASTNode::INT && t!=ASTNode::FLOAT && t!=ASTNode::BYTE)
	                                                      yyerror(&yyloc,p,"Variable is of wrong type.");
	                                                    if(t!=ASTNode::FLOAT)
	                                                      $$ = new ASTAssignToVar($1, ASTNode::INT, new ASTOperation(ASTNode::ADD, new ASTVarValue($1, t) , new ASTIntegerValue(1)));
	                                                    else
	                                                      $$ = new ASTAssignToVar($1, ASTNode::FLOAT, new ASTOperation(ASTNode::ADD, new ASTVarValue($1, t) , new ASTFloatValue(1))); }
              	| ID DECREMENT                  	{
	                                                    int t;
	                                                    if((p->symtable->getType($1,&t))==false)
	                                                      yyerror(&yyloc,p,"Variable has not been declared.");
	                                                    if(t!=ASTNode::INT && t!=ASTNode::FLOAT && t!=ASTNode::BYTE)
	                                                      yyerror(&yyloc,p,"Variable is of wrong type.");
	                                                    if(t!=ASTNode::FLOAT)
	                                                      $$ = new ASTAssignToVar($1, ASTNode::INT, new ASTOperation(ASTNode::SUB, new ASTVarValue($1, t) , new ASTIntegerValue(1)));
	                                                    else
	                                                      $$ = new ASTAssignToVar($1, ASTNode::FLOAT, new ASTOperation(ASTNode::SUB, new ASTVarValue($1, t) , new ASTFloatValue(1))); }


            	|   ID '[' exp ']' INCREMENT   		{
	            										int t;
		                                                if((p->symtable->getType($1,&t))==false)
		                                                    yyerror(&yyloc,p,"Variable has not been declared.");
		                                                else if(t!=ASTNode::FLOATARRAY && t!=ASTNode::INTARRAY && t!=ASTNode::BYTEARRAY)
		                                                    yyerror(&yyloc,p,"Variable is of wrong type.");
		                                                if(t==ASTNode::FLOATARRAY) t = ASTNode::FLOAT;
		                                                else if(t==ASTNode::INTARRAY) t = ASTNode::INT;
		                                                else if(t==ASTNode::BYTEARRAY) t = ASTNode::BYTE;
		                                                if(t!=ASTNode::FLOAT)
		                                                    $$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::ADD, new ASTArrayValue($1, $3, t) , new ASTIntegerValue(1)));
		                                                else
		                                                    $$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::ADD, new ASTArrayValue($1, $3, t) , new ASTFloatValue(1)));
	                                              	}

            	|   ID '[' exp ']' DECREMENT   		{
            											int t;
	                                                  	if((p->symtable->getType($1,&t))==false)
	                                                      	yyerror(&yyloc,p,"Variable has not been declared.");
	                                                  	else if(t!=ASTNode::FLOATARRAY && t!=ASTNode::INTARRAY && t!=ASTNode::BYTEARRAY)
	                                                      	yyerror(&yyloc,p,"Variable is of wrong type.");
	                                                  	if(t==ASTNode::FLOATARRAY) t = ASTNode::FLOAT;
	                                                  	else if(t==ASTNode::INTARRAY) t = ASTNode::INT;
	                                                  	else if(t==ASTNode::BYTEARRAY) t = ASTNode::BYTE;
	                                                  	if(t!=ASTNode::FLOAT)
		                                                	$$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::SUB, new ASTArrayValue($1, $3, t) , new ASTIntegerValue(1)));
	                                                  	else
	                                                      	$$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::SUB, new ASTArrayValue($1, $3, t) , new ASTFloatValue(1)));
	                                                }

                | ID ADDEQ exp                 	    {
	                                                    int t;
	                                                    if((p->symtable->getType($1,&t))==false)
	                                                      yyerror(&yyloc,p,"Variable has not been declared.");
	                                                    if(t!=ASTNode::INT && t!=ASTNode::FLOAT && t!=ASTNode::BYTE)
	                                                      yyerror(&yyloc,p,"Variable is of wrong type.");
	                                                    $$ = new ASTAssignToVar($1, t, new ASTOperation(ASTNode::ADD, new ASTVarValue($1, t) , $3));
                                                    }
              	| ID SUBEQ exp                  	{
	                                                    int t;
	                                                    if((p->symtable->getType($1,&t))==false)
	                                                      yyerror(&yyloc,p,"Variable has not been declared.");
	                                                    if(t!=ASTNode::INT && t!=ASTNode::FLOAT && t!=ASTNode::BYTE)
	                                                      yyerror(&yyloc,p,"Variable is of wrong type.");
	                                                    $$ = new ASTAssignToVar($1, t, new ASTOperation(ASTNode::SUB, new ASTVarValue($1, t) , $3));
                                                    }

                | ID MULEQ exp                  	{
	                                                    int t;
	                                                    if((p->symtable->getType($1,&t))==false)
	                                                      yyerror(&yyloc,p,"Variable has not been declared.");
	                                                    if(t!=ASTNode::INT && t!=ASTNode::FLOAT && t!=ASTNode::BYTE)
	                                                      yyerror(&yyloc,p,"Variable is of wrong type.");
	                                                    $$ = new ASTAssignToVar($1, t, new ASTOperation(ASTNode::MUL, new ASTVarValue($1, t) , $3));
                                                    }
              	| ID DIVEQ exp                	    {
	                                                    int t;
	                                                    if((p->symtable->getType($1,&t))==false)
	                                                      yyerror(&yyloc,p,"Variable has not been declared.");
	                                                    if(t!=ASTNode::INT && t!=ASTNode::FLOAT && t!=ASTNode::BYTE)
	                                                      yyerror(&yyloc,p,"Variable is of wrong type.");
	                                                    $$ = new ASTAssignToVar($1, t, new ASTOperation(ASTNode::DIV, new ASTVarValue($1, t) , $3));
                                                    }

                | ID MODEQ exp                 	    {
                                                      int t;
                                                      if((p->symtable->getType($1,&t))==false)
                                                        yyerror(&yyloc,p,"Variable has not been declared.");
                                                      if(t!=ASTNode::INT && t!=ASTNode::FLOAT && t!=ASTNode::BYTE)
                                                        yyerror(&yyloc,p,"Variable is of wrong type.");
                                                      $$ = new ASTAssignToVar($1, t, new ASTOperation(ASTNode::REM, new ASTVarValue($1, t) , $3));
                                                    }


				|   ID '[' exp ']' ADDEQ exp   		{
				        								int t;
				                                        if((p->symtable->getType($1,&t))==false)
				                                            yyerror(&yyloc,p,"Variable has not been declared.");
				                                        else if(t!=ASTNode::FLOATARRAY && t!=ASTNode::INTARRAY && t!=ASTNode::BYTEARRAY)
				                                            yyerror(&yyloc,p,"Variable is of wrong type.");
				                                        if(t==ASTNode::FLOATARRAY) t = ASTNode::FLOAT;
				                                        else if(t==ASTNode::INTARRAY) t = ASTNode::INT;
				                                        else if(t==ASTNode::BYTEARRAY) t = ASTNode::BYTE;
				                                        if(t!=ASTNode::FLOAT)
				                                            $$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::ADD, new ASTArrayValue($1, $3, t) , $6));
				                                        else
				                                            $$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::ADD, new ASTArrayValue($1, $3, t) , $6));
				                                    }

				|   ID '[' exp ']' SUBEQ exp   		{
				      									int t;
				                                      	if((p->symtable->getType($1,&t))==false)
				                                           	yyerror(&yyloc,p,"Variable has not been declared.");
				                                       	else if(t!=ASTNode::FLOATARRAY && t!=ASTNode::INTARRAY && t!=ASTNode::BYTEARRAY)
				                                          	yyerror(&yyloc,p,"Variable is of wrong type.");
				                                      	if(t==ASTNode::FLOATARRAY) t = ASTNode::FLOAT;
				                                      	else if(t==ASTNode::INTARRAY) t = ASTNode::INT;
				                                      	else if(t==ASTNode::BYTEARRAY) t = ASTNode::BYTE;
				                                       	if(t!=ASTNode::FLOAT)
				                                      	$$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::SUB, new ASTArrayValue($1, $3, t) , $6));
				                                      	else
				                                          	$$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::SUB, new ASTArrayValue($1, $3, t) , $6));
				                                    }

				|   ID '[' exp ']' MULEQ exp    	{
				        								int t;
				                                        if((p->symtable->getType($1,&t))==false)
				                                            yyerror(&yyloc,p,"Variable has not been declared.");
				                                        else if(t!=ASTNode::FLOATARRAY && t!=ASTNode::INTARRAY && t!=ASTNode::BYTEARRAY)
				                                            yyerror(&yyloc,p,"Variable is of wrong type.");
				                                        if(t==ASTNode::FLOATARRAY) t = ASTNode::FLOAT;
				                                        else if(t==ASTNode::INTARRAY) t = ASTNode::INT;
				                                        else if(t==ASTNode::BYTEARRAY) t = ASTNode::BYTE;
				                                        if(t!=ASTNode::FLOAT)
				                                            $$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::MUL, new ASTArrayValue($1, $3, t) , $6));
				                                        else
				                                            $$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::MUL, new ASTArrayValue($1, $3, t) , $6));
				                                    }

				|   ID '[' exp ']' DIVEQ exp    	{
				      									int t;
				                                        if((p->symtable->getType($1,&t))==false)
				                                            yyerror(&yyloc,p,"Variable has not been declared.");
				                                        else if(t!=ASTNode::FLOATARRAY && t!=ASTNode::INTARRAY && t!=ASTNode::BYTEARRAY)
				                                            yyerror(&yyloc,p,"Variable is of wrong type.");
				                                        if(t==ASTNode::FLOATARRAY) t = ASTNode::FLOAT;
				                                        else if(t==ASTNode::INTARRAY) t = ASTNode::INT;
				                                        else if(t==ASTNode::BYTEARRAY) t = ASTNode::BYTE;
				                                        if(t!=ASTNode::FLOAT)
				                                            $$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::DIV, new ASTArrayValue($1, $3, t) , $6));
				                                        else
				                                            $$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::DIV, new ASTArrayValue($1, $3, t) , $6));
				                                    }


				|   ID '[' exp ']' MODEQ exp    	{
				      									int t;
				                                        if((p->symtable->getType($1,&t))==false)
				                                          	yyerror(&yyloc,p,"Variable has not been declared.");
				                                      	else if(t!=ASTNode::FLOATARRAY && t!=ASTNode::INTARRAY && t!=ASTNode::BYTEARRAY)
				                                          	yyerror(&yyloc,p,"Variable is of wrong type.");
				                                      	if(t==ASTNode::FLOATARRAY) t = ASTNode::FLOAT;
				                                      	else if(t==ASTNode::INTARRAY) t = ASTNode::INT;
				                                      	else if(t==ASTNode::BYTEARRAY) t = ASTNode::BYTE;
				                                      	if(t!=ASTNode::FLOAT)
				                                            $$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::REM, new ASTArrayValue($1, $3, t) , $6));
				                                        else
				                                           	$$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::REM, new ASTArrayValue($1, $3, t) , $6));
				                                    }


				;

boolExp         :   logicOr                         { $$ = $1; }
                ;


logicOr         :   logicXor                        { $$ = $1; }
                |   logicOr LOR logicXor            {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::OR, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::OR, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTOperation(ASTNode::OR, $1, $3);
                									}
                ;

logicXor        :   logicAnd                        { $$ = $1; }
                |   logicXor XOR logicAnd           {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::XOR, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::XOR, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTOperation(ASTNode::XOR, $1, $3);
                									}
                ;

logicAnd        :   not                             { $$ = $1; }
                |   logicAnd LAND not               { 	if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::AND, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::AND, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTOperation(ASTNode::AND, $1, $3);
                									}
                ;

not             :   boolEqpar                       { $$ = $1; }
                |   NOT boolEqpar                   { $$ = new ASTOperation(ASTNode::NOT, $2, NULL); }
                ;

boolEqpar       :   boolEq                          { $$ = $1; }
                |   '(' logicOr')'                  { $$ = $2; }
                ;

boolEq          :   boolEq EQUAL exp                {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::EQ, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::EQ, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTRelop(ASTNode::EQ, $1, $3);
                									}
                |   boolEq NEQUAL exp               {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::NE, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::NE, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTRelop(ASTNode::NE, $1, $3);
                									}
                |   boolEq LT exp                   {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::LT, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::LT, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTRelop(ASTNode::LT, $1, $3);
                									}
                |   boolEq BT exp                   {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::GT, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::GT, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTRelop(ASTNode::GT, $1, $3);
                									}
                |   boolEq LEQ exp                  {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::LE, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::LE, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTRelop(ASTNode::LE, $1, $3);
                									}
                |   boolEq BEQ exp                  {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::GE, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::GE, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTRelop(ASTNode::GE, $1, $3);
                									}
                |   exp EQUAL exp                   {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::EQ, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::EQ, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTRelop(ASTNode::EQ, $1, $3);
                									}
                |   exp NEQUAL exp                  {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::NE, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::NE, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTRelop(ASTNode::NE, $1, $3);
                									}
                |   exp LT exp                      {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::LT, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::LT, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTRelop(ASTNode::LT, $1, $3);
                									}
                |   exp BT exp                      {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::GT, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::GT, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTRelop(ASTNode::GT, $1, $3);
                									}
                |   exp LEQ exp                     {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::LE, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::LE, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTRelop(ASTNode::LE, $1, $3);
                									}
                |   exp BEQ exp                     {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::GE, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTRelop(ASTNode::GE, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTRelop(ASTNode::GE, $1, $3);
                									}
                ;

exp             :   addExp                          { $$ = $1; }
                ;




addExp          :   mulExp                          { $$ = $1; }
                |   addExp ADD mulExp               {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::ADD, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::ADD, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else{
                											$$ = new ASTOperation(ASTNode::ADD, $1, $3);
                										}
                									}
                |   addExp SUB mulExp               {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::SUB, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::SUB, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTOperation(ASTNode::SUB, $1, $3);
                									}
                ;




mulExp          :   cast                            { $$ = $1; }
                |   mulExp MUL cast                 {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::MUL, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::MUL, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTOperation(ASTNode::MUL, $1, $3);
                									}
                |   mulExp DIV cast                 {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::DIV, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::DIV, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTOperation(ASTNode::DIV, $1, $3);
                									}
                |   mulExp MOD cast                 {
                										if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::REM, $1, new ASTCast(ASTNode::FLOAT,$3));
                										}
                										else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                											$$ = new ASTOperation(ASTNode::REM, new ASTCast(ASTNode::FLOAT,$1), $3);
                										}
                										else
                											$$ = new ASTOperation(ASTNode::REM, $1, $3);
                									}
                ;


cast            :   '(' TINT ')' pExp               {   if($4->getType()!=ASTNode::INT)
                                                            $$ = new ASTCast(ASTNode::INT, $4);
                                                        else
                                                            $$ = $4;
                                                    }
                |   '(' TFLOAT ')' pExp             {   if($4->getType()!=ASTNode::FLOAT)
                                                            $$ = new ASTCast(ASTNode::FLOAT, $4);
                                                        else
                                                            $$ = $4;
                                                    }
                |   '(' TBYTE ')' pExp              {   if($4->getType()!=ASTNode::BYTE)
                                                            $$ = new ASTCast(ASTNode::BYTE, $4);
                                                        else
                                                            $$ = $4;
                                                    }
                |   pExpn                           { $$ = $1; }
                ;

pExpn           :   SUB pExpBor                    	{ $$ = new ASTNeg($2, $2->getType()); }
                |   pExpBor                        	{ $$ = $1; }
                ;

pExpBor         :   pExpBor BOR pExpXor             {   if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                                                            $$ = new ASTOperation(ASTNode::BOR, $1, new ASTCast(ASTNode::FLOAT,$3));
                                                        }
                                                        else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                                                            $$ = new ASTOperation(ASTNode::BOR, new ASTCast(ASTNode::FLOAT,$1), $3);
                                                        }
                                                        else
                                                            $$ = new ASTOperation(ASTNode::BOR, $1, $3); 
                                                    }
                |   pExpXor                         { $$ = $1; }
                ;

pExpXor         :   pExpXor BXOR pExpAnd            {   if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                                                            $$ = new ASTOperation(ASTNode::BXOR, $1, new ASTCast(ASTNode::FLOAT,$3));
                                                        }
                                                        else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                                                            $$ = new ASTOperation(ASTNode::BXOR, new ASTCast(ASTNode::FLOAT,$1), $3);
                                                        }
                                                        else
                                                            $$ = new ASTOperation(ASTNode::BXOR, $1, $3);
                                                    }
                |   pExpAnd                         { $$ = $1; }
                ;

pExpAnd         :   pExpAnd BAND pExpNot            {   
                                                        if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                                                            $$ = new ASTOperation(ASTNode::BAND, $1, new ASTCast(ASTNode::FLOAT,$3));
                                                        }
                                                        else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                                                            $$ = new ASTOperation(ASTNode::BAND, new ASTCast(ASTNode::FLOAT,$1), $3);
                                                        }
                                                        else
                                                            $$ = new ASTOperation(ASTNode::BAND, $1, $3);
                                                    }
                |   pExpNot                         { $$ = $1; }
                ;

pExpNot         :   BNOT pExpSh                     {   
                                                        $$ = new ASTOperation(ASTNode::BNOT, $2, NULL);
                                                    }
                |   pExpSh                          { $$ = $1; }
                ;

pExpSh          :   pExpSh BSR pExp                  {   
                                                        if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                                                            $$ = new ASTOperation(ASTNode::BSR, $1, new ASTCast(ASTNode::FLOAT,$3));
                                                        }
                                                        else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                                                            $$ = new ASTOperation(ASTNode::BSR, new ASTCast(ASTNode::FLOAT,$1), $3);
                                                        }
                                                        else
                                                            $$ = new ASTOperation(ASTNode::BSR, $1, $3);
                                                    }
                |   pExpSh BSL pExp                 {   
                                                        if($1->getType()==ASTNode::FLOAT && $3->getType()!=ASTNode::FLOAT){
                                                            $$ = new ASTOperation(ASTNode::BSL, $1, new ASTCast(ASTNode::FLOAT,$3));
                                                        }
                                                        else if($3->getType()==ASTNode::FLOAT && $1->getType()!=ASTNode::FLOAT){
                                                            $$ = new ASTOperation(ASTNode::BSL, new ASTCast(ASTNode::FLOAT,$1), $3);
                                                        }
                                                        else
                                                            $$ = new ASTOperation(ASTNode::BSL, $1, $3);
                                                    }
                |   pExp                            { $$ = $1; }
                ;


pExp            :   INT                             { $$ = new ASTIntegerValue($1); }
                |   REAL                            { $$ = new ASTFloatValue($1); }
                |   ID                              {
                                                        int t;
                                                        if((p->symtable->getType($1,&t))==false)
                                                            yyerror(&yyloc,p,"Variable has not been declared.");
                                                        if(t!=ASTNode::INT && t!=ASTNode::FLOAT && t!=ASTNode::BYTE)
                                                            yyerror(&yyloc,p,"Variable is of wrong type.");
                                                        $$ = new ASTVarValue($1, t);
                                                    }
                |   '(' exp ')'                     { $$ = $2; }
                |   attfunc                         { $$ = new ASTFunctionCall($1); }
                |	ID '[' exp ']' 					{
                										int t;
                                                        if($3->getType()==ASTNode::FLOAT){
                                                            yywarning(&yyloc,p,"Assigning float value to int. Cast float to int.");
                                                            $3 = new ASTCast(ASTNode::INT, $3);
                                                        }
                                                        if((p->symtable->getType($1,&t))==false)
                                                            yyerror(&yyloc,p,"Variable has not been declared.");
                                                        if(t!=ASTNode::INTARRAY && t!=ASTNode::FLOATARRAY && t!=ASTNode::BYTEARRAY)
                                                            yyerror(&yyloc,p,"Variable is of wrong type.");
                                                        if(t==ASTNode::INTARRAY)
                											$$ = new ASTArrayValue($1, $3, ASTNode::INT);
                										else if(t==ASTNode::FLOATARRAY)
                											$$ = new ASTArrayValue($1, $3, ASTNode::FLOAT);
                                                        else if(t==ASTNode::BYTEARRAY)
                                                            $$ = new ASTArrayValue($1, $3, ASTNode::BYTE);
                									}
                |	ID INCREMENT 					{
                										int t;
                                                        if((p->symtable->getType($1,&t))==false)
                                                            yyerror(&yyloc,p,"Variable has not been declared.");
                                                        if(t!=ASTNode::INT && t!=ASTNode::FLOAT && t!=ASTNode::BYTE)
                                                            yyerror(&yyloc,p,"Variable is of wrong type.");
                                                        if(t==ASTNode::FLOAT){
                                                        	$$ = new ASTAssignToVar($1, t, new ASTOperation(ASTNode::ADD, new ASTVarValue($1,t), new ASTFloatValue(1)));
                                                        	$$ = new ASTSeqValue($$,new ASTVarValue($1,t));
                                                        }
                                                        else{
                                                        	$$ = new ASTAssignToVar($1, t, new ASTOperation(ASTNode::ADD, new ASTVarValue($1,t), new ASTIntegerValue(1)));
                                                        	$$ = new ASTSeqValue($$,new ASTVarValue($1,t));
                                                        }
									                }
                |	ID DECREMENT					{
                										int t;
                                                        if((p->symtable->getType($1,&t))==false)
                                                            yyerror(&yyloc,p,"Variable has not been declared.");
                                                        if(t!=ASTNode::INT && t!=ASTNode::FLOAT && t!=ASTNode::BYTE)
                                                            yyerror(&yyloc,p,"Variable is of wrong type.");
                                                        if(t==ASTNode::FLOAT){
                                                        	$$ = new ASTAssignToVar($1, t, new ASTOperation(ASTNode::SUB, new ASTVarValue($1,t), new ASTFloatValue(1)));
                                                        	$$ = new ASTSeqValue($$,new ASTVarValue($1,t));
                                                        }
                                                        else{
                                                        	$$ = new ASTAssignToVar($1, t, new ASTOperation(ASTNode::SUB, new ASTVarValue($1,t), new ASTIntegerValue(1)));
                                                        	$$ = new ASTSeqValue($$,new ASTVarValue($1,t));
                                                        }
									                }
                |	ID '[' exp ']' INCREMENT		{
                										int t;
                                                        if($3->getType()==ASTNode::FLOAT){
                                                            yywarning(&yyloc,p,"Assigning float value to int. Cast float to int.");
                                                            $3 = new ASTCast(ASTNode::INT, $3);
                                                        }
                                                        if((p->symtable->getType($1,&t))==false)
                                                            yyerror(&yyloc,p,"Variable has not been declared.");
                                                        if(t!=ASTNode::INTARRAY && t!=ASTNode::FLOATARRAY && t!=ASTNode::BYTEARRAY)
                                                            yyerror(&yyloc,p,"Variable is of wrong type.");
                                                        if(t==ASTNode::INTARRAY)
                											t = ASTNode::INT;
                										else if(t==ASTNode::FLOATARRAY)
                											t = ASTNode::FLOAT;
                                                        else if(t==ASTNode::BYTEARRAY)
                                                            t = ASTNode::BYTE;
                                                        if(t==ASTNode::FLOAT){
                                                        	$$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::ADD, new ASTArrayValue($1, $3, t), new ASTFloatValue(1)));
                                                        	$$ = new ASTSeqValue($$,new ASTArrayValue($1, $3, t));
                                                        }
                                                        else{
                                                        	$$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::ADD, new ASTArrayValue($1, $3, t), new ASTIntegerValue(1)));
                                                        	$$ = new ASTSeqValue($$,new ASTArrayValue($1, $3, t));
                                                        }
                									}
                |	ID '[' exp ']' DECREMENT		{
                										int t;
                                                        if($3->getType()==ASTNode::FLOAT){
                                                            yywarning(&yyloc,p,"Assigning float value to int. Cast float to int.");
                                                            $3 = new ASTCast(ASTNode::INT, $3);
                                                        }
                                                        if((p->symtable->getType($1,&t))==false)
                                                            yyerror(&yyloc,p,"Variable has not been declared.");
                                                        if(t!=ASTNode::INTARRAY && t!=ASTNode::FLOATARRAY && t!=ASTNode::BYTEARRAY)
                                                            yyerror(&yyloc,p,"Variable is of wrong type.");
                                                        if(t==ASTNode::INTARRAY)
                											t = ASTNode::INT;
                										else if(t==ASTNode::FLOATARRAY)
                											t = ASTNode::FLOAT;
                                                        else if(t==ASTNode::BYTEARRAY)
                                                            t = ASTNode::BYTE;
                                                        if(t==ASTNode::FLOAT){
                                                        	$$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::SUB, new ASTArrayValue($1,$3,t), new ASTFloatValue(1)));
                                                        	$$ = new ASTSeqValue($$,new ASTArrayValue($1, $3, t));
                                                        }
                                                        else{
                                                        	$$ = new ASTAssignToArray($1, t, $3, new ASTOperation(ASTNode::SUB, new ASTArrayValue($1,$3,t), new ASTIntegerValue(1)));
                                                        	$$ = new ASTSeqValue($$,new ASTArrayValue($1, $3, t));
                                                        }
                									}
                ;



attfunc         :   RCHAR '(' ')'                   { $$ = ASTNode::READCHAR; }
                |   RINT '(' ')'                    { $$ = ASTNode::READINT; }
                ;

func            :   PINT '(' exp ')'                {
                                                        if($3->getType()==ASTNode::FLOAT){
                                                            yywarning(&yyloc,p,"Variable is of wrong type. Cast to Int.");
                                                            $$ = new ASTPrint(0, new ASTCast(ASTNode::INT, $3));
                                                        }
                                                        else
                                                            $$ = new ASTPrint(0, $3);
                                                    }
				|   PCHAR '(' exp ')'               {
                                                        if($3->getType()==ASTNode::FLOAT){
                                                            yywarning(&yyloc,p,"Variable is of wrong type. Cast to Int.");
                                                            $$ = new ASTPrint(1, new ASTCast(ASTNode::INT, $3));
                                                        }
                                                        else
                                                            $$ = new ASTPrint(1, $3);
                                                    }
                |   PSTR '(' STRING ')'             { $$ = new ASTPrintStr(new ASTStringValue($3),0); }
                |   PSTR '(' ID ')'             	{	int t;
                                                       	if((p->symtable->getType($3,&t))==false)
                                                       		yyerror(&yyloc,p,"Variable has not been declared.");
                                                        if(t!=ASTNode::STRING)
                                                        	yyerror(&yyloc,p,"Variable is of wrong type.");
                                                        $$ = new ASTPrintStr(new ASTStringValue($3),1);
                                                   	}
                ;

%%

void yyerror(YYLTYPE* loc, struct MainData* p, const char* s, ...)
{
    va_list ap;
    va_start(ap, s);

    if (loc->first_line)
    {
        fprintf(stderr, "%d.%d:%d.%d: ERROR: ", loc->first_line, loc->first_column,
                loc->last_line, loc->last_column);
    }
    vfprintf(stderr, s, ap);
    fprintf(stderr, "\n");
    p->no_of_errors++;
}

void yywarning(YYLTYPE* loc, struct MainData* p, const char* s, ...)
{
    va_list ap;
    va_start(ap, s);

    if (loc->first_line)
    {
        fprintf(stderr, "%d.%d:%d.%d: WARNING: ", loc->first_line, loc->first_column,
                loc->last_line, loc->last_column);
    }
    vfprintf(stderr, s, ap);
    fprintf(stderr, "\n");
}
