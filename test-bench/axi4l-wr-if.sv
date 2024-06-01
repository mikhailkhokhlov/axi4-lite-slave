`ifndef _AXI4L_WR_IF_SV_
`define _AXI4L_WR_IF_SV_

interface axi4lite_wr_if #(
  parameter AXI_ADDR_WIDTH = 4,
  parameter AXI_DATA_WIDTH = 32,
  parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH / 8)
) (
  input logic axi4l_clock
);
  import axi4l_test::*;
    // AXI reset
  logic                          axi_areset_n;
  // write address channel
  logic [(AXI_ADDR_WIDTH - 1):0] axi_awaddr;
  logic [2:0]                    axi_awprot;
  logic                          axi_awaddr_valid;
  logic                          axi_awaddr_ready;
  // write data channel
  logic [(AXI_DATA_WIDTH - 1):0] axi_wdata;
  logic [(AXI_STRB_WIDTH - 1):0] axi_wstrb;
  logic                          axi_wdata_valid;
  logic                          axi_wdata_ready;
  // write response channel
  logic [                   1:0] axi_bresp;
  logic                          axi_bready;
  logic                          axi_bvalid;

  clocking wr_cb @(posedge axi4l_clock);
    output axi_awaddr;
    output axi_awprot;
    output axi_awaddr_valid;
    input  axi_awaddr_ready;

    output axi_wdata;
    output axi_wstrb;
    output axi_wdata_valid;
    input  axi_wdata_ready;

    input  axi_bresp;
    output axi_bready;
    input  axi_bvalid;
  endclocking

  class axi4l_rw_bfm extends axi4l_bfm;
    task reset_bus();
      wait(~axi_areset_n);

      wr_cb.axi_awaddr       <= 0;
      wr_cb.axi_awprot       <= 0;
      wr_cb.axi_awaddr_valid <= 0;

      wr_cb.axi_wdata        <= 0;
      wr_cb.axi_wstrb        <= 0;
      wr_cb.axi_wdata_valid  <= 0;

      wr_cb.axi_bready       <= 0;

      wait(axi_areset_n);
    endtask

    task align_clock();
      @wr_cb;
    endtask

    task reset_dut();
      @wr_cb;

      axi_areset_n <= 0;
      repeat (4) @wr_cb;
      axi_areset_n <= 1;
    endtask

    task drive_transaction(inout axi4l_transaction tx_tr,
                           input int               tm,
                           output logic [1:0]      rsp);
      fork
        drive_awaddr     (tx_tr.addr_delay, tx_tr.addr, tm);
        drive_wdata      (tx_tr.data_delay, tx_tr.data, tm);
        wait_for_response(tx_tr.ready_delay, tm, "wait for BVALID", rsp);
      join
      $display("[%0t] axi_bresp = %2b", $time(), wr_cb.axi_bresp);
    endtask

   local task drive_awaddr(input delay_t delay,
                           input addr_t  addr,
                           input int     tm);
     repeat(delay) @(wr_cb);

     wr_cb.axi_awaddr       <= addr;
     wr_cb.axi_awprot       <= 0;
     wr_cb.axi_awaddr_valid <= 1;

     @wr_cb;

     fork : wait_for_aw_ready
       while (wr_cb.axi_awaddr_ready != 1) @wr_cb;
       timeout(tm, "drive aw");
     join_any : wait_for_aw_ready

     disable wait_for_aw_ready;

     wr_cb.axi_awaddr       <= 0;
     wr_cb.axi_awaddr_valid <= 0;
     wr_cb.axi_awprot       <= 0;
   endtask

   local task drive_wdata(input delay_t delay,
                          input data_t  data,
                          input int     tm);
     repeat(delay) @(wr_cb);

     wr_cb.axi_wdata       <= data;
     wr_cb.axi_wstrb       <= {AXI_STRB_WIDTH{1'b1}};
     wr_cb.axi_wdata_valid <= 1;

     @wr_cb;

     fork : wait_for_wdata_ready
       while (~wr_cb.axi_wdata_ready) @wr_cb;
       timeout(tm, "drive wdata");
     join_any : wait_for_wdata_ready

     disable wait_for_wdata_ready;

     wr_cb.axi_wdata       <= 0;
     wr_cb.axi_wstrb       <= {AXI_STRB_WIDTH{1'b0}};
     wr_cb.axi_wdata_valid <= 0;
   endtask

   local task wait_for_response(input int          delay,
                                input int          tm,
                                input string       op,
                                output logic [1:0] rsp) ;
     repeat(delay) @wr_cb;

     wr_cb.axi_bready <= 1;

     @wr_cb;

     fork : wait_for_bvalid
       while (~wr_cb.axi_bvalid) @wr_cb;
       timeout(tm, op);
     join_any : wait_for_bvalid

     disable wait_for_bvalid;

     wr_cb.axi_bready <= 0;

     rsp = wr_cb.axi_bresp;

   endtask

   local task timeout(input int tm,
                      input string op);
     repeat (tm) @wr_cb;
     $display("[%0t] Timeout %s", $time(), op);
     $stop();
   endtask

  endclass : axi4l_rw_bfm

  axi4l_rw_bfm bfm = new();

  modport TEST(import bfm);

endinterface : axi4lite_wr_if


interface wr_reg_file_if #(
  parameter AXI_ADDR_WIDTH = 4,
  parameter AXI_DATA_WIDTH = 32
) (
  input logic axi4l_clock
);
  import axi4l_test::*;

  logic [(AXI_DATA_WIDTH - 1):0] axi4l_wdata;
  logic [(AXI_ADDR_WIDTH - 1):0] axi4l_waddr;
  logic                          axi4l_wvalid;

  clocking wr_cb @(posedge axi4l_clock);
    input axi4l_wdata;
    input axi4l_waddr;
    input axi4l_wvalid;
  endclocking

  class axi4l_wr_monitor_bfm extends axi4l_monitor_bfm;
    task drive_output(axi4l_transaction tx_tr);
      //do nothing, will be disabled in fork-join_any
      forever @wr_cb;
    endtask

    task monitor(output addr_t addr,
                 output data_t data,
                 input int tm);
      fork : wait_for_valid
        while (~wr_cb.axi4l_wvalid) @wr_cb;
        timeout(tm, "monitor data valid");
      join_any : wait_for_valid

      disable wait_for_valid;

      addr = wr_cb.axi4l_waddr;
      data = wr_cb.axi4l_wdata;
    endtask

    local task timeout(input int tm,
                       input string op);
      repeat (tm) @wr_cb;
      $display("[%0t] Timeout %s", $time(), op);
      $stop();
    endtask

    task align_clock();
      @wr_cb;
    endtask

  endclass

  axi4l_wr_monitor_bfm mon_bfm = new();

  modport TEST(import mon_bfm);

endinterface : wr_reg_file_if

`endif // _AXI4L_WR_IF_SV_
