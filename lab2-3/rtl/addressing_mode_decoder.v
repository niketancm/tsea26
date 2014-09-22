`include "registers.h"

  
module addressing_mode_decoder
  (
   input wire [2:0] mode_i,
   output reg pre_op_o,
   output reg [1:0]  other_val_o,
   output reg   modulo_o,
   output reg   br_o,
   output reg   ar_out_o,
   output reg   imm_o,
   output reg   ar_wren_o);

   `include "std_messages.vh"
   
   always@* begin
      other_val_o = 0;
      modulo_o = 0;
      br_o = 0;
      ar_out_o = 1;
      imm_o = 0;
      ar_wren_o = 0;
      pre_op_o = 0;
      case (mode_i) //Decoding addressing mode
	`A_INDR: begin
	   ar_out_o = 0;
	  end
	`A_INDX: begin
	   pre_op_o = 1;
	  end
	`A_INC: begin
	   ar_wren_o = 1;
	   other_val_o = 2'b01;
	  end // case: `A_INC
	`A_DEC: begin
	   pre_op_o = 1;
	   ar_wren_o = 1;
	   other_val_o = 2'b11;
	  end // case: `A_DEC
	`A_OFS: begin  
	   imm_o = 1;
	   pre_op_o = 1;
	  end // case: `A_OFS
	`A_MINC: begin 
	   ar_wren_o = 1;
	   other_val_o = 2'b01;
	   modulo_o = 1;
	  end // case: `A_MINC
	`A_ABS: begin 
	   imm_o = 1;
	   ar_out_o = 0;
	  end // case: `A_ABS
	`A_BRV: begin  
	   ar_wren_o = 1;
	   other_val_o = 2'b01;
	   br_o = 1;
	  end // case: `A_BRV
	default: begin
	   if(defined_but_illegal(mode_i,3,"mode_i")) begin
	      $stop;
	   end
	end
      endcase 
   end

endmodule // addressing_mode_decoder
