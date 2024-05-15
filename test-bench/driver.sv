`ifndef _DRIVER_SV_
`define _DRIVER_SV_

`timescale 1ns / 1ps

`include "parameters.svh"
`include "transaction.sv"
`include "test-config.sv"

class driver;

  local test_config              conf;
  local virtual axi4lite_if.TEST axi4l_if;
  local mailbox                  gen2drv_mbx;
  local mailbox                  drv2chk_mbx;
  local write_transaction        trans;
  local event                    reset_ev;

  extern function new(test_config              conf,
                      virtual axi4lite_if.TEST axi4l_if,
                      mailbox                  gen2drv_mbx,
                      mailbox                  drv2chk_mbx,
                      event                    reset_ev);
  extern task run();

  extern task reset_bus();
  extern task reset_dut();

  extern task drive_aw();
  extern task drive_wdata();
  extern task monitor_bready();

  extern local task timeout(int to_clocks, string op);

endclass : driver


function driver::new(test_config              conf,
                     virtual axi4lite_if.TEST axi4l_if,
                     mailbox                  gen2drv_mbx,
                     mailbox                  drv2chk_mbx,
                     event                    reset_ev);
  this.conf        = conf;
  this.axi4l_if    = axi4l_if;
  this.gen2drv_mbx = gen2drv_mbx;
  this.drv2chk_mbx = drv2chk_mbx;
  this.reset_ev    = reset_ev;
endfunction

//TODO: base class with timeout
task driver::timeout(int to_clocks, string op);
  repeat (to_clocks) @axi4l_if.wr_cb;
  $display("[%0t] Timeout %s", $time(), op);
  $stop();
endtask

task driver::reset_bus();
  wait(~axi4l_if.axi_areset_n);

  axi4l_if.wr_cb.axi_awaddr       <= 0;
  axi4l_if.wr_cb.axi_awprot       <= 0;
  axi4l_if.wr_cb.axi_awaddr_valid <= 0;

  axi4l_if.wr_cb.axi_wdata        <= 0;
  axi4l_if.wr_cb.axi_wstrb        <= 0;
  axi4l_if.wr_cb.axi_wdata_valid  <= 0;

  axi4l_if.wr_cb.axi_bready       <= 0;

  wait(axi4l_if.axi_areset_n);
endtask

task driver::reset_dut();
  @axi4l_if.wr_cb;

  axi4l_if.axi_areset_n <= 0;
  repeat (4) @axi4l_if.wr_cb;
  axi4l_if.axi_areset_n <= 1;

  ->reset_ev;
  //TODO: check DUT outputs
endtask

task driver::run();
  fork
    reset_dut();
    reset_bus();
  join

  @axi4l_if.wr_cb;

  repeat (conf.trans_num) begin
    gen2drv_mbx.get(trans);
    trans.dump();
    fork
      drive_aw();
      drive_wdata();
      monitor_bready();
    join
  end
endtask

task driver::drive_aw();
  repeat(trans.addr_delay) @(axi4l_if.wr_cb);

  axi4l_if.wr_cb.axi_awaddr       <= trans.addr;
  axi4l_if.wr_cb.axi_awprot       <= 0;
  axi4l_if.wr_cb.axi_awaddr_valid <= 1;

  @axi4l_if.wr_cb;

  fork : wait_for_aw_ready
    while (axi4l_if.wr_cb.axi_awaddr_ready != 1) @axi4l_if.wr_cb;
    timeout(conf.timeout_clocks, "drive aw"); 
  join_any : wait_for_aw_ready

  disable wait_for_aw_ready;

  axi4l_if.wr_cb.axi_awaddr       <= 0;
  axi4l_if.wr_cb.axi_awaddr_valid <= 0;
  axi4l_if.wr_cb.axi_awprot       <= 0;
endtask

task driver::drive_wdata();
  repeat(trans.data_delay) @(axi4l_if.wr_cb);

  axi4l_if.wr_cb.axi_wdata       <= trans.data;
  axi4l_if.wr_cb.axi_wstrb       <= {`AXI_STRB_WIDTH{1'b1}};
  axi4l_if.wr_cb.axi_wdata_valid <= 1;

  @axi4l_if.wr_cb;

  fork : wait_for_wdata_ready
    while (~axi4l_if.wr_cb.axi_wdata_ready) @axi4l_if.wr_cb;
    timeout(conf.timeout_clocks, "drive wdata");
  join_any : wait_for_wdata_ready

  disable wait_for_wdata_ready;

  axi4l_if.wr_cb.axi_wdata       <= 0;
  axi4l_if.wr_cb.axi_wstrb       <= {`AXI_STRB_WIDTH{1'b0}};
  axi4l_if.wr_cb.axi_wdata_valid <= 0;
endtask

task driver::monitor_bready();
  repeat(trans.bready_delay) @(axi4l_if.wr_cb);

  axi4l_if.wr_cb.axi_bready <= 1;

  @axi4l_if.wr_cb;

  fork : wait_for_bvalid
    while (~axi4l_if.wr_cb.axi_bvalid) @axi4l_if.wr_cb;
    timeout(conf.timeout_clocks, "wait for BVALID");
  join_any : wait_for_bvalid

  disable wait_for_bvalid;

  //TODO: AXI_OKEY instead of hardcoded values
  assert(axi4l_if.wr_cb.axi_bresp == 2'b00)
    begin
      $display("[%0t] SUCCESS BRESP", $time());
      drv2chk_mbx.put(trans);
    end
  else
    begin
      $display("[%0t] FAIL BRESP, axi_bvalid = %d",
               $time(), axi4l_if.wr_cb.axi_bvalid);
      $stop();
    end
endtask

`endif // _DRIVER_SV_
