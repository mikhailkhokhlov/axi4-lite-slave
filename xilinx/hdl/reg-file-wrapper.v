`ifndef _REG_FILE_WRAPPER_V_
`define _REG_FILE_WRAPPER_V_ 

`include "axi4l-reg-file.v"

`timescale 1ns / 1ps

module reg_file_wrapper 
(
    input wire         S_AXI_ACLK,
    input wire         S_AXI_ARESETN,
    
    input  wire [3:0]  S_AXI_AWADDR,
    input  wire [2:0]  S_AXI_AWPROT,
    input  wire        S_AXI_AWVALID,
    output wire        S_AXI_AWREADY,
    
    input  wire [31:0] S_AXI_WDATA,
    input  wire [ 3:0] S_AXI_WSTRB,
    input  wire        S_AXI_WVALID,
    output wire        S_AXI_WREADY,
    
    output wire [1:0]  S_AXI_BRESP,
    output wire        S_AXI_BVALID,
    input  wire        S_AXI_BREADY,
    
    input  wire [3:0]  S_AXI_ARADDR,
    input  wire [3:0]  S_AXI_ARCACHE,
    input  wire [2:0]  S_AXI_ARPROT,
    input  wire        S_AXI_ARVALID,
    output wire        S_AXI_ARREADY,
    
    output wire [31:0] S_AXI_RDATA,
    output wire [1:0]  S_AXI_RRESP,
    output wire        S_AXI_RVALID,
    input  wire        S_AXI_RREADY
);
    
    axi4l_reg_file reg_file(
        .i_axi_clock        ( S_AXI_ACLK    ),
        .i_axi_aresetn      ( S_AXI_ARESETN ),
        .i_axi_awaddr       ( S_AXI_AWADDR  ),
        .i_axi_awprot       ( S_AXI_AWPROT  ),
        .i_axi_awaddr_valid ( S_AXI_AWVALID ),
        .o_axi_awaddr_ready ( S_AXI_AWREADY ),
        .i_axi_wdata        ( S_AXI_WDATA   ),
        .i_axi_wstrb        ( S_AXI_WSTRB   ),
        .i_axi_wdata_valid  ( S_AXI_WVALID  ),
        .o_axi_wdata_ready  ( S_AXI_WREADY  ),
        .o_axi_bresp        ( S_AXI_BRESP   ),
        .o_axi_bvalid       ( S_AXI_BVALID  ),
        .i_axi_bready       ( S_AXI_BREADY  ),
        .i_axi_araddr       ( S_AXI_ARADDR  ),
        .i_axi_arcache      ( S_AXI_ARCACHE ),
        .i_axi_arprot       ( S_AXI_ARPROT  ),
        .i_axi_araddr_valid ( S_AXI_ARVALID ),
        .o_axi_araddr_ready ( S_AXI_ARREADY ),
        .o_axi_rdata        ( S_AXI_RDATA   ),
        .o_axi_rresp        ( S_AXI_RRESP   ),
        .o_axi_rdata_valid  ( S_AXI_RVALID  ),
        .i_axi_rdata_ready  ( S_AXI_RREADY  )
    );
    
endmodule

`endif /* _REG_FILE_WRAPPER_V_ */
