module fifo #(
    parameter DWIDTH = 16,
    parameter NDEPTH = 4,
    
    localparam DEPTH = (1<<NDEPTH)
) (
    input wire                  iclk,
    input wire                  iresetn,

    input wire                  iwrite,
    input wire [DWIDTH-1:0]     idata,

    input wire                  iread,
    output reg [DWIDTH-1:0]     odata,
    output wire                 oend, //ON if at end of fifo
    
    input wire                  rrst,
    input wire                  wrst
);
    reg [DWIDTH-1:0] fifo [DEPTH-1:0];
    reg [NDEPTH-1:0] rptr, wptr;

    assign oend = (rptr == wptr);

    always @(posedge iclk) begin
        if(iresetn) begin
            rptr <= 0;
            wptr <= 0;
        end
        else begin
            if(wrst)
                wptr <= 0;
            else if(iwrite) begin
                fifo[wptr] <= idata;
                wptr <= wptr+1;
            end
            if(rrst)
                rptr <= 0;
            else if(iread & ~oend) begin 
                odata <= fifo[rptr];
                rptr <= rptr+1;
            end    
        end
    end

endmodule