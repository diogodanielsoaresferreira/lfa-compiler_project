/*
	LFA 2016 - Grupo 3
	Projeto 2
	David Almeida, Diogo Ferreira, Francisco Cunha, José Castanheira
	Lexer
*/

%{
    #include <stdlib.h>
    #include <stdint.h>

    #include "parser.h"
    #include "ast.h"

    #define UPDATE_LOC { \
        yylloc->first_line = yylloc->last_line = yylineno; \
        yylloc->first_column = yycolumn+1; \
        yycolumn += yyleng; \
        yylloc->last_column = yycolumn+yyleng; }

    int32_t charPToInt(char* yyt);
%}


%option noyywrap
%option nounput noinput
%option nodefault yylineno
%option reentrant bison-bridge bison-locations
%option header-file="lexer.h"

id          [a-zA-Z][a-zA-Z0-9_]*
int 		[0-9][0-9]*
real    	(([0-9]+\.?[0-9]*)|(\.[0-9]+))([Ee][+-]?[0-9]+)?
hex 		0x[0-9A-Fa-f]+
stringdec	\"(\\.|[^"])*\"

comment1    "//".*
comment2    "/*"

%x COMM

%%

"program"   { UPDATE_LOC; return PROGRAM; }
"procedure" { UPDATE_LOC; return PROCEDURE; }
"int"		{ UPDATE_LOC; return TINT; }
"byte"		{ UPDATE_LOC; return TBYTE; }
"float" 	{ UPDATE_LOC; return TFLOAT; }
"string"	{ UPDATE_LOC; return TSTRING; }
"&"        	{ UPDATE_LOC; return BAND; }
"|"        	{ UPDATE_LOC; return BOR; }
"^"        	{ UPDATE_LOC; return BXOR; }
"<<"        { UPDATE_LOC; return BSL; }
">>"        { UPDATE_LOC; return BSR; }
"~"        	{ UPDATE_LOC; return BNOT; }
"++"        { UPDATE_LOC; return INCREMENT; }
"--"        { UPDATE_LOC; return DECREMENT; }
"+="        { UPDATE_LOC; return ADDEQ; }
"-="        { UPDATE_LOC; return SUBEQ; }
"*="        { UPDATE_LOC; return MULEQ; }
"/="        { UPDATE_LOC; return DIVEQ; }
"%="        { UPDATE_LOC; return MODEQ; }
"+"         { UPDATE_LOC; return ADD; }
"-"         { UPDATE_LOC; return SUB; }
"*"         { UPDATE_LOC; return MUL; }
"/"         { UPDATE_LOC; return DIV; }
"%"         { UPDATE_LOC; return MOD; }
{hex}       { UPDATE_LOC; yylval->ivalue = (int32_t)strtol(yytext, NULL, 16); return INT; }
'\\{int}'	{ UPDATE_LOC; yylval->ivalue = *(yytext+2)-'0'; return INT; }
'[^\'']+'	{ UPDATE_LOC; yylval->ivalue = charPToInt(yytext); return INT; }
{int}      	{ UPDATE_LOC; yylval->ivalue = atoi(yytext); return INT; }
"if"		{ UPDATE_LOC; return IF; }
"else"		{ UPDATE_LOC; return ELSE; }
"loop"		{ UPDATE_LOC; return LOOP; }
"break"		{ UPDATE_LOC; return BREAK; }
"exit"		{ UPDATE_LOC; return EXIT; }
"readChar"	{ UPDATE_LOC; return RCHAR; }
"readInt"	{ UPDATE_LOC; return RINT; }
"printChar"	{ UPDATE_LOC; return PCHAR; }
"printInt"	{ UPDATE_LOC; return PINT; }
"printStr"	{ UPDATE_LOC; return PSTR; }
"or"        { UPDATE_LOC; return LOR; }
"and"       { UPDATE_LOC; return LAND; }
"xor"       { UPDATE_LOC; return XOR; }
"=="        { UPDATE_LOC; return EQUAL; }
"!="        { UPDATE_LOC; return NEQUAL; }
"<"         { UPDATE_LOC; return LT; }
">"         { UPDATE_LOC; return BT; }
"<="        { UPDATE_LOC; return LEQ; }
">="        { UPDATE_LOC; return BEQ; }
"not"       { UPDATE_LOC; return NOT; }
{stringdec} { UPDATE_LOC; char *trash = strrchr(yytext,'\"'); *trash=0; yytext++; yylval->svalue = strdup(yytext); return STRING; }
{id}        { UPDATE_LOC; yylval->svalue = strdup(yytext); return ID; }
{real}      { UPDATE_LOC; yylval->fvalue = atof(yytext); return REAL; }
{comment1}  {}

"/*"        { yycolumn+=yyleng; BEGIN(COMM); }
<COMM>.     { yycolumn+=yyleng; }
<COMM>"\n"  { yycolumn = 1; }
<COMM>"*/"  { yycolumn+=yyleng; BEGIN(INITIAL); }

[ \t]       {yycolumn+=yyleng; }

.           { UPDATE_LOC; return yytext[0]; }

\n          { yycolumn = 0; }

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
