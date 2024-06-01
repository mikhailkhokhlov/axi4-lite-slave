`ifndef _AXI4L_BFM_SV_
`define _AXI4L_BFM_SV_

`include "transaction.sv"

virtual class axi4l_bfm;
  pure virtual task align_clock(); 
  pure virtual task reset_bus();
  pure virtual task reset_dut();
  pure virtual task drive_transaction(inout axi4l_transaction tx_tr,
                                      input int               tm,
                                      output logic [1:0]      rsp);
endclass : axi4l_bfm


virtual class axi4l_monitor_bfm;
  pure virtual task align_clock();
  pure virtual task drive_output(axi4l_transaction tx_tr);
  pure virtual task monitor(output addr_t addr,
                            output data_t data,
                            input int tm);
endclass : axi4l_monitor_bfm

`endif // _AXI4L_BFM_SV_
