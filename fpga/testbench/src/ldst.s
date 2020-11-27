# 测试读取与写入内存
.include "common.h"

li x1, 1
lw x2, %lo(a)(x0)
# 测试MEM转发
mv x3, x2
sw x3, %lo(b)(x0)
lw x4, %lo(b)(x0)
# 连续读取
lw x5, %lo(b)(x0)
andi x5, x5, 0xff
# 连续写入
li x6, 100
sw x6, %lo(a)(x0)
sw x6, %lo(b)(x0)
lw x7, %lo(a)(x0)
lw x8, %lo(b)(x0)


.data
a:	.word 0x12345678
b:	.word 0x87654321
