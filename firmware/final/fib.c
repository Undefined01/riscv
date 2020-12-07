#include <stdlib.h>
#include <term.h>

int cmd_fib(int *args) {
    if (args == 0) {
        printstr("need arg\n");
        return 0;
    }

    int n = atoi(args);
    unsigned int x = 0, y = 1, z;

    if (n <= 0) {
        y = 0;
    } else {
        for (int i = 1; i < n; i++) {
            z = x + y;
            x = y;
            y = z;
        }
    }

    printstr("The ");
    printdec((unsigned)n);
    printstr(" fib is ");
    printdec(y);
    putchar('\n');

    return 0;
}
