`ifndef _SCOREBOARD_SV_
`define _SCOREBOARD_SV_

`include "transaction.sv"
`include "test-config.sv"

class scoreboard;

  local mailbox mon2chk_mbx;
  local mailbox drv2chk_mbx;

  local axi4l_transaction input_trans;
  local axi4l_transaction output_trans;

  local test_config conf;

  function new(test_config conf,
               mailbox     mon2chk_mbx,
               mailbox     drv2chk_mbx);
    this.conf         = conf;
    this.mon2chk_mbx  = mon2chk_mbx;
    this.drv2chk_mbx  = drv2chk_mbx;
    this.input_trans  = new();
    this.output_trans = new();
  endfunction

  task run();
    repeat (conf.trans_num) begin
      drv2chk_mbx.get(input_trans);
      mon2chk_mbx.get(output_trans);

      assert(input_trans.addr == output_trans.addr)
        $display("[%0t] SUCCESS address transaction check. Addr: 0x%08x",
                 $time(), output_trans.addr);
      else begin
        $error("[%0t] FAIL address transaction check.", $time());
        $error("Expected: 0x%08x, Got: 0x%08x",
               input_trans.addr, output_trans.addr);
      end

      assert(input_trans.data == output_trans.data)
        $display("[%0t] SUCCESS data transation check. Data: 0x%08x",
                 $time(), output_trans.data);
      else begin
        $error("[%0t] FAIL data transaction check.", $time());
        $error("Expected: 0x%08x, Got: 0x%08x",
               input_trans.data, output_trans.data);
      end
    end
  endtask

endclass

`endif // _SCOREBOARD_SV_
