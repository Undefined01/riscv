#include <time.h>

volatile unsigned int * const time_addr = (void*)0xa1000020;

unsigned int time_l() {
	return time_addr[0];
}

unsigned int time_h() {
	return time_addr[1];
}

unsigned long long time() {
	return *(unsigned long long *)time_addr;
}
