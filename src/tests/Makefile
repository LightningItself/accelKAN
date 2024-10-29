HDL_PATH ?= ../hdl

SIM ?= Icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(HDL_PATH)/bf16_class.v
# VERILOG_SOURCES += $(HDL_PATH)/bf16_mul.v
VERILOG_SOURCES += $(HDL_PATH)/bf16_add.v

TOPLEVEL = bf16_add
MODULE = bf16_add_tb

include $(shell cocotb-config --makefiles)/Makefile.sim
