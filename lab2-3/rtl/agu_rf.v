`include "senior_defines.vh"

module agu_rf
  #(parameter nat_w = `SENIOR_NATIVE_WIDTH,
    parameter adr_w = 2,
    parameter other_value = 0)
  (
   input wire clk_i,
   input wire [adr_w-1:0] adr_a_i,
   input wire [adr_w-1:0] adr_b_i,

   output reg [nat_w-1:0] dat_a_o,
   output reg [nat_w-1:0] dat_b_o,

   input wire spr_wren_i,
   input wire spr_read_i,
   input wire [adr_w-1:0] spr_sel_i,
   input wire [nat_w-1:0] spr_dat_i);

   reg [nat_w-1:0] rf [1:0];
   wire [adr_w-1:0] adr_a;
   wire [nat_w-1:0] dat_a;

   assign 	    adr_a = (spr_wren_i | spr_read_i) ? spr_sel_i : adr_a_i; 

   always@(posedge clk_i) begin
      if(spr_wren_i) begin
	 rf[adr_a[0]] = spr_dat_i;
      end
   end

   //Need to do like this to be able to synthesize, bug in xst
   wire [nat_w-1:0] rf_adr_a_0;
   wire [nat_w-1:0] rf_adr_b_i_0;

   assign rf_adr_a_0 = rf[adr_a[0]];
   assign rf_adr_b_i_0 = rf[adr_b_i[0]];
   always@* begin
      casex(adr_a)
	2'b1x: begin
	   dat_a_o = other_value;
	end
	2'b0x: begin
	   dat_a_o = rf_adr_a_0; //rf[adr_a[0]];
	end
      endcase

      casex(adr_b_i)
	2'b1x: begin
	   dat_b_o = other_value;
	end
	2'b0x: begin
	   dat_b_o = rf_adr_b_i_0; //rf[adr_b_i[0]];
	end
      endcase
   end

   
endmodule
