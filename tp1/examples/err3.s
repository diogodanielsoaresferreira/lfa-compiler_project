; Comentário dentro de ; outro comentário .text não deve dar ipush erro

.data

byt:	.byte 'ab' ;erro

.text
	iadd 0x1 ;Erro
	load .data ;Erro
	add 1 ;Erro
	nop 'a';Erro
