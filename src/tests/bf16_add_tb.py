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

def generate_data(size=1000):
    input_a = [bf16(float(x)) for x in np.random.uniform(-1e10, 1e10, size=size)]
    input_b = [bf16(float(x)) for x in np.random.uniform(-1e10, 1e10, size=size)]

    return input_a, input_b


async def check(store1, store2, dut, soft_check=False):
    log = lambda x : dut._log.info(x)
    for input_a in store1:
        for input_b in store2:
            res = input_a + input_b
            dut.i_data_a.value = input_a.bin
            dut.i_data_b.value = input_b.bin
            await Timer(1, units='ns')
            # log(input_a)
            # log(input_b)
            # log(res)
            # log(dut.o_data.value)
            # log(dut.o_flag.value)
            # log(bf16(str(dut.o_data.value)).val)
            # log(f"{input_a.val, input_b.val, input_a.val+input_b.val}")
            if(dut.o_data.value != res.bin):
                log("*********************************")
                log(input_a)
                log(input_b)
                log(res)
                log(dut.o_data.value)
            if(soft_check):
                assert abs(int(dut.o_data.value.binstr, 2) - int(res.bin.binstr, 2)) <= 2
            else:
                assert(dut.o_data.value == res.bin)


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
    store = [bf16(0.0), bf16(-0.0)] 
    store2 = store + [bf16(2343.343), bf16(-234.343)]
    await check(store, store, dut)
    await check(store, store2, dut)

@cocotb.test()
async def bf16_add_test_inf(dut):
    store = [bf16(float('inf')), bf16(float('-inf'))]
    store1 = store + [bf16(0.0), bf16(-0.0), bf16(float('nan')), bf16(float('-nan')), bf16(-2343.434), bf16(2343.4343)]
    await check(store, store1, dut)

@cocotb.test()
async def bf16_add_test_norm(dut):
    input_a, input_b = generate_data(100);

    #await check([bf16(8.234)], [bf16(-6.532)], dut)
    await  check(input_a, input_b, dut, soft_check=True)

@cocotb.test()
async def bf16_add_test_custom(dut):
    
    a = bf16("1100111111101100")
    b = bf16("0100111111101100")
    await check([a, b], [b, a], dut, soft_check=False)


# print(a.val)
# print(b.val)
# print((a+b).val)
# print(int(b.bin.binstr, 2))
# print(a.val)