#include <rt/stdlib.h>
#include <rt/term.h>
#include <rt/time.h>

int cmd_uptime(int *args) {
    UNUSED(args);

    uint32_t th, tl;
    th = rt_timeh();
    tl = rt_timel();

    uint32_t ts = th * (0xffffffff / 1000000) + (tl / 1000000);
    rt_printdec(ts);
    rt_printchar('s');
    rt_printchar(' ');
    rt_printdec(tl % 1000000);
    rt_printchar('u');
    rt_printchar('s');
    rt_printchar('\n');

    return 0;
}
