#include <kbd.h>
#include <stdlib.h>
#include <term.h>

// add command here
int cmd_hello(int *args);
const int hello_name[] = {'h', 'e', 'l', 'l', 'o', '\0'};

int cmd_fib(int *args);
const int fib_name[] = {'f', 'i', 'b', '\0'};

int cmd_help(int *args);
const int cmd_help_name[] = {'h', 'e', 'l', 'p', '\0'};

int cmd_md5(int *args);
const int md5_name[] = {'m', 'd', '5', '\0'};

int cmd_echo(int *args);
const int echo_name[] = {'e', 'c', 'h', 'o', '\0'};

static struct {
    const int *name;
    const char *description;
    int (*handler)(int *);
} cmd_table[] = {
    {cmd_help_name, "help: Display informations about all supported commands\n",
     cmd_help},
    {hello_name, "hello: Print \"hello, world!\"\n", cmd_hello},
    {echo_name, "echo <str>: Print arguments directly\n", cmd_echo},
    {fib_name, "fib <n>: Print the n-th Fibonacci number\n", cmd_fib},
    {md5_name, "md5 <msg>: Print MD5 checksum of arguments\n", cmd_md5},
};

#define NR_CMD (int)(sizeof(cmd_table) / sizeof(cmd_table[0]))

int cmd_help(int *args) {
    UNUSED(args);
    for (int i = 0; i < NR_CMD; i++) printstr(cmd_table[i].description);
    return 0;
}

int cmd[128], cmd_len;
int *cmd_args;

int gcmd() {
    putchar('$');
    cmd_len = 0;
    int ch;

    do {
        ch = getchar();
        if (ch == '\b') {
            backspace();
            cmd[--cmd_len] = '\0';
        } else {
            putchar(ch);
            if (ch == '\n') {
                cmd[cmd_len++] = '\0';
                break;
            } else {
                cmd[cmd_len++] = ch;
            }
        }
    } while (ch != '\n');

    cmd_args = cmd;
    while (*cmd_args != ' ' && *cmd_args != '\n') cmd_args++;
    *cmd_args++ = '\0';
    if (cmd_args - cmd >= cmd_len) cmd_args = NULL;

    for (int i = 0; i < NR_CMD; i++)
        if (strcmp(cmd, cmd_table[i].name) == 0)
            return cmd_table[i].handler(cmd_args);
    printstr("Invalid command\n");
    return 0;
}

int main() {
    printstr("This is RISC-V project, written by Verilog and C.\n");
    printstr("Have fun!\n");

    while (1) {
        gcmd();
    }
}
