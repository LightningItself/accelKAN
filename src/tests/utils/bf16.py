from cocotb.binary import BinaryValue
from ctypes import *
import struct

def bf16_str(num, colored=False):
    BLUE = "\033[1;34m"
    CYAN = "\033[1;36m"
    GREEN = "\033[0;32m"
    RESET = "\033[0;0m"
    
    b_num = [bin(c).replace('0b', '').rjust(8, '0') for c in struct.pack('!f', num)]
    bits = ''.join(b_num)
    
    if(colored):
        return ''.join([BLUE, bits[:1], GREEN, bits[1:9], CYAN, bits[9:][:7], RESET])
    return ''.join([bits[:1], bits[1:9], bits[9:][:7]])

def bf16(num):
    bin_str = bf16_str(num)
    bv = BinaryValue(0, n_bits=16, bigEndian=False)
    bv.binstr = bin_str
    return bv

 
