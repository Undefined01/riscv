.DEFAULT_GOAL := all

toolchain := riscv64-unknown-elf-
AS := ${toolchain}as
LD := ${toolchain}ld
OBJCOPY := ${toolchain}objcopy
OBJDUMP := ${toolchain}objdump

src_dir := src
build_dir := build
utils_dir := utils


UTILS := bin2hexfile
SRCS := $(wildcard src/*.s)

utils_src   := $(addprefix ${utils_dir}/,${UTILS})
utils_build := $(addprefix ${build_dir}/,${UTILS})

HEXS := $(patsubst src/%,${build_dir}/%,${SRCS})
HEXS := $(patsubst %.s,%.hex,${HEXS})

.PHONY: all clean make_build_dir

$(info ${utils_build})

${utils_build}:${build_dir}/%:${utils_dir}/%.c
	@echo + CC $@
	gcc -o $@ $<

${build_dir}/%.o:src/%.s
	@echo + AS $@
	@${AS} -o $@ -I src $<

%.elf:%.o
	@${LD} -T src/section.ld -o $@ $<

%.bin:%.elf
	@${OBJCOPY} --strip-all $^ -O binary $@

%.hex:%.bin
	@echo + HEX $@
	@${build_dir}/bin2hexfile $^ $@

make_build_dir:
	@mkdir -p ${build_dir}

all: make_build_dir \
	$(utils_build) \
	$(HEXS) $(HEXS:.hex=.elf)

clean:
	rm -r ${build_dir}
