# 测试读取与写入内存
.include "common.h"

.equ VMEM_ADDR, 0xa0000000

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
