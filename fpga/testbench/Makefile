toolchain := riscv64-unknown-elf-
build_dir := build

SRCS := $(wildcard src/*.s)
HEXS := $(patsubst src/%,${build_dir}/%,${SRCS})
HEXS := $(patsubst %.s,%.hex,${HEXS})

$(info ${HEXS})

.PHONY: all clean
.DEFAULTGOAL: all

${build_dir}/%.o:src/%.s
	mkdir -p ${build_dir}
	${toolchain}as $^ -o $@

%.bin:%.o
	${toolchain}objcopy --strip-all $^ -O $@

%.hex:%.o
	${toolchain}objdump -d $^ | grep -E '\w+:'$$'\t' | awk '{print $$2}' > $@

all: $(HEXS)

clean:
	rm -r ${build_dir}
