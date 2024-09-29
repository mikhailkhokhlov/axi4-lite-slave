`ifndef _AXI4L_TEST_RD_TOP_
`define _AXI4L_TEST_RD_TOP_

`timescale 1ns / 1ps

`include "axi4l-rd-if.sv"
`include "axi4l-rd-test.sv"
`include "../s-axi4l-rd-channel.v"

`define CLOCK_PERIOD 10

module rd_tb();

  logic clock;

  initial begin
    clock = 0;
    forever
      #(`CLOCK_PERIOD / 2) clock = ~clock;
  end

  axi4lite_rd_if    axi4l_rd_if0( clock );
  rd_reg_file_if rd_reg_file_if0( clock );

  s_axi4l_rd_channel dut( .i_axi_clock        ( clock                             ),
                          .i_axi_aresetn      ( axi4l_rd_if0.axi_areset_n         ),
                          .i_axi_araddr       ( axi4l_rd_if0.axi_araddr           ),
                          .i_axi_arcache      ( axi4l_rd_if0.axi_arcache          ),
                          .i_axi_arprot       ( axi4l_rd_if0.axi_arprot           ),
                          .i_axi_araddr_valid ( axi4l_rd_if0.axi_araddr_valid     ),
                          .o_axi_araddr_ready ( axi4l_rd_if0.axi_araddr_ready     ),

                          .o_axi_rdata        ( axi4l_rd_if0.axi_rdata            ),
                          .o_axi_rresp        ( axi4l_rd_if0.axi_rresp            ),
                          .o_axi_rdata_valid  ( axi4l_rd_if0.axi_rdata_valid      ),
                          .i_axi_rdata_ready  ( axi4l_rd_if0.axi_rdata_ready      ),

                          .o_raddr            ( rd_reg_file_if0.axi4l_raddr       ),
                          .o_raddr_valid      ( rd_reg_file_if0.axi4l_raddr_valid ),
                          .i_rdata            ( rd_reg_file_if0.axi4l_rdata       ));

  axi4l_rd_test test( axi4l_rd_if0,
                      rd_reg_file_if0 );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule

`endif // _AXI4L_TEST_RD_TOP_
