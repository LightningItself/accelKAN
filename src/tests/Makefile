HDL_PATH ?= ../hdl

SIM ?= Icarus
TOPLEVEL_LANG ?= verilog

# VERILOG_SOURCES += $(HDL_PATH)/bf16_class.v
# VERILOG_SOURCES += $(HDL_PATH)/bf16_mul.v
# VERILOG_SOURCES += $(HDL_PATH)/bf16_add.v
# VERILOG_SOURCES += $(HDL_PATH)/gemm_pe.v
# VERILOG_SOURCES += $(HDL_PATH)/gemm_arr.v

VERILOG_SOURCES += $(HDL_PATH)/gemm_w_buff.v


TOPLEVEL = gemm_w_buff
MODULE = gemm_w_buff_tb

include $(shell cocotb-config --makefiles)/Makefile.sim
