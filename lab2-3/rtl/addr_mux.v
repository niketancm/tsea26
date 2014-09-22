`default_nettype none
`include "senior_defines.vh"

module addr_mux
  #(parameter adr_w = `SENIOR_ADDRESS_WIDTH,
    parameter nat_w = `SENIOR_NATIVE_WIDTH)
( 
   input wire [adr_w-1:0] agu0_addr_i, 
   input wire [adr_w-1:0] agu1_addr_i, 
   input wire [adr_w-1:0] agu2_addr_i, 
   input wire [adr_w-1:0] agu3_addr_i, 

   input wire [2:0]  id_agx_dmx_sel_i,
  input wire [nat_w-1:0] value_i, 


   output reg [adr_w-1:0] address_o);

   `include "std_messages.vh"
   
always @* begin
   casex (id_agx_dmx_sel_i) 	//if (id_agu_dmx_kpr_i == 1)  case id_agx_dmx_del_i
     3'b100: address_o=agu0_addr_i;
     3'b101: address_o=agu1_addr_i;
     3'b110: address_o=agu2_addr_i;
     3'b111: address_o=agu3_addr_i;
     3'b0xx: address_o=value_i;
     default: begin
	if(defined_but_illegal(id_agx_dmx_sel_i,3,"id_agx_dmx_sel_i")) begin
	   $stop;
	end
     end
   endcase // case (id_agx_dmx_sel_i)
end // always @ (posedge clk)
   
endmodule // addr_mux

