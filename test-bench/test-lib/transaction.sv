`ifndef _TRANSACTION_SV_
`define _TRANSACTION_SV_

parameter AXI_DATA_WIDTH = 32;
parameter AXI_ADDR_WIDTH = 4;
parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH / 8);

typedef logic [1:0]                    delay_t;
typedef logic [(AXI_ADDR_WIDTH - 1):0] addr_t;
typedef logic [(AXI_DATA_WIDTH - 1):0] data_t;

class axi4l_transaction;

  rand addr_t addr;
  rand data_t data;

  constraint addr_constraint {
    addr inside {5'h0, 5'h4, 5'h8, 5'hc};
  }

  rand delay_t addr_delay;
  rand delay_t data_delay;
  rand delay_t ready_delay;

  constraint addr_c  { addr_delay  >= 0 && addr_delay  <= 3; }
  constraint data_c  { data_delay  >= 0 && data_delay  <= 3; }
  constraint ready_c { ready_delay >= 0 && ready_delay <= 3; }

  function void dump();
    $display("[%0t] --- transaction ---", $time());
    $display("address              : 0x%08x, delay %d", addr, addr_delay);
    $display("data                 : 0x%08x, delay %d", data, data_delay);
    $display("response ready delay : %d", ready_delay);
  endfunction

endclass : axi4l_transaction

`endif // _TRANSACTION_SV_
