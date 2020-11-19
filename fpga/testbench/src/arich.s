
# 计算lowbit
li x1, 0x78
neg x2, x1
and x5, x1, x2;	# x5=8
li x1, 0x54
neg x2, x1
and x6, x1, x2;	# x6=4

li x1, 0x110
addi x2, x1, -1
xor x2, x1, x2
and x7, x1, x2;	# x7=16

nop
nop
nop
nop
nop
nop
