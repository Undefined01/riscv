#include <rt/time.h>

static unsigned int next = 115;

int rt_rand() {
    // RAND_MAX assumed to be 32767
    next = next * 1103515245 + 12345;
    return (next / 65536) % 32768;
}

void rt_sleep(unsigned int us) {
    unsigned int start = rt_timel();
    while (rt_timel() - start < us)
        ;
}

int rt_strcmp(const int* s1, const int* s2) {
    int c1, c2;
    do {
        c1 = *s1++;
        c2 = *s2++;
        if (c1 == '\0') return c1 - c2;
    } while (c1 == c2);
    return c1 - c2;
}

int rt_atoi(const int* nptr) {
    int x = 0;
    while (*nptr == ' ') {
        nptr++;
    }
    while (*nptr >= '0' && *nptr <= '9') {
        x = x * 10 + *nptr - '0';
        nptr++;
    }
    return x;
}
