.section text_end

# 在代码段后增加多个指令，保证流水线执行完毕
nop
nop
nop
nop
nop
nop

# include 位置应该是开头，设置entry和_start符号
.section entry
.globl _start
_start:
