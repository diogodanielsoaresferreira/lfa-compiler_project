; Imprime o abecedário
.text
	bipush 0
for:
	dup
	bipush 26
	isub
	ifge endfor	
	dup
	ipush 'a'
	iadd
	write
	bipush 1
	iadd
	goto for

endfor:
	halt
