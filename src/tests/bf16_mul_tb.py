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

_val = vectorize(lambda v : v.val)
_bf16 = vectorize(lambda v : bf16(float(v)))

def get_flag(arr):
    flag = empty(len(arr), dtype=object)
    for i in range(0, len(arr)):
        num = float(arr[i])
        if(isnan(num)):
            flag[i] = BinaryValue("1000")
        elif(num == 0.0):
            flag[i] = (BinaryValue("0100")) 
        elif(num == float('inf') or num == float('-inf')):
            flag[i] = (BinaryValue("0010")) 
        else:
            flag[i] = (BinaryValue("0001")) 
    return flag

def generate_data(size=1000):
    input_a = [bf16(float(x)) for x in np.random.uniform(0, 1e10, size=size)]
    input_b = [bf16(float(x)) for x in np.random.uniform(0, 1e10, size=size)]
    output_bin = _bf16(_val(input_a)*_val(input_b))
    output_flag = get_flag(_val(output_bin))
    return array([input_a, input_b, output_bin, output_flag]).T


@cocotb.test()
async def bf16_mul_test_norm(dut):

    log = lambda x : dut._log.info(x)

    for input_a, input_b, output_mul, output_flag in generate_data(100):
        dut.i_data_a.value = input_a.bin
        dut.i_data_b.value = input_b.bin
        await Timer(1, units="ns")
        # log("********************************")
        # log(f"Actual o_data   : {output_mul}")
        # log(f"Obtained o_data : {dut.o_data.value}")
        # log(f"Obtained Flag : {dut.o_flag.value}")
        assert(output_mul.bin[14:7] == dut.o_data.value[1:8]), f"Significand mismatch, {input_a}, {input_a.val}, {input_b}, {input_b.val}"
        assert(output_mul.bin == dut.o_data.value), "wrong output"
        assert(output_flag.binstr == dut.o_flag.value), "flag error"

@cocotb.test()
async def bf15_mul_test_edge(dut):

    log = lambda x : dut._log.info(x)


    store = [bf16(0.0), bf16(float('inf')), bf16(-0.0), bf16(float('-inf')), bf16(float('nan')), bf16(1e-20), bf16(1e20)]
    for input_a in store:
        for input_b in store:
            dut.i_data_a.value = input_a.bin
            dut.i_data_b.value = input_b.bin
            output_mul = bf16(input_a.val * input_b.val)
            output_flag = get_flag([output_mul.val])[0]
            await Timer(1, units="ns")
            log("********************************")
            log(f"Actual o_data   : {output_mul}")
            log(f"Obtained o_data : {dut.o_data.value}")
            log(f"Obtained Flag : {dut.o_flag.value}")
            assert(output_mul.bin[14:7] == dut.o_data.value[1:8]), f"Significand mismatch, {input_a}, {input_a.val}, {input_b}, {input_b.val}"
            assert(output_mul.bin == dut.o_data.value),f"Significand mismatch, {input_a}, {input_a.val}, {input_b}, {input_b.val}"
            assert(output_flag.binstr == dut.o_flag.value),f"Significand mismatch, {input_a}, {input_a.val}, {input_b}, {input_b.val}"


print((bf16(float('inf'))*bf16(float('-inf'))))