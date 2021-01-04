src_dir ?= src
include_dir ?= include
build_dir ?= build/${ARCH}

LIBS ?= 

SRC_S ?= $(wildcard ${src_dir}/*.s)
SRC_C ?= $(wildcard ${src_dir}/*.c)

SRCS ?= ${SRC_S} ${SRC_C}

OBJS ?= ${SRC_S:.s=.o} ${SRC_C:.c=.o}
OBJS := $(patsubst ${src_dir}/%,${build_dir}/%,${OBJS})

${build_dir}/%.o:${src_dir}/%.c
	@echo + CC $@
	@mkdir -p $(dir $@)
	@${CC} -c ${CFLAGS} -I ${include_dir} -o $@ $<

${build_dir}/%.o:${src_dir}/%.s
	@echo + AS $@
	@mkdir -p $(dir $@)
	@${AS} ${MARCH} -o $@ $<

${LIBS}:
	@echo + LIB $@
	@${MAKE} -C $(shell echo $@ | sed -E 's/(build)\/.*//g')

%.bin:%.elf
	@${OBJCOPY} --strip-all $^ -O binary $@

%.hex:%.bin
	@echo + HEX $@
	@${BIN2HEX} $^ $@

%.mif:%.bin
	@echo + MIF $@
	@${BIN2MIF} $^ $@

.PHONY: all clean make_build_dir ${LIBS}

clean:
	@rm -r ${build_dir}
