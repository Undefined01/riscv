#include <fcntl.h>
#include <rt/term.h>
#include <rt/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <termios.h>
#include <unistd.h>

void rt_init() __attribute__((constructor));

void rt_init() {
    fcntl(fileno(stdin), F_SETFL, O_NONBLOCK);
    setbuf(stdin, NULL);
    setbuf(stdout, NULL);

    struct termios settings;
    tcgetattr(fileno(stdin), &settings);
    settings.c_lflag &= ~ECHO & ~ICANON;
    settings.c_cc[VERASE] = '\b';
    tcsetattr(fileno(stdin), TCSANOW, &settings);

    fflush(stdout);
    clear_screen();

    extern unsigned long long start_time;
    start_time += rt_time();
}
