`ifndef _ENVIRONMENT_SV_
`define _ENVIRONMENT_SV_

`include "test-config.sv"
`include "transaction.sv"
`include "driver.sv"
`include "generator.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment #(type input_if,
                    type output_if);

  local mailbox gen2drv_mbx;
  local mailbox drv2chk_mbx;
  local mailbox mon2chk_mbx;
  local mailbox gen2mon_mbx;
  local event   reset_ev;

  local driver      #(input_if ) drv;
  local monitor     #(output_if) mon;
  local generator                gen;
  local scoreboard               scrbrd;
  local test_config              conf;

  input_if  axi4l_if;
  output_if output_reg_if;

  function new(input_if  axi4l_if,
               output_if output_reg_if);
    this.axi4l_if      = axi4l_if;
    this.output_reg_if = output_reg_if;
  endfunction

  function void build();
    conf = new(.trans_num      ( 10),
               .timeout_clocks (100));

    gen2drv_mbx = new();
    drv2chk_mbx = new();
    gen2mon_mbx = new();
    mon2chk_mbx = new();

    gen         = new(conf, gen2drv_mbx,   gen2mon_mbx);
    drv         = new(conf, axi4l_if,      gen2drv_mbx, drv2chk_mbx, reset_ev);
    mon         = new(conf, output_reg_if, mon2chk_mbx, gen2mon_mbx, reset_ev);
    scrbrd      = new(conf, mon2chk_mbx,   drv2chk_mbx);
  endfunction

  task start();
    fork
      gen.run();
      mon.run();
      drv.run();
      scrbrd.run();
    join
  endtask

  function void report();
    //TODO: TBD
  endfunction

endclass : environment

`endif // _ENVIRONMENT_SV_
