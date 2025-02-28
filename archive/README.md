PE Structure

Multiplication Module - bf16_mul

fully combinational block to generate the product output
uses bfloat16  format -> 1 sign bit 8 exp bit 7 sig bit

inputs
    i_data_a -> first operand
    i_data_b -> second operand

output
    o_data -> product output
    o_flags -> flag bits to represent output type

flags
    NaN -> output value is not a number.
            we do not differ between signalling and quiet NaN
            output format is {1bx 8b1 7b1}

    zero -> number is zero. output format is {1bx 8b0 7b0}

    infinity -> number is infinity format is {1bx 8b1 7b0}

    normal -> number format is {1bx 8bx 7bx}. exp & sig are non zero

    flag format is 4 bits {nan, zero, inf, norm}



