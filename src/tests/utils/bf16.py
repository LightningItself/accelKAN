from cocotb.binary import BinaryValue
from numpy import random, apply_along_axis, finfo, float32
import struct

def __reduce(arr):
    s = ""
    for i in arr:
        s += "1" if i else "0"
    return bf16(s)

def rand(size=1):
    x = random.randint(0, 2, 16*size)
    x = x.reshape(size, 16)
    return apply_along_axis(__reduce, axis=1, arr=x)

class bf16:

    def __init__(self, value=0):
        if(type(value) == int or type(value) == float):
            self.bf16_bin = self.__float_to_bin(float(value))[:16]
        elif(type(value) == str):
            assert self.__str_is_bf16(value) == True, "Not a Binary Number!"
            self.bf16_bin = value
        else:
            raise AssertionError("Invalid Input")
        self.bf16 = self.__bin_to_float(self.bf16_bin+"0"*16)
        self.bv = BinaryValue(self.bf16_bin, n_bits=16, bigEndian=False)

    def __add__(self, operand):
        bin_str = self.__float_to_bin(self.val+operand.val)[:16]
        return bf16(bin_str)
    
    def __mul__(self, operand):
        bin_str = self.__float_to_bin(self.val*operand.val)[:16]
        return bf16(bin_str)

    def __str__(self):
        BLUE = "\033[1;34m"
        CYAN = "\033[1;36m"
        GREEN = "\033[0;32m"
        RESET = "\033[0;0m"
        sign = self.bf16_bin[:1]
        exp = self.bf16_bin[1:9]
        sig = self.bf16_bin[9:][:7]
        return ''.join([BLUE, sign, GREEN, exp, CYAN, sig, RESET])
    
    def __repr__(self):
        return self.__str__()
    
    def __float_to_bin(self, num):
        try:
            return bin(struct.unpack('!I', struct.pack('!f', num))[0])[2:].zfill(32)
        except OverflowError:
            return self.__float_to_bin(float(finfo(float32).max*2))        

    def __bin_to_float(self, binary):
        return struct.unpack('!f',struct.pack('!I', int(binary, 2)))[0]

    def __str_is_bf16(self, str):
        for c in str:   
            if(c != '0' and c != '1'):
                return False
        if len(str) != 16:
            return False
        return True
    
    bin = property(lambda self : self.bv, __init__)
    val = property(lambda self : self.bf16, __init__)

