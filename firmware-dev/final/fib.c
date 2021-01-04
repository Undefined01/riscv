#include <rt/stdlib.h>
#include <rt/term.h>

int cmd_fib(int *args) {
    if (args == 0) {
        rt_printstr("need arg\n");
        return 0;
    }

    int n = rt_atoi(args);
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

    rt_printstr("The ");
    rt_printdec((unsigned)n);
    rt_printstr(" fib is ");
    rt_printdec(y);
    rt_printchar('\n');

    return 0;
}
