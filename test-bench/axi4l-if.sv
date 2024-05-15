`ifndef _AXI4L_IF_SV_
`define _AXI4L_IF_SV_

`timescale 1ns / 1ps

`include "parameters.svh"

interface axi4lite_if(input logic axi4l_clock);
    // AXI reset
    logic                           axi_areset_n;
    // write address channel
    logic [(`AXI_ADDR_WIDTH - 1):0] axi_awaddr;
    logic [2:0]                     axi_awprot;
    logic                           axi_awaddr_valid;
    logic                           axi_awaddr_ready;
    // write data channel
    logic [(`AXI_DATA_WIDTH - 1):0] axi_wdata;
    logic [(`AXI_STRB_WIDTH - 1):0] axi_wstrb;
    logic                           axi_wdata_valid;
    logic                           axi_wdata_ready;
    // write response channel	
    logic [                    1:0] axi_bresp;
    logic                           axi_bready;
    logic                           axi_bvalid;

    clocking wr_cb @(posedge axi4l_clock);
        output axi_awaddr;
        output axi_awprot;
        output axi_awaddr_valid;
        input  axi_awaddr_ready;

        output axi_wdata;
        output axi_wstrb;
        output axi_wdata_valid;
        input  axi_wdata_ready;

        input  axi_bresp;
        output axi_bready;
        input  axi_bvalid;
    endclocking

    modport TEST(clocking wr_cb, output axi_areset_n);

endinterface

interface wr_reg_file_if(input logic axi4l_clock);

    logic [(`AXI_DATA_WIDTH - 1):0] axi4l_wdata;
    logic [(`AXI_ADDR_WIDTH - 1):0] axi4l_waddr;
    logic                           axi4l_wvalid;

    clocking wr_cb @(posedge axi4l_clock);
        input axi4l_wdata;
        input axi4l_waddr;
        input axi4l_wvalid;
    endclocking

    modport TEST(clocking wr_cb);

endinterface

`endif // _AXI4L_IF_SV_
