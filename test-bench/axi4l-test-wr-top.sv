`ifndef _AXI4L_TEST_WR_TOP_
`define _AXI4L_TEST_WR_TOP_

`timescale 1ns / 1ps

`include "axi4l-wr-if.sv"
`include "axi4l-wr-test.sv"
`include "../s-axi4l-wr-channel.v"

`define CLOCK_PERIOD 10

module wr_tb();

  logic clock;

  initial begin
    clock = 0;
    forever
      #(`CLOCK_PERIOD / 2) clock = ~clock;
  end

  axi4lite_wr_if axi4l_wr_if0( clock );
  wr_reg_file_if reg_file_if0( clock );

  s_axi4l_wr_channel dut( .i_axi_clock        ( clock                         ),
                          .i_axi_aresetn      ( axi4l_wr_if0.axi_areset_n     ),
                          .i_axi_awaddr       ( axi4l_wr_if0.axi_awaddr       ),
                          .i_axi_awprot       ( axi4l_wr_if0.axi_awprot       ),
                          .i_axi_awaddr_valid ( axi4l_wr_if0.axi_awaddr_valid ),
                          .o_axi_awaddr_ready ( axi4l_wr_if0.axi_awaddr_ready ),

                          .i_axi_wdata        ( axi4l_wr_if0.axi_wdata        ),
                          .i_axi_wstrb        ( axi4l_wr_if0.axi_wstrb        ),
                          .i_axi_wdata_valid  ( axi4l_wr_if0.axi_wdata_valid  ),
                          .o_axi_wdata_ready  ( axi4l_wr_if0.axi_wdata_ready  ),

                          .o_axi_bresp        ( axi4l_wr_if0.axi_bresp        ),
                          .o_axi_bvalid       ( axi4l_wr_if0.axi_bvalid       ),
                          .i_axi_bready       ( axi4l_wr_if0.axi_bready       ),

                          .o_waddr            ( reg_file_if0.axi4l_waddr      ),
                          .o_wdata            ( reg_file_if0.axi4l_wdata      ),
                          .o_wvalid           ( reg_file_if0.axi4l_wvalid     ));

  axi4l_wr_test test( axi4l_wr_if0,
                      reg_file_if0 );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule

`endif // _AXI4L_TEST_WR_TOP_
