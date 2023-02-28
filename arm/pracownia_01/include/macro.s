.macro load32, register, value
    movw \register\(), #:lower16:\value
    movt \register\(), #:upper16:\value
.endm

.macro store32 address value
.align
ldr r0, [pc, #4]
ldr r1, [pc, #8]
str r1, [r0]
b . + 10
.word \address
.word \value
.endm

.macro store8 address value
.align
ldr r0, [pc, #8]
movw r1, #\value
str r1, [r0]
b . + 8
nop
.word \address
.endm

.macro readreg register address
.align
ldr r0, [pc, #4]
ldr \register\(), [r0]
b . + 8
nop
.word \address
.endm

.macro storereg address register
.align
ldr r0, [pc, #4]
str \register\(), [r0]
b . + 8
nop
.word \address
.endm
