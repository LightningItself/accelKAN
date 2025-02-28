module pe #(
    parameter WORDSIZE = 16
) (
    input wire iclk,
    input wire [WORDSIZE-1:0] xdata,
    input wire [WORDSIZE-1:0] wdata,
    input wire ivalid,
    output reg [WORDSIZE-1:0] odata,
    output reg ovalid
);

    always @(posedge iclk) begin
        odata1 <= xdata*odata;
        odata2 <= odata1;
        odata <= odata2;

        ovalid1 <= ivalid;
        ovalid2 <= ovalid1;
        ovalid <= ovalid2;
    end 

endmodule