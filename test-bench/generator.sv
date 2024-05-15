`ifndef _GENERATOR_SV_
`define _GENERATOR_SV_

`timescale 1ns / 1ps

`include "transaction.sv"
`include "test-config.sv"

class generator;

  local mailbox     gen2drv_mbx;
  local test_config conf;

  extern function new(test_config conf,
                      mailbox     gen2drv_mbx);
  extern task run();

endclass : generator


function generator::new(test_config conf,
                        mailbox     gen2drv_mbx);
  this.gen2drv_mbx = gen2drv_mbx;
  this.conf        = conf;
endfunction

task generator::run();
  repeat(conf.trans_num) begin
    write_transaction trans = new();
    assert (trans.randomize())
      gen2drv_mbx.put(trans);
    else begin
      $display("[%0t] FAIL transaction randomise", $time());
      $stop();
    end
  end
endtask

`endif // _GENERATOR_SV_
