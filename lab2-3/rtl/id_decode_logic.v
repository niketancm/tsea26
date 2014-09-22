`default_nettype none
`include "mnemonics.h"
`include "registers.h"
`include "senior_defines.vh"
   
  module id_decode_logic
    #(parameter nat_w = `SENIOR_NATIVE_WIDTH)
    (
     input wire [31:0] pm_inst_bus_i, 
       
     output reg [`AGU_CTRL_WIDTH-1:0] agu_ctrl_o,
     output reg [`ALU_CTRL_WIDTH-1:0] alu_ctrl_o,
     output reg [`MAC_CTRL_WIDTH-1:0] mac_ctrl_o,
     output reg [`COND_LOGIC_CTRL_WIDTH-1:0] cond_logic_ctrl_o,
     output reg [`LC_CTRL_WIDTH-1:0] loop_counter_ctrl_o,
     output reg [`WB_MUX_CTRL_WIDTH-1:0] wb_mux_ctrl_o,
     output reg [`PFC_CTRL_WIDTH-1:0] pc_fsm_ctrl_o,
     output reg [`RF_CTRL_WIDTH-1:0] rf_ctrl_o,
     output reg [`IO_CTRL_WIDTH-1:0] io_ctrl_o,
     output reg [`OPSEL_CTRL_WIDTH-1:0] opsel_ctrl_o,
     output reg [`SENIOR_NATIVE_WIDTH-1:0] imm_val_o,
     output reg [`ID_PIPE_TYPE_WIDTH-1:0] pipeline_type_o,
     output reg [`SPR_CTRL_WIDTH-1:0] spr_ctrl_o,
     output reg [`DM_DATA_SELECT_CTRL_WIDTH-1:0] dm_data_select_ctrl_o);
   
  
   //signals to P4
`include "std_messages.vh"
   //Set pipeline type
   always@* begin
      casez(pm_inst_bus_i[31:22])
	`CONV_DEPTH_INSTRUCTIONS:   pipeline_type_o = `ID_CONV_PIPE;
	`E1_DEPTH_INSTRUCTIONS:     pipeline_type_o = `ID_E1_PIPE;
	`MACLD, `MULLD, `MULDBLLD:  pipeline_type_o = `ID_EARLY_WRITE_E2_PIPE;
	`E2_DEPTH_INSTRUCTIONS:     pipeline_type_o = `ID_E2_PIPE;
	default: begin
	   pipeline_type_o = `ID_E1_PIPE;
	   if(defined_but_illegal(pm_inst_bus_i[31:22],10,"pm_inst_bus_i[31:22]")) begin
	      $stop;
	   end
	end
      endcase
   end

   reg [1:0] gacr01;
   reg [1:0] gacr23;
   reg [3:0] hacr;
   reg [3:0] lacr;

   always@* begin
      gacr01 = 0;
      gacr23 = 0;
      hacr = 0;
      lacr = 0;      
      case (pm_inst_bus_i[18:17])
	2'b00:
	  begin
	     gacr01  = 2'b01;
	     hacr[0] = 1'b1;
	     lacr[0] = 1'b1;
	  end
	2'b01:
	  begin
	     gacr01  = 2'b10;
	     hacr[1] = 1'b1;
	     lacr[1] = 1'b1;
	  end
	2'b10:
	  begin
	     gacr23  = 2'b01;
	     hacr[2] = 1'b1;
	     lacr[2] = 1'b1;
	  end
	2'b11:
	  begin
	     gacr23  = 2'b10;
	     hacr[3] = 1'b1;
	     lacr[3] = 1'b1;
	  end // case: 2'b11
      endcase // case (pm_inst_bus_i[18:17])
   end


   wire [1:0] agu_other_val0;
   wire       agu_pre_op0;
   wire       agu_modulo0;
   wire       agu_br0;
   wire       agu_ar_out0;
   wire       agu_imm0;
   wire       agu_ar_wren0;   

   reg [2:0] amd0_mode;
   reg [2:0] amd1_mode;
   
   always@* begin
      casez(pm_inst_bus_i[31:22])
	`CONV: amd0_mode = pm_inst_bus_i[16:14];
	`MULLD, `MACLD: amd0_mode = pm_inst_bus_i[21:19];
	`MULDBLLD: begin
	   if(pm_inst_bus_i[26])
	     amd0_mode = 3'b111;
	   else
	     amd0_mode = 3'b010;
	end
	default: amd0_mode = pm_inst_bus_i[29:27];
      endcase // casez(pm_inst_bus_i[31:22])
   end // always@ *

   always@* begin
      casez(pm_inst_bus_i[31:22])
	`MULDBLLD: begin
	   if(pm_inst_bus_i[25])
	     amd1_mode = 3'b111;
	   else
	     amd1_mode = 3'b010;
	end
	default: amd1_mode = pm_inst_bus_i[11:9];
      endcase
   end
   
   addressing_mode_decoder amd0
     (
      // Outputs
      .pre_op_o			        (agu_pre_op0),
      .other_val_o			(agu_other_val0),
      .modulo_o				(agu_modulo0),
      .br_o				(agu_br0),
      .ar_out_o				(agu_ar_out0),
      .imm_o				(agu_imm0),
      .ar_wren_o			(agu_ar_wren0),
      // Inputs
      .mode_i				(amd0_mode));

   wire [1:0] agu_other_val1;
   wire       agu_pre_op1;
   wire       agu_modulo1;
   wire       agu_br1;
   wire       agu_ar_out1;
   wire       agu_imm1;
   wire       agu_ar_wren1;
   
   addressing_mode_decoder amd1
     (
      // Outputs
      .pre_op_o			        (agu_pre_op1),
      .other_val_o			(agu_other_val1),
      .modulo_o				(agu_modulo1),
      .br_o				(agu_br1),
      .ar_out_o				(agu_ar_out1),
      .imm_o				(agu_imm1),
      .ar_wren_o			(agu_ar_wren1),
      // Inputs
      .mode_i				(amd1_mode));

   wire [nat_w-1:0] alu_imm12s_extd;

   assign 	    alu_imm12s_extd = {{(nat_w-12){pm_inst_bus_i[11]}},pm_inst_bus_i[11:0]};

   wire [nat_w-1:0] alu_imm5z_extd;

   assign 	    alu_imm5z_extd = {{(nat_w-5){1'b0}},pm_inst_bus_i[11:7]};

   always@* begin
      agu_ctrl_o 		= 0;
      alu_ctrl_o`ALU_ORG	= 0;
      mac_ctrl_o 		= 0;
      cond_logic_ctrl_o 	= 0;
      loop_counter_ctrl_o 	= 0;
      wb_mux_ctrl_o 		= 0;
      pc_fsm_ctrl_o 		= 0;
      rf_ctrl_o 		= 0;
      io_ctrl_o 		= 0;
      imm_val_o 		= 0;
      spr_ctrl_o 		= 0;
      opsel_ctrl_o              = 0;
      dm_data_select_ctrl_o          = 0;
      
      casez(pm_inst_bus_i[31:22])
	`MOVE_1: 	begin //Tested
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   spr_ctrl_o`SPR_ADR = pm_inst_bus_i[16:12];
	   if (pm_inst_bus_i[16:12] == `FL0) alu_ctrl_o`ALU_OUT = 3'b110;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0110;
	end
	`MOVE_2: 	begin //Tested
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   spr_ctrl_o`SPR_ADR = pm_inst_bus_i[21:17];
	   spr_ctrl_o`SPR_WREN = 1;
	   spr_ctrl_o`SPR_SOURCE = `SPR_SOURCE_RF;
	end
	`MOVE_3: 	begin //Tested
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0001;

	   mac_ctrl_o`MAC_OPBADR = {1'b0, pm_inst_bus_i[13:12]};
	   mac_ctrl_o`MAC_OPAADR = {1'b0, {2{pm_inst_bus_i[6]}}}; //Rounding
	   mac_ctrl_o`MAC_SCALE = pm_inst_bus_i[10:8];
	   mac_ctrl_o`MAC_RND = pm_inst_bus_i[6];
	   mac_ctrl_o`MAC_SAT = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_OP = `MAC_MOVE;
	   if(pm_inst_bus_i[6]) begin
	      mac_ctrl_o`MAC_OP = `MAC_MOVE_ROUND;
	   end
	      
	end
	`MOVE_4: 	begin //Tested
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   if (pm_inst_bus_i[19]) mac_ctrl_o`MAC_SCALE = 3'b111;
	   mac_ctrl_o`MAC_GACR01 = 0;
	   mac_ctrl_o`MAC_GACR23 = 0;
	   if(pm_inst_bus_i[19]) begin
	      mac_ctrl_o`MAC_HACR0 = hacr[0];
	      mac_ctrl_o`MAC_HACR1 = hacr[1];
	      mac_ctrl_o`MAC_HACR2 = hacr[2];
	      mac_ctrl_o`MAC_HACR3 = hacr[3];
	   end
	   else begin
	      mac_ctrl_o`MAC_LACR0 = lacr[0];
	      mac_ctrl_o`MAC_LACR1 = lacr[1];
	      mac_ctrl_o`MAC_LACR2 = lacr[2];
	      mac_ctrl_o`MAC_LACR3 = lacr[3];
	   end
	   mac_ctrl_o`MAC_OP = `MAC_MOVE;
	end
	`SET_1: 		begin //Tested
	   rf_ctrl_o`RF_OPA = 6'b100000;
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = pm_inst_bus_i[15:0];
       	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0000;
	end
	`SET_2: 		begin //Tested
	   rf_ctrl_o`RF_OPA = 6'b100000;
	   imm_val_o = pm_inst_bus_i[15:0];
	   spr_ctrl_o`SPR_ADR = pm_inst_bus_i[21:17];
	   spr_ctrl_o`SPR_WREN = 1;
	end
	`LD: 			begin //Tested
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[11:7]};	       
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;

	   if (pm_inst_bus_i[29:27] ==  `A_ABS) begin
	      imm_val_o = pm_inst_bus_i[15:0];
	   end
	   else if (pm_inst_bus_i[29:27] ==  `A_OFS) begin
	      imm_val_o = {3'b0, pm_inst_bus_i[12:0]};
	      agu_ctrl_o`AGU_SP_EN = pm_inst_bus_i[15];
	   end
	   else
	     agu_ctrl_o`AGU_SP_EN = pm_inst_bus_i[15];
	   
       	   wb_mux_ctrl_o`WB_MUX_SEL = {3'b010, pm_inst_bus_i[16]};
	   agu_ctrl_o`AGU_OUT_MODE = pm_inst_bus_i[16];

	   agu_ctrl_o`AGU_PRE_OP_0   = agu_pre_op0; 
	   agu_ctrl_o`AGU_OTHER_VAL0 = agu_other_val0; 
	   agu_ctrl_o`AGU_MODULO_0   = agu_modulo0;    
	   agu_ctrl_o`AGU_BR0        = agu_br0;	      
	   agu_ctrl_o`AGU_AR0_OUT    = agu_ar_out0;    
	   agu_ctrl_o`AGU_IMM0_VALUE = agu_imm0;	      
	   agu_ctrl_o`AGU_AR0_WREN   = pm_inst_bus_i[15] ? 0 : agu_ar_wren0;      
	   agu_ctrl_o`AGU_AR0_SEL = pm_inst_bus_i[15] ? 0 : pm_inst_bus_i[14:13];
	end
	`ST: 			begin //Tested
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[11:7]};	       
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[21:17]};

	   if (pm_inst_bus_i[29:27] ==  `A_ABS) begin
	      imm_val_o = pm_inst_bus_i[15:0];
	   end
	   else if (pm_inst_bus_i[29:27] ==  `A_OFS) begin
	      imm_val_o = {3'b0, pm_inst_bus_i[12:0]};
	      agu_ctrl_o`AGU_SP_EN = pm_inst_bus_i[15];
	   end
	   else
	     agu_ctrl_o`AGU_SP_EN = pm_inst_bus_i[15];
	   
	   agu_ctrl_o`AGU_DM1_WREN = pm_inst_bus_i[16];
	   agu_ctrl_o`AGU_DM0_WREN = ~pm_inst_bus_i[16];
	   agu_ctrl_o`AGU_OUT_MODE = pm_inst_bus_i[16];

	   agu_ctrl_o`AGU_PRE_OP_0   = agu_pre_op0; 
	   agu_ctrl_o`AGU_OTHER_VAL0 = agu_other_val0; 
	   agu_ctrl_o`AGU_MODULO_0   = agu_modulo0;    
	   agu_ctrl_o`AGU_BR0        = agu_br0;	      
	   agu_ctrl_o`AGU_AR0_OUT    = agu_ar_out0;    
	   agu_ctrl_o`AGU_IMM0_VALUE = agu_imm0;	      
	   agu_ctrl_o`AGU_AR0_WREN   = pm_inst_bus_i[15] ? 0 : agu_ar_wren0;      
	   agu_ctrl_o`AGU_AR0_SEL = pm_inst_bus_i[15] ? 0 : pm_inst_bus_i[14:13];
	end // case: `ST
	`DBLLD:                 begin
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   
	   rf_ctrl_o`RF_WRITE_REG_EN_DM = 1'b1;
	   rf_ctrl_o`RF_WRITE_REG_SEL_DM = pm_inst_bus_i[16:12];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0100;
	   
	   imm_val_o = 0;
	   
	   agu_ctrl_o`AGU_PRE_OP_0   = agu_pre_op0; 
	   agu_ctrl_o`AGU_OTHER_VAL0 = agu_other_val0; 
	   agu_ctrl_o`AGU_MODULO_0   = agu_modulo0;    
	   agu_ctrl_o`AGU_BR0        = agu_br0;	      
	   agu_ctrl_o`AGU_AR0_OUT    = agu_ar_out0;    
	   agu_ctrl_o`AGU_IMM0_VALUE = agu_imm0;	      
	   agu_ctrl_o`AGU_AR0_WREN   = agu_ar_wren0;      
	   agu_ctrl_o`AGU_AR0_SEL = pm_inst_bus_i[8:7];
	   
	   agu_ctrl_o`AGU_PRE_OP_1   = agu_pre_op1; 
	   agu_ctrl_o`AGU_OTHER_VAL1 = agu_other_val1; 
	   agu_ctrl_o`AGU_MODULO_1   = agu_modulo1;    
	   agu_ctrl_o`AGU_BR1        = agu_br1;	      
	   agu_ctrl_o`AGU_AR1_OUT    = agu_ar_out1;    
	   agu_ctrl_o`AGU_IMM1_VALUE = agu_imm1;	      
	   agu_ctrl_o`AGU_AR1_WREN   = agu_ar_wren1;      
	   agu_ctrl_o`AGU_AR1_SEL = pm_inst_bus_i[6:5];
	end
	`DBLST:                 begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[21:17]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[16:12]};
	   
	   imm_val_o = 0;
	   dm_data_select_ctrl_o`DM0_SELECT = 1;
	   
	   agu_ctrl_o`AGU_DM0_WREN = 1'b1;
	   agu_ctrl_o`AGU_PRE_OP_0   = agu_pre_op0; 
	   agu_ctrl_o`AGU_OTHER_VAL0 = agu_other_val0; 
	   agu_ctrl_o`AGU_MODULO_0   = agu_modulo0;    
	   agu_ctrl_o`AGU_BR0        = agu_br0;	      
	   agu_ctrl_o`AGU_AR0_OUT    = agu_ar_out0;    
	   agu_ctrl_o`AGU_IMM0_VALUE = agu_imm0;	      
	   agu_ctrl_o`AGU_AR0_WREN   = agu_ar_wren0;      
	   agu_ctrl_o`AGU_AR0_SEL = pm_inst_bus_i[8:7];

	   agu_ctrl_o`AGU_DM1_WREN = 1'b1;
	   agu_ctrl_o`AGU_PRE_OP_1   = agu_pre_op1; 
	   agu_ctrl_o`AGU_OTHER_VAL1 = agu_other_val1; 
	   agu_ctrl_o`AGU_MODULO_1   = agu_modulo1;    
	   agu_ctrl_o`AGU_BR1        = agu_br1;	      
	   agu_ctrl_o`AGU_AR1_OUT    = agu_ar_out1;    
	   agu_ctrl_o`AGU_IMM1_VALUE = agu_imm1;	      
	   agu_ctrl_o`AGU_AR1_WREN   = agu_ar_wren1;      
	   agu_ctrl_o`AGU_AR1_SEL = pm_inst_bus_i[6:5];	   
	end
	`IN: 			begin //Tested
	   io_ctrl_o`IO_ADDR = pm_inst_bus_i[7:0];
	   io_ctrl_o`IO_RDEN = 1'b1;
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b1000;
	end
	`OUT: 			begin //Tested
	   io_ctrl_o`IO_ADDR = pm_inst_bus_i[7:0]; 
	   io_ctrl_o`IO_WREN = 1'b1;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[21:17]};
	end
	`ADDN_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   
	   alu_ctrl_o`ALU_OUT = 3'b100;
	end
	`ADDN_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   
	   alu_ctrl_o`ALU_OUT = 3'b100;
	end
	`ADDC_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   
	   alu_ctrl_o`ALU_CIN = 3'b011;
	   alu_ctrl_o`ALU_OUT = 3'b100;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b011;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`ADDC_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   
	   alu_ctrl_o`ALU_CIN = 3'b011;
	   alu_ctrl_o`ALU_OUT = 3'b100;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b011;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`ADDS_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OUT = 3'b101;
	   
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b11;
	   alu_ctrl_o`ALU_AC = 3'b110;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`ADDS_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OUT = 3'b101;
	   
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b11;
	   alu_ctrl_o`ALU_AC = 3'b110;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`ADD_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   
	   alu_ctrl_o`ALU_OUT = 3'b100;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b011;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`ADD_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   
	   alu_ctrl_o`ALU_OUT = 3'b100;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b011;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`SUBN_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b01;
	   alu_ctrl_o`ALU_CIN = 3'b001;
	   alu_ctrl_o`ALU_OUT = 3'b100;
	end
	`SUBN_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b01;
	   alu_ctrl_o`ALU_CIN = 3'b001;
	   alu_ctrl_o`ALU_OUT = 3'b100;
	end
	`SUBC_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b01;
	   alu_ctrl_o`ALU_CIN = 3'b011;
	   alu_ctrl_o`ALU_OUT = 3'b100;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b101;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`SUBC_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b01;
	   alu_ctrl_o`ALU_CIN = 3'b011;
	   alu_ctrl_o`ALU_OUT = 3'b100;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b101;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`SUBS_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b01;
	   alu_ctrl_o`ALU_CIN = 3'b001;
	   alu_ctrl_o`ALU_OUT = 3'b101;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b11;
	   alu_ctrl_o`ALU_AC = 3'b110;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`SUBS_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b01;
	   alu_ctrl_o`ALU_CIN = 3'b001;
	   alu_ctrl_o`ALU_OUT = 3'b101;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b11;
	   alu_ctrl_o`ALU_AC = 3'b110;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`SUB_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b01;
	   alu_ctrl_o`ALU_CIN = 3'b001;
	   alu_ctrl_o`ALU_OUT = 3'b100;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b101;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`SUB_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b01;
	   alu_ctrl_o`ALU_CIN = 3'b001;
	   alu_ctrl_o`ALU_OUT = 3'b100;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b101;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`CMP_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   alu_ctrl_o`ALU_OPA = 2'b01;
	   alu_ctrl_o`ALU_CIN = 3'b001;
	   alu_ctrl_o`ALU_OUT = 3'b100;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b101;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`CMP_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
       	   imm_val_o = {pm_inst_bus_i[20:17],pm_inst_bus_i[11:0]};
	   alu_ctrl_o`ALU_OPA = 2'b01;
	   alu_ctrl_o`ALU_CIN = 3'b001;
	   alu_ctrl_o`ALU_OUT = 3'b100;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AV = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b101;
	   alu_ctrl_o`ALU_AN = 2'b01;
	end
	`MAX_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b11;
	   alu_ctrl_o`ALU_OPB = 2'b11;
	   alu_ctrl_o`ALU_CIN = 3'b001;
	   alu_ctrl_o`ALU_OUT = 3'b011;
	end
	`MAX_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b11;
	   alu_ctrl_o`ALU_OPB = 2'b11;
	   alu_ctrl_o`ALU_CIN = 3'b001;
	   alu_ctrl_o`ALU_OUT = 3'b011;
	end
	`MIN_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b11;
	   alu_ctrl_o`ALU_OPB = 2'b11;
	   alu_ctrl_o`ALU_CIN = 3'b001;
	   alu_ctrl_o`ALU_CMP = 1'b1;
	   alu_ctrl_o`ALU_OUT = 3'b011;
	end
	`MIN_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b11;
	   alu_ctrl_o`ALU_OPB = 2'b11;
	   alu_ctrl_o`ALU_CIN = 3'b001;
	   alu_ctrl_o`ALU_CMP = 1'b1;
	   alu_ctrl_o`ALU_OUT = 3'b011;
	end
	`ABS: 			begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OPA = 2'b10;
	   alu_ctrl_o`ALU_OPB = 2'b01;
	   alu_ctrl_o`ALU_CIN = 3'b010;
	   alu_ctrl_o`ALU_OUT = {2'b10,pm_inst_bus_i[5]};
	   alu_ctrl_o`ALU_ABS_SAT = pm_inst_bus_i[5];
	end
	`ANDN_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OUT = 3'b010;
	end
	`ANDN_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OUT = 3'b010;
	end
	`AND_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OUT = 3'b010;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b111;
	   alu_ctrl_o`ALU_AV = 3'b11;
	   
	end
	`AND_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_OUT = 3'b010;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b111;
	   alu_ctrl_o`ALU_AV = 3'b11;
	end
	`ORN_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_LED = 2'b01;
	   alu_ctrl_o`ALU_LOGIC = 2'b01;	 
	   alu_ctrl_o`ALU_OUT = 3'b010;
	end
	`ORN_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_LED = 2'b01;
	   alu_ctrl_o`ALU_LOGIC = 2'b01;	 
	   alu_ctrl_o`ALU_OUT = 3'b010;
	end
	`OR_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_LED = 2'b01;
	   alu_ctrl_o`ALU_LOGIC = 2'b01;	 
	   alu_ctrl_o`ALU_OUT = 3'b010;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b111;
	   alu_ctrl_o`ALU_AV = 3'b11;
	end
	`OR_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_LED = 2'b01;
	   alu_ctrl_o`ALU_LOGIC = 2'b01;	 
	   alu_ctrl_o`ALU_OUT = 3'b010;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b111;
	   alu_ctrl_o`ALU_AV = 3'b11;
	end
	`XORN_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_LED = 2'b10;
	   alu_ctrl_o`ALU_LOGIC = 2'b10;	 
	   alu_ctrl_o`ALU_OUT = 3'b010;
	end
	`XORN_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_LED = 2'b10;
	   alu_ctrl_o`ALU_LOGIC = 2'b10;	 
	   alu_ctrl_o`ALU_OUT = 3'b010;
	end
	`XOR_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_LED = 2'b10;
	   alu_ctrl_o`ALU_LOGIC = 2'b10;	 
	   alu_ctrl_o`ALU_OUT = 3'b010;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b111;
	   alu_ctrl_o`ALU_AV = 3'b11;
	end
	`XOR_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   imm_val_o = alu_imm12s_extd;
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_LED = 2'b10;
	   alu_ctrl_o`ALU_LOGIC = 2'b10;	 
	   alu_ctrl_o`ALU_OUT = 3'b010;
 	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b111;
	   alu_ctrl_o`ALU_AV = 3'b11;
	end
	`ANDF: 			begin
	   rf_ctrl_o`RF_OPA = 6'b100000;
       	   imm_val_o = {11'b0,pm_inst_bus_i[11:7]};
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
 	   alu_ctrl_o`ALU_AZ = 2'b10;
	   alu_ctrl_o`ALU_AV = 2'b10;
	   alu_ctrl_o`ALU_AC = 3'b100;
	   alu_ctrl_o`ALU_AN = 2'b10;
	   mac_ctrl_o`MAC_MZ_MUX1 = 1'b1;
	   mac_ctrl_o`MAC_MN_MUX1 = 1'b1;
	   mac_ctrl_o`MAC_MS_MUX1 = 1'b1;
	   mac_ctrl_o`MAC_MV_MUX1 = 1'b1;        
	end
	`ORF: 			begin
	   rf_ctrl_o`RF_OPA = 6'b100000;
       	   imm_val_o = {11'b0,pm_inst_bus_i[11:7]};
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_AOX = 2'b01;
 	   alu_ctrl_o`ALU_AZ = 2'b10;
	   alu_ctrl_o`ALU_AV = 2'b10;
	   alu_ctrl_o`ALU_AC = 3'b100;
	   alu_ctrl_o`ALU_AN = 2'b10;
	   mac_ctrl_o`MAC_MZ_MUX1 = 1'b1;
	   mac_ctrl_o`MAC_MN_MUX1 = 1'b1;
	   mac_ctrl_o`MAC_MS_MUX1 = 1'b1;
	   mac_ctrl_o`MAC_MV_MUX1 = 1'b1;        
	end
	`XORF: 			begin
	   rf_ctrl_o`RF_OPA = 6'b100000;
       	   imm_val_o = {11'b0,pm_inst_bus_i[11:7]};
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_AOX = 2'b10;
 	   alu_ctrl_o`ALU_AZ = 2'b10;
	   alu_ctrl_o`ALU_AV = 2'b10;
	   alu_ctrl_o`ALU_AC = 3'b100;
	   alu_ctrl_o`ALU_AN = 2'b10;
	   mac_ctrl_o`MAC_MZ_MUX1 = 1'b1;
	   mac_ctrl_o`MAC_MN_MUX1 = 1'b1;
	   mac_ctrl_o`MAC_MS_MUX1 = 1'b1;
	   mac_ctrl_o`MAC_MV_MUX1 = 1'b1;        
	end
	`LED_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	end
	`LED_2: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	end
	`LED_3: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	end
	`ASR_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`ASR_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   imm_val_o = alu_imm5z_extd;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`ASL_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`ASL_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   imm_val_o = alu_imm5z_extd;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`LSR_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`LSR_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   imm_val_o = alu_imm5z_extd;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`LSL_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`LSL_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   imm_val_o = alu_imm5z_extd;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`ROR_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`ROR_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   imm_val_o = alu_imm5z_extd;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`ROL_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`ROL_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   imm_val_o = alu_imm5z_extd;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`RCR_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`RCR_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   imm_val_o = alu_imm5z_extd;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`RCL_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`RCL_2: 		begin
	   opsel_ctrl_o`OPSEL_OPB = 2;
	   imm_val_o = alu_imm5z_extd;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0010;
	   alu_ctrl_o`ALU_SHIFT = pm_inst_bus_i[25:23];
	   alu_ctrl_o`ALU_OUT = 3'b001;
	   alu_ctrl_o`ALU_AZ = 2'b01;
	   alu_ctrl_o`ALU_AN = 2'b01;
	   alu_ctrl_o`ALU_AC = 3'b010;
	end
	`ADDL_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBADR = {1'b0, pm_inst_bus_i[11:10]};
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[13:12];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_ADD;
	end
	`ADDL_2: 	begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_REGOP = 3'b011;
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[13:12];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_ADD;
	end
	`ADDL_3: 	begin
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_REGOP = 3'b010;
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[13:12];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_ADD;
	end
	`ADDL_4: 	begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPAMUL = 1'b1;
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_REGOP = 3'b100;
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[6:5];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_ADD;
	end // case: `ADDL_4
	`ADDL_5:        begin
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0001;

	   mac_ctrl_o`MAC_REGOP = 3'b011;  //zero extend
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[13:12];
	   mac_ctrl_o`MAC_SAT = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_OUT_RND = pm_inst_bus_i[6];
	   mac_ctrl_o`MAC_OP = `MAC_ADD;
	end
	`ADDL_6:        begin
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0001;

	   mac_ctrl_o`MAC_REGOP = 3'b010;  //sign extend
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[13:12];
	   mac_ctrl_o`MAC_SAT = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_OUT_RND = pm_inst_bus_i[6];
	   mac_ctrl_o`MAC_OP = `MAC_ADD;
	end
	`SUBL_1: 		begin
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBADR = {1'b0, pm_inst_bus_i[11:10]};
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[13:12];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_SUB;
	end
	`SUBL_2: 	begin
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_REGOP = 3'b011;
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[13:12];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_SUB;
	end
	`SUBL_3: 	begin
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_REGOP = 3'b010;
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[13:12];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_SUB;
	end
	`SUBL_4: 	begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPAMUL = 1'b1;
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_REGOP = 3'b100;
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[6:5];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_SUB;
	end	
	`SUBLST_1: 	begin
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[11:7]};
   	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[4:0]};
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0001;
	   mac_ctrl_o`MAC_REGOP = 3'b001;
	   mac_ctrl_o`MAC_SAT = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_OPBADR = {1'b0, pm_inst_bus_i[13:12]};
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_MUX1 = 3'b100; // Select regpair
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_OUT_RND = pm_inst_bus_i[6];
	   mac_ctrl_o`MAC_OP = `MAC_SUB;

	   //Store (inc addressing mode)
	   agu_ctrl_o`AGU_DM1_WREN = pm_inst_bus_i[16];
	   agu_ctrl_o`AGU_DM0_WREN = ~pm_inst_bus_i[16];
	   agu_ctrl_o`AGU_OUT_MODE = pm_inst_bus_i[16];
	   agu_ctrl_o`AGU_OTHER_VAL0 = 2'b01;
	   agu_ctrl_o`AGU_AR0_OUT    = 1;    
	   agu_ctrl_o`AGU_AR0_WREN   = 1;
	   agu_ctrl_o`AGU_AR0_SEL = pm_inst_bus_i[15:14];
	end
	`SUBLST_2: 	begin
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[21:17];
	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[11:7]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[4:0]};
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0001;
	   mac_ctrl_o`MAC_REGOP = 3'b000;
	   mac_ctrl_o`MAC_SAT = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_OPBADR = {1'b0, pm_inst_bus_i[13:12]};
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_MUX1 = 3'b100; // Select regpair
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_OUT_RND = pm_inst_bus_i[6];
	   mac_ctrl_o`MAC_OP = `MAC_SUB;

	   //Store (inc addressing mode)
	   agu_ctrl_o`AGU_DM1_WREN = pm_inst_bus_i[16];
	   agu_ctrl_o`AGU_DM0_WREN = ~pm_inst_bus_i[16];
	   agu_ctrl_o`AGU_OUT_MODE = pm_inst_bus_i[16];
	   agu_ctrl_o`AGU_OTHER_VAL0 = 2'b01;
	   agu_ctrl_o`AGU_AR0_OUT    = 1;    
	   agu_ctrl_o`AGU_AR0_WREN   = 1;
	   agu_ctrl_o`AGU_AR0_SEL = pm_inst_bus_i[15:14];
	end
	`CMPL_1: 		begin
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBADR = {1'b0, pm_inst_bus_i[11:10]};
	   mac_ctrl_o`MAC_MUX1 = {1'b0, pm_inst_bus_i[13:12]};
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_SAT = 1;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_OP = `MAC_CMP;
	end
	`CMPL_2: 	begin
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_REGOP = 3'b011;
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[13:12];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_SAT = 1;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_OP = `MAC_CMP;
	end
	`CMPL_3: 	begin
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_REGOP = 3'b010;
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[13:12];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_SAT = 1;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_OP = `MAC_CMP;
	end
	`CMPL_4: 	begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPAMUL = 1'b1;
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_REGOP = 3'b100;
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[7:6];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_SAT = 1;
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_OP = `MAC_CMP;
	end
	`ABSL_1: 		begin
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBADR = {1'b0, pm_inst_bus_i[13:12]};
	   mac_ctrl_o`MAC_INV = 2'b10;
	   mac_ctrl_o`MAC_SAT = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_ABS_SAT = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_ABS;
	end
	`ABSL_2: 	begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_REGOP = {2'b0,pm_inst_bus_i[6]};
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_INV = 2'b10;
	   mac_ctrl_o`MAC_SAT = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_ABS;
	end
	`NEGL_1: 		begin 
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBADR = {1'b0, pm_inst_bus_i[13:12]};
	   mac_ctrl_o`MAC_OPAADR = 3'b000; 
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_SAT = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_ABS_SAT = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_NEG;
	end
	`NEGL_2: 	begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_REGOP = {2'b0,pm_inst_bus_i[6]};
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_OPAADR = 3'b000;
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_SAT = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_NEG;
	end
	`MOVEL_1: 		begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPAMUL = 1'b1;
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_REGOP = 3'b100;
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_MOVE;
	end
	`MOVEL_2: 	begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_REGOP = {2'b0,pm_inst_bus_i[6]};
	   mac_ctrl_o`MAC_OPBADR = 3'b110;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_MOVE;
	end
	`CLR: 			begin
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBADR = 3'b101;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_CLR;
	end
	`POSTOP: 		begin
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   mac_ctrl_o`MAC_OPBADR = {1'b0, pm_inst_bus_i[11:10]};
	   mac_ctrl_o`MAC_OPAADR = {1'b0, {2{pm_inst_bus_i[6]}}}; //Rounding
	   mac_ctrl_o`MAC_SCALE = pm_inst_bus_i[21:19];
	   mac_ctrl_o`MAC_RND = pm_inst_bus_i[6];
	   mac_ctrl_o`MAC_SAT = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_MS = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_MOVE;
	   if(pm_inst_bus_i[6]) begin
	      mac_ctrl_o`MAC_OP = `MAC_MOVE_ROUND;
	   end
	end
	`MUL: 			begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   mac_ctrl_o`MAC_OPAMUL = 1'b1;
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_OPASGN = pm_inst_bus_i[6];
	   mac_ctrl_o`MAC_OPBSGN = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_OPBADR = 3'b100;
	   mac_ctrl_o`MAC_SCALE = pm_inst_bus_i[21:19];
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_MUL;
	end
	`MAC: 			begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   mac_ctrl_o`MAC_OPAMUL = 1'b1;
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_OPASGN = pm_inst_bus_i[6];
	   mac_ctrl_o`MAC_OPBSGN = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_OPBADR = 3'b100;
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_SCALE = pm_inst_bus_i[21:19];
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[18:17];
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_MAC;
	end
	`MDM: 			begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   mac_ctrl_o`MAC_OPAMUL = 1'b1;
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_OPASGN = pm_inst_bus_i[6];
	   mac_ctrl_o`MAC_OPBSGN = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_OPBADR = 3'b100;
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[18:17];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_SCALE = pm_inst_bus_i[21:19];
	   mac_ctrl_o`MAC_INV = 2'b01;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_MDM;
	end
	`MULLD:                 begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   mac_ctrl_o`MAC_OPAMUL = 1'b1;
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_OPASGN = 1'b1;
	   mac_ctrl_o`MAC_OPBSGN = 1'b1;
	   mac_ctrl_o`MAC_OPBADR = 3'b100;
	   mac_ctrl_o`MAC_SCALE = 0;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_MUL;

	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[6:2];
	   imm_val_o = 0;
	   wb_mux_ctrl_o`WB_MUX_SEL = {3'b010, pm_inst_bus_i[1]};
	   agu_ctrl_o`AGU_OUT_MODE = pm_inst_bus_i[1];
	   agu_ctrl_o`AGU_PRE_OP_0   = agu_pre_op0; 
	   agu_ctrl_o`AGU_OTHER_VAL0 = agu_other_val0; 
	   agu_ctrl_o`AGU_MODULO_0   = agu_modulo0;    
	   agu_ctrl_o`AGU_BR0        = agu_br0;	      
	   agu_ctrl_o`AGU_AR0_OUT    = agu_ar_out0;    
	   agu_ctrl_o`AGU_IMM0_VALUE = agu_imm0;	      
	   agu_ctrl_o`AGU_AR0_WREN   = agu_ar_wren0;      
	   agu_ctrl_o`AGU_AR0_SEL = pm_inst_bus_i[26:25];
	end
	`MACLD:                 begin
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   mac_ctrl_o`MAC_OPAMUL = 1'b1;
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_OPASGN = 1'b1;
	   mac_ctrl_o`MAC_OPBSGN = 1'b1;
	   mac_ctrl_o`MAC_OPBADR = 3'b100;
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_SCALE = 0;
	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[18:17];
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_MAC;

	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[6:2];
	   imm_val_o = 0;
	   wb_mux_ctrl_o`WB_MUX_SEL = {3'b010, pm_inst_bus_i[1]};
	   agu_ctrl_o`AGU_OUT_MODE = pm_inst_bus_i[1];
	   agu_ctrl_o`AGU_PRE_OP_0   = agu_pre_op0; 
	   agu_ctrl_o`AGU_OTHER_VAL0 = agu_other_val0; 
	   agu_ctrl_o`AGU_MODULO_0   = agu_modulo0;    
	   agu_ctrl_o`AGU_BR0        = agu_br0;	      
	   agu_ctrl_o`AGU_AR0_OUT    = agu_ar_out0;    
	   agu_ctrl_o`AGU_IMM0_VALUE = agu_imm0;	      
	   agu_ctrl_o`AGU_AR0_WREN   = agu_ar_wren0;      
	   agu_ctrl_o`AGU_AR0_SEL = pm_inst_bus_i[26:25];
	end
	`MULDBLLD:              begin
//	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[21:19], pm_inst_bus_i[16:15]};
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   rf_ctrl_o`RF_OPB = {1'b0, pm_inst_bus_i[11:7]};
	   mac_ctrl_o`MAC_OPAMUL = 1'b1;
	   mac_ctrl_o`MAC_OPBMUL = 1'b1;
	   mac_ctrl_o`MAC_OPASGN = 1'b1;
	   mac_ctrl_o`MAC_OPBSGN = 1'b1;
	   mac_ctrl_o`MAC_OPBADR = 3'b100;
	   mac_ctrl_o`MAC_SCALE = 0;
	   mac_ctrl_o`MAC_MV = 1'b1;
	   mac_ctrl_o`MAC_MZ = 1'b1;
	   mac_ctrl_o`MAC_MN = 1'b1;
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   mac_ctrl_o`MAC_OP = `MAC_MUL;

	   rf_ctrl_o`RF_WRITE_REG_EN = 1'b1;
	   rf_ctrl_o`RF_WRITE_REG_SEL = pm_inst_bus_i[6:2];
	   
	   rf_ctrl_o`RF_WRITE_REG_EN_DM = 1'b1;
	   rf_ctrl_o`RF_WRITE_REG_SEL_DM = {pm_inst_bus_i[21:19], pm_inst_bus_i[1:0]};
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0100;
	   
	   imm_val_o = 0;
	   
	   agu_ctrl_o`AGU_PRE_OP_0   = agu_pre_op0; 
	   agu_ctrl_o`AGU_OTHER_VAL0 = agu_other_val0; 
	   agu_ctrl_o`AGU_MODULO_0   = agu_modulo0;    
	   agu_ctrl_o`AGU_BR0        = agu_br0;	      
	   agu_ctrl_o`AGU_AR0_OUT    = agu_ar_out0;    
	   agu_ctrl_o`AGU_IMM0_VALUE = agu_imm0;	      
	   agu_ctrl_o`AGU_AR0_WREN   = agu_ar_wren0;      
	   agu_ctrl_o`AGU_AR0_SEL = 2'b00;

	   agu_ctrl_o`AGU_PRE_OP_1   = agu_pre_op1; 
	   agu_ctrl_o`AGU_OTHER_VAL1 = agu_other_val1; 
	   agu_ctrl_o`AGU_MODULO_1   = agu_modulo1;    
	   agu_ctrl_o`AGU_BR1        = agu_br1;	      
	   agu_ctrl_o`AGU_AR1_OUT    = agu_ar_out1;    
	   agu_ctrl_o`AGU_IMM1_VALUE = agu_imm1;	      
	   agu_ctrl_o`AGU_AR1_WREN   = agu_ar_wren1;      
	   agu_ctrl_o`AGU_AR1_SEL = 2'b01;
	end
	`CONV: 			begin
	   mac_ctrl_o`MAC_OPASGN = pm_inst_bus_i[6];
	   mac_ctrl_o`MAC_OPBSGN = pm_inst_bus_i[5];
	   mac_ctrl_o`MAC_OPBADR = 3'b100;
 	   mac_ctrl_o`MAC_MUX1 = pm_inst_bus_i[18:17];
	   mac_ctrl_o`MAC_OPAADR = 3'b010;
	   mac_ctrl_o`MAC_SCALE = pm_inst_bus_i[21:19];
	   mac_ctrl_o`MAC_INV = {1'b0,pm_inst_bus_i[3]};
	   //mac_ctrl_o`MAC_MV = 1'b1; //FIXME: why is this not set during convolution
	   mac_ctrl_o`MAC_GACR01 = gacr01;
	   mac_ctrl_o`MAC_GACR23 = gacr23;
	   mac_ctrl_o`MAC_HACR0 = hacr[0];
	   mac_ctrl_o`MAC_LACR0 = lacr[0];
	   mac_ctrl_o`MAC_HACR1 = hacr[1];
	   mac_ctrl_o`MAC_LACR1 = lacr[1];
	   mac_ctrl_o`MAC_HACR2 = hacr[2];
	   mac_ctrl_o`MAC_LACR2 = lacr[2];
	   mac_ctrl_o`MAC_HACR3 = hacr[3];
	   mac_ctrl_o`MAC_LACR3 = lacr[3];
	   loop_counter_ctrl_o`LC_LOOPE = 1'b1;
	   loop_counter_ctrl_o`LC_LOOPB = 1'b1;
	   if(pm_inst_bus_i[3]) begin
	      mac_ctrl_o`MAC_OP = `MAC_MDM;
	   end else begin
	      mac_ctrl_o`MAC_OP = `MAC_MAC;
	   end

	   agu_ctrl_o`AGU_PRE_OP_0   = agu_pre_op0; 
	   agu_ctrl_o`AGU_OTHER_VAL0 = agu_other_val0; 
	   agu_ctrl_o`AGU_MODULO_0   = agu_modulo0;    
	   agu_ctrl_o`AGU_BR0        = agu_br0;	      
	   agu_ctrl_o`AGU_AR0_OUT    = agu_ar_out0;    
	   agu_ctrl_o`AGU_IMM0_VALUE = agu_imm0;	      
	   agu_ctrl_o`AGU_AR0_WREN   = agu_ar_wren0;      
	   agu_ctrl_o`AGU_AR0_SEL = pm_inst_bus_i[13:12];

	   agu_ctrl_o`AGU_PRE_OP_1   = agu_pre_op1; 
	   agu_ctrl_o`AGU_OTHER_VAL1 = agu_other_val1; 
	   agu_ctrl_o`AGU_MODULO_1   = agu_modulo1;    
	   agu_ctrl_o`AGU_BR1        = agu_br1;	      
	   agu_ctrl_o`AGU_AR1_OUT    = agu_ar_out1;    
	   agu_ctrl_o`AGU_IMM1_VALUE = agu_imm1;	      
	   agu_ctrl_o`AGU_AR1_WREN   = agu_ar_wren1;      
	   agu_ctrl_o`AGU_AR1_SEL = pm_inst_bus_i[8:7];
	end
	`REP: 			begin
	   if (pm_inst_bus_i[6:0] == 7'b0000001)
	     pc_fsm_ctrl_o`PFC_REPEAT_X = 1'b1;
	   else 
	     pc_fsm_ctrl_o`PFC_REPEAT_X = 1'b0; 
	   imm_val_o = {4'b0,pm_inst_bus_i[21:10]};
	   loop_counter_ctrl_o`LC_LOOPE = 1'b1;
	   loop_counter_ctrl_o`LC_LOOPB = 1'b1;
           loop_counter_ctrl_o`LC_LOOPN1 = 1'b1;
           loop_counter_ctrl_o`LC_LOOPB1 = 1'b1;
           loop_counter_ctrl_o`LC_LOOPE1 = 1'b1;    
	   loop_counter_ctrl_o`LC_LOOPN_VAL = {4'b0,pm_inst_bus_i[21:10]};
           loop_counter_ctrl_o`LC_LOOPE_VAL = {9'b0,pm_inst_bus_i[6:0]};
	end
	`JUMP_1: 		begin
	   pc_fsm_ctrl_o`PFC_JUMP = 1'b1; // immediate not clocked
	   pc_fsm_ctrl_o`PFC_DELAY_SLOT = pm_inst_bus_i[28:27];//--PFC-- delay value
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	end
	`JUMP_2: 		begin
	   pc_fsm_ctrl_o`PFC_JUMP = 1'b1; // immediate not clocked
	   pc_fsm_ctrl_o`PFC_DELAY_SLOT = pm_inst_bus_i[28:27];//--PFC-- delay value
	   rf_ctrl_o`RF_OPA = 6'b100000;
	   imm_val_o = pm_inst_bus_i[21:6];
	   cond_logic_ctrl_o = pm_inst_bus_i[4:0];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0;
	end
	`CALL_1: 		begin
	   pc_fsm_ctrl_o`PFC_JUMP = 1'b1; // immediate not clocked
	   pc_fsm_ctrl_o`PFC_DELAY_SLOT = pm_inst_bus_i[28:27];//--PFC-- delay value
	   rf_ctrl_o`RF_OPA = {1'b0, pm_inst_bus_i[16:12]};
	   pc_fsm_ctrl_o`PFC_CALL = 1'b1;
	   if (pm_inst_bus_i[28:27] ==  2'b11) begin
	      dm_data_select_ctrl_o`DM1_SELECT = 2'b10;
	   end
	   else begin
	      dm_data_select_ctrl_o`DM1_SELECT = 2'b01;
	   end

	   agu_ctrl_o`AGU_DM1_WREN = 1'b1;
	   agu_ctrl_o`AGU_PRE_OP_0   = 0;
	   agu_ctrl_o`AGU_OTHER_VAL0 = 2'b01;
	   agu_ctrl_o`AGU_MODULO_0   = 0;
	   agu_ctrl_o`AGU_BR0        = 0;	      
	   agu_ctrl_o`AGU_AR0_OUT    = 1;    
	   agu_ctrl_o`AGU_IMM0_VALUE = 0;	      
	   agu_ctrl_o`AGU_AR0_WREN   = 0;      
	   agu_ctrl_o`AGU_AR0_SEL = 0;	 
	   agu_ctrl_o`AGU_OUT_MODE = 1;
	   agu_ctrl_o`AGU_SP_EN = 1;
	end
	`CALL_2: 		begin
	   pc_fsm_ctrl_o`PFC_JUMP = 1'b1; // immediate not clocked
	   pc_fsm_ctrl_o`PFC_DELAY_SLOT = pm_inst_bus_i[28:27];//--PFC-- delay value
	   imm_val_o = pm_inst_bus_i[21:6];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0;
	   pc_fsm_ctrl_o`PFC_CALL = 1'b1;
	   if (pm_inst_bus_i[28:27] ==  2'b11) begin
	      dm_data_select_ctrl_o`DM1_SELECT = 2'b10;
	   end
	   else begin
	      dm_data_select_ctrl_o`DM1_SELECT = 2'b01;
	   end
	   rf_ctrl_o`RF_OPA = 6'b100000;

	   agu_ctrl_o`AGU_DM1_WREN = 1'b1;
	   agu_ctrl_o`AGU_PRE_OP_0   = 0;
	   agu_ctrl_o`AGU_OTHER_VAL0 = 2'b01;
	   agu_ctrl_o`AGU_MODULO_0   = 0;
	   agu_ctrl_o`AGU_BR0        = 0;	      
	   agu_ctrl_o`AGU_AR0_OUT    = 1;    
	   agu_ctrl_o`AGU_IMM0_VALUE = 0;	      
	   agu_ctrl_o`AGU_AR0_WREN   = 0;      
	   agu_ctrl_o`AGU_AR0_SEL = 0;	 
	   agu_ctrl_o`AGU_OUT_MODE = 1;
	   agu_ctrl_o`AGU_SP_EN = 1;
	end
	`NOP: 			begin
	end
	`RET: 			begin
	   pc_fsm_ctrl_o`PFC_RET = 1'b1;
	   pc_fsm_ctrl_o`PFC_JUMP = 1'b1; // immediate not clocked
	   pc_fsm_ctrl_o`PFC_DELAY_SLOT = pm_inst_bus_i[28:27];//--PFC-- delay value

	   agu_ctrl_o`AGU_PRE_OP_0   = 1;
	   agu_ctrl_o`AGU_OTHER_VAL0 = 2'b11;
	   agu_ctrl_o`AGU_MODULO_0   = 0;
	   agu_ctrl_o`AGU_BR0        = 0;	      
	   agu_ctrl_o`AGU_AR0_OUT    = 1;    
	   agu_ctrl_o`AGU_IMM0_VALUE = 0;	      
	   agu_ctrl_o`AGU_AR0_WREN   = 0;      
	   agu_ctrl_o`AGU_AR0_SEL = 0;	 
	   agu_ctrl_o`AGU_OUT_MODE = 1;
	   agu_ctrl_o`AGU_SP_EN = 1;
	end
	`RETI: 			begin
	   imm_val_o = pm_inst_bus_i[21:6];
	   pc_fsm_ctrl_o`PFC_RET = 1'b1;
	end
	`SLEEP_1: 		begin
	end
	`SLEEP_2: 		begin
	   rf_ctrl_o`RF_OPA = 6'b100000;
	   imm_val_o = pm_inst_bus_i[21:6];
	   wb_mux_ctrl_o`WB_MUX_SEL = 4'b0;
	end
      endcase
   end

   
   always@* begin
      alu_ctrl_o`ALU_STUD	= 0;
      casez(pm_inst_bus_i[31:22])
	`ADDN_1,
	`ADDN_2,
	`ADDS_1,
	`ADDS_2,
	`ADD_1,
	`ADD_2: 	begin
	   alu_ctrl_o`ALU_FUNCTION = 3'b000;
	end
	`ADDC_1,
	`ADDC_2:        begin
	   alu_ctrl_o`ALU_FUNCTION = 3'b001;
	end
	`SUBN_1,
	`SUBN_2,
	`SUBS_1,
	`SUBS_2,
	`SUB_1,
	`SUB_2: 	begin
	   alu_ctrl_o`ALU_FUNCTION = 3'b010;
	end
	`SUBC_1,
	`SUBC_2:        begin
	   alu_ctrl_o`ALU_FUNCTION = 3'b011;	   
	end
	`ABS: 		begin
	   alu_ctrl_o`ALU_FUNCTION = 3'b100;	   	   
	end
	`CMP_1,
	`CMP_2: 	begin
	   alu_ctrl_o`ALU_FUNCTION = 3'b101;
	end
	`MAX_1,
	`MAX_2: 	begin
	   alu_ctrl_o`ALU_FUNCTION = 3'b110;
	end
	`MIN_1,
	`MIN_2: 	begin
	   alu_ctrl_o`ALU_FUNCTION = 3'b111;
	end
      endcase
   end
endmodule // ID_new


