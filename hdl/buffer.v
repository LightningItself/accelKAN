module buffer #(
    parameter DWIDTH = 16
) (
    input wire aclk,
    input wire aresetn,

    //s_axis input port
    input  wire              s_axis0_tvalid,
    output wire              s_axis0_tready,
    input  wire [DWIDTH-1:0] s_axis0_tdata,
    input  wire              s_axis0_tlast,

    //kernel read port
    input  wire              k_rready,
    output wire              k_rvalid,
    output wire [DWIDTH-1:0] k_rdata,

    //kernel write port
    output wire              k_wready,
    input  wire              k_wvalid,
    input  wire [DWIDTH-1:0] k_wdata,

    //control port
    input wire c_lfirst,
    input wire c_llast,
    input wire c_new,

    //s_axis output port
    output wire              s_axis1_tvalid,
    input  wire              s_axis1_tready,
    output wire [DWIDTH-1:0] s_axis1_tdata,
    output wire              s_axis1_tlast
);

    reg [1:0] status;  //00:l1+write, 01:l1+writedone, 10:last, 11:intermediate
    reg fifoin;  // select f2 as input fifo

    //input and output fifo signals
    wire fin_iwrite, fout_iwrite;
    wire [DWIDTH-1:0] fin_idata, fout_idata;
    wire fin_iread, fout_iread;
    wire [DWIDTH-1:0] fin_odata, fout_odata;
    wire fin_oend, fout_oend;
    wire fin_rrst, fout_rrst;
    wire fin_wrst, fout_wrst;

    fifo f1 (
        .iclk   (aclk),
        .iresetn(aresetn),
        .iwrite (fifoin ? fout_iwrite : fin_iwrite),
        .idata  (fifoin ? fout_idata  : fin_idata ),
        .iread  (fifoin ? fout_iread  : fin_iread ),
        .odata  (f1_odata ),
        .oend   (f1_oend  ),
        .rrst   (fifoin ? fout_rrst   : fin_rrst  ),
        .wrst   (fifoin ? fout_wrst   : fin_wrst  )
    );

    fifo f2 (
        .iclk   (aclk),
        .iresetn(aresetn),
        .iwrite (fifoin ? fin_iwrite : fout_iwrite),
        .idata  (fifoin ? fin_idata  : fout_idata ),
        .iread  (fifoin ? fin_iread  : fout_iread ),
        .odata  (f2_odata ),
        .oend   (f2_oend  ),
        .rrst   (fifoin ? fin_rrst   : fout_rrst  ),
        .wrst   (fifoin ? fin_wrst   : fout_wrst  )
    );

    assign fin_odata  = fifoin ? f2_odata : f1_odata;
    assign fout_odata = fifoin ? f1_odata : f2_odata;
    assign fin_oend   = fifoin ? f2_oend  : f1_oend;
    assign fout_oend  = fifoin ? f1_oend  : f2_oend;

    //handle new layer
    assign fout_wrst  = c_new & c_lfirst;
    assign fin_wrst   = c_new;
    assign fin_rrst   = c_new;
    assign fout_rrst  = c_new;

    always @(posedge aclk) begin
        if (aresetn) begin
            status <= 2'b00;
            fifoin <= 0;
        end else if (c_new) begin
            fifoin <= ~fifoin;
            if (c_lfirst) begin
                status <= 2'b00;
            end else if (c_llast) begin
                status <= 2'b10;
            end else begin
                status <= 2'b11;
            end
        end else if (s_axis0_tlast) status <= 2'b01;
    end

    //handle axi input
    assign s_axis0_tready = (status == 2'b00);
    assign fin_iwrite = s_axis0_tready & s_axis0_tvalid;
    assign fin_idata = s_axis0_tdata;

    //handle kernel read
    assign k_rvalid = ~fin_oend | (status == 2'b00);
    assign k_rdata = fin_odata;
    assign fin_iread = k_rvalid & k_rready;

    //handle kernel write
    assign k_wready = 1;
    assign k_wdata = fout_idata;
    assign fout_iwrite = k_wready & k_wvalid;

    //handle axi output
    assign s_axis1_tvalid = (status == 2'b10) & (~fout_oend);
    assign fout_iread = s_axis1_tvalid & s_axis1_tready;
    assign s_axis1_tdata = fout_odata;



endmodule
