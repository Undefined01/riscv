.DEFAULT_GOAL := all


toolchain := riscv64-unknown-elf-
AS := ${toolchain}as
LD := ${toolchain}ld
CC := ${toolchain}gcc
OBJCOPY := ${toolchain}objcopy
OBJDUMP := ${toolchain}objdump
BIN2HEX := ../../fpga/testbench/build/bin2hexfile


LIBS += ../crt/build/crt.a

INCS += ../crt/include

INCS := $(addprefix -I, ${INCS})

src_dir := .
build_dir := build

SRC_S := $(wildcard ${src_dir}/*.s)
SRC_C := $(wildcard ${src_dir}/*.c)

SRCS := ${SRC_S} ${SRC_C}

OBJS := ${SRC_S:.s=.o} ${SRC_C:.c=.o}
OBJS := $(addprefix ${build_dir}/,${OBJS})


${build_dir}/%.o:${src_dir}/%.c
	@echo + CC $@
	@${CC} -c -march=rv32i -mabi=ilp32 -Wall -Wextra -nostdlib -fno-builtin -O1 ${INCS} -o $@ $<

${build_dir}/%.o:${src_dir}/%.s
	@echo + AS $@
	@${AS} -march=rv32i -o $@ $<

${LIBS}:
	@echo + LIB $@
	@${MAKE} -C $(shell echo $@ | sed -E 's/(build)?\/[^\/]*\.a//g')

${build_dir}/firmware.elf: \
		${OBJS} ${src_dir}/section.ld \
		${LIBS}
	@echo + LD $@
	@${LD} -T ${src_dir}/section.ld -o $@ ${OBJS} ${LIBS}

%.bin:%.elf
	@${OBJCOPY} --strip-all $^ -O binary $@

%.hex:%.bin
	@echo + HEX $@
	@${BIN2HEX} $^ $@


.PHONY: all clean make_build_dir

make_build_dir:
	@mkdir -p ${build_dir}

all: make_build_dir \
	${build_dir}/firmware.hex

clean:
	rm -r ${build_dir}
