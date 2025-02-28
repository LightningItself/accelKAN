module test (
    input clk,
    input reset,

    input [2:0] a,
    input valid,
    output reg [2:0] b
);

    always @(posedge clk) begin
        if(valid)
            b <= a;
        
    end
    
    always @(posedge clk) begin
        if(reset)
            b <= 0;
    end
endmodule