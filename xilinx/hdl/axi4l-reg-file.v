`ifndef _AXI4L_REG_FILE_V_
`define _AXI4L_REG_FILE_V_

`timescale 1ns / 1ps

`include "../../s-axi4l-wr-channel.v"
`include "../../s-axi4l-rd-channel.v"
`include "reg-file-4x32.v"

module axi4l_reg_file
(
    input  wire        i_axi_clock,
    input  wire        i_axi_aresetn,
    // write address channel
    input  wire [3:0]  i_axi_awaddr,
    input  wire [2:0]  i_axi_awprot,
    input  wire        i_axi_awaddr_valid,
    output wire        o_axi_awaddr_ready,
    // write data channel
    input  wire [31:0] i_axi_wdata,
    input  wire [ 3:0] i_axi_wstrb,
    input  wire        i_axi_wdata_valid,
    output wire        o_axi_wdata_ready,
    // write response channel	
    output wire [1:0]  o_axi_bresp,
    output wire        o_axi_bvalid,
    input  wire        i_axi_bready,
    // read address channel
    input  wire [3:0]  i_axi_araddr,
    input  wire [3:0]  i_axi_arcache,
    input  wire [2:0]  i_axi_arprot,
    input  wire        i_axi_araddr_valid,
    output wire        o_axi_araddr_ready,
    // read data channel
    output wire [31:0] o_axi_rdata,
    output wire [ 1:0] o_axi_rresp,
    output wire        o_axi_rdata_valid,
    input  wire        i_axi_rdata_ready
);

    wire [31:0] write_data;
    wire [ 3:0] write_addr;
    wire        write_data_valid;

    s_axi4l_wr_channel slave_write_channel(
        .i_axi_clock        ( i_axi_clock        ),
        .i_axi_aresetn      ( i_axi_aresetn      ),
        .i_axi_awaddr       ( i_axi_awaddr       ),
        .i_axi_awprot       ( i_axi_awprot       ),
        .i_axi_awaddr_valid ( i_axi_awaddr_valid ),
        .o_axi_awaddr_ready ( o_axi_awaddr_ready ),
        .i_axi_wdata        ( i_axi_wdata        ),
        .i_axi_wstrb        ( i_axi_wstrb        ),
        .i_axi_wdata_valid  ( i_axi_wdata_valid  ),
        .o_axi_wdata_ready  ( o_axi_wdata_ready  ),
        .o_axi_bresp        ( o_axi_bresp        ),
        .o_axi_bvalid       ( o_axi_bvalid       ),
        .i_axi_bready       ( i_axi_bready       ),
        .o_waddr            ( write_addr         ),
        .o_wdata            ( write_data         ),
        .o_wvalid           ( write_data_valid   )
    );

    wire [ 3:0] read_addr;
    wire        read_addr_valid;
    wire [31:0] read_data;

    s_axi4l_rd_channel slave_read_channel(
        .i_axi_clock        ( i_axi_clock        ),
        .i_axi_aresetn      ( i_axi_aresetn      ),
        .i_axi_araddr       ( i_axi_araddr       ),
        .i_axi_arcache      ( i_axi_arcache      ),
        .i_axi_arprot       ( i_axi_arprot       ),
        .i_axi_araddr_valid ( i_axi_araddr_valid ),
        .o_axi_araddr_ready ( o_axi_araddr_ready ),
        .o_axi_rdata        ( o_axi_rdata        ),
        .o_axi_rresp        ( o_axi_rresp        ),
        .o_axi_rdata_valid  ( o_axi_rdata_valid  ),
        .i_axi_rdata_ready  ( i_axi_rdata_ready  ),
        .o_raddr            ( read_addr          ),
        .o_raddr_valid      ( read_addr_valid    ),
        .i_rdata            ( read_data          )
    );

    reg_file_4x32 reg_file0(
        .i_clock        ( i_axi_clock      ),
        .i_aresetn      ( i_axi_aresetn    ),
        .i_write_data   ( write_data       ),
        .i_write_addr   ( write_addr       ),
        .i_write_enable ( write_data_valid ),
        .i_read_addr    ( read_addr        ),
        .i_read_enable  ( read_addr_valid  ),
        .o_read_data    ( read_data        )
    );

endmodule

`endif // _AXI4L_REG_FILE_V_
