module bf16_add #(
    parameter EXP_WIDTH = 8.
    parameter SIG_WIDTH = 7, 
    parameter FLAG_WIDTH = 4
) (
    input [EXP_WIDTH+SIG_WIDTH:0] i_data_a,
    input [EXP_WIDTH+SIG_WIDTH:0] i_data_b,

    output [EXP_WIDTH+SIG_WIDTH:0] o_data,
    output [FLAG_WIDTH-1:0] o_flag
)



endmodule