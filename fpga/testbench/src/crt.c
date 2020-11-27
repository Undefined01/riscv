int * const term_addr = (void*)0xa0000000;
int * const kbd_addr  = (void*)0xa1000010;
int * const time_addr = (void*)0xa1000020;

const int term_w = 70;
const int term_h = 30;
const int term_tot = term_w * (term_h - 1);

static int cursor_tot = 0;
static int cursor_row = 0;
static int cursor_col = 0;

static void newline() {
	if (cursor_row == term_h - 1) {
		for (int i = 0; i < term_tot; i++)
			term_addr[i] = term_addr[i + term_w];
		cursor_tot -= cursor_col;
		cursor_col = 0;
	} else {
		cursor_tot += term_w - cursor_col;
		cursor_row++;
		cursor_col = 0;
	}
}

int putchar(int ch) {
	term_addr[cursor_tot] = ch;
	if (ch == '\n' || cursor_col == term_w - 1) {
		newline();
	} else {
		cursor_tot++;
		cursor_col++;
	}
}

void set_cursor(int row, int col) {
	cursor_row = row;
	cursor_col = col;
	cursor_tot = row * term_w + col;
}

void _start() {
	extern char _stack_pointer;
	extern int main();

	asm volatile(
		"lui sp, %%hi(%[stack_pointer]);"
		"addi sp, %%lo(%[stack_pointer])"
		:: [stack_pointer]"i" (&_stack_pointer)
	);
	main();
	while (1);
}
