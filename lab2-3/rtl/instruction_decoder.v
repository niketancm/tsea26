`include "senior_defines.vh"
`include "mnemonics.h"
`include "registers.h"

module instruction_decoder
  #(parameter spr_adr_w = `SPR_ADR_BUS_WIDTH)
    (
     input wire 	      clk_i, 
     input wire 	      reset_i, 
     input wire [31:0] pm_inst_bus_i, 
   
     output wire [`AGU_CTRL_WIDTH-1:0] agu_ctrl_o,
     output wire [`ALU_CTRL_WIDTH-1:0] alu_ctrl_o,
     output wire [`MAC_CTRL_WIDTH-1:0] mac_ctrl_o,
     output wire [`COND_LOGIC_CTRL_WIDTH-1:0] cond_logic_ctrl_p5_o,
     output wire [`COND_LOGIC_CTRL_WIDTH-1:0] cond_logic_ctrl_p4_o,
     output wire [`LC_CTRL_WIDTH-1:0] loop_counter_ctrl_o,
     output wire [`WB_MUX_CTRL_WIDTH-1:0] wb_mux_ctrl_o,
     output wire [`PFC_CTRL_WIDTH-1:0] pc_fsm_ctrl_o,
     output wire [`RF_CTRL_WIDTH-1:0] rf_ctrl_o,
     output wire [`IO_CTRL_WIDTH-1:0] io_ctrl_o,
     output wire [`OPSEL_CTRL_WIDTH-1:0] opsel_ctrl_o,
     output wire [`SENIOR_NATIVE_WIDTH-1:0] imm_val_p3_o,
     output wire [`SENIOR_NATIVE_WIDTH-1:0] imm_val_p4_o,
     output wire [`SENIOR_NATIVE_WIDTH-1:0] imm_val_p5_o,
     output wire [`SPR_CTRL_WIDTH-1:0] spr_ctrl_o,
     output wire [`DM_DATA_SELECT_CTRL_WIDTH-1:0] dm_data_select_ctrl_o,
     output wire [`FWD_CTRL_WIDTH-1:0] fwd_ctrl_o);
   
   wire [`AGU_CTRL_WIDTH-1:0] agu_ctrl_decoded;
   wire [`ALU_CTRL_WIDTH-1:0] alu_ctrl_decoded;
   wire [`MAC_CTRL_WIDTH-1:0] mac_ctrl_decoded;
   wire [`COND_LOGIC_CTRL_WIDTH-1:0] cond_logic_ctrl_decoded;
   wire [`LC_CTRL_WIDTH-1:0] 	     loop_counter_ctrl_decoded;
   wire [`WB_MUX_CTRL_WIDTH-1:0]     wb_mux_ctrl_decoded;
   wire [`PFC_CTRL_WIDTH-1:0] 	     pc_fsm_ctrl_decoded;
   wire [`RF_CTRL_WIDTH-1:0] 	     rf_ctrl_decoded;
   wire [`IO_CTRL_WIDTH-1:0] 	     io_ctrl_decoded;
   wire [`OPSEL_CTRL_WIDTH-1:0]      opsel_ctrl_decoded;
   wire [`SPR_CTRL_WIDTH-1:0] 	     spr_ctrl_decoded;
   wire [`DM_DATA_SELECT_CTRL_WIDTH-1:0]   dm_data_select_ctrl_decoded;
//   wire [``FWD_CTRL_WIDTH-1:0]   fwd_ctrl_decoded;
   
   wire [`ID_PIPE_TYPE_WIDTH-1:0]    pipeline_type;   
   
   wire [15:0] 			     imm_val_decoded;
	      
   id_decode_logic decode_logic
     (
      // Outputs
      .agu_ctrl_o			(agu_ctrl_decoded),
      .alu_ctrl_o			(alu_ctrl_decoded),
      .mac_ctrl_o			(mac_ctrl_decoded),
      .cond_logic_ctrl_o		(cond_logic_ctrl_decoded),
      .loop_counter_ctrl_o		(loop_counter_ctrl_decoded),
      .wb_mux_ctrl_o                    (wb_mux_ctrl_decoded),
      .pc_fsm_ctrl_o			(pc_fsm_ctrl_decoded),
      .rf_ctrl_o			(rf_ctrl_decoded),
      .io_ctrl_o			(io_ctrl_decoded),
      .opsel_ctrl_o			(opsel_ctrl_decoded),
      .imm_val_o			(imm_val_decoded),
      .pipeline_type_o                  (pipeline_type),
      .spr_ctrl_o                       (spr_ctrl_decoded),
      .dm_data_select_ctrl_o            (dm_data_select_ctrl_decoded),
      // Inputs
      .pm_inst_bus_i			(pm_inst_bus_i));


   id_pipeline_logic pipeline_logic
     (
      // Outputs
      .agu_ctrl_o			(agu_ctrl_o),
      .alu_ctrl_o			(alu_ctrl_o),
      .mac_ctrl_o			(mac_ctrl_o),
      .cond_logic_ctrl_p5_o		(cond_logic_ctrl_p5_o),
      .cond_logic_ctrl_p4_o		(cond_logic_ctrl_p4_o),
      .loop_counter_ctrl_o		(loop_counter_ctrl_o),
      .wb_mux_ctrl_o                    (wb_mux_ctrl_o),
      .pc_fsm_ctrl_o			(pc_fsm_ctrl_o),
      .rf_ctrl_o			(rf_ctrl_o),
      .io_ctrl_o			(io_ctrl_o),
      .opsel_ctrl_o			(opsel_ctrl_o),
      .imm_val_p3_o			(imm_val_p3_o),
      .imm_val_p4_o			(imm_val_p4_o),
      .imm_val_p5_o			(imm_val_p5_o),
      .spr_ctrl_o                       (spr_ctrl_o),
      .dm_data_select_ctrl_o            (dm_data_select_ctrl_o),
      .fwd_ctrl_o                       (fwd_ctrl_o),
      // Inputs
      .clk_i                            (clk_i),
      .reset_i                          (reset_i),
      .agu_ctrl_i			(agu_ctrl_decoded),
      .alu_ctrl_i			(alu_ctrl_decoded),
      .mac_ctrl_i			(mac_ctrl_decoded),
      .cond_logic_ctrl_i		(cond_logic_ctrl_decoded),
      .loop_counter_ctrl_i		(loop_counter_ctrl_decoded),
      .wb_mux_ctrl_i                    (wb_mux_ctrl_decoded),
      .pc_fsm_ctrl_i			(pc_fsm_ctrl_decoded),
      .rf_ctrl_i			(rf_ctrl_decoded),
      .io_ctrl_i			(io_ctrl_decoded),
      .opsel_ctrl_i			(opsel_ctrl_decoded),
      .imm_val_i			(imm_val_decoded),
      .pipeline_type_i			(pipeline_type),
      .spr_ctrl_i                       (spr_ctrl_decoded),
      .dm_data_select_ctrl_i            (dm_data_select_ctrl_decoded));				    
endmodule // ID_new


