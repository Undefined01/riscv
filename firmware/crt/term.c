#include <term.h>

int * const term_addr = (void*)0xa0000000;

const int term_w = 70;
const int term_h = 30;
const int term_tot = term_w * term_h;

static int cursor_tot = 0;
static int cursor_row = 0;
static int cursor_col = 0;

void newline() {
	if (cursor_row == term_h - 1) {
		int i = 0;
		for (; i < term_tot - term_w; i++)
			*(int *)((int)term_addr + i) = *(int *)((int)term_addr + i + term_w);
		for (;i < term_tot; i++)
			*(int *)((int)term_addr + i) = 0;
		cursor_tot -= cursor_col;
		cursor_col = 0;
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

void _putch(int ch) {
	*(int *)((int)term_addr + cursor_tot) = ch;
}

void putchar(int ch) {
	if (ch == '\n') {
		newline();
		return;
	}
	*(int *)((int)term_addr + cursor_tot) = ch;
	step_cursor();
}

void puts(char *str) {
	int *s = (int *)str;
	unsigned int pack, ch;
	while (1) {
		pack = *s++;
		ch = pack & 0xff;
		if (ch == 0) break;
		putchar(ch);
		pack >>= 8;
		ch = pack & 0xff;
		if (ch == 0) break;
		putchar(ch);
		pack >>= 8;
		ch = pack & 0xff;
		if (ch == 0) break;
		putchar(ch);
		pack >>= 8;
		ch = pack;
		if (ch == 0) break;
		putchar(ch);
		pack >>= 8;
	}
}

void printhex(unsigned int num) {
	int len = 0;
	int d[8];
	do {
		d[len++] = num & 0xff;
		num >>= 8;
	} while (num);
	while (len--)
		putchar(d[len]);
}

void set_cursor(int row, int col) {
	cursor_row = row;
	cursor_col = col;
	cursor_tot = row * term_w + col;
}
