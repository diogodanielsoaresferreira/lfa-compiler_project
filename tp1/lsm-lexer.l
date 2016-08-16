/*
	LFA 2016 - Grupo 3
	Projeto 1
	David Almeida, Diogo Ferreira, Francisco Cunha, José Castanheira
	Lexer
*/

%{
    #include <stdlib.h>
	#include <string>
	#include <stdio.h>
    #include <stdint.h>
    #include "lsm-parser.h"

    #define UPDATE_LOC yylloc->first_line = yylloc->last_line = yylineno; \
        yylloc->first_column = yycolumn; yylloc->last_column = yycolumn+yyleng-1; \
        yycolumn += yyleng;

    uint8_t opcodeValue(char *op);
    int32_t charPToInt(char* yyt);
%}

%option noyywrap
%option nounput noinput
%option nodefault yylineno
%option reentrant bison-bridge bison-locations
%option header-file="lsm-lexer.h"

stringdec	\"(\\.|[^"])*\"

real    	-?(([0-9]+\.?[0-9]*)|(\.[0-9]+))([Ee][+-]?[0-9]+)?

hex 		0x[0-9A-Fa-f]+

int 		-?[0-9][0-9]*

id      	[a-zA-Z][a-zA-Z0-9_]*


intman  	iadd|isub|imul|idiv|irem|iand|ior|ixor|ishl|ishr|iushr|ineg

realman 	fadd|fsub|fmul|fdiv|frem|fneg|i2f|f2i

jumplab 	goto|jsr|ifeq|ifne|iflt|ifge|ifgt|ifle
ret 		ret

stackint  	bipush|ipush
stackreal	fpush
stacknoop 	pop|dup|dup_x1|dup2|swap|baload|bastore|iaload|iastore|faload|fastore|saload|fcmpg
stacklab 	load|store|laload

otherM  	nop|halt|read|write|writes

spaces  	[ \t]+


all     	.*

%%
;{all}              {}
.data               { UPDATE_LOC; return DATA; }
.text               { UPDATE_LOC; return TEXT; }

.word               { UPDATE_LOC; return TWORD; }
.float              { UPDATE_LOC; return TFLOAT; }
.byte               { UPDATE_LOC; return TBYTE; }
.string             { UPDATE_LOC; return TSTRING; }
.space              { UPDATE_LOC; return TSPACE; }

{intman}			{ UPDATE_LOC; yylval->opcode = opcodeValue(&yytext[0]); return INTMAN; }
{realman}			{ UPDATE_LOC; yylval->opcode = opcodeValue(&yytext[0]); return REALMAN; }
{jumplab}			{ UPDATE_LOC; yylval->opcode = opcodeValue(&yytext[0]); return JUMPLAB; }
{ret}				{ UPDATE_LOC; yylval->opcode = 0x40; return RET; }
{stackint}			{ UPDATE_LOC; yylval->opcode = opcodeValue(&yytext[0]); return STACKINT; }
{stackreal}			{ UPDATE_LOC; yylval->opcode = opcodeValue(&yytext[0]); return STACKREAL; }
{stacknoop}			{ UPDATE_LOC; yylval->opcode = opcodeValue(&yytext[0]); return STACKNOOP; }
{stacklab}			{ UPDATE_LOC; yylval->opcode = opcodeValue(&yytext[0]); return STACKLAB; }

{stringdec}         { UPDATE_LOC; char *trash = strrchr(yytext,'\"'); *trash=0; yytext++;  yylval->vstr = strdup(yytext); return STRING; }
{hex}             	{ UPDATE_LOC; yylval->vint = (int32_t)strtol(yytext, NULL, 16); return HEX; }
'\\{int}' 			{ UPDATE_LOC; yylval->vint = *(yytext+2)-'0'; return BYTE; }
'[^\'']+'     		{ UPDATE_LOC; yylval->vint = charPToInt(yytext); return BYTE; }
{int}               { UPDATE_LOC; yylval->vint = atoi(yytext); return NUM; }
{real}              { UPDATE_LOC; yylval->vfloat = atof(yytext); return REAL; }
{otherM}			{ UPDATE_LOC; yylval->opcode = opcodeValue(&yytext[0]); return OTHERM; }

{id}                { UPDATE_LOC; yylval->vstr = strdup(yytext); return LABEL; }
{spaces}    		{ UPDATE_LOC; }
\n          		{ yycolumn = 1; UPDATE_LOC; return '\n'; }
.           		{ UPDATE_LOC; return yytext[0]; }


%%

// Função usada para transformar char com mais de um elemento num inteiro
int32_t charPToInt(char* yyt){
	unsigned int i=0;
	int32_t r=0;

	while(yyt[++i]!='\''){
		r+=yyt[i];
	}

	return r;

}

uint8_t opcodeValue(char *op)
{
	/* opcodes for operations with integers */
	if(std::string(op) == "iadd")
	{
		return 0x10;
	}
	else if(std::string(op) == "isub")
	{
		return 0x11;
	}
	else if(std::string(op) == "imul")
	{
		return 0x12;
	}
	else if(std::string(op) == "idiv")
	{
		return 0x13;
	}
	else if(std::string(op) == "irem")
	{
		return 0x14;
	}
	else if(std::string(op) == "ineg")
	{
		return 0x15;
	}
	else if(std::string(op) == "iand")
	{
		return 0x16;
	}
	else if(std::string(op) == "ior")
	{
		return 0x17;
	}
	else if(std::string(op) == "ixor")
	{
		return 0x18;
	}
	else if(std::string(op) == "ishl")
	{
		return 0x19;
	}
	else if(std::string(op) == "ishr")
	{
		return 0x1a;
	}
	else if(std::string(op) == "iushr")
	{
		return 0x1b;
	}

	/* opcodes for operations with floats */

	else if(std::string(op) == "fadd")
	{
		return 0x20;
	}
	else if(std::string(op) == "fsub")
	{
		return 0x21;
	}
	else if(std::string(op) == "fmul")
	{
		return 0x22;
	}
	else if(std::string(op) == "fdiv")
	{
		return 0x23;
	}
	else if(std::string(op) == "frem")
	{
		return 0x24;
	}
	else if(std::string(op) == "fneg")
	{
		return 0x25;
	}
	else if(std::string(op) == "i2f")
	{
		return 0x26;
	}
	else if(std::string(op) == "f2i")
	{
		return 0x27;
	}
	else if(std::string(op) == "fcmpg")
	{
		return 0x28;
	}

	/* opcodes for operations with salto */

	else if(std::string(op) == "goto")
	{
		return 0x30;
	}
	else if(std::string(op) == "jsr")
	{
		return 0x31;
	}
	else if(std::string(op) == "ifeq")
	{
		return 0x32;
	}
	else if(std::string(op) == "ifne")
	{
		return 0x33;
	}
	else if(std::string(op) == "iflt")
	{
		return 0x34;
	}
	else if(std::string(op) == "ifge")
	{
		return 0x35;
	}
	else if(std::string(op) == "ifgt")
	{
		return 0x36;
	}
	else if(std::string(op) == "ifle")
	{
		return 0x37;
	}

	/* opcodes for operations with Data Stack */
	else if(std::string(op) == "bipush")
	{
		return 0x50;
	}
	else if(std::string(op) == "ipush")
	{
		return 0x51;
	}
	else if(std::string(op) == "fpush")
	{
		return 0x52;
	}
	else if(std::string(op) == "pop")
	{
		return 0x53;
	}
	else if(std::string(op) == "dup")
	{
		return 0x54;
	}
	else if(std::string(op) == "dup_x1")
	{
		return 0x55;
	}
	else if(std::string(op) == "dup2")
	{
		return 0x56;
	}
	else if(std::string(op) == "swap")
	{
		return 0x57;
	}
	else if(std::string(op) == "load")
	{
		return 0x60;
	}
	else if(std::string(op) == "store")
	{
		return 0x61;
	}
	else if(std::string(op) == "baload")
	{
		return 0x62;
	}
	else if(std::string(op) == "bastore")
	{
		return 0x63;
	}
	else if(std::string(op) == "iaload")
	{
		return 0x64;
	}
	else if(std::string(op) == "iastore")
	{
		return 0x65;
	}
	else if(std::string(op) == "faload")
	{
		return 0x66;
	}
	else if(std::string(op) == "fastore")
	{
		return 0x67;
	}
	else if(std::string(op) == "saload"){
		return 0x68;
	}
	else if(std::string(op) == "laload")
	{
		return 0x69;
	}


	//Outras instruções
	else if(std::string(op) == "nop")
	{
		return 0x00;
	}
	else if(std::string(op) == "halt")
	{
		return 0xF0;
	}
	else if(std::string(op) == "read")
	{
		return 0xF1;
	}
	else if(std::string(op) == "write")
	{
		return 0xF2;
	}
	else if(std::string(op) == "writes"){
		return 0xF3;
	}

	// ERRO
	else
	{
		return 0xFF;
	}
}
