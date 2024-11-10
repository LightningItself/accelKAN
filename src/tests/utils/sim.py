import cocotb
from cocotb.triggers import Timer
from utils.bf16 import bf16, rand
from cocotb.binary import BinaryValue
from numpy import vectorize, isnan, array, empty

async def _generate_clock(dut):
    for cycle in range(10000):
        dut.i_clk.value = 0
        await Timer(1, units='ns')
        dut.i_clk.value = 1
        await Timer(1, units='ns')

async def clock(dut):
    await cocotb.start(_generate_clock(dut))

async def cycle(dut, step=1):
    await Timer(2*step, units='ns')

async def reset(dut):
    dut.i_rst.value = 1
    await cycle(dut)
    dut.i_rst.value = 0
    await cycle(dut)

def log(dut, data):
    dut._log.info(data)