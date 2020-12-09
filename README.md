# riscv
An FPGA-based RISC-V CPU.

本项目为 2020 年数字电路实验的期末大实验。由 李晗 [@Undefined01](https://github.com/Undefined01) 和 高灏 [@UYTFVBNJ](https://github.com/UYTFVBNJ) 共同开发。

本项目实现了基于 `RISC-V` 指令集的 CPU （`RV32I`），并针对 `Cyclone 5CSXFC6D6F31C6` 开发板实现了相应的外设模块。
CPU 可以通过 MMIO 的方式对外设进行控制并运行具有一定实用性的程序。

## 硬件设计

Quartus 项目位于 [fpga](https://github.com/Undefined01/riscv/tree/master/fpga) 目录。

设计源文件主要位于 [fpga/src](https://github.com/Undefined01/riscv/tree/master/fpga/src) 目录。

* CPU 频率： 50MHz
* 上电启动地址： 0x00000000 （非标准）
* 内存大小： 16KB （定义于 [common.v](https://github.com/Undefined01/riscv/blob/cea991249bc0af470cd6f9b74ef122cea91e5eaf/fpga/src/common.v#L21)）
* 指令集： RV32I （未实现特权相关指令，如 `ecall` 和 `sret`。未实现非四字节内存访问，如 `lb`, `sh` 等等。设计程序时应总是使用 `int` 等四字节变量。）
* 内置固件： firmware/final （定义于 [perip.v](https://github.com/Undefined01/riscv/blob/cea991249bc0af470cd6f9b74ef122cea91e5eaf/fpga/src/perip/ram.v#L14)）
* MMIO： 定义于 [common.v](https://github.com/Undefined01/riscv/blob/cea991249bc0af470cd6f9b74ef122cea91e5eaf/fpga/src/common.v#L21-L29) ，在 [perip.v](https://github.com/Undefined01/riscv/blob/master/fpga/src/perip/perip.v) 中进行转发。具体映射如下：

  | Address                 | Description                                                  |
  | ----------------------- | ------------------------------------------------------------ |
  | 0x00000000 - 0x10000000 | 内存。仅使用开头到实际内存大小的段。指令、数据等均存放在内存中。 |
  | 0xa0000000 - 0xa1000000 | 字符显存。仅使用开头到实际显存大小的段。向此处写入字符的 `ASCII` 码即可被自动显示在屏幕上。 |
  | 0xa1000010 - 0xa1000020 | 键盘。仅使用第一个四字节。从此处读取键盘事件。               |
  | 0xa1000020 - 0xa1000030 | 启动时间。仅使用前两个四字节。从此处读取以小端序保存、 8 字节的、以微秒计的启动时间。 |

## 硬件测试

测试激励模块和简易测试用例位于 [fpga/testbench](https://github.com/Undefined01/riscv/tree/master/fpga/testbench) 目录。

可使用 `make` 自动编译测试用例（需要安装 `riscv64-unknown-elf` 工具链）。

本项目还移植了 `RISC-V` 的官方测试集 `riscv-tests` （位于 [riscv-tests](https://github.com/UYTFVBNJ/riscv-tests/tree/b0408637f268e63fd58e14496c5d7c842612b2e3) 目录下）。
在使用 `git submodule update --init` 初始化子项目后，可在 [riscv-tests/isa](https://github.com/UYTFVBNJ/riscv-tests/tree/b0408637f268e63fd58e14496c5d7c842612b2e3/isa) 目录下执行 `make` 命令自动编译测试用例（需要安装 `riscv64-unknown-elf` 工具链）。

编译完测试用例后，可在 `Quartus` 中进行 RTL 级仿真。
激励模块中有简易的测试框架，能够对 CPU 进行自动化测试。

## 软件设计

最终展示时使用的软件位于 [firmware](https://github.com/Undefined01/riscv/tree/master/firmware) 目录。
主要使用 C 语言进行开发。

其中， [crt](https://github.com/Undefined01/riscv/tree/master/firmware/crt) 目录为支撑 C 程序运行的最小运行时，包括 `putchar` 、 `sleep` 等常用函数）。

[final](https://github.com/Undefined01/riscv/tree/master/firmware/final) 目录为最终展示程序。
可以使用 `make` 指令一键编译。
该程序实现了一个最小终端，并支持运行以下程序。

| 程序名称 | 程序描述和参数                                      |
| -------- | --------------------------------------------------- |
| help     | 输出终端支持的指令。                                |
| hello    | 输出 hello world 并退出。                           |
| echo     | 原样输出参数。                                      |
| fib      | 需要一个整数`n`，输出斐波那契数列的第`n`项。        |
| uptime   | 输出 CPU 启动的时间。                               |
| md5      | 需要一个字符串，输出该字符串的 `MD5` 哈希值。       |
| snake    | 进入贪吃蛇小程序。使用`wasd`进行控制，使用`q`退出。 |

