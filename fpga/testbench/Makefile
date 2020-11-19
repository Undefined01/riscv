toolchain := riscv64-unknown-elf-
build_dir := build

SRCS := $(wildcard src/*.s)
HEXS := $(patsubst src/%,${build_dir}/%,${SRCS})
HEXS := $(patsubst %.s,%.hex,${HEXS})

.PHONY: all clean
.DEFAULTGOAL: all

${build_dir}/%.o:src/%.s
	@echo + AS $@
	@mkdir -p ${build_dir}
	@${toolchain}as -o $@ -I src $<

%.elf:%.o
	@${toolchain}ld -T src/section.ld -o $@ $<

%.bin:%.elf
	@${toolchain}objcopy --strip-all $^ -O binary $@

%.hex:%.bin
	@echo + HEX $@
	@utils/bin2hexfile $^ $@
# %.hex:%.o
# 	@echo + HEX $@
# 	@${toolchain}objdump -d $^ | grep -E '\w+:'$$'\t' \
# 		| awk '{printf("@%x\t%s\n", strtonum("0x" substr($$1, 0, length($$1)-1))/4, $$2)}' > $@

all: $(HEXS) $(HEXS:.hex=.elf)

clean:
	rm -r ${build_dir}
