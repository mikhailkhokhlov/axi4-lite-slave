`ifndef _AXI4L_RW_TEST_SV_
`define _AXI4L_RW_TEST_SV_

program axi4l_wr_test(axi4lite_wr_if.TEST axi4l_wr_if,
                      wr_reg_file_if.TEST wr_reg_if);

  import axi4l_test::*;

  environment #(
    virtual axi4lite_wr_if.TEST,
    virtual wr_reg_file_if.TEST) env;

  initial begin
    env = new(axi4l_wr_if, wr_reg_if);
    env.build();
    env.start();
    env.report();
  end

endprogram

`endif // _AXI4L_RW_TEST_SV_
