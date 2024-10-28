HDL_PATH ?= ../hdl

SIM ?= Icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(HDL_PATH)/bf16_class.v
VERILOG_SOURCES += $(HDL_PATH)/bf16_mul.v

TOPLEVEL = bf16_mul
MODULE = bf16_mul_tb

include $(shell cocotb-config --makefiles)/Makefile.sim
