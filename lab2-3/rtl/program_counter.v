`include "senior_defines.vh"

module program_counter
#(parameter nat_w = `SENIOR_NATIVE_WIDTH)
( 
   input wire clk_i, 
   input wire reset_i,
   input wire [nat_w-1:0] ise_i, 
   input wire [nat_w-1:0] lc_pc_loopb_i, 
   input wire [nat_w-1:0] ta_i, 
   input wire pfc_pcadd_opa_sel_i, 
   input wire [2:0] pfc_pc_sel_i, 
   input wire [nat_w-1:0] stack_address_i,
   output wire [nat_w-1:0] pc_addr_bus_o
);

   `include "std_messages.vh"

// Internal Declarations
reg [nat_w-1:0] pc_op_add_sig;
reg [nat_w-1:0] pc_addr_sig;
reg [nat_w-1:0] pc_addr_reg;

assign pc_addr_bus_o=pc_addr_sig;

// compute the next PC

    // mux for OPA adder
always @(*) begin
    case (pfc_pcadd_opa_sel_i)
      1'b0: pc_op_add_sig={15'd0,1'b1};
      1'b1: pc_op_add_sig= 16'b1111111111111111;
    endcase    
end
    // mux for selecting operation on PC value 
always @(*) begin
    case (pfc_pc_sel_i)
       3'b000: pc_addr_sig=pc_addr_reg;
       3'b001: pc_addr_sig=pc_addr_reg+pc_op_add_sig;
       3'b010: pc_addr_sig=16'd0;
       3'b011: pc_addr_sig=ta_i;
       3'b100: pc_addr_sig=lc_pc_loopb_i;
       3'b101: pc_addr_sig=ise_i;
      3'b110: pc_addr_sig=stack_address_i;
      default: begin
	 pc_addr_sig=0;
	 if(defined_but_illegal(pfc_pc_sel_i,3,"pfc_pc_sel_i")) begin
	    $stop;
	 end
      end
    endcase
end

// register the PC value
always @(posedge clk_i) begin
  if (!reset_i) begin
    pc_addr_reg<=0;
  end
  else begin
     pc_addr_reg<=pc_addr_sig;
  end
end

endmodule
