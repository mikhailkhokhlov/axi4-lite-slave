`ifndef _SCOREBOARD_SV_
`define _SCOREBOARD_SV_

`include "transaction.sv"
`include "test-config.sv"

class scoreboard;

  local mailbox mon2chk_mbx;
  local mailbox drv2chk_mbx;

  local axi4l_transaction master_trans;
  local axi4l_transaction slave_trans;

  local test_config conf;

  function new(test_config conf,
               mailbox     mon2chk_mbx,
               mailbox     drv2chk_mbx);
    this.conf         = conf;
    this.mon2chk_mbx  = mon2chk_mbx;
    this.drv2chk_mbx  = drv2chk_mbx;
    this.master_trans  = new();
    this.slave_trans = new();
  endfunction

  task run();
    repeat (conf.trans_num) begin
      drv2chk_mbx.get(master_trans);
      mon2chk_mbx.get(slave_trans);

      assert(master_trans.addr == slave_trans.addr)
        $display("[%0t] SUCCESS address transaction check. Slave addr: 0x%08x, Master addr: 0x%08x",
                 $time(), slave_trans.addr, master_trans.addr);
      else begin
        $error("[%0t] FAIL address transaction check.", $time());
        $error("Expected: 0x%08x, Got: 0x%08x",
               master_trans.addr, slave_trans.addr);
      end

      assert(master_trans.data == slave_trans.data)
        $display("[%0t] SUCCESS data transation check. Slave data: 0x%08x, Master data: 0x%08x",
                 $time(), slave_trans.data, master_trans.data);
      else begin
        $error("[%0t] FAIL data transaction check.", $time());
        $error("Expected: 0x%08x, Got: 0x%08x",
               master_trans.data, slave_trans.data);
      end
    end
  endtask

endclass

`endif // _SCOREBOARD_SV_
