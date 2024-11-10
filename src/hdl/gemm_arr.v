// systolic array module
// weights supplied from top == COLS*DATA_WIDTH
// x supplied from left -> x_data == ROWS*DATA_WIDTH


module gemm_arr #(
    parameter ROWS = 2,
    parameter COLS = 2,
    parameter N_ROWS = 1, //log2(rows)
    parameter N_COLS = 1, //log2(cols)
    parameter DATA_WIDTH = 16,
    parameter FLAG_WIDTH = 4
) (
    input i_clk,
    input i_rst,
    input i_valid,

    input [COLS*DATA_WIDTH-1:0] i_data_w,
    input [ROWS*DATA_WIDTH-1:0] i_data_x,

    //how to return output data?? entire matrix?
    //ideally we must feed cols from left back into the f module for next layer... so return cols wise

    input [N_COLS-1:0] i_addr,
    output [ROWS*DATA_WIDTH-1:0] o_data_acc, //return data of selected column
    output [ROWS*FLAG_WIDTH-1:0] o_data_flag
);


    //create vertical & horizontal wires
    wire [DATA_WIDTH-1:0] conn_w [ROWS*COLS-1:0]; 
    wire [DATA_WIDTH-1:0] conn_x [ROWS*COLS-1:0];
    wire [ROWS*DATA_WIDTH-1:0] conn_acc [COLS-1:0]; //store each column
    wire [ROWS*FLAG_WIDTH-1:0] conn_flag [COLS-1:0];


    genvar i;
    genvar j;
    generate
        for(i=0; i<ROWS; i=i+1) begin
            for(j=0; j<COLS; j=j+1) begin
                if(i==0 && j==0) begin
                    gemm_pe m_pe (
                        .i_clk(i_clk),
                        .i_rst(i_rst),
                        .i_valid(i_valid),
                        .i_data_x(i_data_x[ROWS*DATA_WIDTH-1:(ROWS-1)*DATA_WIDTH]), //input
                        .i_data_w(i_data_w[COLS*DATA_WIDTH-1:(COLS-1)*DATA_WIDTH]), //input
                        .o_data_x(conn_x[0]),
                        .o_data_w(conn_w[0]),
                        .o_data_acc(conn_acc[0][ROWS*DATA_WIDTH-1:(ROWS-1)*DATA_WIDTH]), //[COL no][row range]
                        .o_flag_acc(conn_flag[0][ROWS*FLAG_WIDTH-1:(ROWS-1)*FLAG_WIDTH])
                    );
                end
                else if(i==0) begin
                    gemm_pe m_pe (
                        .i_clk(i_clk),
                        .i_rst(i_rst),
                        .i_valid(i_valid),
                        .i_data_x(conn_x[j-1]),
                        .i_data_w(i_data_w[(COLS-j)*DATA_WIDTH-1:(COLS-1-j)*DATA_WIDTH]),  //input
                        .o_data_x(conn_x[j]),
                        .o_data_w(conn_w[j]),
                        .o_data_acc(conn_acc[j][ROWS*DATA_WIDTH-1:(ROWS-1)*DATA_WIDTH]),
                        .o_flag_acc(conn_flag[j][ROWS*FLAG_WIDTH-1:(ROWS-1)*FLAG_WIDTH])
                    );
                end
                else if(j==0) begin
                    gemm_pe m_pe (
                        .i_clk(i_clk),
                        .i_rst(i_rst),
                        .i_valid(i_valid),
                        .i_data_x(i_data_x[(ROWS-i)*DATA_WIDTH-1:(ROWS-1-i)*DATA_WIDTH]), //input
                        .i_data_w(conn_w[(i-1)*COLS]),
                        .o_data_x(conn_x[i*COLS]),
                        .o_data_w(conn_w[i*COLS]),
                        .o_data_acc(conn_acc[0][(ROWS-i)*DATA_WIDTH-1:(ROWS-1-i)*DATA_WIDTH]),
                        .o_flag_acc(conn_flag[0][(ROWS-i)*FLAG_WIDTH-1:(ROWS-1-i)*FLAG_WIDTH])
                    );
                end
                else begin
                    gemm_pe m_pe (
                        .i_clk(i_clk),
                        .i_rst(i_rst),
                        .i_valid(i_valid),
                        .i_data_x(conn_x[i*COLS+j-1]),
                        .i_data_w(conn_w[(i-1)*COLS+j]),
                        .o_data_x(conn_x[i*COLS+j]),
                        .o_data_w(conn_w[i*COLS+j]),
                        .o_data_acc(conn_acc[j][(ROWS-i)*DATA_WIDTH-1:(ROWS-1-i)*DATA_WIDTH]),
                        .o_flag_acc(conn_flag[j][(ROWS-i)*FLAG_WIDTH-1:(ROWS-1-i)*FLAG_WIDTH])
                    );
                end
                
            end
        end
    endgenerate

    assign o_data_acc = conn_acc[i_addr];
    assign o_data_flag = conn_flag[i_addr];
endmodule