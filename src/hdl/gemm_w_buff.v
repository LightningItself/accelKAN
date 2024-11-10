module gemm_w_buff #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 512, //should be more than grid size ~~100??
    parameter N_DEPTH = $clog2(DEPTH)
    //this module is for one column... need each of this module for each column in pe array
    )(
    input i_clk,
    input i_rst,
    input i_valid,

    input i_write,
    input [DATA_WIDTH-1:0] i_data,

    output [DATA_WIDTH-1:0] o_data,
);
    reg [DATA_WIDTH-1:0] store [DEPTH-1:0];
    reg [N_DEPTH-1:0] store_ptr;

    always @(posedge i_clk) begin
        if(i_rst) begin
            //reset pointer to zero
            store_ptr <= 'd0;
        end
        else if(i_valid & i_write) begin
            //write input data to store pointer and increment
            store[store_ptr] <= i_data;
            store_ptr <= store_ptr+1; 
        end
        else if(i_valid) begin
            //read, increment pointer
            store_ptr <= store_ptr+1;
        end
    end
    assign o_data = store[store_ptr];

endmodule

//read -> async read
//update -> i_valid will increment pointer
//write -> use rst to zero the ptr, then i_write+i_valid -> write to mem+increment_pointer
//do write DEPTH times to completely rewrite the mem