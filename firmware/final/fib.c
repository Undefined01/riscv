#include <term.h>
#include <stdlib.h>

int fib(int * args) {
    if (args == 0) {
        puts("need arg\n");
        return 0;
    }
    int n = atoi(args);

    if (n <= 0) {
        printhex(0);
        putchar('\n');
        return 0;
    }

    int x = 0, y = 1, z;
    for (int i = 1; i < n; i ++) {
        z = x + y;
        x = y;
        y = z;
    }

    printhex(y);
    putchar('\n');
    return 0;
}