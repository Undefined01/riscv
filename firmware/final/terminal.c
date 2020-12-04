#include <term.h>
#include <kbd.h>
#include <stdlib.h>

// add command here
int hello(int *);
const int hello_name[] = {'h', 'e', 'l', 'l', 'o', '\0'};

int fib(int *);
const int fib_name[] = {'f', 'i', 'b', '\0'};
//
int cmd_help(int *);
const int cmd_help_name[] = {'h', 'e', 'l', 'p', '\0'};
//

static struct {
  const int *name;
  char *description;
  int (*handler) (int *);
} cmd_table [] = {
  { cmd_help_name, "help: Display informations about all supported commands\n", cmd_help },
  { hello_name, "hello: Hell, world!\n", hello },
  { fib_name, "fib arg: fibonacii[arg]\n", fib },

  // add command here
};

#define NR_CMD (int)(sizeof(cmd_table) / sizeof(cmd_table[0]))

int cmd_help(int * args) {
  int i;
  for (i = 0; i < NR_CMD; i ++) {
    puts(cmd_table[i].description);
  }

  return 0;
}

int cmd[40], cmd_len = 0;
int * cmd_args;

void gcmd() {
    putchar('$');
    while (cmd_len == 0 || cmd[cmd_len - 1] != '\n') {
        int ch = getchar();
        // if (cmd_len == 0) putchar('!');
        if (ch == '\b') {
          backspace();
          cmd[-- cmd_len] = '\0';
        } else {
          cmd[cmd_len ++] = ch;
          putchar(ch);
        }
    }

    for (int i = 0; i < cmd_len; i ++) if (cmd[i] == ' ' || cmd[i] == '\n') {
      cmd[i] = '\0';
      cmd_args = &cmd[i + 1];
      break;
    }
}

void exec() {
  int i;
  for (i = 0; i < NR_CMD; i ++) {
    if (strcmp(cmd, cmd_table[i].name) == 0) {
      // puts("exec");
      if (cmd_table[i].handler(cmd_args) < 0) { return; }
      break;
    }
  }
}

void clear() {
  while (cmd_len) {
    cmd_len --;
    // if (cmd_len == 0) putchar('!');
    // putchar(cmd[cmd_len]);
    cmd[cmd_len] = '\0';
  }
  cmd_args = 0;
}

int main() {
	puts("This is RISC-V project, written by Verilog and C.\n");
	puts("Have fun!\n");

	while (1) {
        gcmd();
        // for (int i = 0; i < cmd_len; i ++) putchar(cmd[i]); putchar('\n');
        exec();
        clear();
	}
}
