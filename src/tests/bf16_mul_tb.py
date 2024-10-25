import cocotb
from cocotb.triggers import Timer
from random import randint
from cocotb.binary import BinaryValue

# input       i_data_a -> 16 bit bfloat16 input operand
# input       i_data_b -> 16 bit bfloat16 input operand

# output      o_data   -> 16 bit bfloat16 multiplication result
# output      o_flag   ->  4 bit type flag for output number

