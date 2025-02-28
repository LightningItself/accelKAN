// fifo for feeding x input to systolic array
// each of these modules handle one of the rows of the pe
// control unit must handle i_valid depending on all row states

module gemm_x_buff #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 16,
    parameter N_DEPTH = 4,

) (
    input i_clk,
    input i_rst,
    
)