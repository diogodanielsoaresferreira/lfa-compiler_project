.data
L1: .word 1, 2
L2: .float 3.1, 4.5
str:.string "Working"

.text
	laload L1
	ipush 0
	iaload
	ipush 1
	iadd
	laload L2
	ipush 1
	faload
	fpush 2
	fadd
	laload str
	saload
	writes

	halt
