#include <stdlib.h>
#include <term.h>
#include <time.h>

int cmd_uptime(int *args) {
    UNUSED(args);

    uint32_t th, tl;
    th = time_h();
    tl = time_l();

    uint32_t ts = th * (0xffffffff / 1000000) + (tl / 1000000);
    printdec(ts);
    putchar('s');
    putchar(' ');
    printdec(tl % 1000000);
    putchar('u');
    putchar('s');
    putchar('\n');

    return 0;
}
