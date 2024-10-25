import struct

BLUE = "\033[1;34m"
CYAN = "\033[1;36m"
GREEN = "\033[0;32m"
RESET = "\033[0;0m"

def binary(num):
    return [bin(c).replace('0b', '').rjust(8, '0') for c in struct.pack('!f', num)]

def fp32(num):
    bits = ''.join(binary(num))
    return ''.join([BLUE, bits[:1], GREEN, bits[1:9], CYAN, bits[9:], RESET])

def bf16(num):
    bits = ''.join(binary(num))
    return ''.join([BLUE, bits[:1], GREEN, bits[1:9], CYAN, bits[9:][:7], RESET])

def display(num):
    print("num  : ", num)
    print("fp32 : ", fp32(num))
    print("bf16 : ", bf16(num))
    

#display(173.3125)

