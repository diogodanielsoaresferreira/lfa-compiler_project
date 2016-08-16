.text
L1:	
	ipush 1
	ipush 2
	ifeq L1
	ipush 0
	ifeq L1
L2:
	iadd
