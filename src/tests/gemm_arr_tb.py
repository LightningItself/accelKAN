import cocotb
from cocotb.triggers import Timer
from utils.bf16 import bf16, rand
from cocotb.binary import BinaryValue
from numpy import vectorize, isnan, array, empty
import numpy as np
from random import uniform


ROWS = 2
COLS = 2

#*********************utils******************************
async def generate_clock(dut):
    for cycle in range(10000):
        dut.i_clk.value = 0
        await Timer(1, units='ns')
        dut.i_clk.value = 1
        await Timer(1, units='ns')

async def one_cycle():
    await Timer(2, units='ns')

async def reset(dut):
    dut.i_rst.value = 1
    await Timer(4, units='ns')
    dut.i_rst.value = 0
#********************************************************

def generate_matrix(rows=4, cols=4):
    def f(x):
        return bf16(float(x))
    data = np.random.uniform(0, 100, (rows, cols))
    vf = np.vectorize(f)
    return vf(data)

# a = generate_matrix()
# b = generate_matrix()
# m = np.matmul(a, b)

# getval = np.vectorize(lambda x : x.val)
# print(getval(a))
# print(getval(b))
# print(getval(m))
# print(np.matmul(getval(a), getval(b)))@cocotb.test()


@cocotb.test()
async def gemm_arr_test(dut):

    log = lambda x : dut._log.info(x)

    await cocotb.start(generate_clock(dut))
    await Timer(20, units='ns')
    await reset(dut)
    dut.i_addr.value = 0
    await Timer(2, units='ns')
    log(dut.o_data_acc.value)
    dut.i_data_x.value = BinaryValue(bf16(1).bin.binstr+bf16(2).bin.binstr)
    dut.i_data_w.value = BinaryValue(bf16(3).bin.binstr+bf16(-4).bin.binstr)
    dut.i_valid.value = 1
    await Timer(6, units='ns')
    log(await get_res(dut, 'all'))



#check output
async def get_res(dut, col='all'):
    if(col != 'all'):
        dut.i_addr.value = col
        dut.i_valid.value = 0
        await one_cycle()
        col_data = str(dut.o_data_acc.value)
        return [bf16(col_data[i:i+16]).val for i in range(0, len(col_data), 16)]
    else:
        return [await get_res(dut, col=i) for i in range(0, ROWS)]
        
