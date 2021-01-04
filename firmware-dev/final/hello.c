#include <rt/stdlib.h>
#include <rt/term.h>

int cmd_hello(int *args) {
    UNUSED(args);
    rt_printstr("hello, world!\n");
    return 0;
}
