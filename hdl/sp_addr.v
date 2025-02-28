module sp_cache (
    input i_clk,
    input i_en,
    input signed [17:0] i_x, // only fractional bits
    input [3:0] i_hbits,
    output [9:0] o_data_1,
    output [9:0] o_data_2,
    output [9:0] o_data_3,
    output [9:0] o_data_4
);


// 10 bit output since range [0, 1]
// 18 bit number format
// 10 bit fraction.
// 1 bit for sign. so 7 bit towards value

wire [17:0] x_abs = i_x[17] ? ~i_x+1 : i_x;
wire [9:0] x_rem_p = x_abs[9:0] & (10'b1111111111 >> i_hbits);

wire [9:0] x_addr_p = x_rem_p << (i_hbits-1);
wire [9:0] x_addr_n = 10'b0111111111 - x_addr_p;

sp_rom_a store_a (
    i_clk,
    i_en,
    x_addr_p,
    x_addr_n,
    o_data_3,
    o_data_2
);

sp_rom_b store_b (
    i_clk,
    i_en,
    ({1'b1, x_addr_p[8:0]}),
    ({1'b1, x_addr_n[8:0]}),
    o_data_4,
    o_data_1
);

endmodule
