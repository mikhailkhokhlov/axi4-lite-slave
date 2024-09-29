`ifndef _GENERATOR_SV_
`define _GENERATOR_SV_

`include "transaction.sv"
`include "test-config.sv"

class generator;

  local mailbox     gen2drv_mbx;
  local mailbox     gen2mon_mbx;
  local test_config conf;

  function new(test_config conf,
               mailbox     gen2drv_mbx,
               mailbox     gen2mon_mbx);

    this.gen2drv_mbx = gen2drv_mbx;
    this.gen2mon_mbx = gen2mon_mbx;
    this.conf        = conf;
  endfunction

  task run();
    repeat(conf.trans_num) begin
      transaction tr = new();
      assert (tr.randomize())
        begin
          gen2drv_mbx.put(tr);
          gen2mon_mbx.put(tr);
        end
      else
        begin
          $display("[%0t] FAIL transaction randomize", $time());
          $stop();
        end
    end // repeat
  endtask

endclass : generator

`endif // _GENERATOR_SV_
