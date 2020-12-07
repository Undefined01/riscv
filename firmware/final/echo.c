#include <term.h>

int cmd_echo(int *args) {
    while (*args != '\0') putchar(*args++);
    putchar('\n');
    return 0;
}