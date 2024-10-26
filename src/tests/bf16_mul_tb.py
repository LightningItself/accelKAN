import cocotb
from cocotb.triggers import Timer
from utils.bf16 import bf16, rand
from cocotb.binary import BinaryValue
from numpy import vectorize, isnan, array, empty
import numpy as np

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
        elif(num == float('inf')):
            flag[i] = (BinaryValue("0010")) 
        else:
            flag[i] = (BinaryValue("0001")) 
    return flag

def generate_data(size=10000):
    input_a = rand(size)
    input_b = rand(size)
    
    output_bin = _bf16(_val(input_a)*_val(input_b))
    output_flag = get_flag(_val(output_bin))

    return array([input_a, input_b, output_bin, output_flag]).T


@cocotb.test()
async def bf16_mul_test_norm(dut):
    for input_a, input_b, output_mul, output_flag in generate_data(100):
        dut.i_data_a.value = input_a.bin
        dut.i_data_b.value = input_b.bin
        await Timer(1, units="ns")
        dut._log.info(dut.o_data.value)
        dut._log.info(dut.o_flag.value)

@cocotb.test()
async def bf16_mul_test_zero(dut):
    return
