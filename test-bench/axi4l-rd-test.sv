`ifndef _AXI4L_RD_TEST_SV_
`define _AXI4L_RD_TEST_SV_

program axi4l_rd_test(axi4lite_rd_if.TEST axi4l_rd_if,
                      rd_reg_file_if.TEST rd_reg_if);

  import axi4l_test::*;

  environment #(
    virtual axi4lite_rd_if.TEST,
    virtual rd_reg_file_if.TEST) env;

  initial begin
    env = new(axi4l_rd_if, rd_reg_if);
    env.build();
    env.start();
    env.report();
  end

endprogram

`endif // _AXI4L_RD_TEST_SV_
