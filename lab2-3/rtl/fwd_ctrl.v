`include "senior_defines.vh"

module fwd_ctrl(
 input wire[`FWD_CTRL_WIDTH-1:0] ctrl_i,		
 input wire condition_p4_i,
 input wire condition_p5_i,
 input wire condition_wb_i,
 input wire [`RF_CTRL_WIDTH-1:0] rf_ctrl_i,

 output reg [`FWDMUX_CTRL_WIDTH-1:0] fwdmux_ctrl_o
);
   wire p5_mux_mac;

   //p5 in mac wants to write to rf?
   assign p5_mux_mac = (ctrl_i`FWD_WB_MUX_SEL_P5 == 4'b0001) ? 1'b1 : 1'b0;
   
   //operand A
   always@* begin
      fwdmux_ctrl_o`FWDMUX_OPA = 0;
      casex({rf_ctrl_i`RF_OPA, 1'b1, p5_mux_mac})
	{1'b0, ctrl_i`FWD_RF_WRITE_CTRL_P4, 1'bx}: begin
	   if((ctrl_i`FWD_WB_MUX_SEL_P4 == 4'b0010) && condition_p4_i)
	     fwdmux_ctrl_o`FWDMUX_OPA = 1;
	end
	{1'b0, ctrl_i`FWD_RF_WRITE_CTRL_P5, 1'b1}: begin
	   if(condition_p5_i)
	     fwdmux_ctrl_o`FWDMUX_OPA = 4;
	end
	{1'b0, rf_ctrl_i`RF_WRITE_REG_SEL, rf_ctrl_i`RF_WRITE_REG_EN, 1'bx}: begin
	   if(condition_wb_i)
	     fwdmux_ctrl_o`FWDMUX_OPA = 2;
	end
	{1'b0, rf_ctrl_i`RF_WRITE_REG_SEL_DM, rf_ctrl_i`RF_WRITE_REG_EN_DM, 1'bx}:
	  fwdmux_ctrl_o`FWDMUX_OPA = 3;
      endcase
   end

   //operand B
   always@* begin
      fwdmux_ctrl_o`FWDMUX_OPB = 0;
      casex({rf_ctrl_i`RF_OPB, 1'b1, p5_mux_mac})
	{1'b0, ctrl_i`FWD_RF_WRITE_CTRL_P4, 1'bx}: begin
	   if((ctrl_i`FWD_WB_MUX_SEL_P4 == 4'b0010) && condition_p4_i)
	     fwdmux_ctrl_o`FWDMUX_OPB = 1;
	end
	{1'b0, ctrl_i`FWD_RF_WRITE_CTRL_P5, 1'b1}: begin
	   if(condition_p5_i)
	     fwdmux_ctrl_o`FWDMUX_OPB = 4;
	end
	{1'b0, rf_ctrl_i`RF_WRITE_REG_SEL, rf_ctrl_i`RF_WRITE_REG_EN, 1'bx}: begin
	   if(condition_wb_i)
	     fwdmux_ctrl_o`FWDMUX_OPB = 2;
	end
	{1'b0, rf_ctrl_i`RF_WRITE_REG_SEL_DM, rf_ctrl_i`RF_WRITE_REG_EN_DM, 1'bx}:
	  fwdmux_ctrl_o`FWDMUX_OPB = 3;
      endcase
   end
endmodule
