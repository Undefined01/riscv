.section text_end

# 在代码段后增加多个指令，保证流水线执行完毕
.globl _halt
_halt:
nop
nop
nop
nop
nop
nop
# Magic number，用以识别结束
.word 0x7f2a214b

# include 位置应该是开头，设置entry和_start符号
.section entry
.globl _start
_start:
