NAME := crt

include ../toolchain.mk

src_dir := src
include_dir := include

SRC_S := $(wildcard ${src_dir}/*.s)
SRC_S += $(wildcard ${src_dir}/${ARCH}/*.s)
SRC_C := $(wildcard ${src_dir}/*.c)
SRC_C += $(wildcard ${src_dir}/${ARCH}/*.c)

include ../build_rule.mk

${build_dir}/crt-${ARCH}.a: ${OBJS}
	@echo + AR $@
	@${AR} rcs $@ $^

all: ${build_dir}/crt-${ARCH}.a
