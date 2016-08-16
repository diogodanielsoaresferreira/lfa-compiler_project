; soma as constantes 10 e 20
.text
    bipush 10
    ipush 20
    iadd
    

; soma as constantes 10 e 20
.data
var0:   .word 10
var1:   .word 20
vvv:    .space 0x100


.text
    load var0
    load var1
    iadd
    halt
