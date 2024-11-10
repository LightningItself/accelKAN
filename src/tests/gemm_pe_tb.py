import cocotb
from cocotb.triggers import Timer
from utils.bf16 import bf16, rand
from cocotb.binary import BinaryValue
from numpy import vectorize, isnan, array, empty
import numpy as np
from random import uniform


async def generate_clock(dut):
    for cycle in range(10000):
        dut.i_clk.value = 0
        await Timer(1, units='ns')
        dut.i_clk.value = 1
        await Timer(1, units='ns')

async def reset(dut):
    dut.i_rst.value = 1
    await Timer(1, units='ns')
    dut.i_rst.value = 0

async def operate(dut):
    dut.i_valid.value = 1
    await Timer(1, units='ns')
    dut.i_valid.value = 0
    await Timer(1, units='ns')



        
@cocotb.test()
async def gemm_pe_tb(dut):

    log = lambda x : dut._log.info(x)

    await cocotb.start(generate_clock(dut)) #clock cycle time 2ns
    await Timer(5, units='ns')
    log(dut.o_data_acc.value)
    await reset(dut)
    log(dut.o_data_acc.value)

    inp_a = bf16(-2.0)
    inp_b = bf16(2)

    for i in range(1, 4):
        dut.i_data_x.value = inp_a.bin
        dut.i_data_w.value = inp_b.bin
        dut.i_valid = 1
        await Timer(2, units='ns')
        dut.i_valid = 0
        await Timer(40, units='ns')
        log(bf16(str(dut.o_data_acc.value)).val)