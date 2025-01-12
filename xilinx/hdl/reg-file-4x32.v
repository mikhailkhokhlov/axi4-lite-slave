`ifndef _REG_FILE_4x32_V_
`define _REG_FILE_4x32_V_

`timescale 1ns / 1ps

`include "../../dff-async-rst-n.v"

module reg_file_4x32(
    input  wire        i_clock,
    input  wire        i_aresetn,
    input  wire [31:0] i_write_data,
    input  wire [ 3:0] i_write_addr,
    input  wire        i_write_enable,
    input  wire [ 3:0] i_read_addr,
    input  wire        i_read_enable,
    output wire [31:0] o_read_data
);
    reg enable [3:0];
    wire [31:0] reg_data_out [3:0];

    always @(*) begin
        enable[0] = 1'b0;
        enable[1] = 1'b0;
        enable[2] = 1'b0;
        enable[3] = 1'b0;
        case (i_write_addr)
            4'h00: enable[0] = (i_write_enable) ? 1'b1 : 1'b0;
            4'h04: enable[1] = (i_write_enable) ? 1'b1 : 1'b0;
            4'h08: enable[2] = (i_write_enable) ? 1'b1 : 1'b0;
            4'h0c: enable[3] = (i_write_enable) ? 1'b1 : 1'b0;
        endcase
    end

    generate
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin
            (* DONT_TOUCH = "true" *) dff_async_rst_n #(.WIDTH(32)) ff_data( 
                .i_clock    ( i_clock         ),
                .i_areset_n ( i_aresetn       ),
                .en         ( enable[i]       ),
                .d          ( i_write_data    ),
                .q          ( reg_data_out[i] )
            );
        end
    endgenerate

    reg [31:0] read_data;

    always @(*) begin
        read_data = 32'b0;
        if (i_read_enable) begin
            case (i_read_addr)
                4'h00: read_data = ~reg_data_out[0];
                4'h04: read_data = ~reg_data_out[1];
                4'h08: read_data = ~reg_data_out[2];
                4'h0c: read_data = ~reg_data_out[3];
            endcase
        end
    end

    assign o_read_data = read_data;

endmodule

`endif  // _REG_FILE_4x32_V_

