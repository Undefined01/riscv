.include "common.h"

li x1, 1
li x2, 2
beq x1, x2, skip_end1
# 应该执行这些指令
ori x5, x5, 1
skip_end1:
addi x2, x2, -5
blt x1, x2, skip_end2
# 应该执行这些指令
ori x5, x5, 2
skip_end2:
bltu x1, x2, skip_end3
# 不应该执行这条指令
ori x5, x5, 4
skip_end3:
bge x2, x1, skip_end4
# 应该执行这条指令
ori x5, x5, 8
skip_end4:
