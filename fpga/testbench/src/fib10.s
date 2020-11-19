# 只用加法计算斐波那契数列第十项
# 最终x2应该等于89
.include "common.h"

li x1, 1		# 第零项
li x2, 1		# 第一项

add x3, x1, x2	# 第二项
mv x1, x2
mv x2, x3

add x3, x1, x3	# 第三项
mv x1, x2
mv x2, x3

add x3, x1, x3
mv x1, x2
mv x2, x3

add x3, x1, x3
mv x1, x2
mv x2, x3

add x3, x1, x3
mv x1, x2
mv x2, x3

add x3, x1, x3
mv x1, x2
mv x2, x3

add x3, x1, x3
mv x1, x2
mv x2, x3

add x3, x1, x3
mv x1, x2
mv x2, x3

add x3, x1, x3
mv x1, x2
mv x2, x3
