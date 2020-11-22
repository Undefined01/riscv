.include "common.h"

li x1, 1
jal x2, skip
# 不应该执行这些指令
li x1, 100
li x2, 100
li x3, 100
skip:
addi x1, x1, 10
