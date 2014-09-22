`include "senior_defines.vh"

module register_file
  #(parameter ctrl_w = `RF_CTRL_WIDTH,
    parameter nat_w = `SENIOR_NATIVE_WIDTH)
( 
   input wire clk_i, 
   input wire reset_i,
   input wire [nat_w-1:0] pass_through_dat_i,

  input wire [ctrl_w-1:0] ctrl_i,

   input wire [nat_w-1:0] dat_i,
   input wire [nat_w-1:0] dm_dat_i, 
   input wire register_enable_i,
   output reg [nat_w-1:0] dat_a_o, 
   output reg [nat_w-1:0] dat_b_o
);

   reg [nat_w-1:0] theRF [31:0];
   wire [nat_w-1:0] out_a;
   wire [nat_w-1:0] out_b;
   
   
// Internal Declarations
always@(posedge clk_i) begin
   if(register_enable_i && ctrl_i`RF_WRITE_REG_EN) begin
      theRF[ctrl_i`RF_WRITE_REG_SEL] <= dat_i;
   end
   if(register_enable_i && ctrl_i`RF_WRITE_REG_EN_DM && 
      ctrl_i`RF_WRITE_REG_SEL != ctrl_i`RF_WRITE_REG_SEL_DM) begin

      theRF[ctrl_i`RF_WRITE_REG_SEL_DM] <= dm_dat_i;
   end
end

   wire [5:0] ctrl_i_opa;
   wire [5:0] ctrl_i_opb;

   assign     ctrl_i_opa = ctrl_i`RF_OPA;
   assign     ctrl_i_opb = ctrl_i`RF_OPB;

   assign out_a = theRF[ctrl_i_opa[4:0]]; 
   assign out_b = theRF[ctrl_i_opb[4:0]]; 

   
   
// output logic
// mux for operand A
always @(*) begin
   case (ctrl_i_opa[5]) 
     1'b0: dat_a_o=out_a;
     1'b1: dat_a_o=pass_through_dat_i;
   endcase // case(id_rf_opa_sel_i[5])
end
   

   // mux for operand B
always@(*) begin     
   case (ctrl_i_opb[5]) 
     1'b0: dat_b_o=out_b;       
     1'b1: dat_b_o=pass_through_dat_i;       
   endcase     
end 

endmodule
