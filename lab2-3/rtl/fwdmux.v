`include "senior_defines.vh"

module fwdmux  
  #(parameter nat_w=`SENIOR_NATIVE_WIDTH)
 (
 input wire[`FWDMUX_CTRL_WIDTH-1:0] ctrl_i,
 input wire [nat_w-1:0] rf_a_i,
 input wire [nat_w-1:0] rf_b_i,
 input wire [nat_w-1:0] dm1_data_i,
 input wire [nat_w-1:0] alu_p4_result_i,
 input wire [nat_w-1:0] wb_result_i,
 input wire [nat_w-1:0] mac_p5_result_i,
  
 output reg [nat_w-1:0] opa_o,
 output reg [nat_w-1:0] opb_o
);
   
   always@* begin
      case(ctrl_i`FWDMUX_OPA)
	0: opa_o = rf_a_i;
       	1: opa_o = alu_p4_result_i;
	2: opa_o = wb_result_i;
	3: opa_o = dm1_data_i;
	4: opa_o = mac_p5_result_i;
      endcase
   end
   
   always@* begin
      case(ctrl_i`FWDMUX_OPB)
	0: opb_o = rf_b_i;
       	1: opb_o = alu_p4_result_i;
	2: opb_o = wb_result_i;
	3: opb_o = dm1_data_i;
	4: opb_o = mac_p5_result_i;
      endcase
   end
  
endmodule
