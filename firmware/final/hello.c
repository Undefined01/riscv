#include <stdlib.h>
#include <term.h>

int cmd_hello(int *args) {
    UNUSED(args);
    printstr("hello, world!\n");
    return 0;
}
