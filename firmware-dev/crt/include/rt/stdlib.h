#pragma pack(4)

#define NULL ((void *)0)
#define UNUSED(...) ((void)(__VA_ARGS__))

typedef unsigned int uint32_t;

int rt_rand();
void rt_sleep(unsigned int us);
int rt_strcmp(const int *s1, const int *s2);
int rt_atoi(const int *nptr);
