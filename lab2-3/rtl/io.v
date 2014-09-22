`include "senior_defines.vh"

module io
  #(parameter nat_w = `SENIOR_NATIVE_WIDTH,
    parameter ctrl_w = `IO_CTRL_WIDTH)
    (
     // Internal interface
     input wire [nat_w-1:0] io_intdata_i,
     input wire [ctrl_w-1:0] ctrl_i,
     output wire [nat_w-1:0] io_intdata_o,
     
     // External interface
     input wire [nat_w-1:0]  io_data_i,
     output wire io_wr_strobe_o,
     output wire io_rd_strobe_o,
     output wire [nat_w-1:0] io_data_o,
     output wire [7:0] io_addr_o);


   assign io_addr_o = ctrl_i`IO_ADDR;
   assign io_data_o = io_intdata_i;
   assign io_wr_strobe_o = ctrl_i`IO_WREN;
   assign io_rd_strobe_o = ctrl_i`IO_RDEN;
   assign io_intdata_o = io_data_i;
   


endmodule // IO
