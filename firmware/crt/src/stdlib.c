#include <stdlib.h>

int buf1[12];
int buf2[12];

int strcmp(const int* s1, const int* s2) {
    unsigned int c1, c2;
    do {
        c1 = (unsigned int)*s1++;
        c2 = (unsigned int)*s2++;
        if (c1 == '\0') return c1 - c2;
    } while (c1 == c2);
    return c1 - c2;
}

int atoi(const int* nptr) {
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
