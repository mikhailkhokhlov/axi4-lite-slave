`timescale 1ns / 1ps

`include "skid-buffer.v"
`include "dff-async-rst-n.v"

module s_axi4l_wr_channel #(parameter AXI_DATA_WIDTH = 32,
                            parameter AXI_ADDR_WIDTH = 4,
                            parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH / 8))

                           (input                           i_axi_clock,
                            input                           i_axi_aresetn,
                            // write address channel
                            input [(AXI_ADDR_WIDTH - 1):0]  i_axi_awaddr,
                            input [2:0]                     i_axi_awprot,
                            input                           i_axi_awaddr_valid,
                            output                          o_axi_awaddr_ready,
                            // write data channel
                            input [(AXI_DATA_WIDTH - 1):0]  i_axi_wdata,
                            input [(AXI_STRB_WIDTH - 1):0]  i_axi_wstrb,
                            input                           i_axi_wdata_valid,
                            output                          o_axi_wdata_ready,
                            // write response channel	
                            output [1:0]                    o_axi_bresp,
                            output                          o_axi_bvalid,
                            input                           i_axi_bready,
                            // register output channel
                            output [(AXI_ADDR_WIDTH - 1):0] o_waddr,
                            output [(AXI_DATA_WIDTH - 1):0] o_wdata,
                            output                          o_wvalid);

  localparam IDLE                 = 2'b00;
  localparam WAIT_FOR_WADDR_VALID = 2'b01;
  localparam WAIT_FOR_WDATA_VALID = 2'b10;
  localparam BRESP                = 2'b11;

  reg [1:0]                     reg_state;
  reg [1:0]                     next_state;

  wire                          awaddr_valid;
  wire                          awaddr_ready;
  wire                          awaddr_hs;
  wire [(AXI_ADDR_WIDTH - 1):0] next_awaddr;
  wire [(AXI_ADDR_WIDTH - 1):0] axi_awaddr;

  assign awaddr_ready = ((reg_state == IDLE) | (reg_state == WAIT_FOR_WADDR_VALID)) ? 1'b1 : 1'b0;

  skid_buffer #(.DWIDTH(AXI_ADDR_WIDTH)) awddr_buff( .i_clock      ( i_axi_clock        ),
                                                     .i_areset_n   ( i_axi_aresetn      ),
                                                     .i_data       ( i_axi_awaddr       ),
                                                     .i_data_valid ( i_axi_awaddr_valid ),
                                                     .o_data_ready ( o_axi_awaddr_ready ),
                                                     .o_data       ( next_awaddr        ),
                                                     .o_data_valid ( awaddr_valid       ),
                                                     .i_data_ready ( awaddr_ready       ));

  assign awaddr_hs = (awaddr_valid & awaddr_ready);

  dff_async_rst_n #(.WIDTH(AXI_ADDR_WIDTH)) ff_awaddr( .i_clock    ( i_axi_clock   ),
                                                       .i_areset_n ( i_axi_aresetn ),
                                                       .en         ( awaddr_hs     ),
                                                       .d          ( next_awaddr   ),
                                                       .q          ( axi_awaddr    ));

  wire                          wdata_valid;
  wire                          wdata_ready;
  wire                          wdata_hs;
  wire [(AXI_DATA_WIDTH - 1):0] next_wdata;
  wire [(AXI_DATA_WIDTH - 1):0] axi_wdata;

  assign wdata_ready = ((reg_state == IDLE) | (reg_state == WAIT_FOR_WDATA_VALID)) ? 1'b1 : 1'b0;

  skid_buffer #(.DWIDTH(AXI_DATA_WIDTH)) wdata_buff( .i_clock      ( i_axi_clock       ),
                                                     .i_areset_n   ( i_axi_aresetn     ),
                                                     .i_data       ( i_axi_wdata       ),
                                                     .i_data_valid ( i_axi_wdata_valid ),
                                                     .o_data_ready ( o_axi_wdata_ready ),
                                                     .o_data       ( next_wdata        ),
                                                     .o_data_valid ( wdata_valid       ),
                                                     .i_data_ready ( wdata_ready       ));

  assign wdata_hs = (wdata_valid & wdata_ready);

  dff_async_rst_n #(.WIDTH(AXI_DATA_WIDTH)) ff_wdata( .i_clock    ( i_axi_clock   ),
                                                      .i_areset_n ( i_axi_aresetn ),
                                                      .en         ( wdata_hs      ),
                                                      .d          ( next_wdata    ),
                                                      .q          ( axi_wdata     ));

  wire                          wstrb_valid;
  wire                          wstrb_ready;
  wire                          wstrb_hs;
  wire [(AXI_STRB_WIDTH - 1):0] next_wstrb;
  wire [(AXI_STRB_WIDTH - 1):0] axi_wstrb;

  assign wstrb_ready = wdata_ready;

  skid_buffer #(.DWIDTH(AXI_STRB_WIDTH)) wstrb_buff( .i_clock      ( i_axi_clock       ),
                                                     .i_areset_n   ( i_axi_aresetn     ),
                                                     .i_data       ( i_axi_wstrb       ),
                                                     .i_data_valid ( i_axi_wdata_valid ),
                                                     .o_data_ready (                   ),
                                                     .o_data       ( next_wstrb        ),
                                                     .o_data_valid ( wstrb_valid       ),
                                                     .i_data_ready ( wstrb_ready       ));

  assign wstrb_hs = (wstrb_valid & wstrb_ready);

  dff_async_rst_n #(.WIDTH(AXI_STRB_WIDTH)) ff_wstrb( .i_clock    ( i_axi_clock   ),
                                                      .i_areset_n ( i_axi_aresetn ),
                                                      .en         ( wstrb_hs      ),
                                                      .d          ( next_wstrb    ),
                                                      .q          ( axi_wstrb     ));

  wire [1:0] bresp; 
  wire       bresp_valid;
  wire       bresp_ready;

  assign bresp_valid = (reg_state == BRESP) ? 1'b1  : 1'b0;
  assign bresp =       (reg_state == BRESP) ? 2'b00 : 2'b10; //TODO: OKEY, SLVERR

  skid_buffer #(.DWIDTH(2)) bresp_buff(.i_clock      ( i_axi_clock   ),
                                       .i_areset_n   ( i_axi_aresetn ),
                                       .i_data       ( bresp         ),
                                       .i_data_valid ( bresp_valid   ),
                                       .o_data_ready ( bresp_ready   ),
                                       .o_data       ( o_axi_bresp   ),
                                       .o_data_valid ( o_axi_bvalid  ),
                                       .i_data_ready ( i_axi_bready  ));

  always @(posedge i_axi_clock, negedge i_axi_aresetn)
    if (~i_axi_aresetn)
      reg_state <= IDLE;
    else
      reg_state <= next_state;

  always @(*)
    case (reg_state)
      IDLE:
        begin
          if (i_axi_awaddr_valid & i_axi_wdata_valid)
            next_state = BRESP;
          else if (i_axi_awaddr_valid & ~i_axi_wdata_valid)
            next_state = WAIT_FOR_WDATA_VALID;
          else if (~i_axi_awaddr_valid & i_axi_wdata_valid)
            next_state = WAIT_FOR_WADDR_VALID;
          else
            next_state = reg_state;
        end
      WAIT_FOR_WADDR_VALID:
        next_state = (i_axi_awaddr_valid ? BRESP : WAIT_FOR_WADDR_VALID);
      WAIT_FOR_WDATA_VALID:
        next_state = (i_axi_wdata_valid  ? BRESP : WAIT_FOR_WDATA_VALID);
      BRESP:
        next_state = (bresp_ready ? IDLE : BRESP);
    endcase

  function [AXI_DATA_WIDTH - 1:0] strb_data(input [AXI_DATA_WIDTH - 1:0] wdata,
                                            input [AXI_STRB_WIDTH - 1:0] wstrb);
    integer i;
    strb_data = {AXI_DATA_WIDTH{1'b0}};

    for (i = 0; i < AXI_STRB_WIDTH; i = i + 1)
      if (wstrb[i] == 1)
        strb_data[(i * 8) +: 8] = wdata[(i * 8) +: 8];
  endfunction

  assign o_wdata  = (reg_state == BRESP) ? strb_data(axi_wdata, axi_wstrb) : {AXI_DATA_WIDTH{1'b0}};
  assign o_waddr  = (reg_state == BRESP) ? axi_awaddr                      : {AXI_ADDR_WIDTH{1'b0}};
  assign o_wvalid = (reg_state == BRESP) ? 1'b1                            : 1'b0;

endmodule
