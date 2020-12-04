.DEFAULT_GOAL := all


toolchain := riscv64-unknown-elf-
AS := ${toolchain}as
LD := ${toolchain}ld
OBJCOPY := ${toolchain}objcopy
OBJDUMP := ${toolchain}objdump


src_dir := src
build_dir := build
utils_dir := utils

UTILS := bin2hexfile bin2mif
SRCS := $(wildcard ${src_dir}/*.s)

utils_src   := $(addprefix ${utils_dir}/,${UTILS})
utils_build := $(addprefix ${build_dir}/,${UTILS})

HEXS := $(patsubst ${src_dir}/%,${build_dir}/%,${SRCS})
HEXS := $(patsubst %.s,%.hex,${HEXS})



${utils_build}:${build_dir}/%:${utils_dir}/%.c
	@echo + CC $@
	@gcc -o $@ $<

${build_dir}/%.o:${src_dir}/%.s ${src_dir}/common.h
	@echo + AS $@
	@${AS} -march=rv32i -o $@ -I src $<

%.elf:%.o ${src_dir}/section.ld
	@${LD} -T ${src_dir}/section.ld -o $@ $<

%.bin:%.elf
	@${OBJCOPY} --strip-all $^ -O binary $@

%.hex:%.bin
	@echo + HEX $@
	@${build_dir}/bin2hexfile $^ $@


.PHONY: all clean make_build_dir

make_build_dir:
	@mkdir -p ${build_dir}

all: make_build_dir \
	$(utils_build) \
	$(HEXS) $(HEXS:.hex=.elf)

clean:
	rm -r ${build_dir}
