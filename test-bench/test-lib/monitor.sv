`ifndef _MONITOR_SV_
`define _MONITOR_SV_

`include "transaction.sv"
`include "test-config.sv"
`include "axi4l-bfm.sv"

class monitor #(type input_if,
                type output_if);

  local axi4l_master_bfm  in_bfm;
  local axi4l_output_bfm  out_bfm;
  local mailbox           mon2chk_mbx;
  local mailbox           gen2mon_mbx;
  local axi4l_transaction slave_tr;
  local axi4l_transaction master_tr;
  local test_config       conf;
  local event             reset_ev;

  function new(test_config conf,
               input_if    in_if,
               output_if   out_if,
               mailbox     mon2chk_mbx,
               mailbox     gen2mon_mbx,
               event       reset_ev);

    this.conf        = conf;
    this.mon2chk_mbx = mon2chk_mbx;
    this.gen2mon_mbx = gen2mon_mbx;
    this.reset_ev    = reset_ev;
    this.out_bfm     = out_if.out_bfm;
    this.in_bfm      = in_if.in_bfm;
    this.master_tr   = new();
    this.slave_tr    = new();
  endfunction

  task run();
    @reset_ev;

    repeat (conf.trans_num) begin
      addr_t addr;
      data_t data_out;
      data_t data_in;

      gen2mon_mbx.get(master_tr);

      out_bfm.align_clock();

      fork : monitor_output
        in_bfm.monitor_data(data_in);
        out_bfm.monitor_output(addr,
                               data_out,
                               conf.timeout_clocks);
      join : monitor_output

      slave_tr.addr = addr;
      slave_tr.data = (data_in === 'x) ? data_out : data_in;

      mon2chk_mbx.put(slave_tr);
    end
  endtask

endclass : monitor

`endif // _MONITOR_SV_
