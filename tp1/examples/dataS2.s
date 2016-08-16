.data
L1:	.word 1,2,3
L2:	.word 2,3,4
L3:	.byte 'a','b','c'
L4:	.byte 'd','e','f'
L5:	.string "abc"
L6:	.string "jkl"
L7:	.float 1.2,2.2,3.2
L8:	.float 2.2,2.3,4.2
L9:	.space 100
L10:.space 100


.text
	; Deve escrever a d a a 3
	load L3
	write
	load L4
	write
	load L3
	store L4
	load L3
	write
	load L4
	write
	load L1
	load L2
	iadd
	bipush '0'
	iadd
	write
	load L5

	; Teste baload deve imprimir a b c a e f
	bipush 6
	bipush 0
	baload
	write

	bipush 6
	bipush 1
	baload
	write

	bipush 6
	bipush 2
	baload
	write

	bipush 9
	bipush 0
	baload
	write


	bipush 9
	bipush 1
	baload
	write

	bipush 9
	bipush 2
	baload
	write

	; Teste bastore. Deve imprimir 'a' e 'f'

	bipush 20
	bipush 0
	ipush 'a'
	bastore

	bipush 20
	bipush 0
	baload
	write

	
	bipush 22
	bipush 0
	ipush 'f'
	bastore

	bipush 22
	bipush 0
	baload
	write

	;Teste iaload e iastore

	bipush 23
	bipush 1
	ipush 'f'
	iastore

	ipush 23
	ipush 1
	iaload
	write

	;Teste faload e fastore

	bipush 14
	ipush 0
	faload
	write

	bipush 15
	ipush 0
	fpush 2.2
	fastore


	halt

