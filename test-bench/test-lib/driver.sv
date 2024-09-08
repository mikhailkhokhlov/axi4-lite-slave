`ifndef _DRIVER_SV_
`define _DRIVER_SV_

`include "transaction.sv"
`include "test-config.sv"

class driver #(type input_if,
               type output_if);

  local test_config              conf;
  local axi4l_master_bfm         in_bfm;
  local axi4l_output_bfm         out_bfm;
  local mailbox                  gen2drv_mbx;
  local mailbox                  drv2chk_mbx;
  local axi4l_transaction        master_tr;
  local event                    reset_ev;

  function new(test_config conf,
               input_if    in_if,
               output_if   out_if,
               mailbox     gen2drv_mbx,
               mailbox     drv2chk_mbx,
               event       reset_ev);

    this.conf        = conf;
    this.gen2drv_mbx = gen2drv_mbx;
    this.drv2chk_mbx = drv2chk_mbx;
    this.in_bfm      = in_if.in_bfm;
    this.out_bfm     = out_if.out_bfm;
    this.reset_ev    = reset_ev;
  endfunction

  local task wait_for_response_internal(input int delay,
                                        input int tm);
    logic [1:0] response = 2'b11;

    in_bfm.wait_for_response(master_tr.ready_delay,
                             tm,
                             response);

    $display("response = %2b", response);
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

  endtask

  task run();

    fork
      reset_dut();
      reset_bus();
    join

    in_bfm.align_clock();

    repeat (conf.trans_num) begin

      gen2drv_mbx.get(master_tr);
      master_tr.dump();

      fork
        out_bfm.drive_output(master_tr.data,
                             conf.timeout_clocks);
        in_bfm.drive_transaction(master_tr,
                                 conf.timeout_clocks);
        wait_for_response_internal(master_tr.ready_delay,
                                   conf.timeout_clocks);
      join
    end // repeat
  endtask

  local task reset_bus();
    $display("[%0t] BUS RESET", $time());
    in_bfm.reset_bus();
  endtask

  local task reset_dut();
    $display("[%0t] RESET assert", $time());
    in_bfm.reset_dut();
    ->reset_ev;
    $display("[%0t] RESET deassert", $time());
  endtask

endclass : driver

`endif // _DRIVER_SV_
