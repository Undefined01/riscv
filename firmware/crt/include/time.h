#pragma pack(4)

extern volatile unsigned int * const time_addr;

extern const int term_w;
extern const int term_h;
extern const int term_tot;


unsigned int time_l();
unsigned int time_h();
unsigned long long time();
