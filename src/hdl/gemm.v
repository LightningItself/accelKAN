module #(
    parameter ROWS = 4,
    parameter COLS = 4,
    
    parameter W_DEPTH = 16,

)(
    input i_clk,
    input i_rst,

);

    gemm_arr m_gemm_arr (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_valid(i_valid),
        
    )

endmodule