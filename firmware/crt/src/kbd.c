#include <kbd.h>

int* const kbd_addr = (void*)0xa1000010;

const int KEYUP_MASK = 1 << 17;
const int EXTEND_MASK = 1 << 16;
const int SCANCODE_MASK = 0x0000ff00;
const int ASCII_MASK = 0x000000ff;

int kbd_pollevent() {
    int ch, base;
    asm volatile(
        "lui %[base], %%hi(%[addr])\n\t"
        "lw %[ch], %%lo(%[addr])(%[base])\n\t"
        : [ base ] "=r"(base), [ ch ] "=r"(ch)
        : [ addr ] "i"(kbd_addr));
	return ch;
}

int kbd_waitevent() {
    int event;
    do {
        event = *kbd_addr;
    } while (event != 0);
    return event;
}

int getchar() {
    int ch, base;
    while (1) {
        // 防止此处被gcc优化成单byte的读写
        asm volatile(
            "lui %[base], %%hi(%[addr])\n\t"
            "lw %[ch], %%lo(%[addr])(%[base])\n\t"
            "andi %[ch], %[ch], 0xff"
            : [ base ] "=r"(base), [ ch ] "=&r"(ch)
            : [ addr ] "i"(kbd_addr));
        if (ch != 0) return ch;
    }
}
