.data
f:	.float 1,1.1,-2.3


.text
	fpush 1
	fpush 1.1
	fpush -2.3
	fpush -1.1
	ipush -1
	bipush 4
	ipush -65000
	fpush 5
	fpush 1.1
	fpush 1.1
	fadd
	fsub
