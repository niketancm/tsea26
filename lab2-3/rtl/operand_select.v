`include "senior_defines.vh"
module operand_select
  #(parameter nat_w=`SENIOR_NATIVE_WIDTH,
    parameter ctrl_w=`OPSEL_CTRL_WIDTH)
    (
     input wire [nat_w-1:0] imm_val_i,
     input wire [nat_w-1:0] rf_a_i,
     input wire [nat_w-1:0] rf_b_i,
     input wire [ctrl_w-1:0] ctrl_i,

     output reg [nat_w-1:0] op_a_o,
     output reg [nat_w-1:0] op_b_o);

`include "std_messages.vh"
   
   always@* begin
      case(ctrl_i`OPSEL_OPA)
	0: op_a_o = rf_a_i;
	1: op_a_o = rf_b_i;
	2: op_a_o = imm_val_i;
	default: begin
	   op_a_o = rf_a_i;
	   if(defined_but_illegal(ctrl_i`OPSEL_OPA,2,"ctrl_i`OPSEL_OPA")) begin
	      $stop;
	   end
	end
      endcase // case(ctrl_i`OPSEL_OPA)
   end
   
   always@* begin
      case(ctrl_i`OPSEL_OPB)
	0: op_b_o = rf_b_i;
	1: op_b_o = rf_a_i;
	2: op_b_o = imm_val_i;
	default: begin
	   op_b_o = rf_b_i;
	   if(defined_but_illegal(ctrl_i`OPSEL_OPB,2,"ctrl_i`OPSEL_OPB")) begin
	      $stop;
	   end
	end
      endcase // case(ctrl_i`OPSEL_OPB)
   end

endmodule // operand_select

     
   