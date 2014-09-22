`include "senior_defines.vh"

module loop_controller
  #(parameter ctrl_w = `LC_CTRL_WIDTH,
    parameter nat_w = `SENIOR_NATIVE_WIDTH,
    parameter spr_dat_w = `SPR_DATA_BUS_WIDTH,
    parameter spr_adr_w = `SPR_ADR_BUS_WIDTH)
  ( 
   input wire clk_i,
   input wire reset_i,

   input wire pfc_lc_loopn_sel_i, 
   input wire [ctrl_w-1:0] ctrl_i,

   input wire [nat_w-1:0] rf_opa_bus_i,
   input wire [nat_w-1:0] pc_lc_addr_i,

   output wire lc_pfc_loop_flag_o, 
   output wire [nat_w-1:0] lc_pfc_loopb_o,
   output wire [nat_w-1:0] lc_pfc_loope_o,

    input wire [spr_dat_w-1:0] spr_dat_i,
    input wire [spr_adr_w-1:0] spr_adr_i,
    input wire spr_wren_i,
    output reg [spr_dat_w-1:0] spr_dat_o
);

`include "std_messages.vh"

// Internal Declarations
reg [nat_w-1:0] loopn_reg;
wire [1:0] loopn_mux_sel;
reg [nat_w-1:0] loopn_sig;
reg [nat_w-1:0] loopn1_sig;
reg [nat_w-1:0] loope1_sig;
reg [nat_w-1:0] loope_reg;
reg [nat_w-1:0] loope_sig;
reg [nat_w-1:0] loopb1_sig;
reg [nat_w-1:0] loopb_reg;
reg [nat_w-1:0] loopb_sig;
   reg [nat_w-1:0] old_pc;

   always@* begin
      old_pc = pc_lc_addr_i;
   end
   

   always@(*) begin
      case(spr_adr_i)
	(`SPR_CP_GROUP + `LC_SPR_LOOPN): begin
	   spr_dat_o = loopn_reg;
	end
	(`SPR_CP_GROUP + `LC_SPR_LOOPB): begin
	   spr_dat_o = loopb_reg;
	end
	(`SPR_CP_GROUP + `LC_SPR_LOOPE): begin
	   spr_dat_o = loope_reg;
	end
	default: begin
	  spr_dat_o = 0;
	end
      endcase
   end
   
   
// compute the loop counter value
always @(*) begin
  case (pfc_lc_loopn_sel_i)
    1'b0: loopn_sig=loopn_reg;
    1'b1: loopn_sig=loopn_reg-1;
  endcase     
end
   

   always@(*) begin
      case (ctrl_i`LC_LOOPN1)
	1'b0: loopn1_sig=loopn_sig;
	1'b1: loopn1_sig=ctrl_i`LC_LOOPN_VAL;
      endcase
   end



   wire [nat_w-1:0] loope1_sig_sum;
   wire loope1_sig_sum_carry;

   assign {loope1_sig_sum_carry,loope1_sig_sum} = ctrl_i`LC_LOOPE_VAL+old_pc-1;


   
always@(*) begin
  case (ctrl_i`LC_LOOPE1)
      1'b0: loope1_sig=loope_reg;
    1'b1: loope1_sig=loope1_sig_sum;
  endcase
end
  
always@(*) begin
  case (ctrl_i`LC_LOOPB1)
      1'b0: loopb1_sig=loopb_reg;
      1'b1: loopb1_sig=old_pc;
  endcase
end
  


   assign lc_pfc_loop_flag_o = ~(|loopn_reg);
assign lc_pfc_loopb_o = loopb_reg;
assign lc_pfc_loope_o = loope_reg;

   wire spr_write_loopn;
   wire spr_write_loopb;
   wire spr_write_loope;
   
   assign spr_write_loopn = ((`SPR_CP_GROUP + `LC_SPR_LOOPN) == spr_adr_i) & spr_wren_i;
   assign spr_write_loopb = ((`SPR_CP_GROUP + `LC_SPR_LOOPB) == spr_adr_i) & spr_wren_i;
   assign spr_write_loope = ((`SPR_CP_GROUP + `LC_SPR_LOOPE) == spr_adr_i) & spr_wren_i;
   
// register the loop counter value
always @(posedge clk_i) begin
  if (!reset_i) begin
     loopn_reg<=0;      
     loopb_reg<=0;      
     loope_reg<=16'b1111111111111111;     
  end
  else begin
     if(spr_write_loopn) begin
	loopn_reg<=spr_dat_i;
     end
     else begin
	loopn_reg<=loopn1_sig;
     end

     if(spr_write_loopb) begin
	loopb_reg<=spr_dat_i;
     end
     else begin
	loopb_reg<=loopb1_sig;
     end

     if(spr_write_loope) begin
	loope_reg<=spr_dat_i;
     end
     else begin
	loope_reg<=loope1_sig;
     end
  end 
end
endmodule
