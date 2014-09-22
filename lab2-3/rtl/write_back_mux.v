`include "senior_defines.vh"

module write_back_mux
#(parameter ctrl_w = `WB_MUX_CTRL_WIDTH)
(
   input wire [15:0] io_rf_bus_i,
   input wire [15:0] id_data_bus_i, 
   input wire [15:0] mac_data_bus_i, 
   input wire [15:0] alu_data_bus_i, 
   input wire [15:0] rf_opa_in_bus_i, 
   input wire [15:0] dm0_data_bus_i, 
   input wire [15:0] dm1_data_bus_i, 
 input wire [15:0] spr_result_i,
 input wire cond_check_p4_i,
 input wire cond_check_p5_i,
 
 input wire [ctrl_w-1:0] ctrl_i,
 
 output reg [15:0] dat_o,
 output reg rf_cond_o
);
   `include "std_messages.vh"

always @(*) begin
   rf_cond_o = cond_check_p4_i;
   case (ctrl_i`WB_MUX_SEL) //mux for register file input
     4'b0000: dat_o=id_data_bus_i;
     4'b0001: begin
	dat_o=mac_data_bus_i;
	rf_cond_o = cond_check_p5_i;
     end
     4'b0010: dat_o=alu_data_bus_i;
     4'b0011: dat_o=rf_opa_in_bus_i;
     4'b0100: dat_o=dm0_data_bus_i;
     4'b0101: dat_o=dm1_data_bus_i;
     4'b0110: dat_o=spr_result_i;
     4'b1000: dat_o=io_rf_bus_i;      
     default: begin
	dat_o=0;
	if(defined_but_illegal(ctrl_i`WB_MUX_SEL,4,"ctrl_i`WB_MUX_SEL")) begin
	   $stop;
	end
     end
   endcase
end

endmodule
