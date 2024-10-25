HDL_PATH ?= ../hdl

SIM ?= Icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(HDL_PATH)/bf16_class.v
TOPLEVEL = bf16_class
MODULE = bf16_class_tb

include $(shell cocotb-config --makefiles)/Makefile.sim