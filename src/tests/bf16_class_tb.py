import cocotb
from random import randint, uniform
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue
from utils.bf16 import bf16, rand
from numpy import isnan, add

# input       i_data -> 16 bit bfloat16 number
# output      o_flag ->  4 bit {NaN, zero, infinity, normal}
# output      o_exp  ->  8 bit exponent portion
# output      o_sig  ->  7 bit significand portion
  
def generate_zero():
    sign = ["0", "1"]
    exp = ["0"*8]
    sig = ["0"*7]
    val = []
    for i in sign:
        for j in exp:
            for k in sig:
                val.append((bf16(i+j+k).bin, BinaryValue("0100")))
    return val

def generate_inf():
    sign = ["0", "1"]
    exp = ["1"*8]
    sig = ["0"*7]
    val = []
    for i in sign:
        for j in exp:
            for k in sig:
                val.append((bf16(i+j+k).bin, BinaryValue("0010")))
    return val

def generate_nan():
    sign = ["0", "1"]
    exp = ["1"*8]
    sig = ["1"+"0"*6]
    val = []
    for i in sign:
        for j in exp:
            for k in sig:
                val.append((bf16(i+j+k).bin, BinaryValue("1000")))
    return val

def generate_norm(size=10000):
    val = []
    for i in range(size):
        sign = str(randint(0, 1))
        exp = str(bin(randint(1, (1<<8)-2))[2:]).zfill(8)
        sig = str(bin(randint(1, (1<<7)-2))[2:]).zfill(7)
        input = bf16(sign+exp+sig)
        val.append((input.bin, BinaryValue("0001")))
    return val

async def bf16_class_test_unit(dut, data):
    for (input, output) in data:
        dut.i_data.value = input
        await Timer(1, units='ns')
        #dut._log.info(f"{input}, {dut.o_flag.value}")
        assert dut.o_flag.value == output, input


@cocotb.test()
async def bf16_class_test_zero(dut):
    await bf16_class_test_unit(dut, generate_zero())

@cocotb.test()
async def bf16_class_test_nan(dut):
    await bf16_class_test_unit(dut, generate_nan())

@cocotb.test()
async def bf16_class_test_inf(dut):
    await bf16_class_test_unit(dut, generate_inf())

@cocotb.test()
async def bf16_class_test_norm(dut):
    await bf16_class_test_unit(dut, generate_norm())

@cocotb.test()
async def bf16_class_test_random(dut):
    c = [0,0,0,0]
    def check(input, output):
        if(isnan(input.val)):
            assert(output == "1000"), input
            c = [1,0,0,0]
        elif(input.val == 0.0):
            assert(output == "0100"), input
            c = [0,1,0,0]
        elif(input.val == float('inf')):
            assert(output == "0010"), input
            c = [0,0,1,0]
        else:
            assert(output == "0001"), input
            c = [0,0,0,1]
        count = 0
        for k in output:
            count += 1 if k=="1" else 0
        assert(count == 1), input
        return c

  
    for i in range(1, 10000):
        i_data = bf16(uniform(1e-40, 1e40))
        dut.i_data.value = i_data.bin
        await Timer(1, units="ns")
        output = dut.o_flag.value
        c = add(c, check(i_data, output))
    dut._log.info(c)

    