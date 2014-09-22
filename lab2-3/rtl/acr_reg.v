`include "senior_defines.vh"

module  acr_reg 
  #(parameter  reg_w = `MAC_ACR_BITS)
    (
     input wire clk_i,
     input wire reset_i,
     input wire load_guards_i,
     input wire load_high_i,
     input wire load_low_i,
     input wire load_enable_i,
     input wire [`MAC_ACR_GUARDS] guards_i,
     input wire [`MAC_ACR_HIGH] high_i,
     input wire [`MAC_ACR_LOW] low_i,
     output wire [reg_w-1:0] dat_o);


   
   reg [reg_w-1:0]    register;

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 register <= 0;
      end
      else if (load_enable_i) begin
	 if(load_guards_i) begin
	    register[`MAC_ACR_GUARDS] <= guards_i;
	 end
	 if(load_high_i) begin
	    register[`MAC_ACR_HIGH] <= high_i;
	 end
	 if(load_low_i) begin
	    register[`MAC_ACR_LOW] <= low_i;
	 end
      end       
   end // always@ (posedge clk_i)

   assign dat_o = register;
endmodule // acr_reg
