#include <time.h>

unsigned int * const time_addr = (void*)0xa1000020;

unsigned int time_l() {
	return time_addr[0];
}

unsigned int time_h() {
	return time_addr[1];
}
