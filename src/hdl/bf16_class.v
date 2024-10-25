module bf16_class # (
    parameter NUM_WIDTH = 16,
    parameter EXP_WIDTH = 8,
    parameter SIG_WIDTH = 7,
    parameter FLAG_WIDTH = 4
) (
    input [NUM_WIDTH-1:0] i_data,
    output [FLAG_WIDTH-1:0] o_flag,
    output [SIG_WIDTH-1:0] o_sig,
    output signed [EXP_WIDTH-1:0] o_exp,
    output o_sign
);

assign o_sign = i_data[NUM_WIDTH-1];
assign o_exp = i_data[NUM_WIDTH-2:SIG_WIDTH];
assign o_sig = i_data[SIG_WIDTH-1:0];

assign nan = &o_exp && &o_sig;
assign zero = &(~o_exp) && &(~o_sig);
assign inf = &o_exp && ~&o_sig;
assign norm = ~nan && ~zero && ~inf;

assign o_flag = {nan, zero, inf, norm};

endmodule