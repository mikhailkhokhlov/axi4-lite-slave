`ifndef _S_AXI4L_RD_CHANNEL_V_
`define _S_AXI4L_RD_CHANNEL_V_

`timescale 1ns / 1ps

`include "dff-async-rst-n.v"

module s_axi4l_rd_channel #(parameter AXI_DATA_WIDTH = 32,
                            parameter AXI_ADDR_WIDTH = 4,
                            parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH / 8))

                           (input wire                           i_axi_clock,
                            input wire                           i_axi_aresetn,
                            // read address channel
                            input  wire [(AXI_ADDR_WIDTH - 1):0] i_axi_araddr,
                            input  wire [                   3:0] i_axi_arcache,
                            input  wire [                   2:0] i_axi_arprot,
                            input  wire                          i_axi_araddr_valid,
                            output wire                          o_axi_araddr_ready,
                            // read data channel
                            output wire [(AXI_DATA_WIDTH - 1):0] o_axi_rdata,
                            output wire [                   1:0] o_axi_rresp,
                            output wire                          o_axi_rdata_valid,
                            input  wire                          i_axi_rdata_ready,
                            // register input signals
                            output wire [(AXI_ADDR_WIDTH - 1):0] o_raddr,
                            output wire                          o_raddr_valid,
                            input  wire [(AXI_DATA_WIDTH - 1):0] i_rdata);

  localparam IDLE       = 2'b00;
  localparam RADDR_RECV = 2'b01;
  localparam RRESP      = 2'b10;

  reg [1:0] reg_state;
  reg [1:0] next_state;

  wire [(AXI_ADDR_WIDTH - 1):0] raddr;
  wire [(AXI_DATA_WIDTH - 1):0] rdata;

  wire raddr_hs;

  always @(posedge i_axi_clock, negedge i_axi_aresetn)
    if (~i_axi_aresetn)
      reg_state <= IDLE;
    else
      reg_state <= next_state;

  always @(*) begin
    next_state = reg_state;
    case (reg_state)
      IDLE:       next_state = ( i_axi_araddr_valid ? RADDR_RECV : IDLE  );
      RADDR_RECV: next_state = RRESP;
      RRESP:      next_state = ( i_axi_rdata_ready  ? IDLE       : RRESP );
    endcase
  end

  assign raddr_hs = (i_axi_araddr_valid & o_axi_araddr_ready);

  dff_async_rst_n #(.WIDTH(AXI_ADDR_WIDTH)) ff_raddr( .i_clock    ( i_axi_clock   ),
                                                      .i_areset_n ( i_axi_aresetn ),
                                                      .en         ( raddr_hs      ),
                                                      .d          ( i_axi_araddr  ),
                                                      .q          ( raddr         ));

  dff_async_rst_n #(.WIDTH(AXI_DATA_WIDTH)) ff_rdata( .i_clock    ( i_axi_clock   ),
                                                      .i_areset_n ( i_axi_aresetn ),
                                                      .en         ( o_raddr_valid ),
                                                      .d          ( i_rdata       ),
                                                      .q          ( rdata         ));

  assign o_axi_araddr_ready = (reg_state == IDLE) ? 1'b1 : 1'b0;

  assign o_raddr_valid = (reg_state == RADDR_RECV) ? 1'b1  : 1'b0;
  assign o_raddr       = (reg_state == RADDR_RECV) ? raddr : {AXI_ADDR_WIDTH{1'b0}};

  assign o_axi_rdata       = (reg_state == RRESP) ? rdata : {AXI_DATA_WIDTH{1'b0}};
  assign o_axi_rdata_valid = (reg_state == RRESP) ? 1'b1  : 1'b0;
  assign o_axi_rresp       = (reg_state == RRESP) ? 2'b00 : 2'b10; // OKEY, SLVERR

endmodule

`endif /* _S_AXI4L_RD_CHANNEL_V_ */
