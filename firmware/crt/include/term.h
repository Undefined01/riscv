#pragma pack(4)

extern int * const term_addr;

extern const int term_w;
extern const int term_h;
extern const int term_tot;


void newline();
void putchar(int ch);
void puts(char *str);
void printhex(unsigned int num);
void set_cursor(int row, int col);
int  get_cursor_row();
int  get_cursor_col();
void set_cursor_row(int row);
void set_cursor_col(int col);
