`ifndef _TRANSACTION_SV_
`define _TRANSACTION_SV_

`include "parameters.svh"

class write_transaction;

  rand logic [(`AXI_ADDR_WIDTH - 1):0] addr;
  rand logic [(`AXI_DATA_WIDTH - 1):0] data;

  constraint addr_c {
    addr inside {5'h0, 5'h4, 2'h8, 5'hc};
  }

  rand logic [1:0] addr_delay;
  rand logic [1:0] data_delay;
  rand logic [1:0] bready_delay;

  extern function void dump();
  
endclass : write_transaction


function void write_transaction::dump();
  $display("[%0t] --- WR transaction ---", $time());
  $display("address      : 0x%08x, delay %d", addr, addr_delay);
  $display("data to write: 0x%08x, delay %d", data, data_delay);
  $display("bready       :             delay %d", bready_delay);
endfunction

`endif // _TRANSACTION_SV_
