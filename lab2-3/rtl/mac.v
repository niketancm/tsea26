`include "senior_defines.vh"

module mac
  #(parameter ctrl_w = `MAC_CTRL_WIDTH,
    parameter spr_dat_w = `SPR_DATA_BUS_WIDTH,
    parameter spr_adr_w = `SPR_ADR_BUS_WIDTH,
    parameter nat_w = `SENIOR_NATIVE_WIDTH,
    parameter mac_flags_w = `MAC_NUM_FLAGS,
    parameter alu_flags_w = `ALU_NUM_FLAGS)
  ( 
   input wire clk_i, 
   input wire reset_i, 
   input wire [nat_w-1:0] dm0_data_bus_i, 
   input wire [nat_w-1:0] rf_opa_bus_i, 
   input wire [nat_w-1:0] dm1_data_bus_i, 
   input wire [nat_w-1:0] rf_opb_bus_i, 
   input wire [ctrl_w-1:0] ctrl_i,
   input wire [alu_flags_w-1:0] alu_flags_i,
   input wire condition_check_i,

    output reg [nat_w-1:0] dat_o, 
    output reg [nat_w-1:0] dat_o_unr,
    output wire [mac_flags_w-1:0] flags_o,

    input wire [spr_dat_w-1:0] spr_dat_i,
    input wire [spr_adr_w-1:0] spr_adr_i,
    input wire spr_wren_i,
    output reg [spr_dat_w-1:0] spr_dat_o
   );


   
   // Internal Declarations
parameter mul_op_w = nat_w+1;
parameter mul_res_w = mul_op_w*2;
parameter num_guards = `MAC_NUM_GUARDS;
parameter mul_res_extd_w = `MAC_ACR_BITS;
   parameter 		 acr_w = `MAC_ACR_BITS;


   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			add_neg_overflow;	// From macu0 of macu.v
   wire			add_pos_overflow;	// From macu0 of macu.v
   wire			sat_flag;		// From macu0 of macu.v
   wire [mul_res_extd_w-1:0] mac_result;		// From macu0 of macu.v
   wire			scale_overflow;		// From macu0 of macu.v
   // End of automatics
   
   reg [nat_w-1:0] mul_opa_sig, mul_opb_sig;

   reg 	      signed [mul_op_w-1:0] mul_opbsgn_sig;
   reg 	      signed [mul_op_w-1:0] mul_opasgn_sig;
   reg 	      signed [mul_op_w-1:0] mul_opa_reg;
   reg 	      signed [mul_op_w-1:0] mul_opb_reg;
   reg 	      signed [mul_res_w-1:0] mul_sig;
   reg 	      signed [mul_res_extd_w-1:0] mul_sgnxt_sig;
   reg [mul_res_extd_w-1:0] mul_sgnxt_reg;
   
   reg [mul_res_extd_w-1:0] regpair_of_reg;
   reg [mul_res_extd_w-1:0] regpair_of_sig;
   reg [mul_res_extd_w-1:0] regpair_reg;
   
   reg [mul_res_extd_w-1:0] adr_opa_sig;
   reg [mul_res_extd_w-1:0] mac_operanda;


   reg signed [mul_res_extd_w-1:0] adr_opb_sig;
   wire [mul_res_extd_w-1:0] adr_opbscl_sig;



   reg [mac_flags_w-1:0] flags_reg;
   reg [mac_flags_w-1:0] flags_sig;

   
   wire [acr_w-1:0] acr0_sig;
   wire [acr_w-1:0] acr1_sig;
   wire [acr_w-1:0] acr2_sig;
   wire [acr_w-1:0] acr3_sig;



   `include "std_messages.vh"

   reg spr_write_flags;
   reg spr_write_gacr10;
   reg spr_write_gacr32;
   always@* begin
      spr_dat_o = 0;
      spr_write_flags = 0;
      spr_write_gacr10 = 0;
      spr_write_gacr32 = 0;
      case(spr_adr_i)
	(`SPR_CP_GROUP+`SPR_STATUS_FLAGS): begin
	   spr_write_flags = spr_wren_i;
	   spr_dat_o = {{(spr_dat_w-(`MAC_NUM_FLAGS+`ALU_NUM_FLAGS)){1'b0}},flags_reg,`MAC_NUM_FLAGS'b0};
	end
	(`SPR_MAC_GROUP+`MAC_SPR_ACR10_GUARDS): begin
	   spr_write_gacr10 = spr_wren_i;
	   spr_dat_o = {acr0_sig[39:32],acr1_sig[39:32]};
	end
	(`SPR_MAC_GROUP+`MAC_SPR_ACR32_GUARDS): begin
	   spr_write_gacr32 = spr_wren_i;
	   spr_dat_o = {acr2_sig[39:32],acr3_sig[39:32]};
	end
      endcase // case(spr_adr_i)
   end


   //Pipeline control signals
   reg [ctrl_w-1:0] ctrl_c1;
   reg [ctrl_w-1:0] ctrl_c2;

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 ctrl_c1 <= 0;
	 ctrl_c2 <= 0;
      end
      else begin
	 ctrl_c1 <= ctrl_i;
	 ctrl_c2 <= ctrl_c1;
      end      
   end
   
   //SPR management



 // operand fetch stage
   
   // select opa for MUL
always @(*) begin
    case (ctrl_i`MAC_OPAMUL)
      1'b0: mul_opa_sig=dm0_data_bus_i;
      1'b1: mul_opa_sig=rf_opa_bus_i;
    endcase
end    
    //select opb for MUL
always@(*) begin
    case (ctrl_i`MAC_OPBMUL)
      1'b0: mul_opb_sig=dm1_data_bus_i;
      1'b1: mul_opb_sig=rf_opb_bus_i;
    endcase
end    
       
    //sign extend opa for MUL
always@(*) begin
   case (ctrl_i`MAC_OPASGN)
      1'b0: mul_opasgn_sig={1'b0, mul_opa_sig[15:0]};
      1'b1: mul_opasgn_sig={mul_opa_sig[15], mul_opa_sig[15:0]};
    endcase
end    
    //sign extend opb for MUL
always@(*) begin
   case (ctrl_i`MAC_OPBSGN)
      1'b0: mul_opbsgn_sig={1'b0, mul_opb_sig[15:0]};
      1'b1: mul_opbsgn_sig={mul_opb_sig[15], mul_opb_sig[15:0]};
    endcase
end     
    
    //register pair operation
always@(*) begin
    case (ctrl_i`MAC_REGOP)
      3'b000: regpair_of_sig={{24{rf_opa_bus_i[15]}}, rf_opa_bus_i[15:0]};
      3'b001: regpair_of_sig={{8{rf_opa_bus_i[15]}}, rf_opa_bus_i[15:0], 16'b0000000000000000};
      3'b010: regpair_of_sig={{24{rf_opb_bus_i[15]}}, rf_opb_bus_i[15:0]};
      3'b011: regpair_of_sig={{8{rf_opb_bus_i[15]}}, rf_opb_bus_i[15:0], 16'b0000000000000000};
      3'b100: regpair_of_sig={{8{rf_opa_bus_i[15]}}, rf_opa_bus_i[15:0], rf_opb_bus_i[15:0]};
      default: begin
	 regpair_of_sig = 0;
	 if(defined_but_illegal(ctrl_i`MAC_REGOP,3,"ctrl_i`MAC_REGOP")) begin
	    $stop;
	 end
      end
    endcase    
end
   
// register sign extended opa and opb to mul
always @(posedge clk_i)
begin
  if (!reset_i) begin
     regpair_of_reg<=0;
     mul_opa_reg<=0;
     mul_opb_reg<=0;
     regpair_reg<=0;
  end  
  else  begin
     mul_opa_reg<=mul_opasgn_sig;
     mul_opb_reg<=mul_opbsgn_sig;
     regpair_of_reg<=regpair_of_sig;
     regpair_reg<=regpair_of_reg;
  end
end

//compute multiplication and sign extent to 40 bits - execution stage 1   
always @(*) begin
  mul_sig= mul_opa_reg * mul_opb_reg;
end

always @(posedge clk_i) begin
  if (!reset_i) begin
     mul_sgnxt_reg<=0;
  end
  else begin 
     mul_sgnxt_reg<={{6{mul_sig[33]}}, mul_sig[33:0]};
  end  
end

// Pipleline 2 Accumulation Execution

   reg [mul_res_extd_w-1:0] 	    mac_operandb;

    // Mux for selecting the opb of adder
always@(*) begin
    case (ctrl_c2`MAC_OPBADR)
      3'b000: mac_operandb=acr0_sig;
      3'b001: mac_operandb=acr1_sig;
      3'b010: mac_operandb=acr2_sig;
      3'b011: mac_operandb=acr3_sig;
      default: mac_operandb=regpair_reg;
    endcase
end
   
    // Mux for selecting the opb of adder
always@(*) begin
    case (ctrl_c2`MAC_OPBADR)
      3'b000: adr_opb_sig=acr0_sig;
      3'b001: adr_opb_sig=acr1_sig;
      3'b010: adr_opb_sig=acr2_sig;
      3'b011: adr_opb_sig=acr3_sig;
      3'b100: adr_opb_sig=mul_sgnxt_reg;
      3'b101: adr_opb_sig=0;
      3'b110: adr_opb_sig=regpair_reg;
      default: begin
	 adr_opb_sig=regpair_reg;
	 if(defined_but_illegal(ctrl_c2`MAC_OPBADR,3,"ctrl_c2`MAC_OPBADR")) begin
	    $stop;
	 end
      end
    endcase
end


   // We don't support this in the student version of Senior to avoid
   // complicating the datapath of the MAC.
   always @(posedge clk_i) begin
      if(ctrl_c2`MAC_OUT_RND) begin
	 $display("%m: Warning: addl, subl, or sublst with rounding is not supported!");
	 $stop;
      end
   end

   // # NEW MODULE HERE - andreask

   mac_dp mac_datapath(.c_scalefactor(ctrl_c2`MAC_SCALE),
	      .c_dosat(ctrl_c2`MAC_SAT),
	      .c_macop(ctrl_c2`MAC_OP),
	      /*AUTOINST*/
	      // Outputs
	      .scale_overflow		(scale_overflow),
	      .sat_flag			(sat_flag),
	      .mac_result			(mac_result[mul_res_extd_w-1:0]),
	      .add_pos_overflow		(add_pos_overflow),
	      .add_neg_overflow		(add_neg_overflow),
	      // Inputs
	      .clk_i			(clk_i),
	      .reset_i			(reset_i),
	      .mul_opa_reg		(mul_opa_reg),
	      .mul_opb_reg		(mul_opb_reg),
	      .mac_operanda		(mac_operanda),
	      .mac_operandb		(mac_operandb));

   
   // Mux1 for selecting opa
   always@(*) begin
      case(ctrl_c2`MAC_MUX1)
	3'b000: mac_operanda=acr0_sig;
	3'b001: mac_operanda=acr1_sig;
	3'b010: mac_operanda=acr2_sig;
	3'b011: mac_operanda=acr3_sig;
	default: mac_operanda=regpair_reg;
      endcase
   end
   

      
   always@(*) begin
      dat_o_unr = mac_result[31:16]; 
   end 
   
   // Native word extract
   always@(posedge clk_i) begin
      dat_o <= dat_o_unr;
   end
   
   // # NEW MODULE ENDS HERE - andreask
   
   // flags logic

   //Flags register
   always@(posedge clk_i) begin
      if(!reset_i) begin
	 flags_reg<=0;
      end
      else begin
	 if(spr_write_flags) begin
	    flags_reg <= spr_dat_i[7:4];
	 end
	 else if(condition_check_i) begin
	    if(ctrl_c2`MAC_MV) begin
	       flags_reg[`MAC_FLAG_MV]<=flags_sig[`MAC_FLAG_MV];
	    end
	    if(ctrl_c2`MAC_MS) begin
	       flags_reg[`MAC_FLAG_MS]<=flags_sig[`MAC_FLAG_MS];
	    end
	    if(ctrl_c2`MAC_MN) begin
	       flags_reg[`MAC_FLAG_MN]<=flags_sig[`MAC_FLAG_MN];
	    end
	    if(ctrl_c2`MAC_MZ) begin
	       flags_reg[`MAC_FLAG_MZ]<=flags_sig[`MAC_FLAG_MZ];
	    end
	 end
      end
   end

   // zero flag    
   always@(*) begin
      casex(ctrl_c2`MAC_MZ_MUX1)
	1'b0: flags_sig[`MAC_FLAG_MZ] = ~(|mac_result[39:0]);
	1'b1: flags_sig[`MAC_FLAG_MZ] = alu_flags_i[`MAC_FLAG_MZ];
      endcase
   end

   // negative flag    
   always@(*) begin
      casex(ctrl_c2`MAC_MN_MUX1)
	1'b0: flags_sig[`MAC_FLAG_MN] = mac_result[39];
	1'b1: flags_sig[`MAC_FLAG_MN] = alu_flags_i[`MAC_FLAG_MN]; 
      endcase
   end

   // saturate/carry flag    
   always@(*) begin
      casex(ctrl_c2`MAC_MS_MUX1)
	1'b0: flags_sig[`MAC_FLAG_MS] = sat_flag | flags_reg[`MAC_FLAG_MS];
	1'b1: flags_sig[`MAC_FLAG_MS] = alu_flags_i[`MAC_FLAG_MS];
      endcase
   end

   always @(posedge clk_i) begin
      if(ctrl_c2`MAC_OP == `MAC_CMP) begin
	 $display("GRR %d  %d", condition_check_i, ctrl_c2`MAC_MV);
	 $display("  Nisse: %d %d",flags_sig[`MAC_FLAG_MV], alu_flags_i[`MAC_FLAG_MV]);
      end
   end
   
   //overflow flag
   always@(*) begin
      casex(ctrl_c2`MAC_MV_MUX1)
	1'b0: flags_sig[`MAC_FLAG_MV] = ((add_pos_overflow || add_neg_overflow || scale_overflow) && (!sat_flag || (ctrl_c2`MAC_OP == `MAC_CMP))) || flags_reg[`MAC_FLAG_MV];
	1'b1: flags_sig[`MAC_FLAG_MV] = alu_flags_i[`MAC_FLAG_MV];
      endcase
   end
   
   assign flags_o=flags_reg;



   // Muxes and registers for ACR0- ACR3
   //ACR0

   wire load_acr0_guards;
   reg [7:0] acr0_guards;

   wire [1:0] ctrl_c2_gacr01;

   assign    ctrl_c2_gacr01 = ctrl_c2`MAC_GACR01;
   
   assign    load_acr0_guards = (~ctrl_c2_gacr01[1]) & ctrl_c2_gacr01[0]
                                | spr_write_gacr10;

   always@(*) begin
      casex(spr_write_gacr10)
	1'b0: acr0_guards=mac_result[39:32];
	1'b1: acr0_guards=spr_dat_i[15:8];
      endcase
   end
   
   acr_reg ACR0(
		// Outputs
		.dat_o			(acr0_sig),
		// Inputs
		.clk_i			(clk_i),
		.reset_i		(reset_i),
		.load_guards_i		(load_acr0_guards),
		.load_high_i		(ctrl_c2`MAC_HACR0),
		.load_low_i		(ctrl_c2`MAC_LACR0),
		.load_enable_i		(condition_check_i),
		.guards_i		(acr0_guards),
		.high_i			(mac_result[31:16]),
		.low_i			(mac_result[15:0])
		);


   
   //ACR1
   wire load_acr1_guards;
   reg [7:0] acr1_guards;

   assign    load_acr1_guards = ((ctrl_c2_gacr01[1]) & (~ctrl_c2_gacr01[0])) 
                                | spr_write_gacr10;

   always@(*) begin
      case(spr_write_gacr10)
	1'b0: acr1_guards=mac_result[39:32];
	1'b1: acr1_guards=spr_dat_i[7:0];
      endcase
   end

   acr_reg ACR1(
		// Outputs
		.dat_o			(acr1_sig),
		// Inputs
		.clk_i			(clk_i),
		.reset_i		(reset_i),
		.load_guards_i		(load_acr1_guards),
		.load_high_i		(ctrl_c2`MAC_HACR1),
		.load_low_i		(ctrl_c2`MAC_LACR1),
		.load_enable_i		(condition_check_i),
		.guards_i		(acr1_guards),
		.high_i			(mac_result[31:16]),
		.low_i			(mac_result[15:0]));


   
   //ACR2
   wire load_acr2_guards;
   reg [7:0] acr2_guards;

   wire [1:0] ctrl_c2_gacr23;

   assign    ctrl_c2_gacr23 = ctrl_c2`MAC_GACR23;

   assign    load_acr2_guards = (~ctrl_c2_gacr23[1]) & ctrl_c2_gacr23[0]
                                | spr_write_gacr32;

   always@(*) begin
      case(spr_write_gacr32)
	1'b0: acr2_guards=mac_result[39:32];
	1'b1: acr2_guards=spr_dat_i[15:8];
      endcase
   end

   acr_reg ACR2(
		// Outputs
		.dat_o			(acr2_sig),
		// Inputs
		.clk_i			(clk_i),
		.reset_i		(reset_i),
		.load_guards_i		(load_acr2_guards),
		.load_high_i		(ctrl_c2`MAC_HACR2),
		.load_low_i		(ctrl_c2`MAC_LACR2),
		.load_enable_i		(condition_check_i),
		.guards_i		(acr2_guards),
		.high_i			(mac_result[31:16]),
		.low_i			(mac_result[15:0]));

   
   //ACR3
   wire load_acr3_guards;
   reg [7:0] acr3_guards;

   assign    load_acr3_guards = (ctrl_c2_gacr23[1]) & (~ctrl_c2_gacr23[0])
                                | spr_write_gacr32;

   always@(*) begin
      case(spr_write_gacr32)
	1'b0: acr3_guards=mac_result[39:32];
	1'b1: acr3_guards=spr_dat_i[7:0];
      endcase
   end

   acr_reg ACR3(
		// Outputs
		.dat_o			(acr3_sig),
		// Inputs
		.clk_i			(clk_i),
		.reset_i		(reset_i),
		.load_guards_i		(load_acr3_guards),
		.load_high_i		(ctrl_c2`MAC_HACR3),
		.load_low_i		(ctrl_c2`MAC_LACR3),
		.load_enable_i		(condition_check_i),
		.guards_i		(acr3_guards),
		.high_i			(mac_result[31:16]),
		.low_i			(mac_result[15:0]));


endmodule

