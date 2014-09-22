`include "senior_defines.vh"

module pc_fsm
  #(parameter ctrl_w = `PFC_CTRL_WIDTH,
    parameter nat_w = `SENIOR_NATIVE_WIDTH)
  ( 
   input wire clk_i, 
   input wire reset_i,

   input wire jump_decision_i, 
   input wire [nat_w-1:0] lc_pfc_loope_i, 
   input wire lc_pfc_loop_flag_i, //High when loopn is 0;

   input wire [ctrl_w-1:0] ctrl_i,

   output reg pfc_pc_add_opa_sel_o, 
   output reg pfc_lc_loopn_sel_o,
   output reg [2:0] pfc_pc_sel_o, 
   output reg pfc_inst_nop_o, 
   input wire interrupt, 
   input wire [nat_w-1:0] pc_addr_bus_i
);

   `include "std_messages.vh"

   // Internal Declarations
   reg [3:0] state, next_state;
   reg [ctrl_w-1:0] ctrl_c1;
   reg [ctrl_w-1:0] ctrl_c2;
   reg [ctrl_w-1:0] ctrl_c3;


   parameter s0=4'd0; 
   parameter s1=4'd1; 
   parameter s3=4'd3; 
   parameter s4=4'd4; 
   parameter s5=4'd5; 
   parameter s6=4'd6; 
   parameter s7=4'd7; 
   parameter s8=4'd8; 
   parameter s9=4'd9; 
   parameter s10=4'd10; 
   parameter s13=4'd13;

// register generation logic
always @(posedge clk_i) begin
  if (!reset_i) begin
     state<=s0;
  end
  else begin
     ctrl_c1 <= ctrl_i;
     ctrl_c2 <= ctrl_c1;
     ctrl_c3 <= ctrl_c2;
     state<=next_state;
  end
end

// next state logic
always @(*) begin
   next_state = s0;
  case (state)
     s0: begin
	casex({ctrl_i`PFC_JUMP,ctrl_i`PFC_DELAY_SLOT})
	  3'b100: next_state = s0; //What is the next state?
	  3'b101: next_state = s0; //What is the next state?
	  3'b110: next_state = s0; //What is the next state?
	  3'b111: next_state = s0; //What is the next state?
	  default: next_state = s0; //What is the next state?
	endcase
      end
    s1: begin
      next_state=s7;
      end
    s3: begin
      next_state=s6;
      end
    s4: begin
      next_state=s8;
      end
    s5: begin
      next_state=s8;
      end
    s6: begin
      next_state=s10;
      end
    s7: begin
      next_state=s9;
      end
    s8: begin
      next_state=s10;      
      end
    s9: begin
       //What is the next state?
       next_state=s0;
      end      
    s10: begin
       //What is the next state?
       next_state=s0;
      end
    s13: begin
	next_state=s0;
    end
    default: begin
       if(defined_but_illegal(state,4,"state")) begin
	  $stop;
       end
    end
  endcase      
end

// output logic
always @(*) begin    
   pfc_pc_add_opa_sel_o=1'b0; //Default value
   pfc_pc_sel_o=3'b001;       //Default value
   pfc_inst_nop_o=1'b0;	      //Default value
   pfc_lc_loopn_sel_o=1'b0;   //Default value
   case (state)
     s0: begin
	//Your code here
     end
     s1: begin
	//Empty
     end
    s3: begin
       //Empty
      end      
    s4: begin
       //Your code here
      end      
    s5: begin
       //Your code here
      end      
    s6: begin
       casex({ctrl_c2`PFC_RET,jump_decision_i})
	 2'b1x: begin
            //Your code here
	 end
	 2'b01: begin
            //Your code here
	 end
	 2'b00: begin
            //Your code here
	 end
       endcase
      end      
    s7: begin
       casex({ctrl_c2`PFC_RET,jump_decision_i})
	 2'b1x: begin
          //Your code here
	 end
	 2'b01: begin
          //Your code here
	 end
	 2'b00: begin
	    //Empty
	 end
       endcase
       
      end      
    s8: begin
       //Your code here
       casex({ctrl_c2`PFC_RET,jump_decision_i})
	 2'b1x: begin
            //Your code here
	 end
	 2'b01: begin
            //Your code here
	 end
	 2'b00: begin
            //Your code here
	 end
       endcase
      end
    s9: begin
       //Your code here
      end      
    s10: begin
       //Your code here
      end      
     s13: begin
	//Your code here
     end
    default: begin  
    end // case: default
    
  
  endcase  
end
endmodule
