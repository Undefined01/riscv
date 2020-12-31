.DEFAULT_GOAL := all


toolchain ?= riscv64-unknown-elf-
AS := ${toolchain}as
LD := ${toolchain}ld
CC := ${toolchain}gcc
OBJCOPY := ${toolchain}objcopy
OBJDUMP := ${toolchain}objdump
BIN2HEX := ../../fpga/testbench/build/bin2hexfile
BIN2MIF := ../../fpga/testbench/build/bin2mif


GCC_WARNS := -Wall -Wextra -Wconversion -pedantic -Wcast-qual -Wcast-align -Wwrite-strings
CFLAGS ?= -O2 -march=rv32i -mabi=ilp32 -nostdinc -nostdlib -fno-builtin \
	${GCC_WARNS}

LIBS := ../crt/build/crt.a

INCLUDES := ../crt/include

INCLUDES := $(addprefix -I, ${INCLUDES})

src_dir := .
build_dir := build

SRC_S := $(wildcard ${src_dir}/*.s)
SRC_C := $(wildcard ${src_dir}/*.c)

SRCS := ${SRC_S} ${SRC_C}

OBJS := ${SRC_S:.s=.o} ${SRC_C:.c=.o}
OBJS := $(addprefix ${build_dir}/,${OBJS})


${build_dir}/%.o:${src_dir}/%.c
	@echo + CC $@
	@${CC} -c ${CFLAGS} ${INCLUDES} -o $@ $<

${build_dir}/%.o:${src_dir}/%.s
	@echo + AS $@
	@${AS} -march=rv32i -o $@ $<

${LIBS}: force_update
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

%.mif:%.bin
	@echo + MIF $@
	@${BIN2MIF} $^ $@


.PHONY: all clean make_build_dir

make_build_dir:
	@mkdir -p ${build_dir}

all: make_build_dir \
	${build_dir}/firmware.mif

clean:
	rm -r ${build_dir}

force_update:
