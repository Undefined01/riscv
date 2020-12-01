.section entry

.globl _start
_start:
	lui sp, %hi(_stack_pointer)
	addi sp, sp, %lo(_stack_pointer)
	call main
stop:
	j stop
