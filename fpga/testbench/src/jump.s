.include "common.h"

li x1, 1
jal x2, skip_end1
# 不应该执行这些指令
skip_start1:
li x1, 100
li x2, 100
li x3, 100
skip_end1:
addi x1, x1, 10
# 此时x2应为skip_start1
jalr x4, %lo(skip_end2-skip_start1)(x2)
skip_start2:
li x5, 100
li x6, 100
li x7, 100
skip_end2:
addi x1, x1, 10
