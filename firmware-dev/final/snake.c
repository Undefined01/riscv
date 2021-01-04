#include <rt/kbd.h>
#include <rt/stdlib.h>
#include <rt/term.h>
#include <rt/time.h>

#define W 32
#define H 24

// 障碍物，包括墙和蛇
static int map[W * H];
// 循环队列，存储蛇的坐标
static unsigned int q[W * H], h, t;
// 当前位置，奖励位置（一维）
static unsigned int p, a;
// 速度（一维）
static int d;
static unsigned int score;

static void q_push(unsigned int x) {
    q[h] = x;
    h = h == W * H - 1 ? 0 : h + 1;
}

static unsigned int q_pop() {
    unsigned int res = q[t];
    t = t == W * H - 1 ? 0 : t + 1;
    return res;
}

static void gen_a() {
    do {
        a = (unsigned)rt_rand() % (W * H);
    } while (map[a]);
}

static void update() {
    for (int i = 1; i < H - 1; i++) {
        int base = i * W;
        set_cursor(i, 2);
        for (int j = 1; j < W - 1; j++) {
            if (map[base + j] == 0) {
                rt_printchar(' ');
                rt_printchar(' ');
            } else {
                // 身体
                rt_printchar('[');
                rt_printchar(']');
            }
        }
    }
    // 奖励
    set_cursor((signed)a / W, (signed)a % W * 2);
    rt_printchar('<');
    rt_printchar('>');

    set_cursor(H, 0);
    rt_printstr("Score: ");
    rt_printdec(score);
}

static void draw_border() {
    set_cursor(0, 1);
    for (int i = 1; i < W * 2 - 1; i++) {
        rt_printchar('-');
    }
    set_cursor(H - 1, 1);
    for (int i = 1; i < W * 2 - 1; i++) {
        rt_printchar('-');
    }
    for (int i = 1; i < H - 1; i++) {
        set_cursor(i, 1);
        rt_printchar('|');
    }
    for (int i = 1; i < H - 1; i++) {
        set_cursor(i, 2 * W - 2);
        rt_printchar('|');
    }
}

static int getch() { return rt_kbd_pollevent() & 0xff; }

int cmd_snake(int *args) {
    UNUSED(args);
    int key;

    clear_screen();
    draw_border();

    p = H / 2 * W + (W / 2);
    h = 0;
    t = 0;
    for (int i = 0; i < W * H; i++) map[i] = 0;
    for (int i = 0; i < W; i++) map[i] = map[W * (H - 1) + i] = 1;
    for (int i = 0; i < H; i++) map[W * i] = map[W * i + (W - 1)] = 1;

    d = 1;
    score = 0;
    gen_a();

    q_push(p);
    map[p] = 1;

    while ((key = getch()) != 'q') {
        if (key == 'w' && d != W)
            d = -W;
        else if (key == 's' && d != -W)
            d = W;
        else if (key == 'a' && d != 1)
            d = -1;
        else if (key == 'd' && d != -1)
            d = 1;

        p += (unsigned)d;
        if (map[p]) break;

        q_push(p);
        map[p] = 1;
        if (p == a) {
            score++;
            gen_a();
        } else {
            map[q_pop()] = 0;
        }

        update();
        rt_sleep(500000);
    }

    // clear_screen();
    set_cursor(H + 1, 0);
    return 0;
}
