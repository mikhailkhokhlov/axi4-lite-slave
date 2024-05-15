`ifndef _ENVIRONMENT_SV_
`define _ENVIRONMENT_SV_

`timescale 1ns / 1ps

`include "driver.sv"
`include "generator.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "test-config.sv"

class environment;

  local mailbox    gen2drv_mbx;
  local mailbox    drv2chk_mbx;
  local mailbox    mon2chk_mbx;
  local event      reset_ev;

  local driver      drv;
  local generator   gen;
  local monitor     mon;
  local scoreboard  scrbrd;
  local test_config conf;

  virtual axi4lite_if.TEST    axi4l_if;
  virtual wr_reg_file_if.TEST wr_reg_if;

  extern function new(virtual axi4lite_if.TEST    axi4l_if,
                      virtual wr_reg_file_if.TEST wr_reg_if);

  extern function void build();
  extern task start();
  extern function void report(); 

endclass : environment


function environment::new(virtual axi4lite_if.TEST    axi4l_if,
                          virtual wr_reg_file_if.TEST wr_reg_if);
  this.axi4l_if  = axi4l_if;
  this.wr_reg_if = wr_reg_if;
endfunction

function void environment::build();
  conf = new(.trans_num      ( 10),
             .timeout_clocks (100));

  gen2drv_mbx = new();
  drv2chk_mbx = new();
  gen         = new(conf, gen2drv_mbx);
  drv         = new(conf, axi4l_if, gen2drv_mbx, drv2chk_mbx, reset_ev);

  mon2chk_mbx = new();
  mon         = new(conf, wr_reg_if, mon2chk_mbx, reset_ev);

  scrbrd      = new(conf, mon2chk_mbx, drv2chk_mbx);
endfunction

task environment::start();
  fork
    gen.run();
    mon.run();
    drv.run();
    scrbrd.run();
  join
endtask

function void environment::report();

endfunction

`endif // _ENVIRONMENT_SV_
