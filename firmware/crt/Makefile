.DEFAULT_GOAL := all


toolchain ?= riscv64-unknown-elf-
AS := ${toolchain}as
LD := ${toolchain}ld
AR := ${toolchain}ar
CC := ${toolchain}gcc


GCC_WARNS := -Wall -Wextra -Wconversion -pedantic -Wcast-qual -Wcast-align -Wwrite-strings
CFLAGS ?= -O2 -march=rv32i -mabi=ilp32 -nostdinc -nostdlib -fno-builtin \
	${GCC_WARNS}

src_dir := src
include_dir := include
build_dir := build

SRC_S := $(wildcard ${src_dir}/*.s)
SRC_C := $(wildcard ${src_dir}/*.c)

SRCS := ${SRC_S} ${SRC_C}

OBJS := ${SRC_S:.s=.o} ${SRC_C:.c=.o}
OBJS := $(patsubst ${src_dir}/%,${build_dir}/%,${OBJS})


${build_dir}/%.o:${src_dir}/%.c
	@echo + CC $@
	@${CC} -c ${CFLAGS} -I ${include_dir} -o $@ $<

${build_dir}/%.o:${src_dir}/%.s
	@echo + AS $@
	@${AS} -march=rv32i -o $@ $<

${build_dir}/crt.a: ${OBJS}
	@echo + AR $@
	@${AR} rcs $@ $^

.PHONY: all clean make_build_dir

make_build_dir:
	@mkdir -p ${build_dir}

all: make_build_dir \
	${build_dir}/crt.a

clean:
	rm -r ${build_dir}
