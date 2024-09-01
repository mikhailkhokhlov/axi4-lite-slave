`ifndef _DRIVER_SV_
`define _DRIVER_SV_

`include "transaction.sv"
`include "test-config.sv"

class driver #(type input_if);

  local test_config              conf;
  local input_if                 axi4l_if;
  local axi4l_bfm                bfm;
  local mailbox                  gen2drv_mbx;
  local mailbox                  drv2chk_mbx;
  local axi4l_transaction        master_tr;
  local event                    reset_ev;

  function new(test_config conf,
               input_if    axi4l_if,
               mailbox     gen2drv_mbx,
               mailbox     drv2chk_mbx,
               event       reset_ev);

    this.conf        = conf;
    this.axi4l_if    = axi4l_if;
    this.gen2drv_mbx = gen2drv_mbx;
    this.drv2chk_mbx = drv2chk_mbx;
    this.bfm         = axi4l_if.bfm;
    this.reset_ev    = reset_ev;
  endfunction

  task run();
    logic [1:0] response = 2'b11;

    fork
      reset_dut();
      reset_bus();
    join

    bfm.align_clock();

    repeat (conf.trans_num) begin
      gen2drv_mbx.get(master_tr);
      master_tr.dump();

      bfm.drive_transaction(master_tr,
                            conf.timeout_clocks,
                            response);

      assert(response == 2'b00)
        begin
          $display("[%0t] SUCCESS RESPONSE", $time());
          drv2chk_mbx.put(master_tr);
        end
      else
        begin
          $display("[%0t] FAIL RESPONSE", $time());
          $stop();
        end
    end // repeat
  endtask

  local task reset_bus();
    $display("[%0t] BUS RESET", $time());
    bfm.reset_bus();
  endtask

  local task reset_dut();
    $display("[%0t] RESET assert", $time());
    bfm.reset_dut();
    ->reset_ev;
    $display("[%0t] RESET deassert", $time());
  endtask

endclass : driver

`endif // _DRIVER_SV_
