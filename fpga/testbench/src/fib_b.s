# 使用分支指令计算斐波那契第20项
.include "common.h"

li x1, 1		# 第零项
li x2, 1		# 第一项
li x5, 19		# 迭代19次

LOOP:
jal x10, step
bne x5, x0, LOOP

j _halt

step:
add x3, x1, x2
mv x1, x2
mv x2, x3
addi x5, x5, -1
jr x10
