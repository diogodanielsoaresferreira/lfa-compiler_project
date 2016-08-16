.data
L1:	.string "LFA"
L2:	.string "All Working"

.text
	ipush -1
	ipush 2
	iadd
	ipush 'a'
	ipush 'b'
	ipush 0
	saload
	writes
	ipush 1
	saload
	writes
	halt
