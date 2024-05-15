`ifndef _TEST_CONFIG_SV_
`define _TEST_CONFIG_SV_

class test_config;
  extern function new(int trans_num,
                      int timeout_clocks);

  int trans_num;
  int timeout_clocks;
endclass

function test_config::new(int trans_num,
                          int timeout_clocks);
  this.trans_num      = trans_num;
  this.timeout_clocks = timeout_clocks;
endfunction

`endif // _TEST_CONFIG_SV_
