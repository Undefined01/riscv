# 测试读取与写入内存
.include "common.h"

li x1, 1
lw x2, %lo(a)(x0)
# 测试MEM转发
mv x3, x2
sw x3, %lo(b)(x0)
lw x4, %lo(b)(x0)


.data

.globl a
.globl b
a:	.word 0x12345678
b:	.word 0x87654321
