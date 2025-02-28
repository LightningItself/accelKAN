from tests.utils.bf16 import bf16
import sys
b = bf16(1e-20)
print(b)
c = bf16(1e-20)
print(b*c)
print(bf16(1e-40))

print(bf16(float('inf')))