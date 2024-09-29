`ifndef _AXI4L_RD_IF_SV_
`define _AXI4L_RD_IF_SV_

interface axi4lite_rd_if #(
  parameter AXI_ADDR_WIDTH = 4,
  parameter AXI_DATA_WIDTH = 32,
  parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH / 8)
) (
  input logic axi4l_clock
);
  import axi4l_test::*;
    // AXI reset
  logic                          axi_areset_n;
  // read address channel
  logic [(AXI_ADDR_WIDTH - 1):0] axi_araddr;
  logic [                   3:0] axi_arcache;
  logic [                   2:0] axi_arprot;
  logic                          axi_araddr_valid;
  logic                          axi_araddr_ready;
  // read data channel
  logic [(AXI_DATA_WIDTH - 1):0] axi_rdata;
  logic [                   1:0] axi_rresp;
  logic                          axi_rdata_valid;
  logic                          axi_rdata_ready;

  clocking rd_cb @(posedge axi4l_clock);
    default input #1step output #1step;

    output axi_araddr;
    output axi_arcache;
    output axi_arprot;
    output axi_araddr_valid;
    input  axi_araddr_ready;

    input  axi_rdata;
    input  axi_rresp;
    input  axi_rdata_valid;
    output axi_rdata_ready;
  endclocking

  clocking rd_cb_mon @(posedge axi4l_clock);
    input axi_araddr_valid;
    input axi_araddr_ready;

    input axi_rdata;
    input axi_rresp;
    input axi_rdata_valid;
    input axi_rdata_ready;
  endclocking

  class axi4l_rd_bfm extends master_bfm;
    task reset_bus();
      wait(~axi_areset_n);

      rd_cb.axi_araddr       <= 0;
      rd_cb.axi_arprot       <= 0;
      rd_cb.axi_arcache      <= 0;
      rd_cb.axi_araddr_valid <= 0;

      rd_cb.axi_rdata_ready  <= 0;

      wait(axi_areset_n);
    endtask

    task reset_dut();
      @rd_cb;

      axi_areset_n <= 0;
      repeat (4) @rd_cb;
      axi_areset_n <= 1;
    endtask

    task align_clock();
      @(rd_cb);
    endtask

    task drive_transaction(input transaction tx_tr,
                           input int         tm);
      drive_araddr(tx_tr.addr_delay, tx_tr.addr, tm);
    endtask

    local task drive_araddr(input delay_t delay,
                            input addr_t  addr,
                            input int     tm);
      repeat(delay) @(rd_cb);

      rd_cb.axi_araddr       <= addr;
      rd_cb.axi_arcache      <= 0;
      rd_cb.axi_arprot       <= 0;
      rd_cb.axi_araddr_valid <= 1;

      fork : wait_for_rd_ready
        do
           @rd_cb_mon;
        while (~rd_cb_mon.axi_araddr_ready);
        timeout(tm, "wait for AXI_ARADDR_READY");
      join_any : wait_for_rd_ready

      disable wait_for_rd_ready;

      rd_cb.axi_araddr       <= 0;
      rd_cb.axi_arcache      <= 0;
      rd_cb.axi_araddr_valid <= 0;
      rd_cb.axi_arprot       <= 0;
    endtask

    task wait_for_response(input int          delay,
                           input int          tm,
                           output logic [1:0] rsp);
      repeat(delay) @rd_cb;

      rd_cb.axi_rdata_ready <= 1;

      fork : wait_for_rdata_valid
        do
          @rd_cb_mon;
        while (~rd_cb_mon.axi_rdata_valid);
        timeout(tm, "wait for AXI_RDATA_VALID");
      join_any : wait_for_rdata_valid

      disable wait_for_rdata_valid;

      rd_cb.axi_rdata_ready <= 0;
      rsp = rd_cb_mon.axi_rresp;
    endtask

    task monitor_data(output data_t data);
      do
         @rd_cb_mon;
      while (~(rd_cb_mon.axi_rdata_valid & rd_cb_mon.axi_rdata_ready));
      data = rd_cb_mon.axi_rdata;
    endtask

    task timeout(input int    tm,
                 input string op);
      repeat (tm) @rd_cb;
      $display("[%0t] Timeout(%d) %s", $time(), tm, op);
      $stop();
    endtask


  endclass : axi4l_rd_bfm

  axi4l_rd_bfm in_bfm = new();

  modport TEST(import in_bfm);

endinterface : axi4lite_rd_if


interface rd_reg_file_if #(
  parameter AXI_ADDR_WIDTH = 4,
  parameter AXI_DATA_WIDTH = 32
) (
  input logic axi4l_clock
);
  import axi4l_test::*;

  logic [(AXI_DATA_WIDTH - 1):0] axi4l_rdata;
  logic [(AXI_ADDR_WIDTH - 1):0] axi4l_raddr;
  logic                          axi4l_raddr_valid;

  clocking out_rd_cb @(posedge axi4l_clock);
    input  axi4l_raddr;
    input  axi4l_raddr_valid;
    output axi4l_rdata;
  endclocking

  class axi4l_rd_monitor_bfm extends output_bfm;

    task drive_output(input data_t data,
                      input int    tm);
      do
        @out_rd_cb;
      while (~axi4l_raddr_valid);

      out_rd_cb.axi4l_rdata <= data;
      @out_rd_cb;
      out_rd_cb.axi4l_rdata <= {AXI_DATA_WIDTH{1'b0}};
    endtask

    task monitor_output(output addr_t addr,
                        output data_t data,
                        input int     tm);

      fork : wait_for_raddr_valid
        do
          @out_rd_cb;
        while (~out_rd_cb.axi4l_raddr_valid);
        timeout(tm, "monitor raddr valid");
      join_any : wait_for_raddr_valid

      disable wait_for_raddr_valid;

      addr = out_rd_cb.axi4l_raddr;
      data = 'x;
    endtask

    task timeout(input int    tm,
                 input string op);
      repeat (tm) @(posedge axi4l_clock);
      $display("[%0t] Timeout(%d) %s", $time(), tm, op);
      $stop();
    endtask

    task align_clock();
      @(posedge axi4l_clock);
    endtask

  endclass : axi4l_rd_monitor_bfm

  axi4l_rd_monitor_bfm out_bfm = new();

  modport TEST(import out_bfm);

endinterface : rd_reg_file_if

`endif // _AXI4L_RD_IF_SV_
