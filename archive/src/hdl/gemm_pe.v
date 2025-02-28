module gemm_pe #(
    parameter DATA_WIDTH = 16,
    parameter FLAG_WIDTH = 4
) (
    input i_clk,
    input i_rst,
    input i_valid,

    input [DATA_WIDTH-1:0] i_data_x,
    input [DATA_WIDTH-1:0] i_data_w,

    output reg [DATA_WIDTH-1:0] o_data_x,
    output reg [DATA_WIDTH-1:0] o_data_w,
    output reg [DATA_WIDTH-1:0] o_data_acc,
    output reg [FLAG_WIDTH-1:0] o_flag_acc
);

wire [DATA_WIDTH-1:0] o_mul_data, o_add_data;
wire [FLAG_WIDTH-1:0] o_mul_flag, o_add_flag;

bf16_mul m_mul(
    .i_data_a(i_data_x),
    .i_data_b(i_data_w),
    .o_data(o_mul_data),
    .o_flag(o_mul_flag)
);

bf16_add m_add(
    .i_data_a(o_data_acc),
    .i_data_b(o_mul_data),
    .o_data(o_add_data),
    .o_flag(o_add_flag)
);

always @(posedge i_clk) begin
    if(i_rst) begin
        o_data_acc <= 'd0;
        o_flag_acc <= 'd0;
        o_data_x <= 'd0;
        o_data_w <= 'd0;
    end
    else if(i_valid) begin
        o_data_acc <= o_add_data;
        o_flag_acc <= o_add_flag;
        o_data_x <= i_data_x;
        o_data_w <= i_data_w;
    end
end

endmodule