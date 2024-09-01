`ifndef _MONITOR_SV_
`define _MONITOR_SV_

`include "transaction.sv"
`include "test-config.sv"

class monitor #(type output_if);

  local output_if         wr_reg_if;
  local axi4l_monitor_bfm mon_bfm;
  local mailbox           mon2chk_mbx;
  local mailbox           gen2mon_mbx;
  local axi4l_transaction slave_tr;
  local axi4l_transaction master_tr;
  local test_config       conf;
  local event             reset_ev;

  function new(test_config conf,
               output_if   wr_reg_if,
               mailbox     mon2chk_mbx,
               mailbox     gen2mon_mbx,
               event       reset_ev);

    this.conf        = conf;
    this.wr_reg_if   = wr_reg_if;
    this.mon2chk_mbx = mon2chk_mbx;
    this.gen2mon_mbx = gen2mon_mbx;
    this.reset_ev    = reset_ev;
    this.mon_bfm     = wr_reg_if.mon_bfm;
    this.master_tr       = new();
    this.slave_tr       = new();
  endfunction

  task run();
    @reset_ev;

    repeat (conf.trans_num) begin
      addr_t addr;
      data_t data;

      gen2mon_mbx.get(master_tr);

      mon_bfm.align_clock();

      fork : drive_output
        mon_bfm.drive_output(master_tr);
        mon_bfm.monitor(addr, data, conf.timeout_clocks);
      join_any : drive_output

      disable drive_output;

      slave_tr.addr = addr;
      slave_tr.data = data;

      mon2chk_mbx.put(slave_tr);
    end
  endtask

endclass : monitor

`endif // _MONITOR_SV_
