`ifndef _AXI4L_BFM_SV_
`define _AXI4L_BFM_SV_

`include "transaction.sv"

virtual class base_bfm;
  pure virtual task timeout(input int tm,
                            input string op);
endclass : base_bfm


virtual class axi4l_master_bfm extends base_bfm;

  pure virtual task align_clock(); 
  pure virtual task reset_bus();
  pure virtual task reset_dut();

  pure virtual task drive_transaction(input axi4l_transaction tx_tr,
                                      input int               tm);

  // must return 'x in case of no response data on input channel
  pure virtual task monitor_data(output data_t data);

  pure virtual task wait_for_response(input int          delay,
                                      input int          tm,
                                      output logic [1:0] rsp);
endclass : axi4l_master_bfm


virtual class axi4l_output_bfm extends base_bfm;

  pure virtual task align_clock();

  pure virtual task drive_output(input data_t data,
                                 input int    tm);

  pure virtual task monitor_output(output    addr_t addr,
                                   output    data_t data,
                                   input int tm);

endclass : axi4l_output_bfm

`endif // _AXI4L_BFM_SV_
