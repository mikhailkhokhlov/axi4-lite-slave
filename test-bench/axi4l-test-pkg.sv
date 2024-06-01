package axi4l_test;

  parameter AXI_DATA_WIDTH = 32;
  parameter AXI_ADDR_WIDTH = 4;
  parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH / 8);

  typedef logic [1:0]                    delay_t;
  typedef logic [(AXI_ADDR_WIDTH - 1):0] addr_t;
  typedef logic [(AXI_DATA_WIDTH - 1):0] data_t;

  `include "test-lib/axi4l-bfm.sv"
  `include "test-lib/test-config.sv"
  `include "test-lib/transaction.sv"
  `include "test-lib/monitor.sv"
  `include "test-lib/scoreboard.sv"
  `include "test-lib/driver.sv"
  `include "test-lib/generator.sv"
  `include "test-lib/environment.sv"

endpackage
