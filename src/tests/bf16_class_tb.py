import cocotb
from random import randint
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue
from utils.bf16 import bf16

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
