.DEFAULT_GOAL := all

ARCH ?= native

$(info Compiling ${NAME}-${ARCH})
ifeq (${ARCH},native)
	TOOLCHAIN ?= 
else ifeq (${ARCH},riscv)
	TOOLCHAIN ?= riscv64-unknown-elf-
	MARCH ?= -march=rv32i
	MABI ?= -mabi=ilp32
	CFLAGS_EXTRA ?= -nostdinc -nostdlib -fno-builtin
else
	$(error Unsupported target ${ARCH})
endif

AS := ${TOOLCHAIN}as
LD := ${TOOLCHAIN}ld
AR := ${TOOLCHAIN}ar
CC := ${TOOLCHAIN}gcc
BIN2HEX := ../../fpga/testbench/build/bin2hexfile
BIN2MIF := ../../fpga/testbench/build/bin2mif


GCC_WARNS ?= -Wall -Wextra -Wconversion -pedantic -Wcast-qual -Wcast-align -Wwrite-strings
CFLAGS ?= ${CFLAGS_EXTRA} \
	${MARCH} ${MABI} \
	-ggdb3 \
	${GCC_WARNS}
