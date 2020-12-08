#pragma pack(4)

#define NULL ((void *)0)
#define UNUSED(...) ((void)(__VA_ARGS__))

typedef unsigned int uint32_t;

int rand();
void sleep(unsigned int us);
int strcmp(const int *s1, const int *s2);
int atoi(const int *nptr);
