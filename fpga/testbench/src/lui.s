.include "common.h"

.equ VMEM_ADDR, 0xa0000000

lui x1, %hi(VMEM_ADDR)
addi x2, x1, 1
addi x3, x1, 2
addi x4, x1, 3
addi x5, x1, 4
