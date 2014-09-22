`include "senior_defines.vh"
module mac_scale 
   (input wire signed [39:0] to_scaling,
	     input wire [2:0] 		     c_scalefactor,
	     output wire 		     scale_overflow,
	     output reg [39:0] from_scaling);


   reg 					     scale_pos_overflow;
   reg 					     scale_neg_overflow;

   assign scale_overflow = scale_neg_overflow | scale_pos_overflow;
   // Mux for scaling
   always@(*) begin
      scale_pos_overflow = 0;
      scale_neg_overflow = 0;
      case (c_scalefactor)
	3'b000: begin
	   from_scaling=to_scaling;  // *1
	end
	3'b001: begin
	   from_scaling=to_scaling << 1;  // *2
	   scale_pos_overflow = ~to_scaling[39] & to_scaling[38];
	   scale_neg_overflow = to_scaling[39] & ~to_scaling[38];
	end
	3'b010: begin
	   from_scaling=to_scaling << 2;  // *4
	   scale_pos_overflow = ~to_scaling[39] & (|to_scaling[38:37]);
	   scale_neg_overflow = to_scaling[39] & ~(&to_scaling[38:37]);
	end
	3'b011: begin
	   from_scaling={to_scaling[39],to_scaling[39:1]};  // *0.5
	end
	3'b100: begin
	   from_scaling={{2{to_scaling[39]}},to_scaling[39:2]};  // *0.25
	end
	3'b101: begin
	   from_scaling={{3{to_scaling[39]}},to_scaling[39:3]};  // *0.125
	end
	3'b110: begin
	   from_scaling={{4{to_scaling[39]}},to_scaling[39:4]};  // *0.0625
	end
	3'b111: begin
	   from_scaling=to_scaling << 16; // *2^16
	   scale_pos_overflow = ~to_scaling[39] & (|to_scaling[38:23]);
	   scale_neg_overflow = to_scaling[39] & ~(&to_scaling[38:23]);
	end
      endcase
   end
   

endmodule
