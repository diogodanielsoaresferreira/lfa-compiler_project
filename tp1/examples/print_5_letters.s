; recebe uma letra e imprime as 5 seguintes

.text
	read
	ipush 0
for:
	dup
	bipush 5
	isub
	ifge endfor	
	swap
	ipush 1
	iadd
	dup
	write
	swap
	bipush 1
	iadd
	goto for

endfor:
	halt
