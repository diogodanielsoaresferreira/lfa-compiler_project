.text
L1:	
	ipush 1
	ipush 2
	ifeq L1
	ipush 0
	ifeq L3
L2:
	ipush 2
	iadd
	ret
L3:
	ipush 1
	isub
	jsr L2
	ipush 5
	goto L1
