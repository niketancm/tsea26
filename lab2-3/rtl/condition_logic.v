`include "senior_defines.vh"
`include "registers.h"

module condition_logic
  #(parameter alu_flags_w = `ALU_NUM_FLAGS,
    parameter mac_flags_w = `MAC_NUM_FLAGS,
    parameter ctrl_w = `COND_LOGIC_CTRL_WIDTH)
  (
   input wire [ctrl_w-1:0] ctrl_i,
   input wire [alu_flags_w-1:0] alu_flags_i,
   input wire [mac_flags_w-1:0] mac_flags_i,

   output reg condition_check_o
   );
`include "std_messages.vh"
   
   always @(*) begin
      case (ctrl_i`COND_LOGIC_CDT)
	`UT: condition_check_o=1'b1;
	`EQ: condition_check_o=alu_flags_i[`ALU_FLAG_AZ];
	`NE: condition_check_o=~alu_flags_i[`ALU_FLAG_AZ];
        `UGT: condition_check_o=(~alu_flags_i[`ALU_FLAG_AZ]) & (alu_flags_i[`ALU_FLAG_AC]);
	`UGE_CS: condition_check_o=alu_flags_i[`ALU_FLAG_AC];
        `ULE: condition_check_o=alu_flags_i[`ALU_FLAG_AZ] | ~alu_flags_i[`ALU_FLAG_AC];
	`ULT_CC: condition_check_o=~alu_flags_i[`ALU_FLAG_AC];
	`SGT: condition_check_o=(~alu_flags_i[`ALU_FLAG_AZ]) & ~(alu_flags_i[`ALU_FLAG_AN]^alu_flags_i[`ALU_FLAG_AV]);
	`SGE: condition_check_o = ~(alu_flags_i[`ALU_FLAG_AN]^alu_flags_i[`ALU_FLAG_AV]);
	`SLE: condition_check_o = alu_flags_i[`ALU_FLAG_AZ] | ~(alu_flags_i[`ALU_FLAG_AN]^(~alu_flags_i[`ALU_FLAG_AV]));
	`SLT: condition_check_o= ~(alu_flags_i[`ALU_FLAG_AN]^(~alu_flags_i[`ALU_FLAG_AV]));
	`MI: condition_check_o=alu_flags_i[`ALU_FLAG_AN];
	`PL: condition_check_o=~alu_flags_i[`ALU_FLAG_AN];
	`VS: condition_check_o=alu_flags_i[`ALU_FLAG_AV];
	`VC: condition_check_o=~alu_flags_i[`ALU_FLAG_AV];
	`MEQ: condition_check_o=mac_flags_i[`MAC_FLAG_MZ];
	`MNE: condition_check_o=~mac_flags_i[`MAC_FLAG_MZ];
	`MGT: condition_check_o=(~mac_flags_i[`MAC_FLAG_MZ]) & (~mac_flags_i[`MAC_FLAG_MN]);
	`MGE_MPL: condition_check_o=~mac_flags_i[`MAC_FLAG_MN];
	`MLE: condition_check_o=(~mac_flags_i[`MAC_FLAG_MZ]) | mac_flags_i[`MAC_FLAG_MN];
	`MLT_MMI: condition_check_o=mac_flags_i[`MAC_FLAG_MN];
	`MVS: condition_check_o=mac_flags_i[`MAC_FLAG_MS];
	`MVC: condition_check_o=~mac_flags_i[`MAC_FLAG_MS];
	default: begin
	   condition_check_o=1'b1;  // others reserved
	   if(defined_but_illegal(ctrl_i`COND_LOGIC_CDT,5,"ctrl_i`COND_LOGIC_CDT")) begin
	      $stop;
	   end
	end
      endcase
   end
endmodule