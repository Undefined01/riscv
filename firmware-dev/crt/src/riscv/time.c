volatile unsigned int * const time_addr = (void*)0xa1000020;

unsigned int rt_timel() {
	return time_addr[0];
}

unsigned int rt_timeh() {
	return time_addr[1];
}

unsigned long long rt_time() {
	return *(volatile unsigned long long *)time_addr;
}
