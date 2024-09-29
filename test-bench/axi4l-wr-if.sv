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
    default input #1step output #1step;

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

  class axi4l_rw_bfm extends master_bfm;
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

    task drive_transaction(input transaction tx_tr,
                           input int         tm);
      fork
        drive_awaddr(tx_tr.addr_delay, tx_tr.addr, tm);
        drive_wdata (tx_tr.data_delay, tx_tr.data, tm);
      join
    endtask

    task monitor_data(output data_t data);
      data = 'x;
    endtask

    task wait_for_response(input int          delay,
                           input int          tm,
                           output logic [1:0] rsp);
      repeat(delay) @wr_cb;

      wr_cb.axi_bready <= 1;

      fork : wait_for_bvalid
        do
          @wr_cb;
        while (~wr_cb.axi_bvalid);
        timeout(tm, "wait for BVALID");
      join_any : wait_for_bvalid

      disable wait_for_bvalid;

      rsp = wr_cb.axi_bresp;
      wr_cb.axi_bready <= 0;
//      $display("bresp = %2b", rsp);
    endtask

    local task drive_awaddr(input delay_t delay,
                            input addr_t  addr,
                            input int     tm);
      repeat(delay) @(wr_cb);

      wr_cb.axi_awaddr       <= addr;
      wr_cb.axi_awprot       <= 0;
      wr_cb.axi_awaddr_valid <= 1;

      fork : wait_for_aw_ready
        do
          @wr_cb;
        while (~wr_cb.axi_awaddr_ready);
        timeout(tm, "drive AXI_AWADDR");
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

      fork : wait_for_wdata_ready
        do
          @wr_cb;
        while (~wr_cb.axi_wdata_ready);
        timeout(tm, "drive AXI_WDATA");
      join_any : wait_for_wdata_ready

      disable wait_for_wdata_ready;

      wr_cb.axi_wdata       <= 0;
      wr_cb.axi_wstrb       <= {AXI_STRB_WIDTH{1'b0}};
      wr_cb.axi_wdata_valid <= 0;
    endtask

    task timeout(input int    tm,
                 input string op);
      repeat (tm) @wr_cb;
      $display("[%0t] Timeout(%d) %s", $time(), tm, op);
      $stop();
    endtask

  endclass : axi4l_rw_bfm

  axi4l_rw_bfm in_bfm = new();

  modport TEST(import in_bfm);

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

  clocking out_wr_cb @(posedge axi4l_clock);
    input axi4l_wdata;
    input axi4l_waddr;
    input axi4l_wvalid;
  endclocking

  class axi4l_wr_output_bfm extends output_bfm;

    task monitor_output(output    addr_t addr,
                        output    data_t data,
                        input int tm);
      fork : wait_for_wvalid
        while (~out_wr_cb.axi4l_wvalid) @out_wr_cb;
        timeout(tm, "wait for output wvalid");
      join_any : wait_for_wvalid

      disable wait_for_wvalid;

      addr = out_wr_cb.axi4l_waddr;
      data = out_wr_cb.axi4l_wdata;
    endtask

    task drive_output(input     data_t data,
                      input int tm);
      //do nothing for axi4lite write transaction
    endtask

    task timeout(input int tm,
                 input string op);
      repeat (tm) @out_wr_cb;
      $display("[%0t] Timeout %s", $time(), op);
      $stop();
    endtask

    task align_clock();
      @out_wr_cb;
    endtask

  endclass : axi4l_wr_output_bfm

  axi4l_wr_output_bfm out_bfm = new();

  modport TEST(import out_bfm);

endinterface : wr_reg_file_if

`endif // _AXI4L_WR_IF_SV_
