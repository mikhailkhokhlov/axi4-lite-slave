`ifndef _MONITOR_SV_
`define _MONITOR_SV_

`include "parameters.svh"
`include "transaction.sv"
`include "test-config.sv"

class monitor;

  local virtual wr_reg_file_if.TEST wr_reg_if;
  local mailbox                     mon2chk_mbx;
  local write_transaction           recv_trans;
  local test_config                 conf;
  local event                       reset_ev;

  extern function new(test_config                 conf,
                      virtual wr_reg_file_if.TEST wr_reg_if,
                      mailbox                     mon2chk_mbx,
                      event                       reset_ev);

  extern task run();
  extern local task timeout(int to_clocks, string op);

endclass : monitor


function monitor::new(test_config                 conf,
                      virtual wr_reg_file_if.TEST wr_reg_if,
                      mailbox                     mon2chk_mbx,
                      event                       reset_ev);
  this.conf        = conf;
  this.wr_reg_if   = wr_reg_if;
  this.mon2chk_mbx = mon2chk_mbx;
  this.reset_ev    = reset_ev;
  this.recv_trans  = new();
endfunction

task monitor::timeout(int to_clocks, string op);
  repeat(to_clocks) @wr_reg_if.wr_cb;
  $display("[%0t] Timeout: %s", $time(), op);
  $stop();
endtask

task monitor::run();
  @reset_ev;

  repeat (conf.trans_num) begin
    @wr_reg_if.wr_cb;

    fork : wait_for_valid
      while (~wr_reg_if.wr_cb.axi4l_wvalid) @wr_reg_if.wr_cb;
      timeout(conf.timeout_clocks, "monitor data valid");
    join_any : wait_for_valid

    disable wait_for_valid;

    recv_trans.addr = wr_reg_if.wr_cb.axi4l_waddr;
    recv_trans.data = wr_reg_if.wr_cb.axi4l_wdata;

    mon2chk_mbx.put(recv_trans);
  end
endtask

`endif // _MONITOR_SV_
