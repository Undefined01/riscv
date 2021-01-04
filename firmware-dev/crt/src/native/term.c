#include <stdio.h>
#include <string.h>

const int term_w = 70;
const int term_h = 30;
const int term_tot = 70 * 30;
static int vga_buf[70 * 30];

static int cursor_tot = 0;
static int cursor_row = 0;
static int cursor_col = 0;

void clear_screen() {
    printf("\033c");        // 清屏
    printf("\033[?25l");    // 隐藏光标
    memset(vga_buf, 0, sizeof(vga_buf));
    cursor_tot = 0;
    cursor_col = 0;
    cursor_row = 0;
}

static void redraw() {
    printf("\033c");        // 清屏
    printf("\033[?25l");    // 隐藏光标
    for (int i = 0; i < term_h; i++) {
        printf("\033[%d;1H", i + 1);
        for (int j = 0; j < term_w; j++)
            putchar(vga_buf[i * term_w + j]);
    }
}

static void _putch(int ch) {
    vga_buf[cursor_tot] = ch;
    printf("\033[%d;%dH%c", cursor_row + 1, cursor_col + 1, ch);
}

void newline() {
    if (cursor_row == term_h - 1) {
        int i = 0;
        for (; i < term_tot - term_w; i++) vga_buf[i] = vga_buf[i + term_w];
        for (; i < term_tot; i++) vga_buf[i] = 0;
        cursor_tot -= cursor_col;
        cursor_col = 0;
        redraw();
    } else {
        cursor_tot += term_w - cursor_col;
        cursor_row++;
        cursor_col = 0;
    }
}

void step_cursor() {
    if (cursor_col == term_w - 1) {
        newline();
    } else {
        cursor_tot++;
        cursor_col++;
    }
}

void revstep_cursor() {
    if (cursor_col != 0) {
        cursor_tot--;
        cursor_col--;
    }
}

void backspace() {
    revstep_cursor();
    _putch(0);
}

void rt_printchar(int ch) {
    if (ch == '\n') {
        newline();
        return;
    }
    _putch(ch);
    step_cursor();
}

void rt_printstr(const char *str) {
    const unsigned int *s = (const unsigned int *)str;
    unsigned int pack;
    int ch;
    while (1) {
        pack = *s++;
        ch = pack & 0xff;
        if (ch == 0) break;
        rt_printchar(ch);
        pack >>= 8;
        ch = pack & 0xff;
        if (ch == 0) break;
        rt_printchar(ch);
        pack >>= 8;
        ch = pack & 0xff;
        if (ch == 0) break;
        rt_printchar(ch);
        pack >>= 8;
        ch = (signed)pack;
        if (ch == 0) break;
        rt_printchar(ch);
        pack >>= 8;
    }
}

void rt_printhex(unsigned int num) {
    int len = 0;
    int d[8];
    do {
        d[len++] = num & 0xf;
        num >>= 4;
    } while (num);
    while (len--) {
        if (d[len] >= 10)
            rt_printchar(d[len] + 'a' - 10);
        else
            rt_printchar(d[len] + '0');
    }
}

void rt_printdec(unsigned int num) {
    int len = 0;
    int d[8];
    do {
        d[len++] = (signed)(num % 10);
        num /= 10;
    } while (num);
    while (len--) rt_printchar(d[len] + '0');
}

int get_cursor_row() { return cursor_row; }

int get_cursor_col() { return cursor_col; }

void set_cursor_row(int row) {
    cursor_tot += (row - cursor_row) * term_w;
    cursor_row = row;
}

void set_cursor_col(int col) {
    cursor_tot += col - cursor_col;
    cursor_col = col;
}

void set_cursor(int row, int col) {
    cursor_row = row;
    cursor_col = col;
    cursor_tot = row * term_w + col;
}
