`include "senior_defines.vh"

module dsp_core(
 input wire clk_i,
 input wire reset_i,

 // for io operations
 output wire [15:0] io_data_o,
 input wire [15:0] io_data_i,
 output wire io_wr_strobe_o,
 output wire io_rd_strobe_o,
 output wire [7:0] io_addr_o,
 
 // for PM
 output wire [15:0] pm_addr_o,
 input wire [31:0]  pm_data_i,
 
 // for DM0
 output wire [15:0] dm0_addr_o,
 output wire [15:0] dm0_data_o,
 output wire dm0_wr_en_o,
 input wire [15:0] dm0_data_i,
 
 // for DM1
 output wire [15:0] dm1_addr_o,
 output wire [15:0] dm1_data_o,
 output wire dm1_wr_en_o,
 input wire [15:0] dm1_data_i
);

//internal declarations
wire [15:0] pm_addr;
wire [15:0] rf_opb_bus_dm;
wire interrupt;
wire pc_opa_sel;
wire pfc_loopn_sel;
wire [2:0] pc_mode_sel;
wire nopmux_sel;
wire condition_check;
wire condition_check_p5;
wire [15:0] loopb;
wire [15:0] loope;
wire [15:0] rf_opa_bus;
reg [15:0] io_rf_bus;
reg [15:0] dm1_data; 
wire [15:0] io_in_data;
wire [15:0] ise;
wire [15:0] id_lc_loopn_value;
wire [15:0] id_lc_loope_value;
wire [31:0] pm_inst_bus;
wire [15:0] rf_opa_bus_unr;
wire [15:0] fwdmux_opa_bus_unr;
wire [15:0] fwdmux_opb_bus_unr;   
wire [15:0] rfpp_rf_rfin;
wire [15:0] mac_data_bus;
wire [15:0] mac_data_bus_unr;
wire [15:0] alu_data_bus;
wire [15:0] alu_data_bus_unr;
wire [15:0] selected_op_a;
wire [15:0] selected_op_b;
wire loop_flag;
wire [15:0] rf_opb_bus_unr;
wire [15:0] rf_opb_bus;
wire [15:0] rf_opa_bus_alu;
   wire     wb_mux_o_rf_cond;

   wire [`ALU_NUM_FLAGS-1:0] alu_o_flags;
   reg [`ALU_NUM_FLAGS-1:0] alu_o_flags_ff;

   wire [`MAC_NUM_FLAGS-1:0] alu_o_masked_mac_flags;
   wire [`MAC_NUM_FLAGS-1:0] mac_o_flags;
   
   //SPR signals
   parameter  spr_dat_w = `SPR_DATA_BUS_WIDTH;
   parameter  spr_adr_w = `SPR_ADR_BUS_WIDTH;

   reg [spr_dat_w-1:0] spr_result;
   wire [spr_dat_w-1:0] loop_counter_o_spr_dat;
   wire [spr_dat_w-1:0] agu_o_spr_dat;
   wire [spr_dat_w-1:0] alu_o_spr_dat;
   wire [spr_dat_w-1:0] mac_o_spr_dat;

   wire [`SENIOR_NATIVE_WIDTH-1:0] 		id_o_imm_val_p3;
   wire [`SENIOR_NATIVE_WIDTH-1:0] 		id_o_imm_val_p4;
   wire [`SENIOR_NATIVE_WIDTH-1:0] 		id_o_imm_val_p5;

   wire [spr_dat_w-1:0] spr_dat;
   wire [spr_adr_w-1:0] spr_adr;
   wire 		spr_wren;

   //Control signals
   wire [`PFC_CTRL_WIDTH-1:0] id_o_pc_fsm_ctrl;
   wire [`IO_CTRL_WIDTH-1:0] id_o_io_ctrl;
   wire [`OPSEL_CTRL_WIDTH-1:0] id_o_opsel_ctrl;
   wire [`LC_CTRL_WIDTH-1:0] id_o_loop_counter_ctrl;
   wire [`AGU_CTRL_WIDTH-1:0] id_o_agu_ctrl;
   wire [`WB_MUX_CTRL_WIDTH-1:0] id_o_wb_mux_ctrl;
   wire [`RF_CTRL_WIDTH-1:0] id_o_rf_ctrl;
   wire [`ALU_CTRL_WIDTH-1:0] id_o_alu_ctrl;
   wire [`MAC_CTRL_WIDTH-1:0] id_o_mac_ctrl;
   wire [`COND_LOGIC_CTRL_WIDTH-1:0] id_o_cond_logic_ctrl_p5;
   wire [`COND_LOGIC_CTRL_WIDTH-1:0] id_o_cond_logic_ctrl_p4;
   wire [`SPR_CTRL_WIDTH-1:0] id_o_spr_ctrl;
   wire [`DM_DATA_SELECT_CTRL_WIDTH-1:0] id_o_dm_data_select_ctrl;
   wire [`FWDMUX_CTRL_WIDTH-1:0] fwd_o_fwdmux_ctrl;
   wire [`FWD_CTRL_WIDTH-1:0]  id_o_fwd_ctrl;   
   
   always @(posedge clk_i) begin
      spr_result <=
		   loop_counter_o_spr_dat |
		   agu_o_spr_dat          |
		   alu_o_spr_dat          |
		   mac_o_spr_dat;
   end
   
   assign   interrupt = 0;

   assign   spr_adr = id_o_spr_ctrl`SPR_ADR;
   assign   spr_wren = id_o_spr_ctrl`SPR_WREN;
   assign   spr_dat = (id_o_spr_ctrl`SPR_SOURCE == `SPR_SOURCE_RF) 
                       ? rf_opa_bus 
                       : id_o_imm_val_p4;

   reg [15:0] pm_addr_ff;
   reg condition_check_ff;

   assign pm_addr_o = pm_addr;
   
   always@(posedge clk_i) begin
      pm_addr_ff <= pm_addr;
      condition_check_ff <= wb_mux_o_rf_cond;
      io_rf_bus <= io_in_data;
   end
   
//   instances
pc_fsm pc_fsm(
	      // Outputs
	      .pfc_pc_add_opa_sel_o	(pc_opa_sel),
	      .pfc_lc_loopn_sel_o	(pfc_loopn_sel),
	      .pfc_pc_sel_o		(pc_mode_sel),
	      .pfc_inst_nop_o		(nopmux_sel),
	      // Inputs
	      .clk_i                    (clk_i),
	      .reset_i			(reset_i),
	      .jump_decision_i		(condition_check),
	      .lc_pfc_loope_i		(loope),
	      .lc_pfc_loop_flag_i	(loop_flag),
	      .ctrl_i			(id_o_pc_fsm_ctrl),
	      .interrupt		(interrupt),
	      .pc_addr_bus_i		(pm_addr_ff));

   io io
     (
      // Outputs
      .io_intdata_o			(io_in_data),
      .io_wr_strobe_o			(io_wr_strobe_o),
      .io_rd_strobe_o			(io_rd_strobe_o),
      .io_data_o			(io_data_o),
      .io_addr_o			(io_addr_o),
      // Inputs
      .io_intdata_i                     (rf_opa_bus),
      .ctrl_i				(id_o_io_ctrl),
      .io_data_i	       		(io_data_i));
   
program_counter program_counter
  (
   // Outputs
   .pc_addr_bus_o			(pm_addr),
   // Inputs
   .clk_i                               (clk_i),
   .reset_i				(reset_i),
   .ise_i				(ise),
   .lc_pc_loopb_i			(loopb),
   .ta_i				(rf_opa_bus),
   .pfc_pcadd_opa_sel_i			(pc_opa_sel),
   .pfc_pc_sel_i			(pc_mode_sel),
   .stack_address_i			(dm1_data_i));

loop_controller loop_counter
  (
   // Outputs
   .lc_pfc_loop_flag_o                  (loop_flag),
   .lc_pfc_loopb_o                      (loopb),
   .lc_pfc_loope_o                      (loope),
   .spr_dat_o	                        (loop_counter_o_spr_dat),
   // Inputs
   .clk_i                               (clk_i),
   .reset_i	                        (reset_i),
   .pfc_lc_loopn_sel_i                  (pfc_loopn_sel),
   .ctrl_i	                        (id_o_loop_counter_ctrl),
   .rf_opa_bus_i                        (rf_opa_bus),
   .pc_lc_addr_i                        (pm_addr_ff),
   .spr_dat_i	                        (spr_dat),
   .spr_adr_i	                        (spr_adr),
   .spr_wren_i                          (spr_wren));
   
nop_mux nop_mux(      
      .pfc_inst_nop_i (nopmux_sel),
      .pm_inst_bus_i (pm_data_i),
      .pm_inst_bus_o (pm_inst_bus)
      );
      
   instruction_decoder instruction_decoder
     (
      // Outputs
      .agu_ctrl_o			(id_o_agu_ctrl),
      .alu_ctrl_o			(id_o_alu_ctrl),
      .mac_ctrl_o			(id_o_mac_ctrl),
      .cond_logic_ctrl_p5_o		(id_o_cond_logic_ctrl_p5),
      .cond_logic_ctrl_p4_o		(id_o_cond_logic_ctrl_p4),
      .loop_counter_ctrl_o		(id_o_loop_counter_ctrl),
      .wb_mux_ctrl_o                    (id_o_wb_mux_ctrl),
      .pc_fsm_ctrl_o			(id_o_pc_fsm_ctrl),
      .rf_ctrl_o			(id_o_rf_ctrl),
      .io_ctrl_o			(id_o_io_ctrl),
      .opsel_ctrl_o			(id_o_opsel_ctrl),
      .imm_val_p3_o			(id_o_imm_val_p3),
      .imm_val_p4_o			(id_o_imm_val_p4),
      .imm_val_p5_o			(id_o_imm_val_p5),
      .spr_ctrl_o                       (id_o_spr_ctrl),
      .dm_data_select_ctrl_o            (id_o_dm_data_select_ctrl),
      .fwd_ctrl_o                       (id_o_fwd_ctrl),
      // Inputs
      .clk_i				(clk_i),
      .reset_i				(reset_i),
      .pm_inst_bus_i			(pm_inst_bus));
   
   combined_agu agu
     (
      // Outputs
      .dm0_address_o			(dm0_addr_o),
      .dm0_wren_o                       (dm0_wr_en_o),
      .dm1_address_o			(dm1_addr_o),
      .dm1_wren_o                       (dm1_wr_en_o),
      .spr_dat_o			(agu_o_spr_dat),
      // Inputs
      .clk_i                            (clk_i),
      .reset_i				(reset_i),
      .ctrl_i				(id_o_agu_ctrl),
      .id_data_bus_i			(id_o_imm_val_p3),
      .rf_opa_bus_i			(fwdmux_opa_bus_unr),
      .spr_dat_i			(spr_dat),
      .spr_adr_i			(spr_adr),
      .spr_wren_i			(spr_wren));
      
   // data_memory muxes
   assign dm0_data_o = id_o_dm_data_select_ctrl`DM0_SELECT ? fwdmux_opa_bus_unr : fwdmux_opb_bus_unr;
   assign dm1_data_o = dm1_data;
  
   always@* begin
      dm1_data = fwdmux_opb_bus_unr;
      
      case(id_o_dm_data_select_ctrl`DM1_SELECT)
	2'b00: dm1_data = fwdmux_opb_bus_unr;
	2'b01: dm1_data = pm_addr;
	2'b10: dm1_data = pm_addr+1;
	2'b11: dm1_data = spr_result; //To be able to push sr registers to stack, not used at this time
      endcase
   end

   write_back_mux wb_mux
     (
      // Outputs
      .dat_o				(rfpp_rf_rfin),
      .rf_cond_o                        (wb_mux_o_rf_cond),
      // Inputs
      .io_rf_bus_i                      (io_rf_bus),
      .id_data_bus_i			(id_o_imm_val_p5),
      .mac_data_bus_i			(mac_data_bus),
      .alu_data_bus_i			(alu_data_bus),
      .rf_opa_in_bus_i			(rf_opa_bus),
      .dm0_data_bus_i			(dm0_data_i),
      .dm1_data_bus_i			(dm1_data_i),
      .spr_result_i			(spr_result),
      .cond_check_p4_i                  (condition_check),
      .cond_check_p5_i                  (condition_check_p5),
      .ctrl_i				(id_o_wb_mux_ctrl));
   

   operand_select opsel
     (
      // Outputs
      .op_a_o				(selected_op_a),
      .op_b_o				(selected_op_b),
      // Inputs
      .imm_val_i                        (id_o_imm_val_p3),
      .rf_a_i				(fwdmux_opa_bus_unr),
      .rf_b_i				(fwdmux_opb_bus_unr),
      .ctrl_i				(id_o_opsel_ctrl));

   fwd_ctrl fwd
     (
      //Outputs
      .fwdmux_ctrl_o                    (fwd_o_fwdmux_ctrl),
      //Inputs
      .ctrl_i                           (id_o_fwd_ctrl),
      .condition_p4_i                   (condition_check),
      .condition_p5_i                   (condition_check_p5),
      .condition_wb_i                   (condition_check_ff),
      .rf_ctrl_i                        (id_o_rf_ctrl));

   fwdmux fwdmux
     (
      //Outputs
      .opa_o                            (fwdmux_opa_bus_unr),
      .opb_o                            (fwdmux_opb_bus_unr),
      //Inputs
      .ctrl_i                           (fwd_o_fwdmux_ctrl),
      .rf_a_i                           (rf_opa_bus_unr),
      .rf_b_i                           (rf_opb_bus_unr),
      .dm1_data_i                       (dm1_data_i),
      .alu_p4_result_i                  (alu_data_bus_unr),
      .wb_result_i                      (rfpp_rf_rfin),
      .mac_p5_result_i                  (mac_data_bus_unr));
   
   register_file register_file
     (
      // Outputs
      .dat_a_o				(rf_opa_bus_unr),
      .dat_b_o				(rf_opb_bus_unr),
      // Inputs
      .clk_i                            (clk_i),
      .reset_i				(reset_i),
      .pass_through_dat_i		(id_o_imm_val_p3),
      .ctrl_i				(id_o_rf_ctrl),
      .dat_i				(rfpp_rf_rfin),
      .dm_dat_i                         (dm1_data_i),
      .register_enable_i		(condition_check_ff));

   dff operandA_register(
			 // Outputs
			 .clocked_dat_o	(rf_opa_bus),
			 // Inputs
			 .clk_i         (clk_i),
			 .reset_i	(reset_i),
			 .dat_i		(fwdmux_opa_bus_unr));

   dff operandB_register(
			 // Outputs
			 .clocked_dat_o	(rf_opb_bus),
			 // Inputs
			 .clk_i         (clk_i),
			 .reset_i	(reset_i),
			 .dat_i		(selected_op_b));
		      
      
   dff operandA_alu_register(
			     // Outputs
			     .clocked_dat_o(rf_opa_bus_alu),
			     // Inputs
			     .clk_i        (clk_i),
			     .reset_i	(reset_i),
			     .dat_i	(selected_op_a));
   
   dff operandB_DM_register(
			    // Outputs
			    .clocked_dat_o(rf_opb_bus_dm),
			    // Inputs
			    .clk_i        (clk_i),
			    .reset_i	(reset_i),
			    .dat_i	(selected_op_b));
   alu ALU(
	   // Outputs
	   .flags_o			(alu_o_flags),
	   .masked_mac_flags_o		(alu_o_masked_mac_flags),
	   .result_o			(alu_data_bus),
	   .result_unr_o                (alu_data_bus_unr),
	   .spr_dat_o                   (alu_o_spr_dat),
	   // Inputs
	   .clk_i                       (clk_i),
	   .reset_i			(reset_i),
	   .ctrl_i			(id_o_alu_ctrl),
	   .opa_i			(rf_opa_bus_alu),
	   .opb_i			(rf_opb_bus),
	   .condition_check_i		(condition_check),
	   .mac_flags_i			(mac_o_flags),
           .spr_dat_i			(spr_dat),
	   .spr_adr_i			(spr_adr),
           .spr_wren_i	        	(spr_wren));

 mac MAC(
	     // Outputs
	     .dat_o			(mac_data_bus),
	     .dat_o_unr                 (mac_data_bus_unr),
	     .flags_o			(mac_o_flags),
	     .spr_dat_o			(mac_o_spr_dat),
	     // Inputs
	     .clk_i                     (clk_i),
	     .reset_i			(reset_i),
	     .dm0_data_bus_i		(dm0_data_i),
	     .rf_opa_bus_i		(fwdmux_opa_bus_unr),
	     .dm1_data_bus_i		(dm1_data_i),
	     .rf_opb_bus_i		(fwdmux_opb_bus_unr),
	     .ctrl_i			(id_o_mac_ctrl),
	     .alu_flags_i		(alu_o_flags),
	     .condition_check_i		(condition_check_p5),
	     .spr_dat_i			(spr_dat),
	     .spr_adr_i			(spr_adr),
	     .spr_wren_i		(spr_wren));

   
condition_logic condition_logic_p4
  (
   // Outputs
   .condition_check_o			(condition_check),
   // Inputs
   .ctrl_i                              (id_o_cond_logic_ctrl_p4),
   .alu_flags_i				(alu_o_flags),
   .mac_flags_i				(mac_o_flags));      

   always@(posedge clk_i) begin
      alu_o_flags_ff <= alu_o_flags;
   end
condition_logic condition_logic_p5
  (
   // Outputs
   .condition_check_o			(condition_check_p5),
   // Inputs
   .ctrl_i                              (id_o_cond_logic_ctrl_p5),
   .alu_flags_i				(alu_o_flags_ff),
   .mac_flags_i				(mac_o_flags));      
endmodule    
