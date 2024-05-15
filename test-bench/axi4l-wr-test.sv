`ifndef _AXI4L_RW_TEST_SV_
`define _AXI4L_RW_TEST_SV_

`timescale 1ns / 1ps

//`include "axi4l-if.sv"
`include "environment.sv"

program axi4l_wr_test(axi4lite_if.TEST    axi4l_if,
                      wr_reg_file_if.TEST wr_reg_if);

  environment env;

  initial begin
    env = new(axi4l_if, wr_reg_if);
    env.build();
    env.start();
    env.report();
  end

endprogram

`endif // _AXI4L_RW_TEST_SV_
