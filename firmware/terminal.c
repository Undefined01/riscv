#include <term.h>
#include <kbd.h>

static struct {
  char *name;
  char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { cmd_help_name, "help: Display informations about all supported commands", cmd_help },
  { hello_name, "hello: Hell, world!", hello },

  // add command here
};

#define NR_CMD (sizeof(cmd_table) / sizeof(cmd_table[0]))

//

int strcmp(const int* s1, const int* s2) {
  int i;

  for (i = 0; s1[i] != '\0' && s2[i] != '\0' && s1[i] == s2[i]; i++) ;

  if (s1[i] > s2[i]) return 1;
  else if (s1[i] == s2[i]) return 0;
  else return -1;
}

//

int cmd[40], cmd_len;

void gcmd() {
    while (cmd_len == 0 || cmd[cmd_len - 1] != '\n') {
        cmd[cmd_len ++] = getchar();
    }
}

void exec() {
  int i;
  for (i = 0; i < NR_CMD; i ++) {
    if (strcmp(cmd, cmd_table[i].name) == 0) {
      if (cmd_table[i].handler() < 0) { return; }
      break;
    }
  }
}

// 
void hello();
const int hello_name = {'h', 'e', 'l', 'l', 'o', '\0'};
//
void cmd_help() {
  int i;
  for (i = 0; i < NR_CMD; i ++) {
    puts(cmd_table[i].description);
  }
}
const int cmd_help_name = {'h', 'e', 'l', 'p', '\0'};
//

int main() {
	puts("This is RISC-V project, written by Verilog and C.\n");
	puts("Have fun!\n");

	while (1) { //
        gcmd();
        exec();
	}
}
