# 测试读取与写入内存
.include "common.h"

.equ VMEM_ADDR, 0xa0000000
.equ KBD_ADDR, 0xa1000010
.equ TIME_ADDR, 0xa1000020

lui x1, %hi(VMEM_ADDR)

li x2, 'h'
sw x2, %lo(0)(x1)
li x2, 'e'
sw x2, %lo(1)(x1)
li x2, 'l'
sw x2, %lo(2)(x1)
li x2, 'l'
sw x2, %lo(3)(x1)
li x2, 'o'
sw x2, %lo(4)(x1)
li x2, ' '
sw x2, %lo(5)(x1)
li x2, 'w'
sw x2, %lo(6)(x1)
li x2, 'o'
sw x2, %lo(7)(x1)
li x2, 'r'
sw x2, %lo(8)(x1)
li x2, 'l'
sw x2, %lo(9)(x1)
li x2, 'd'
sw x2, %lo(10)(x1)
li x2, '!'
sw x2, %lo(11)(x1)

li x5, 0
lui x4, %hi(1000000)
addi x4, x4, %lo(1000000)
addi x1, x1, 12
li x3, '.'
sw x3, (x1)
addi x1, x1, 1


mv x11, x4
jal x10, printhex

mv x11, x1
jal x10, printhex

lui x2, %hi(TIME_ADDR)
LOOP:
lw x3, %lo(KBD_ADDR)(x2)
beq x0, x3, KBD_END
mv x11, x3
jal x10, printhex
li x3, '-'
sw x3, (x1)
addi x1, x1, 1
KBD_END:
lw x3, %lo(TIME_ADDR)(x2)
sub x3, x3, x5
blt x3, x4, TIME_END
mv x5, x3
li x3, '*'
sw x3, (x1)
addi x1, x1, 1
TIME_END:
j LOOP

printhex:
bne x11, x0, NOT_ZERO
li x12, '0'
sw x12, (x1)
addi x1, x1, 2
jr x10
NOT_ZERO:
andi x12, x11, 0xf
addi x12, x12, 48
sw x12, (x1)
addi x1, x1, 1
srli x11, x11, 4
bne x11, x0, NOT_ZERO
addi x1, x1, 1
jr x10
