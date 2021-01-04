NAME := final

include ../toolchain.mk

src_dir := .
include_dir := ../crt/include

LIBS := ../crt/build/${ARCH}/crt-${ARCH}.a

include ../build_rule.mk

ifeq (${ARCH},native)
${build_dir}/firmware.elf: \
		${OBJS} \
		${LIBS}
	@echo + LD $@
	@${CC} -static -o $@ ${OBJS} -Wl,--whole-archive ${LIBS} -Wl,--no-whole-archive
else
${build_dir}/firmware.elf: \
		${OBJS} ${src_dir}/section.ld \
		${LIBS}
	@echo + LD $@
	@${LD} -T ${src_dir}/section.ld -o $@ ${OBJS} ${LIBS}
endif

all: ${build_dir}/firmware.elf
