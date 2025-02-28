module #(
    parameter DWIDTH = 16,
    parameter PECOUNT = 64,
    parameter NAXIWIDTH = 10,

    localparam AXIWIDTH = (1<<10)
) (
    //axi master address
    output wire m_axi_arvalid,
    input wire m_axi_arready,
    output wire [31:0] m_axi_araddr,
    output wire [2:0] m_axi_arsize,
    output wire [1:0] m_axi_arburst,
    output wire [7:0] m_axi_arlen,
    //axi master data
    input wire m_axi_rvalid,
    output wire m_axi_rready,
    input wire m_axi_rlast,
    input wire [NAXIWIDTH-1:0] m_axi_rdata,
    input wire m_axi_rlast,
    input wire [1:0] m_axi_rresp

    //read from buffer
    output wire k_ready,
    input wire k_rvalid,
    input wire [DWIDTH-1:0] k_rdata,

    //write to buffer
    input wire k_wready,
    output wire k_wvalid,
    output wire [DWIDTH-1:0] k_wdata

);

    //for each input x we make axi with burst length = 4
    

    //handle axi master control


endmodule