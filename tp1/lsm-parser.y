/*
	LFA 2016 - Grupo 3
	Projeto 1
	David Almeida, Diogo Ferreira, Francisco Cunha, José Castanheira
	Parser
*/

%code top {
    #include <stdint.h>
}
%code {
    #include "lsm-lexer.h"
    #include "label.h"
    #include <iostream>
    #include <vector>
    #include "lsm-data.h"
    #define scanner p->scanner


    void yyerror(YYLTYPE* loc, struct LSMData* p, const char*);
    void yywarning(YYLTYPE* loc, struct LSMData* p, const char* s);
    void addData(struct LSMData* p, uint8_t* f, unsigned int n);
    void addDataReal(struct LSMData* p, float f, unsigned int n);
    void addTextReal(struct LSMData* p, float f, unsigned int n);
    void addDataInteger(struct LSMData* p, int32_t f, unsigned int n);
    void addText(struct LSMData* p, int32_t f, unsigned int n);


}

%error-verbose
%locations
%verbose
%define api.pure
%defines "lsm-parser.h"
%lex-param {scanner}
%parse-param {struct LSMData* p}

%union
{
    uint8_t opcode;
    float vfloat;
    int32_t vint;
    char* vstr;
}

%token DATA;
%token TEXT;

%token TWORD;
%token TFLOAT;
%token TBYTE;
%token TSTRING;
%token TSPACE;

%token <opcode> INTMAN;
%token <opcode> REALMAN
%token <opcode> JUMPLAB;
%token <opcode> RET;
%token <opcode> STACKLAB;
%token <opcode> STACKNOOP;
%token <opcode> STACKINT;
%token <opcode> STACKREAL;


%token <vint> NUM;
%token <vint> HEX;
%token <vint> BYTE;
%token <vstr> LABEL;
%token <vstr> STRING;

%token <opcode> OTHERM;
%token <vfloat> REAL;

%type <vint> num_or_hex_or_byte


%%

lsm         :   block_list { 	if(p->first_time==false){
									if(p->debug_mode){
										printf("\nData Size: %zu\nBss Size: %d\nText Size: %d\n",p->data.size()/4, p->bss_size, p->text_size);
										printf("\n---DATA"); 
										for (std::vector<uint8_t>::iterator it = p->data.begin() ; it != p->data.end(); ++it)
	    									printf("\n%u",*it); 
	    								printf("\n----TEXT"); 
	    								for (std::vector<uint8_t>::iterator it = p->text.begin() ; it != p->text.end(); ++it)
	    									printf("\n%u",*it); 
	    								map<string, Label*> m = p->lbl_table->getTable();
	    								printf("\n--Labels"); 
										for (std::map<string, Label*>::iterator it = m.begin() ; it != m.end(); ++it)
								    		printf("\n%s: %d-%d",it->first.c_str(),it->second->address,it->second->t);
								     	printf("\n");
								     }
							 	}
							 	else{
							 		// Soma Data_size a todos os endereços Bss no final da primeira passagem
							 		map<string, Label*> m = p->lbl_table->getTable();
							 		for (std::map<string, Label*>::iterator it = m.begin() ; it != m.end(); ++it)
							 				if(it->second->t==bss)
								    			it->second->address+=p->data.size()/4;
							 	}
							}
            |   '\n' lsm
            ;


block_list  :   block
            |   block_list block
            ;


block       :   text_block
            |   data_block
            |   error block_newline { yyerrok; }
            ;

text_block  :   TEXT block_newline operation_block
			|	TEXT block_newline
			;

operation_block:
				instruction block_newline	
			|	instruction block_newline operation_block
			;


instruction:
			tlabelexists INTMAN 				{ if(p->first_time==false){ p->text.push_back($2); } p->text_size+=1; }
		|	tlabelexists REALMAN 				{ if(p->first_time==false){ p->text.push_back($2); } p->text_size+=1; }
		|	tlabelexists JUMPLAB LABEL 			{ if(p->first_time==false){ p->text.push_back($2); if(p->lbl_table->checkExists($3) && p->lbl_table->getType($3)==text){ p->text.push_back((uint8_t)((p->lbl_table->getAddress($3)-p->text_size)>>8)); p->text.push_back((uint8_t)((p->lbl_table->getAddress($3)-p->text_size))); } else yyerror(&yyloc,p,"Label does not Exist or its from data segment.");} p->text_size+=3; }
		|	tlabelexists RET 					{ if(p->first_time==false){ p->text.push_back($2); } p->text_size+=1; }
		|	tlabelexists STACKLAB LABEL  		{ if(p->first_time==false){ p->text.push_back($2); if(p->lbl_table->checkExists($3) && p->lbl_table->getType($3)!=text){ p->text.push_back((uint8_t)((uint8_t)(p->lbl_table->getAddress($3))>>8)); p->text.push_back((uint8_t)((p->lbl_table->getAddress($3)))); } else yyerror(&yyloc,p,"Label does not Exist or its from text segment.");} p->text_size+=3; }
		|	tlabelexists STACKNOOP 				{ if(p->first_time==false){ p->text.push_back($2); } p->text_size+=1; }
		|	tlabelexists STACKINT NUM 			{ if(p->first_time==false){ p->text.push_back($2); if($2==0x50){ addText(p, $3, 1); if($3>>8 && $3>>8!=0xFFFFFFFF) yywarning(&yyloc,p,"Maximum reprentation range exceeded."); } else addText(p, $3, 4); } if($2==0x50) p->text_size+=2; else p->text_size+=5; }
		|	tlabelexists STACKINT BYTE 			{ if(p->first_time==false){ p->text.push_back($2); if($2==0x50){ addText(p, $3, 1); if($3>>8 && $3>>8!=0xFFFFFFFF) yywarning(&yyloc,p,"Maximum reprentation range exceeded."); } else addText(p, $3, 4); } if($2==0x50) p->text_size+=2; else p->text_size+=5; }
		|	tlabelexists STACKINT HEX 			{ if(p->first_time==false){ p->text.push_back($2); if($2==0x50){ addText(p, $3, 1); if($3>>8 && $3>>8!=0xFFFFFFFF) yywarning(&yyloc,p,"Maximum reprentation range exceeded."); } else addText(p, $3, 4); } if($2==0x50) p->text_size+=2; else p->text_size+=5; }
		|	tlabelexists STACKREAL REAL 		{ if(p->first_time==false){ p->text.push_back($2); addTextReal(p,$3,4); } p->text_size+=5; }
		|	tlabelexists STACKREAL BYTE 		{ if(p->first_time==false){ p->text.push_back($2); float fp = (float)$3; addTextReal(p,fp,4); } p->text_size+=5; }
		|	tlabelexists STACKREAL NUM 			{ if(p->first_time==false){ p->text.push_back($2); float fp = (float)$3; addTextReal(p,fp,4); } p->text_size+=5; }
		|	tlabelexists OTHERM 				{ if(p->first_time==false){ p->text.push_back($2); } p->text_size+=1; }
		|	LABEL':'							{ if(p->first_time==true){ if(p->lbl_table->checkExists($1)){ yyerror(&yyloc,p,"Label Already Exists"); } p->lbl_table->add($1,new Label(text, p->text_size));} }
		;

tlabelexists:
			LABEL ':'							{ if(p->first_time==true){ if(p->lbl_table->checkExists($1)){ yyerror(&yyloc,p,"Label Already Exists"); } p->lbl_table->add($1,new Label(text, p->text_size));} }
		|
		;


data_block  :   DATA block_newline data_declarationblock
			|	DATA block_newline
			;

data_declarationblock:
				data_declaration block_newline
			|	data_declaration block_newline data_declarationblock
			;

data_declaration:
            	label ':' TWORD nnum_or_hex_or_byte			
            |	label ':' TFLOAT nnum_or_float_or_hex_or_byte 	
            |	label ':' TBYTE nbyte_hex_num 			
            |	label ':' TSTRING nstrings 			
            |	label ':' TSPACE num_or_hex_or_byte		{ 	/* Label foi adicionada como sendo do segmento data. É necessário alterar o adress e o tipo do último label. */
            												if(p->first_time==true){ Label *b = p->lbl_table->getLast(); b->t=bss; b->address=p->bss_size; p->bss_size+=$4; } }
            ;

label	:	LABEL 										{ if(p->first_time==true){ if(p->lbl_table->checkExists($1)){ yyerror(&yyloc,p,"Label Already Exists"); } p->lbl_table->add($1,new Label(data, p->data.size()/4));} }
		;


nnum_or_hex_or_byte:	
			nnum_or_hex_or_byte ',' NUM   				{ if(p->first_time==true){ addDataInteger(p, $3, 4);} }
		|	nnum_or_hex_or_byte ',' HEX  				{ if(p->first_time==true){ addDataInteger(p, $3, 4);} }
		|	nnum_or_hex_or_byte ',' BYTE  				{ if(p->first_time==true){ addDataInteger(p, $3, 4);} }
		|	BYTE 										{ if(p->first_time==true){ addDataInteger(p, $1, 4);} }
		|	NUM 										{ if(p->first_time==true){ addDataInteger(p, $1, 4);} }
		|	HEX 										{ if(p->first_time==true){ addDataInteger(p, $1, 4);} }
		;

nnum_or_float_or_hex_or_byte:	
			NUM 										{ if(p->first_time==true){ float fp = (float)$1; addDataReal(p,fp,4);} }
		|	REAL 										{ if(p->first_time==true){ addDataReal(p,$1,4);} }
		|	HEX 										{ if(p->first_time==true){ float fp = (float)$1; addDataReal(p,fp,4);} }
		|	BYTE 										{ if(p->first_time==true){ float fp = (float)$1; addDataReal(p,fp,4);} }
		|	nnum_or_float_or_hex_or_byte ',' BYTE		{ if(p->first_time==true){ float fp = (float)$3; addDataReal(p,fp,4);} }
		|	nnum_or_float_or_hex_or_byte ',' NUM 		{ if(p->first_time==true){ float fp = (float)$3; addDataReal(p,fp,4);} }
		|	nnum_or_float_or_hex_or_byte ',' REAL		{ if(p->first_time==true){ addDataReal(p,$3,4);} }
		|	nnum_or_float_or_hex_or_byte ',' HEX 		{ if(p->first_time==true){ float fp = (float)$3; addDataReal(p,fp,4);} }
		;

nbyte_hex_num:
			BYTE 										{ if(p->first_time==true){ if($1>=0) addDataInteger(p, 0, 3); else addDataInteger(p, 0xFFFFFF, 3); addDataInteger(p, $1, 1); if($1>>8 && ($1>>8)!=0xffffffff) yywarning(&yyloc,p,"Maximum reprentation range exceeded.");} }
		|	HEX 										{ if(p->first_time==true){ if($1>=0) addDataInteger(p, 0, 3); else addDataInteger(p, 0xFFFFFF, 3); addDataInteger(p, $1, 1); if($1>>8 && ($1>>8)!=0xffffffff) yywarning(&yyloc,p,"Maximum reprentation range exceeded.");} }
		|	NUM 										{ if(p->first_time==true){ if($1>=0) addDataInteger(p, 0, 3); else addDataInteger(p, 0xFFFFFF, 3); addDataInteger(p, $1, 1); if($1>>8 && ($1>>8)!=0xffffffff) yywarning(&yyloc,p,"Maximum reprentation range exceeded.");} }
		|	nbyte_hex_num ',' BYTE  					{ if(p->first_time==true){ if($3>=0) addDataInteger(p, 0, 3); else addDataInteger(p, 0xFFFFFF, 3); addDataInteger(p, $3, 1); if($3>>8 && ($3>>8)!=0xffffffff) yywarning(&yyloc,p,"Maximum reprentation range exceeded.");} }
		|	nbyte_hex_num ',' HEX 						{ if(p->first_time==true){ if($3>=0) addDataInteger(p, 0, 3); else addDataInteger(p, 0xFFFFFF, 3); addDataInteger(p, $3, 1); if($3>>8 && ($3>>8)!=0xffffffff) yywarning(&yyloc,p,"Maximum reprentation range exceeded.");} }
		|	nbyte_hex_num ',' NUM 						{ if(p->first_time==true){ if($3>=0) addDataInteger(p, 0, 3); else addDataInteger(p, 0xFFFFFF, 3); addDataInteger(p, $3, 1); if($3>>8 && ($3>>8)!=0xffffffff) yywarning(&yyloc,p,"Maximum reprentation range exceeded.");} }
		;

nstrings:	STRING 										{ if(p->first_time==true){ addData(p, reinterpret_cast<uint8_t*>($1), strlen($1)); addDataInteger(p, 0, 1); if(p->data.size()%4) addDataInteger(p, 0, 4-p->data.size()%4); } }
		;

num_or_hex_or_byte: 
			NUM 										{ if(p->first_time==true){ if($1<0) yyerror(&yyloc, p, "Value cannot be negative"); $$ = $1; if($1>>16) yywarning(&yyloc,p,"Maximum reprentation range exceeded.");} }
		|	HEX 										{ if(p->first_time==true){ if($1<0) yyerror(&yyloc, p, "Value cannot be negative"); $$ = $1; if($1>>16) yywarning(&yyloc,p,"Maximum reprentation range exceeded.");} }
		|	BYTE 										{ if(p->first_time==true){ if($1<0) yyerror(&yyloc, p, "Value cannot be negative"); $$ = $1; if($1>>16) yywarning(&yyloc,p,"Maximum reprentation range exceeded.");} }		
		;


block_newline: 	'\n'
			|	'\n' block_newline
			;

%%

#include <stdio.h>

void yyerror(YYLTYPE* loc, struct LSMData* p, const char* s)
{
	p->syntax_only=true;
	p->error_cnt++;
    fprintf(stderr, "@ line %d: columns %d-%d: %s\n", 
            loc->first_line, loc->first_column, loc->last_column, s);
}

void yywarning(YYLTYPE* loc, struct LSMData* p, const char* s)
{
    fprintf(stderr, "WARNING: @ line %d: columns %d-%d: %s\n", 
            loc->first_line, loc->first_column, loc->last_column, s);
}


// Apenas pode ser usado para char*!! 
// Para outros casos, poderá variar da arquitetura do cpu (big-endian ou little-endian)
void addData(struct LSMData* p, uint8_t* f, unsigned int n){

	unsigned int i;

	for(i=0;i<n;i++){
		p->data.push_back(*(f+i) & 0xFF);
	}

}

// Para variáveis inteiras
void addDataInteger(struct LSMData* p, int32_t f, unsigned int n){

	int i;

	for(i=n-1;i>=0;i--){
		p->data.push_back((uint8_t)(f>>(i*8)) & 0xFF);
	}

}

// Para variáveis reais
void addDataReal(struct LSMData* p, float f, unsigned int n){

	int i;

	for(i=n-1;i>=0;i--){
		p->data.push_back((*(uint32_t*)(&f) >> (i*8)) & 0xFF);
	}

}

// Para variáveis inteiras
void addText(struct LSMData* p, int32_t f, unsigned int n){

	int i;

	for(i=n-1;i>=0;i--){
		p->text.push_back((uint8_t)(f>>(i*8)) & 0xFF);
	}

}


// Para variáveis reais
void addTextReal(struct LSMData* p, float f, unsigned int n){

	int i;

	for(i=n-1;i>=0;i--){
		p->text.push_back((*(uint32_t*)(&f) >> (i*8)) & 0xFF);
	}

}
