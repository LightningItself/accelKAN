import cocotb
from cocotb.triggers import Timer
from utils.bf16 import bf16, rand
from utils.sim import cycle, clock, reset, log
from cocotb.binary import BinaryValue
from numpy import vectorize, isnan, array, empty
import numpy as np
from random import uniform

@cocotb.test()
async def gemm_w_buff_tb(dut):
    await clock(dut)
    await cycle(dut)
    await reset(dut)
    log(dut, dut.o_data.value)

    dut.i_valid.value = 1
    dut.i_write.value = 1
    for i in [2,5,34534.54,7]: 
        dut.i_data.value = bf16(i).bin
        await cycle(dut)
    dut.i_valid.value = 0
    dut.i_write.value = 0
    await cycle(dut)
    await reset(dut)
    dut.i_valid.value = 1
    for i in range(0, 4):
        log(dut, bf16(str(dut.o_data.value)).val)
        await cycle(dut)
