import cocotb
from cocotb.triggers import Timer
from utils.bf16 import bf16, rand
from cocotb.binary import BinaryValue
from numpy import vectorize, isnan, array, empty
import numpy as np
from random import uniform

# input       i_data_a -> 16 bit bfloat16 input operand
# input       i_data_b -> 16 bit bfloat16 input operand
# output      o_data   -> 16 bit bfloat16 multiplication result
# output      o_flag   ->  4 bit type flag for output number

@cocotb.test()
async def bf16_add_test_nan(dut):
    a = [bf16(float('-nan')), bf16(float('nan'))]
    b = [bf16(float('nan')), bf16(float('-nan')), bf16(3454.45), ]
    for input_a in a:    
        for input_b in b:
            res = input_a+input_b
            dut.i_data_a.value = input_a.bin
            dut.i_data_b.value = input_b.bin
            await Timer(1, units='ns')
            assert(dut.o_data.value == res.bin)

@cocotb.test()
async def bf16_add_test_zero(dut):

    log = lambda x : dut._log.info(x)

    store = [bf16(0.0), bf16(-0.0)] 
    store2 = [bf16(2343.343), bf16(-234.343)]

    async def check(store1, store2):
        for input_a in store1:
            for input_b in store2:
                res = input_a + input_b
                dut.i_data_a.value = input_a.bin
                dut.i_data_b.value = input_b.bin
                await Timer(1, units='ns')
                log("*********************************")
                log(input_a)
                log(input_b)
                log(res)
                log(dut.o_data.value)
                assert(dut.o_data.value == res.bin)

    await check(store, store)
    await check(store, store2)
