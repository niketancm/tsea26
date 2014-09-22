`include "senior_defines.vh"

module id_pipeline_logic
  (
   input wire clk_i,
   input wire reset_i,
   input wire [`AGU_CTRL_WIDTH-1:0] agu_ctrl_i,
   input wire [`ALU_CTRL_WIDTH-1:0] alu_ctrl_i,
   input wire [`MAC_CTRL_WIDTH-1:0] mac_ctrl_i,
   input wire [`COND_LOGIC_CTRL_WIDTH-1:0] cond_logic_ctrl_i,
   input wire [`LC_CTRL_WIDTH-1:0] loop_counter_ctrl_i,
   input wire [`WB_MUX_CTRL_WIDTH-1:0] wb_mux_ctrl_i,
   input wire [`PFC_CTRL_WIDTH-1:0] pc_fsm_ctrl_i,
   input wire [`RF_CTRL_WIDTH-1:0] rf_ctrl_i,
   input wire [`IO_CTRL_WIDTH-1:0] io_ctrl_i,
   input wire [`OPSEL_CTRL_WIDTH-1:0] opsel_ctrl_i,
   input wire [`SENIOR_NATIVE_WIDTH-1:0] imm_val_i,
   input wire [`ID_PIPE_TYPE_WIDTH-1:0] pipeline_type_i,
   input wire [`SPR_CTRL_WIDTH-1:0] spr_ctrl_i,
   input wire [`DM_DATA_SELECT_CTRL_WIDTH-1:0] dm_data_select_ctrl_i,
   
   output reg [`AGU_CTRL_WIDTH-1:0] agu_ctrl_o,
   output reg [`ALU_CTRL_WIDTH-1:0] alu_ctrl_o,
   output reg [`MAC_CTRL_WIDTH-1:0] mac_ctrl_o,
   output reg [`COND_LOGIC_CTRL_WIDTH-1:0] cond_logic_ctrl_p4_o,
   output reg [`COND_LOGIC_CTRL_WIDTH-1:0] cond_logic_ctrl_p5_o,
   output reg [`LC_CTRL_WIDTH-1:0] loop_counter_ctrl_o,
   output reg [`WB_MUX_CTRL_WIDTH-1:0] wb_mux_ctrl_o,
   output reg [`PFC_CTRL_WIDTH-1:0] pc_fsm_ctrl_o,
   output reg [`RF_CTRL_WIDTH-1:0] rf_ctrl_o,
   output reg [`IO_CTRL_WIDTH-1:0] io_ctrl_o,
   output reg [`OPSEL_CTRL_WIDTH-1:0] opsel_ctrl_o,
   output reg [`SENIOR_NATIVE_WIDTH-1:0] imm_val_p3_o,
   output reg [`SENIOR_NATIVE_WIDTH-1:0] imm_val_p4_o,
   output reg [`SENIOR_NATIVE_WIDTH-1:0] imm_val_p5_o,
   output reg [`SPR_CTRL_WIDTH-1:0] spr_ctrl_o,
   output reg [`DM_DATA_SELECT_CTRL_WIDTH-1:0] dm_data_select_ctrl_o,
   output reg [`FWD_CTRL_WIDTH-1:0] fwd_ctrl_o);


   //Pipeline type
   reg [`ID_PIPE_TYPE_WIDTH-1:0] pipeline_type_p3;
   reg [`ID_PIPE_TYPE_WIDTH-1:0] pipeline_type_p4;
   reg [`ID_PIPE_TYPE_WIDTH-1:0] pipeline_type_p5;
   reg [`ID_PIPE_TYPE_WIDTH-1:0] pipeline_type_p6;

   always@(posedge clk_i) begin
      pipeline_type_p3 <= pipeline_type_i;
      pipeline_type_p4 <= pipeline_type_p3;
      pipeline_type_p5 <= pipeline_type_p4;
      pipeline_type_p6 <= pipeline_type_p5;
   end
   
   //AGU pipeline
   reg [`AGU_CTRL_WIDTH-1:0] agu_ctrl_p3;   

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 agu_ctrl_p3 <= 0;
      end
      else begin
	 agu_ctrl_p3 <= agu_ctrl_i;
      end
   end // always@ (posedge clk_i)

   always@* begin
      agu_ctrl_o = agu_ctrl_p3;   
   end
   //ALU pipeline
   reg [`ALU_CTRL_WIDTH-1:0] alu_ctrl_p3;   
   reg [`ALU_CTRL_WIDTH-1:0] alu_ctrl_p4;   
   always@(posedge clk_i) begin
      if(!reset_i) begin
	 alu_ctrl_p4 <= 0;   
	 alu_ctrl_p3 <= 0;   
      end
      else begin
	 alu_ctrl_p3 <= alu_ctrl_i;   
	 alu_ctrl_p4 <= alu_ctrl_p3;   
      end
   end

   always@* begin
      alu_ctrl_o = alu_ctrl_p4;
   end

   //MAC pipeline
   reg [`MAC_CTRL_WIDTH-1:0] mac_ctrl_p3;   
   reg [`MAC_CTRL_WIDTH-1:0] mac_ctrl_p4;   
   reg [`MAC_CTRL_WIDTH-1:0] mac_ctrl_p5;   
   always@(posedge clk_i) begin
      if(!reset_i) begin
	 mac_ctrl_p3 <= 0;   
	 mac_ctrl_p4 <= 0;   
	 mac_ctrl_p5 <= 0;   
      end
      else begin
	 mac_ctrl_p3 <= mac_ctrl_i;   
	 mac_ctrl_p4 <= mac_ctrl_p3;   
	 mac_ctrl_p5 <= mac_ctrl_p4;
      end
   end

   always@* begin
      if(pipeline_type_p5 == `ID_CONV_PIPE) begin
	 mac_ctrl_o = mac_ctrl_p5;
      end
      else if (pipeline_type_p3 != `ID_CONV_PIPE) begin
	 mac_ctrl_o = mac_ctrl_p3;
      end
      else begin
	 mac_ctrl_o = 0;
      end
   end


   //Condition logic
   reg [`COND_LOGIC_CTRL_WIDTH-1:0] cond_logic_ctrl_p3;
   reg [`COND_LOGIC_CTRL_WIDTH-1:0] cond_logic_ctrl_p4;
   reg [`COND_LOGIC_CTRL_WIDTH-1:0] cond_logic_ctrl_p5;

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 cond_logic_ctrl_p4 <= 0;   
	 cond_logic_ctrl_p3 <= 0;   
	 cond_logic_ctrl_p4 <= 0;   
	 cond_logic_ctrl_p5 <= 0;   
      end
      else begin
	 cond_logic_ctrl_p3 <= cond_logic_ctrl_i;   
	 cond_logic_ctrl_p4 <= cond_logic_ctrl_p3;   
	 cond_logic_ctrl_p5 <= cond_logic_ctrl_p4;   
      end
   end

   always@* begin
      cond_logic_ctrl_p5_o = cond_logic_ctrl_p5;
      cond_logic_ctrl_p4_o = cond_logic_ctrl_p4;
   end


   //Write back mux
   reg [`WB_MUX_CTRL_WIDTH-1:0] wb_mux_ctrl_p3;
   reg [`WB_MUX_CTRL_WIDTH-1:0] wb_mux_ctrl_p4;
   reg [`WB_MUX_CTRL_WIDTH-1:0] wb_mux_ctrl_p5;
   reg [`WB_MUX_CTRL_WIDTH-1:0] wb_mux_ctrl_p6;

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 wb_mux_ctrl_p3 <= 0;   
	 wb_mux_ctrl_p4 <= 0;   
	 wb_mux_ctrl_p5 <= 0;   
	 wb_mux_ctrl_p6 <= 0;   
      end
      else begin
	 wb_mux_ctrl_p3 <= wb_mux_ctrl_i;   
	 wb_mux_ctrl_p4 <= wb_mux_ctrl_p3;   
	 wb_mux_ctrl_p5 <= wb_mux_ctrl_p4;
	 wb_mux_ctrl_p6 <= wb_mux_ctrl_p5;
      end
   end

   always@* begin
      if(pipeline_type_p6 == `ID_E2_PIPE) begin
	 wb_mux_ctrl_o = wb_mux_ctrl_p6;
      end
      else begin
	 wb_mux_ctrl_o = wb_mux_ctrl_p5;
      end
   end

   //Register file
   reg [`RF_CTRL_WIDTH-1:0] rf_ctrl_p3;
   reg [`RF_CTRL_WIDTH-1:0] rf_ctrl_p4;
   reg [`RF_CTRL_WIDTH-1:0] rf_ctrl_p5;
   reg [`RF_CTRL_WIDTH-1:0] rf_ctrl_p6;

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 rf_ctrl_p3 <= 0;   
	 rf_ctrl_p4 <= 0;   
	 rf_ctrl_p5 <= 0;   
	 rf_ctrl_p6 <= 0;   
      end
      else begin
	 rf_ctrl_p3 <= rf_ctrl_i;   
	 rf_ctrl_p4 <= rf_ctrl_p3;   
	 rf_ctrl_p5 <= rf_ctrl_p4;
	 rf_ctrl_p6 <= rf_ctrl_p5;
      end
   end


   always @(posedge clk_i) begin
      if ( (pipeline_type_p6 == `ID_E2_PIPE) && (rf_ctrl_p6`RF_WRITE_REG_EN && rf_ctrl_p5`RF_WRITE_REG_EN) && 
	   (pipeline_type_p5 != `ID_E2_PIPE)) begin
	 $display("Structural hazard when writing to the register file from two instructions of different pipeline lengths");
	 $display("This will typically happen because the move rX,acrY takes an extra pipeline stage to run compared to all other instructions that write to WB");
	 $display("Note: srsim cannot detect this as yet, so this is not an indication of a bug in your RTL code.");
	 $stop;
      end
   end
   
   
   always@* begin
      rf_ctrl_o = 0;
      rf_ctrl_o`RF_READ_CTRL = rf_ctrl_p3`RF_READ_CTRL;
      if((pipeline_type_p6 == `ID_E2_PIPE) && rf_ctrl_p6`RF_WRITE_REG_EN) begin
	 rf_ctrl_o`RF_WRITE_CTRL = rf_ctrl_p6`RF_WRITE_CTRL;
      end
      else begin
	 rf_ctrl_o`RF_WRITE_CTRL = rf_ctrl_p5`RF_WRITE_CTRL;
      end
   end

   //Forwarding
   always@* begin
      fwd_ctrl_o = 0;
      fwd_ctrl_o`FWD_RF_WRITE_CTRL_P5 = {rf_ctrl_p5`RF_WRITE_REG_SEL, rf_ctrl_p5`RF_WRITE_REG_EN};
      fwd_ctrl_o`FWD_WB_MUX_SEL_P5 = wb_mux_ctrl_p5;
      fwd_ctrl_o`FWD_RF_WRITE_CTRL_P4 = {rf_ctrl_p4`RF_WRITE_REG_SEL, rf_ctrl_p4`RF_WRITE_REG_EN};
      fwd_ctrl_o`FWD_WB_MUX_SEL_P4 = wb_mux_ctrl_p4;
   end

   //Loop counter
   reg [`LC_CTRL_WIDTH-1:0] loop_counter_ctrl_p3;

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 loop_counter_ctrl_p3 <= 0;
      end
      else begin
	 loop_counter_ctrl_p3 <= loop_counter_ctrl_i;
      end
   end
   
   always@* begin
      loop_counter_ctrl_o = loop_counter_ctrl_i;
   end

   //PC FSM
   reg [`PFC_CTRL_WIDTH-1:0] pc_fsm_ctrl_p3;

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 pc_fsm_ctrl_p3 <= 0;
      end
      else begin
	 pc_fsm_ctrl_p3 <= pc_fsm_ctrl_i;
      end
   end
   
   always@* begin
      pc_fsm_ctrl_o = pc_fsm_ctrl_i;
   end

   //I/O   
   reg [`IO_CTRL_WIDTH-1:0] io_ctrl_p3;
   reg [`IO_CTRL_WIDTH-1:0] io_ctrl_p4;

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 io_ctrl_p4 <= 0;   
	 io_ctrl_p3 <= 0;   
      end
      else begin
	 io_ctrl_p3 <= io_ctrl_i;   
	 io_ctrl_p4 <= io_ctrl_p3;   
      end
   end

   always@* begin
      io_ctrl_o = io_ctrl_p4;
   end

   //Operand select   
   reg [`OPSEL_CTRL_WIDTH-1:0] opsel_ctrl_p3;

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 opsel_ctrl_p3 <= 0;   
      end
      else begin
	 opsel_ctrl_p3 <= opsel_ctrl_i;   
      end
   end

   always@* begin
      opsel_ctrl_o = opsel_ctrl_p3;
   end

   //Immediate value
   reg [`SENIOR_NATIVE_WIDTH-1:0] imm_val_p3;
   reg [`SENIOR_NATIVE_WIDTH-1:0] imm_val_p4;
   reg [`SENIOR_NATIVE_WIDTH-1:0] imm_val_p5;

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 imm_val_p3 <= 0;
	 imm_val_p4 <= 0;
	 imm_val_p5 <= 0;
      end
      else begin
	 imm_val_p3 <= imm_val_i;
	 imm_val_p4 <= imm_val_p3;
	 imm_val_p5 <= imm_val_p4;
      end
   end

   always@* begin
      imm_val_p3_o = imm_val_p3;
      imm_val_p4_o = imm_val_p4;
      imm_val_p5_o = imm_val_p5;
   end


   //SPR
   reg [`SPR_CTRL_WIDTH-1:0] spr_ctrl_p3;
   reg [`SPR_CTRL_WIDTH-1:0] spr_ctrl_p4;
   always@(posedge clk_i) begin
      if(!reset_i) begin
	 spr_ctrl_p3 <= 0;
	 spr_ctrl_p4 <= 0;
      end
      else begin
	 spr_ctrl_p3 <= spr_ctrl_i;
	 spr_ctrl_p4 <= spr_ctrl_p3;
      end
   end

   always@* begin
      spr_ctrl_o = spr_ctrl_p4;
   end

   //DM Data Select ctrl
   reg [`DM_DATA_SELECT_CTRL_WIDTH-1:0] dm_data_select_ctrl_p3;

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 dm_data_select_ctrl_p3 <= 0;   
      end
      else begin
	 dm_data_select_ctrl_p3 <= dm_data_select_ctrl_i;	 
      end
   end

   always@* begin
      dm_data_select_ctrl_o = dm_data_select_ctrl_p3;
   end
   
endmodule
