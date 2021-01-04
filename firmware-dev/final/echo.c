#include <rt/term.h>

int cmd_echo(int *args) {
    while (*args != '\0') rt_printchar(*args++);
    rt_printchar('\n');
    return 0;
}
