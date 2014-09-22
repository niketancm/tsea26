`include "senior_defines.vh"

module combined_agu
  #(parameter nat_w = `SENIOR_NATIVE_WIDTH,
    parameter ctrl_w = `AGU_CTRL_WIDTH,    
    parameter adr_w = `SENIOR_ADDRESS_WIDTH,
    parameter spr_dat_w = `SPR_DATA_BUS_WIDTH,
    parameter spr_adr_w = `SPR_ADR_BUS_WIDTH,
    parameter spr_group = `SPR_AGU_GROUP)
( 
  input wire clk_i, 
  input wire reset_i, 
  
  input wire [ctrl_w-1:0] ctrl_i,
  input wire [nat_w-1:0] id_data_bus_i, 
  input wire [nat_w-1:0] rf_opa_bus_i, 

   output reg [adr_w-1:0] dm0_address_o,
  output wire dm0_wren_o,
   output reg [adr_w-1:0] dm1_address_o,
  output wire dm1_wren_o,

  input wire [spr_dat_w-1:0] spr_dat_i,
  input wire [spr_adr_w-1:0] spr_adr_i,
  input wire spr_wren_i,
  output reg [spr_dat_w-1:0] spr_dat_o
);

   reg [adr_w-1:0] ar_rf [3:0];
   reg [nat_w-1:0] btm_rf [1:0];
   reg [nat_w-1:0] top_rf [1:0];
   reg [nat_w-1:0] stp_rf [1:0];
   reg [adr_w-1:0] sp;
   reg [2:0] 	   bitrev_rf;

   reg [adr_w-1:0] ar0_data_out;
   reg [adr_w-1:0] ar1_data_out;
   
   wire [nat_w-1:0] btm_o_dat_a;
   wire [nat_w-1:0] btm_o_dat_b;
   wire [nat_w-1:0] top_o_dat_a;
   wire [nat_w-1:0] top_o_dat_b;
   wire [nat_w-1:0] stp_o_dat_a;
   wire [nat_w-1:0] stp_o_dat_b;
 	    
   reg [1:0] 	   spr_sel;
   reg 		   spr_ar_wren;
   reg 		   spr_top_wren;
   reg 		   spr_btm_wren;
   reg 		   spr_stp_wren;
   reg 		   spr_top_read;
   reg 		   spr_btm_read;
   reg 		   spr_stp_read;
   reg 		   spr_bitrev_wren;
   reg             spr_sp_wren;		   
 		   
   //Need to do like this to be able to synthesize, bug in xst
   wire [adr_w-1:0] 	   ar_rf0;
   wire [adr_w-1:0] 	   ar_rf1;
   wire [adr_w-1:0] 	   ar_rf2;
   wire [adr_w-1:0] 	   ar_rf3;
   assign ar_rf0 = ar_rf[0];
   assign ar_rf1 = ar_rf[1];
   assign ar_rf2 = ar_rf[2];
   assign ar_rf3 = ar_rf[3];
   
   always@(*) begin
      spr_sel = 0;
      spr_dat_o = 0;
      spr_ar_wren = 0;
      spr_top_wren = 0;
      spr_btm_wren = 0;
      spr_stp_wren = 0;
      spr_top_read = 0;
      spr_btm_read = 0;
      spr_stp_read = 0;
      spr_bitrev_wren = 0;
      spr_sp_wren =0;
      case(spr_adr_i)
	(spr_group+`AGU_SPR_AR0): begin
	   spr_dat_o = ar_rf0;
	   spr_sel = 0;
	   spr_ar_wren = spr_wren_i;
	end
	(spr_group+`AGU_SPR_AR1): begin
	   spr_dat_o = ar_rf1;
	   spr_sel = 1;
	   spr_ar_wren = spr_wren_i;
	end
	(spr_group+`AGU_SPR_AR2): begin
	   spr_dat_o = ar_rf2;
	   spr_sel = 2;
	   spr_ar_wren = spr_wren_i;
	end
	(spr_group+`AGU_SPR_AR3): begin
	   spr_dat_o = ar_rf3;
	   spr_sel = 3;
	   spr_ar_wren = spr_wren_i;
	end
	(spr_group+`AGU_SPR_TOP0): begin
	   spr_dat_o = top_o_dat_a;
	   spr_sel = 0;
	   spr_top_wren = spr_wren_i;
	   spr_top_read = 1;
	end
	(spr_group+`AGU_SPR_TOP1): begin
	   spr_dat_o = top_o_dat_a;
	   spr_sel = 1;
	   spr_top_wren = spr_wren_i;
	   spr_top_read = 1;
	end
	(spr_group+`AGU_SPR_BTM0): begin
	   spr_dat_o = btm_o_dat_a;
	   spr_sel = 0;
	   spr_btm_wren = spr_wren_i;
	   spr_btm_read = 1;
	end
	(spr_group+`AGU_SPR_BTM1): begin
	   spr_dat_o = btm_o_dat_a;
	   spr_sel = 1;
	   spr_btm_wren = spr_wren_i;
	   spr_btm_read = 1;
	end
	(spr_group+`AGU_SPR_STP0): begin
	   spr_dat_o = stp_o_dat_a;
	   spr_sel = 0;
	   spr_stp_wren = spr_wren_i;
	   spr_stp_read = 1;
	end
	(spr_group+`AGU_SPR_STP1): begin
	   spr_dat_o = stp_o_dat_a;
	   spr_sel = 1;
	   spr_stp_wren = spr_wren_i;
	   spr_stp_read = 1;
	end
	(spr_group+`AGU_SPR_BITREV): begin
	   spr_dat_o = bitrev_rf;
	   spr_bitrev_wren = spr_wren_i;
	end
	(spr_group+`AGU_SPR_SP): begin
	   spr_dat_o = sp;
	   spr_sp_wren=spr_wren_i;
	end
      endcase // case(spr_adr_i)
   end

   wire ar0_rf_wren;
   wire ar1_rf_wren;

   wire [1:0] ar0_rf_adr;
   wire [1:0] ar1_rf_adr;

   wire [1:0] agu_ar0_sel;
   wire [1:0] agu_ar1_sel;
   reg [adr_w-1:0] ar0_data_in;
   reg [adr_w-1:0] ar1_data_in;

   wire [adr_w-1:0] add_res_a;
   wire 	    carry_out_a;
   reg 	    carry_in_a;
   reg [adr_w-1:0] add_a_other_op;
   
   wire [adr_w-1:0] add_res_b;
   wire 	    carry_out_b;
   reg 	    carry_in_b;
   reg [adr_w-1:0] add_b_other_op;

   wire 	   ar0_at_top;
   wire 	   ar1_at_top;

   wire [adr_w-1:0] bit_rv_a;
   wire [adr_w-1:0] bit_rv_b;

   wire [nat_w-1:0] value0;
   wire [nat_w-1:0] value1;
   
   reg [adr_w-1:0]  address_0;
   reg [adr_w-1:0]  address_1;
		   
   assign 	    value0 = ctrl_i`AGU_IMM0_VALUE ? id_data_bus_i : rf_opa_bus_i;
   assign 	    value1 = ctrl_i`AGU_IMM1_VALUE ? id_data_bus_i : rf_opa_bus_i;

   
   assign 	   ar0_at_top = (ar0_data_out == top_o_dat_a);
   assign 	   ar1_at_top = (ar1_data_out == top_o_dat_b);

   assign     agu_ar0_sel = ctrl_i`AGU_AR0_SEL;
   assign     agu_ar1_sel = ctrl_i`AGU_AR1_SEL;
  
   assign ar0_rf_wren = ctrl_i`AGU_AR0_WREN;   
   assign ar1_rf_wren = ctrl_i`AGU_AR1_WREN;

   always@* begin
      casex(ar0_at_top & ctrl_i`AGU_MODULO_0)
	1'b0: ar0_data_in = add_res_a;
	1'b1: ar0_data_in = btm_o_dat_a;
      endcase
      
      if(ar1_at_top & ctrl_i`AGU_MODULO_1) begin
	 ar1_data_in = btm_o_dat_b;
      end
      else begin
	 ar1_data_in = add_res_b;
      end
   end

   //Stack pointer special register
   always@(posedge clk_i) begin
      if(spr_sp_wren)
	sp <= spr_dat_i;
      if(ctrl_i`AGU_SP_EN & ~ctrl_i`AGU_IMM0_VALUE) //Not write to sp with offset
	sp <= ar0_data_in;
   end
   
   always@(posedge clk_i) begin
      if(ar0_rf_wren) begin 
	 ar_rf[agu_ar0_sel] <= ar0_data_in;
      end
      if(spr_ar_wren) begin
	 ar_rf[spr_sel] <= spr_dat_i;
      end
      if(ar1_rf_wren) begin
	 ar_rf[agu_ar1_sel] <= ar1_data_in;
      end
   end

   //Need to do like this to be able to synthesize, bug in xst
   wire [adr_w-1:0] 	   ar_rf_ar0_sel;
   wire [adr_w-1:0] 	   ar_rf_ar1_sel;
   assign ar_rf_ar0_sel = ctrl_i`AGU_SP_EN ? sp : ar_rf[ctrl_i`AGU_AR0_SEL];
   assign ar_rf_ar1_sel = ar_rf[ctrl_i`AGU_AR1_SEL];
   
   always@* begin
      ar0_data_out = ar_rf_ar0_sel;
      ar1_data_out = ar_rf_ar1_sel;
   end
   
   bit_reversal #(.dat_w(adr_w))
   bit_reversal0
     (
      // Outputs
      .dat_o				(bit_rv_a),
      // Inputs
      .dat_i				(ar0_data_out),
      .bitrev                           (bitrev_rf));
   
   bit_reversal #(.dat_w(adr_w))
   bit_reversal1
     (
      // Outputs
      .dat_o				(bit_rv_b),
      // Inputs
      .dat_i				(ar1_data_out),
      .bitrev                           (bitrev_rf));
   
   //Bit reversal special register
   always@(posedge clk_i) begin
      if(spr_bitrev_wren)
	bitrev_rf = spr_dat_i[2:0];
   end
   
   always@* begin
      casex({ctrl_i`AGU_PRE_OP_0, ctrl_i`AGU_BR0, ctrl_i`AGU_AR0_OUT})
	3'b000: address_0 = value0; 
	3'b001: address_0 = ar0_data_out;
	3'b01x: address_0 = bit_rv_a;
	3'b1xx: address_0 = ar0_data_in;
      endcase // casex({ctrl_i`AGU_BR0, ctrl_i`AGU_AR0_OUT})
   end

   always@* begin
      casex({ctrl_i`AGU_PRE_OP_1, ctrl_i`AGU_BR1, ctrl_i`AGU_AR1_OUT})
	3'b000: address_1 = value1; 
	3'b001: address_1 = ar1_data_out;
	3'b01x: address_1 = bit_rv_b;
	3'b1xx: address_1 = ar1_data_in;
      endcase // casex({ctrl_i`AGU_BR0, ctrl_i`AGU_AR0_OUT})
   end

   always@* begin
      case(ctrl_i`AGU_OUT_MODE)
	1'b0: begin
	   dm0_address_o = address_0;
	   dm1_address_o = address_1;
	end		  
	1'b1: begin	  
	   dm0_address_o = address_1;
	   dm1_address_o = address_0;
	end
      endcase // case(ctrl_i`AGU_OUT_MODE)
   end
   
   assign dm0_wren_o = ctrl_i`AGU_DM0_WREN;
   assign dm1_wren_o = ctrl_i`AGU_DM1_WREN;
   
   agu_rf #(.other_value({adr_w{1'b1}}))
     top
     (
      // Outputs
      .dat_a_o				(top_o_dat_a),
      .dat_b_o				(top_o_dat_b),
      // Inputs
      .clk_i                            (clk_i),
      .adr_a_i				(agu_ar0_sel),
      .adr_b_i				(agu_ar1_sel),
      .spr_wren_i			(spr_top_wren),
      .spr_read_i			(spr_top_read),
      .spr_sel_i			(spr_sel),
      .spr_dat_i			(spr_dat_i));
   

      agu_rf #(.other_value(0))
	btm
     (
      // Outputs
      .dat_a_o				(btm_o_dat_a),
      .dat_b_o				(btm_o_dat_b),
      // Inputs
      .clk_i                            (clk_i),
      .adr_a_i				(agu_ar0_sel),
      .adr_b_i				(agu_ar1_sel),
      .spr_wren_i			(spr_btm_wren),
      .spr_read_i			(spr_btm_read),
      .spr_sel_i			(spr_sel),
      .spr_dat_i			(spr_dat_i));

      agu_rf #(.other_value(1))
	stp
     (
      // Outputs
      .dat_a_o				(stp_o_dat_a),
      .dat_b_o				(stp_o_dat_b),
      // Inputs
      .clk_i                            (clk_i),
      .adr_a_i				(agu_ar0_sel),
      .adr_b_i				(agu_ar1_sel),
      .spr_wren_i			(spr_stp_wren),
      .spr_read_i			(spr_stp_read),
      .spr_sel_i			(spr_sel),
      .spr_dat_i			(spr_dat_i));


   assign 	    {carry_out_a,add_res_a} = ar0_data_out + add_a_other_op + carry_in_a; 
   assign 	    {carry_out_b,add_res_b} = ar1_data_out + add_b_other_op + carry_in_b; 

   always@* begin
      add_a_other_op = 0;
      carry_in_a = 0;
      casex({ctrl_i`AGU_SP_EN, ctrl_i`AGU_OTHER_VAL0})
	3'b000,3'b100: add_a_other_op = value0;
	3'b001: add_a_other_op = stp_o_dat_a;
	3'b01x: begin
	   add_a_other_op = ~stp_o_dat_a;
	   carry_in_a = 1;
	end
	3'b101: add_a_other_op = 1;
	3'b111: begin
	   add_a_other_op = -1;
	end
      endcase
   end
   
   always@* begin
      add_b_other_op = 0;
      carry_in_b = 0;
      casex(ctrl_i`AGU_OTHER_VAL1)
	2'b00: add_b_other_op = value1;
	2'b01: add_b_other_op = stp_o_dat_b;
	2'b1x: begin
	   add_b_other_op = ~stp_o_dat_b;
	   carry_in_b = 1;
	end
      endcase
   end

   
endmodule
