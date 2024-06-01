`ifndef _TRANSACTION_SV_
`define _TRANSACTION_SV_

//`include "parameters.svh"

class axi4l_transaction;

  rand addr_t addr;
  rand data_t data;

  constraint addr_c {
    addr inside {5'h0, 5'h4, 2'h8, 5'hc};
  }

  rand delay_t addr_delay;
  rand delay_t data_delay;
  rand delay_t ready_delay;

  extern function void dump();
  
endclass : axi4l_transaction


function void axi4l_transaction::dump();
  $display("[%0t] --- transaction ---", $time());
  $display("address              : 0x%08x, delay %d", addr, addr_delay);
  $display("data                 : 0x%08x, delay %d", data, data_delay);
  $display("response ready delay : %d", ready_delay);
endfunction

`endif // _TRANSACTION_SV_
