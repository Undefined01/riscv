#include <sys/time.h>
#include <stdlib.h>

unsigned long long start_time;

unsigned long long rt_time() {
	struct timeval now;
	gettimeofday(&now, NULL);
	return (unsigned long long)now.tv_sec * 1000000 + (unsigned long long)now.tv_usec - start_time;
}

unsigned int rt_timel() {
	return (unsigned int)(rt_time() & 0xffffffff);
}

unsigned int rt_timeh() {
	return (unsigned int)(rt_time() >> 32);
}
