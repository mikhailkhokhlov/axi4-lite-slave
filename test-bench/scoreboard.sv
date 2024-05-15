`ifndef _SCOREBOARD_SV_
`define _SCOREBOARD_SV_

`include "transaction.sv"
`include "test-config.sv"

class scoreboard;

  extern function new(test_config conf,
                      mailbox     mon2chk_mbx,
                      mailbox     drv2chk_mbx);

  extern task run();

  local mailbox mon2chk_mbx;
  local mailbox drv2chk_mbx;

  local write_transaction input_trans;
  local write_transaction output_trans;

  local test_config conf;
endclass


function scoreboard::new(test_config conf,
                         mailbox     mon2chk_mbx,
                         mailbox     drv2chk_mbx);
  this.conf         = conf;
  this.mon2chk_mbx  = mon2chk_mbx;
  this.drv2chk_mbx  = drv2chk_mbx;
  this.input_trans  = new();
  this.output_trans = new();
endfunction

task scoreboard::run();
  repeat (conf.trans_num) begin
    drv2chk_mbx.get(input_trans);
    mon2chk_mbx.get(output_trans);

    assert(input_trans.addr == output_trans.addr)
      $display("[%0t] SUCCESS address transation check", $time());
    else begin
      $error("[%0t] FAIL address transaction check. Expected: 0x%08x, Got: 0x%08x",
             $time(), input_trans.addr, output_trans.addr);
    end

    assert(input_trans.data == output_trans.data)
      $display("[%0t] SUCCESS wdata transation check", $time());
    else begin
      $error("[%0t] FAIL wdata transaction check. Expected: 0x%08x, Got: 0x%08x",
             $time(), input_trans.data, output_trans.data);
    end
  end
endtask

`endif // _SCOREBOARD_SV_
