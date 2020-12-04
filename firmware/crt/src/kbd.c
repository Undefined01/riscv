#include <kbd.h>

int * const kbd_addr  = (void*)0xa1000010;

int kbd_pollevent() {
	return *kbd_addr;
}

int getchar() {
	int ch;
	int base;
	while (1) {
		// 防止此处被gcc优化成单byte的读写
		asm volatile(
			"lui %[base], %%hi(%[addr])\n\t"
			"lw %[ch], %%lo(%[addr])(%[base])\n\t"
			"andi %[ch], %[ch], 0xff"
			: [base]"=r"(base), [ch]"+r"(ch)
			: [addr]"i"(kbd_addr)
		);
		if (ch != 0)
			return ch;
	}
}
