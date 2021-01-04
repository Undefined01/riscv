#include <unistd.h>

const int KEYUP_MASK = 1 << 17;
const int EXTEND_MASK = 1 << 16;
const int SCANCODE_MASK = 0x0000ff00;
const int ASCII_MASK = 0x000000ff;

// 暂不支持原始键码的模拟，只模拟最后 8 位的 ASCII 码
int rt_kbd_pollevent() {
    char ch[2];
    ssize_t n = read(0, ch, 1);
    if (n > 0) return ch[0];
    return 0;
}

int rt_kbd_waitevent() {
    int event;
    do {
        event = rt_kbd_pollevent();
    } while (event == 0);
    return event;
}

int rt_getchar() {
    int ch;
    do {
        ch = rt_kbd_pollevent();
    } while (ch == 0);
    return ch;
}
