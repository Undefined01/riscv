#pragma pack(4)

extern volatile int * const kbd_addr;

int getchar();
int kbd_pollevent();
int kbd_waitevent();
