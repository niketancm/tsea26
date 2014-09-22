`include "senior_defines.vh"
`default_nettype none
  

module alu
  #(parameter nat_w = `SENIOR_NATIVE_WIDTH,
    parameter ctrl_w = `ALU_CTRL_WIDTH,
    parameter mac_flags_w = `MAC_NUM_FLAGS,
    parameter alu_flags_w = `ALU_NUM_FLAGS,
    parameter spr_dat_w = `SPR_DATA_BUS_WIDTH,
    parameter spr_adr_w = `SPR_ADR_BUS_WIDTH
    )
  ( 
    input wire clk_i,
    input wire reset_i, 
    input wire [ctrl_w-1:0] ctrl_i,
    input wire [nat_w-1:0] opa_i, 
    input wire [nat_w-1:0] opb_i, 
    input wire condition_check_i,
    input wire [mac_flags_w-1:0] mac_flags_i,
    
    output wire [alu_flags_w-1:0] flags_o,    
    output wire [mac_flags_w-1:0] masked_mac_flags_o,
    output reg [nat_w-1:0] result_o,
    output reg [nat_w-1:0] result_unr_o,

    input wire [spr_dat_w-1:0] spr_dat_i,
    input wire [spr_adr_w-1:0] spr_adr_i,
    input wire spr_wren_i,
    output reg [spr_dat_w-1:0] spr_dat_o
    );

`include "std_messages.vh"
// Internal Declarations
   reg 	[1:0]   opa_sel_sig;
   reg [nat_w-1:0] opa_sig;
   reg [nat_w-1:0] opb_sig;
   wire [(nat_w-1):0] add_sig;
   wire 		add_carry;
   reg 			max_sig;
   reg [nat_w-1:0] 	mxmn_sig;
   reg 			cin_sig;
   reg [nat_w-1:0] 	add_sat_sig;
   reg 			led_cnt_sig;
   reg [nat_w-1:0] 	led_sig;
   reg [nat_w-1:0] 	logic_sig;
   reg [(nat_w-1)+1:0] 	shift_sig;
   reg [(mac_flags_w+alu_flags_w)-1:0] aox_flag_sig;
   
   reg [alu_flags_w-1:0] 	       flags_reg;
   reg [alu_flags_w-1:0] 	       flags_sig;

   wire 			       mx_minmax;
   wire 			       mx_opa_inv;
   wire [1:0]			       mx_ci;

   min_max_ctrl min_max_ctrl
     (
      // Outputs
      .mx_minmax_o			(mx_minmax),
      // Inputs
      .function_i			(ctrl_i`ALU_FUNCTION),
      .opb_sign_i			(opb_i[nat_w-1]),
      .opa_sign_i			(opa_i[nat_w-1]),
      .carry_i				(add_carry)
      );

   adder_ctrl adder_ctrl
     (
      // Outputs
      .mx_opa_inv_o			(mx_opa_inv),
      .mx_ci_o				(mx_ci),
      // Inputs
      .function_i			(ctrl_i`ALU_FUNCTION),
      .opa_sign_i			(opa_i[nat_w-1])
      );
   
   assign flags_o = flags_reg;
assign masked_mac_flags_o[`MAC_FLAG_MZ]=aox_flag_sig[4];
assign masked_mac_flags_o[`MAC_FLAG_MN]=aox_flag_sig[5];
assign masked_mac_flags_o[`MAC_FLAG_MS]=aox_flag_sig[6];
assign masked_mac_flags_o[`MAC_FLAG_MV]=aox_flag_sig[7];

   // Compute Adder
   assign {add_carry,add_sig}=opa_sig+opb_sig+cin_sig;

   wire   add_pos_overflow;
   wire   add_neg_overflow;
   wire   abs_overflow;

   assign add_pos_overflow = ~opa_sig[nat_w-1] & ~opb_sig[nat_w-1] & add_sig[nat_w-1];
   assign add_neg_overflow = opa_sig[nat_w-1] & opb_sig[nat_w-1] & ~add_sig[nat_w-1];
   assign abs_overflow = opa_i[nat_w-1] & add_sig[nat_w-1];
   
   // Mux to select mux signal for Operand A
always @(*) begin
    case (ctrl_i`ALU_OPA)   
      2'b00: opa_sel_sig=2'b00;      
      2'b01: opa_sel_sig=2'b01;
      2'b10: opa_sel_sig={1'b0,opa_i[15]};
      2'b11: opa_sel_sig=2'b11;
    endcase
end
    
    //Mux to select Operand A
   always@* begin
      case(mx_opa_inv)
	1'b0: opa_sig=opa_i;
	1'b1: opa_sig=~(opa_i);
      endcase // case(mx_opa_inv)
   end
    
    //Mux to select Operand B
always@(*) begin
    casex(ctrl_i`ALU_OPB)
      2'b00: opb_sig=opb_i;
      2'b01: opb_sig=0;
      2'b1x: opb_sig=opb_i;
    endcase
end
    
    //Mux to select Carry for adder
always@* begin
   case(mx_ci)
     2'b00: cin_sig = 0;
     2'b01: cin_sig = 1;
     2'b10: cin_sig = flags_reg[`ALU_FLAG_AC];
     default: begin
	cin_sig=0;
	if(defined_but_illegal(mx_ci,2,"mx_ci")) begin
	   $stop;
	end
     end 
   endcase // case(mx_ci_o)
end
    
always@* begin
    case (mx_minmax)
      1'b0: mxmn_sig=opa_i;
      1'b1: mxmn_sig=opb_i;
    endcase
end

   reg sat_carry;
   
    //Check Saturation
always@(*) begin
   sat_carry = 0;
    casex ({ctrl_i`ALU_ABS_SAT,add_neg_overflow,add_pos_overflow})
      3'b000: add_sat_sig=add_sig;
      3'b001: begin
	 add_sat_sig=16'b0111111111111111;
	 sat_carry = 1;
      end
      3'b010: begin
	 add_sat_sig=16'b1000000000000000;
	 sat_carry = 1;
      end
      3'b011: begin
	 add_sat_sig=add_sig;
	 $display("illagal to be here");
	 $stop;
      end
      3'b1xx: begin
	 add_sat_sig=abs_overflow ? 16'h7fff : add_sig;
      end
    endcase
end
    
    //Mux to select the Leading bit to be counted
always@(*) begin
    case (ctrl_i`ALU_LED)
      2'b00: led_cnt_sig=1'b0;
      2'b01: led_cnt_sig=1'b1;
      2'b10: led_cnt_sig=opa_i[15];
      2'b11: led_cnt_sig=flags_reg[`ALU_FLAG_AC];
    endcase
end
    
   // compute leading x
always@(*) begin
   if(led_cnt_sig) begin
      casex(opa_i)
	16'b0xxxxxxxxxxxxxxx: led_sig = 16'd0;
	16'b1111111111111111: led_sig = 16'd16;
	16'b111111111111111x: led_sig = 16'd15;
	16'b11111111111111xx: led_sig = 16'd14;
	16'b1111111111111xxx: led_sig = 16'd13;
	16'b111111111111xxxx: led_sig = 16'd12;
	16'b11111111111xxxxx: led_sig = 16'd11;
	16'b1111111111xxxxxx: led_sig = 16'd10;
	16'b111111111xxxxxxx: led_sig = 16'd9;
	16'b11111111xxxxxxxx: led_sig = 16'd8;
	16'b1111111xxxxxxxxx: led_sig = 16'd7;
	16'b111111xxxxxxxxxx: led_sig = 16'd6;
	16'b11111xxxxxxxxxxx: led_sig = 16'd5;
	16'b1111xxxxxxxxxxxx: led_sig = 16'd4;
	16'b111xxxxxxxxxxxxx: led_sig = 16'd3;
	16'b11xxxxxxxxxxxxxx: led_sig = 16'd2;
	16'b1xxxxxxxxxxxxxxx: led_sig = 16'd1;
      endcase // casex(opa_i)
   end
   else begin	  
      casex(opa_i)
	16'b1xxxxxxxxxxxxxxx: led_sig = 16'd0;
	16'b0000000000000000: led_sig = 16'd16;
	16'b000000000000000x: led_sig = 16'd15;
	16'b00000000000000xx: led_sig = 16'd14;
	16'b0000000000000xxx: led_sig = 16'd13;
	16'b000000000000xxxx: led_sig = 16'd12;
	16'b00000000000xxxxx: led_sig = 16'd11;
	16'b0000000000xxxxxx: led_sig = 16'd10;
	16'b000000000xxxxxxx: led_sig = 16'd9;
	16'b00000000xxxxxxxx: led_sig = 16'd8;
	16'b0000000xxxxxxxxx: led_sig = 16'd7;
	16'b000000xxxxxxxxxx: led_sig = 16'd6;
	16'b00000xxxxxxxxxxx: led_sig = 16'd5;
	16'b0000xxxxxxxxxxxx: led_sig = 16'd4;
	16'b000xxxxxxxxxxxxx: led_sig = 16'd3;
	16'b00xxxxxxxxxxxxxx: led_sig = 16'd2;
	16'b0xxxxxxxxxxxxxxx: led_sig = 16'd1;
      endcase // casex(opa_i)
   end // else: !if(led_cnt_sig)
end // always@ (*)
   
    
    //Mux and logic to select the logic operation
always@(*) begin
    case (ctrl_i`ALU_LOGIC)
      2'b00: logic_sig=opa_i & opb_i; 
      2'b01: logic_sig=opa_i | opb_i;
      2'b10: logic_sig=opa_i ^ opb_i;
      default: begin
	 logic_sig=0;
	 if(defined_but_illegal(ctrl_i`ALU_LOGIC,2,"ctrl_i`ALU_LOGIC")) begin
	    $stop;
	 end
      end
    endcase
end

   wire signed [17:0] shift_vector;
   reg right_shift_carry;
   
   assign shift_vector = {opa_i[15], opa_i, 1'b0};
   
    // Mux and logic for selecting shift type
always@(*) begin
   right_shift_carry = 0;
    case (ctrl_i`ALU_SHIFT)
      //arithmetic right shift
      3'b000: begin
	 {shift_sig,right_shift_carry} = shift_vector >>> opb_i[4:0];
      end

      // logical right shift         
      3'b010: begin
	 {shift_sig,right_shift_carry} = {1'b0, opa_i, 1'b0} >> opb_i[4:0];
      end

      3'b001:  // arithmetic left shift
      begin
	 shift_sig = {1'b0, opa_i} << opb_i[4:0];
      end


      3'b011: // logical left shift
      begin
	 shift_sig = {1'b0, opa_i} << opb_i[4:0];
      end
      
      3'b100: // right rotation without carry
	begin
	   shift_sig[16] = 0;
         case(opb_i[3:0])
             0: shift_sig[15:0]=opa_i;
             1: shift_sig[15:0]={opa_i[0],opa_i[15:1]};
             2: shift_sig[15:0]={opa_i[1:0],opa_i[15:2]};
             3: shift_sig[15:0]={opa_i[2:0],opa_i[15:3]};
             4: shift_sig[15:0]={opa_i[3:0],opa_i[15:4]};
             5: shift_sig[15:0]={opa_i[4:0],opa_i[15:5]};
             6: shift_sig[15:0]={opa_i[5:0],opa_i[15:6]};
             7: shift_sig[15:0]={opa_i[6:0],opa_i[15:7]};
             8: shift_sig[15:0]={opa_i[7:0],opa_i[15:8]};
             9: shift_sig[15:0]={opa_i[8:0],opa_i[15:9]};
            10: shift_sig[15:0]={opa_i[9:0],opa_i[15:10]};
            11: shift_sig[15:0]={opa_i[10:0],opa_i[15:11]};
            12: shift_sig[15:0]={opa_i[11:0],opa_i[15:12]};
            13: shift_sig[15:0]={opa_i[12:0],opa_i[15:13]};
            14: shift_sig[15:0]={opa_i[13:0],opa_i[15:14]};
            15: shift_sig[15:0]={opa_i[14:0],opa_i[15]};
        endcase
      end  

      // left rotation without carry
      3'b101: begin
	 shift_sig[16] = 0;
         case(opb_i[3:0])
             0: shift_sig[15:0]=opa_i;
             1: shift_sig[15:0]={opa_i[14:0],opa_i[15]};
             2: shift_sig[15:0]={opa_i[13:0],opa_i[15:14]};
             3: shift_sig[15:0]={opa_i[12:0],opa_i[15:13]};
             4: shift_sig[15:0]={opa_i[11:0],opa_i[15:12]};
             5: shift_sig[15:0]={opa_i[10:0],opa_i[15:11]};
             6: shift_sig[15:0]={opa_i[9:0],opa_i[15:10]};
             7: shift_sig[15:0]={opa_i[8:0],opa_i[15:9]};
             8: shift_sig[15:0]={opa_i[7:0],opa_i[15:8]};
             9: shift_sig[15:0]={opa_i[6:0],opa_i[15:7]};
            10: shift_sig[15:0]={opa_i[5:0],opa_i[15:6]};
            11: shift_sig[15:0]={opa_i[4:0],opa_i[15:5]};
            12: shift_sig[15:0]={opa_i[3:0],opa_i[15:4]};
            13: shift_sig[15:0]={opa_i[2:0],opa_i[15:3]};
            14: shift_sig[15:0]={opa_i[1:0],opa_i[15:2]};
            15: shift_sig[15:0]={opa_i[0],opa_i[15:1]};
        endcase
      end 

      //right rotation with carry
      3'b110: begin
         case(opb_i[4:0])
             0: shift_sig={flags_reg[`ALU_FLAG_AC],opa_i};
             1: shift_sig={opa_i[0],flags_reg[`ALU_FLAG_AC],opa_i[15:1]};
             2: shift_sig={opa_i[1:0],flags_reg[`ALU_FLAG_AC],opa_i[15:2]};
             3: shift_sig={opa_i[2:0],flags_reg[`ALU_FLAG_AC],opa_i[15:3]};
             4: shift_sig={opa_i[3:0],flags_reg[`ALU_FLAG_AC],opa_i[15:4]};
             5: shift_sig={opa_i[4:0],flags_reg[`ALU_FLAG_AC],opa_i[15:5]};
             6: shift_sig={opa_i[5:0],flags_reg[`ALU_FLAG_AC],opa_i[15:6]};
             7: shift_sig={opa_i[6:0],flags_reg[`ALU_FLAG_AC],opa_i[15:7]};
             8: shift_sig={opa_i[7:0],flags_reg[`ALU_FLAG_AC],opa_i[15:8]};
             9: shift_sig={opa_i[8:0],flags_reg[`ALU_FLAG_AC],opa_i[15:9]};
            10: shift_sig={opa_i[9:0],flags_reg[`ALU_FLAG_AC],opa_i[15:10]};
            11: shift_sig={opa_i[10:0],flags_reg[`ALU_FLAG_AC],opa_i[15:11]};
            12: shift_sig={opa_i[11:0],flags_reg[`ALU_FLAG_AC],opa_i[15:12]};
            13: shift_sig={opa_i[12:0],flags_reg[`ALU_FLAG_AC],opa_i[15:13]};
            14: shift_sig={opa_i[13:0],flags_reg[`ALU_FLAG_AC],opa_i[15:14]};
            15: shift_sig={opa_i[14:0],flags_reg[`ALU_FLAG_AC],opa_i[15]};
            16: shift_sig={opa_i[15:0],flags_reg[`ALU_FLAG_AC]};
	   default: begin
              shift_sig={opa_i[15:0],flags_reg[`ALU_FLAG_AC]};
	      $display("Warning: undefined value (%h) used for right rotation with carry on opa_i[4:0] in %m", opa_i[4:0]);
	   end
         endcase
      end  
      
      3'b111: // left rotation with carry
      begin
         case(opb_i[4:0])
              0: shift_sig={flags_reg[`ALU_FLAG_AC],opa_i[15:0]};
              1: shift_sig={opa_i[15:0],flags_reg[`ALU_FLAG_AC]};
              2: shift_sig={opa_i[14:0],flags_reg[`ALU_FLAG_AC],opa_i[15]};
              3: shift_sig={opa_i[13:0],flags_reg[`ALU_FLAG_AC],opa_i[15:14]};
              4: shift_sig={opa_i[12:0],flags_reg[`ALU_FLAG_AC],opa_i[15:13]};
              5: shift_sig={opa_i[11:0],flags_reg[`ALU_FLAG_AC],opa_i[15:12]};
              6: shift_sig={opa_i[10:0],flags_reg[`ALU_FLAG_AC],opa_i[15:11]};
              7: shift_sig={opa_i[9:0],flags_reg[`ALU_FLAG_AC],opa_i[15:10]};
              8: shift_sig={opa_i[8:0],flags_reg[`ALU_FLAG_AC],opa_i[15:9]};           
              9: shift_sig={opa_i[7:0],flags_reg[`ALU_FLAG_AC],opa_i[15:8]};
             10: shift_sig={opa_i[6:0],flags_reg[`ALU_FLAG_AC],opa_i[15:7]};
             11: shift_sig={opa_i[5:0],flags_reg[`ALU_FLAG_AC],opa_i[15:6]};
             12: shift_sig={opa_i[4:0],flags_reg[`ALU_FLAG_AC],opa_i[15:5]};
             13: shift_sig={opa_i[3:0],flags_reg[`ALU_FLAG_AC],opa_i[15:4]};
             14: shift_sig={opa_i[2:0],flags_reg[`ALU_FLAG_AC],opa_i[15:3]};
             15: shift_sig={opa_i[1:0],flags_reg[`ALU_FLAG_AC],opa_i[15:2]};
             16: shift_sig={opa_i[0],flags_reg[`ALU_FLAG_AC],opa_i[15:1]};
	   default: begin
              shift_sig=0;
	      $display("Warning: undefined value (%h) used for left rotation with carry on opa_i[4:0] in %m", opa_i[4:0]);
	   end
	 endcase
      end  
    endcase
end

   reg [nat_w-1:0] result;
 
    // Mux for selecting the output operation
   always@* begin
    case (ctrl_i`ALU_OUT)
      3'b000: result=led_sig;
      3'b001: result=shift_sig[15:0];
      3'b010: result=logic_sig;
      3'b011: result=mxmn_sig;
      3'b100: result=add_sig;
      3'b101: result=add_sat_sig;
      3'b110: result={8'b0,                //Reserved
			aox_flag_sig[7], //MV
			aox_flag_sig[6], //MS
			aox_flag_sig[5], //MN
			aox_flag_sig[4], //MZ
			flags_reg[`ALU_FLAG_AV],
			flags_reg[`ALU_FLAG_AC],
			flags_reg[`ALU_FLAG_AN],
			flags_reg[`ALU_FLAG_AZ]};
      default: begin
	 result=add_sat_sig;
	 if(defined_but_illegal(ctrl_i`ALU_OUT,3,"ctrl_i`ALU_OUT")) begin
	    $stop;
	 end
      end
    endcase    
end

   always @(*) begin
      result_unr_o = result;
   end

   always@(posedge clk_i) begin
      result_o <= result;
   end
   // and or xor flags 
always@(*) begin
   case (ctrl_i`ALU_AOX) 
       2'b00: 
       begin
       aox_flag_sig[0] = flags_reg[`ALU_FLAG_AZ] & opa_i[0];
       aox_flag_sig[1] = flags_reg[`ALU_FLAG_AN] & opa_i[1];
       aox_flag_sig[2] = flags_reg[`ALU_FLAG_AC] & opa_i[2];
       aox_flag_sig[3] = flags_reg[`ALU_FLAG_AV] & opa_i[3];
       aox_flag_sig[4] = mac_flags_i[`MAC_FLAG_MZ] & opa_i[4];
       aox_flag_sig[5] = mac_flags_i[`MAC_FLAG_MN] & opa_i[5];
       aox_flag_sig[6] = mac_flags_i[`MAC_FLAG_MS] & opa_i[6];
       aox_flag_sig[7] = mac_flags_i[`MAC_FLAG_MV] & opa_i[7];
       end
       2'b10: 
       begin
       aox_flag_sig[0] = flags_reg[`ALU_FLAG_AZ] ^ opa_i[0];
       aox_flag_sig[1] = flags_reg[`ALU_FLAG_AN] ^ opa_i[1];
       aox_flag_sig[2] = flags_reg[`ALU_FLAG_AC] ^ opa_i[2];
       aox_flag_sig[3] = flags_reg[`ALU_FLAG_AV] ^ opa_i[3];
       aox_flag_sig[4] = mac_flags_i[`MAC_FLAG_MZ] ^ opa_i[4];
       aox_flag_sig[5] = mac_flags_i[`MAC_FLAG_MN] ^ opa_i[5];
       aox_flag_sig[6] = mac_flags_i[`MAC_FLAG_MS] ^ opa_i[6];
       aox_flag_sig[7] = mac_flags_i[`MAC_FLAG_MV] ^ opa_i[7];
       end
       2'b01: 
       begin
       aox_flag_sig[0] = flags_reg[`ALU_FLAG_AZ] | opa_i[0];
       aox_flag_sig[1] = flags_reg[`ALU_FLAG_AN] | opa_i[1];
       aox_flag_sig[2] = flags_reg[`ALU_FLAG_AC] | opa_i[2];
       aox_flag_sig[3] = flags_reg[`ALU_FLAG_AV] | opa_i[3];
       aox_flag_sig[4] = mac_flags_i[`MAC_FLAG_MZ] | opa_i[4];
       aox_flag_sig[5] = mac_flags_i[`MAC_FLAG_MN] | opa_i[5];
       aox_flag_sig[6] = mac_flags_i[`MAC_FLAG_MS] | opa_i[6];
       aox_flag_sig[7] = mac_flags_i[`MAC_FLAG_MV] | opa_i[7];
       end
     default: begin
	aox_flag_sig = 0;
	if(defined_but_illegal(ctrl_i`ALU_AOX,2,"ctrl_i`ALU_AOX")) begin
	   $stop;
	end
     end
   endcase
end
   
   // zero flag    
always@(*) begin
   case (ctrl_i`ALU_AZ)
     2'b01: flags_sig[`ALU_FLAG_AZ]=~(|result);
     2'b10: flags_sig[`ALU_FLAG_AZ]=aox_flag_sig[0];
     default: flags_sig[`ALU_FLAG_AZ]=flags_reg[`ALU_FLAG_AZ];
   endcase
end
   
   // negative flag    
always@(*) begin
    case (ctrl_i`ALU_AN)
        2'b01: flags_sig[`ALU_FLAG_AN]=result[15];
        2'b10: flags_sig[`ALU_FLAG_AN]=aox_flag_sig[1];
        default: flags_sig[`ALU_FLAG_AN]=flags_reg[`ALU_FLAG_AN];
   endcase
end
   
   // saturate/carry flag    
always@(*) begin
    case (ctrl_i`ALU_AC)
      3'b000: flags_sig[`ALU_FLAG_AC]=flags_reg[`ALU_FLAG_AC];
        3'b001: begin 
	   flags_sig[`ALU_FLAG_AC]=opa_i[15];
	   $stop; 
	end
        3'b010: begin
	   case(ctrl_i`ALU_SHIFT)
	     3'b000: flags_sig[`ALU_FLAG_AC]=right_shift_carry;
	     3'b001: flags_sig[`ALU_FLAG_AC]=shift_sig[16];
	     3'b010: flags_sig[`ALU_FLAG_AC]=right_shift_carry;
	     3'b011: flags_sig[`ALU_FLAG_AC]=shift_sig[16];
	     3'b100: flags_sig[`ALU_FLAG_AC]=shift_sig[15];
	     3'b101: flags_sig[`ALU_FLAG_AC]=shift_sig[0]; 
	     3'b110: flags_sig[`ALU_FLAG_AC]=shift_sig[16];
	     3'b111: flags_sig[`ALU_FLAG_AC]=shift_sig[16];
	   endcase // casex(ctrl_i`ALU_shift)
	end
        3'b011: flags_sig[`ALU_FLAG_AC]=add_carry;
        3'b100: flags_sig[`ALU_FLAG_AC]=aox_flag_sig[2];
        3'b101: flags_sig[`ALU_FLAG_AC]=add_carry;
        3'b110: flags_sig[`ALU_FLAG_AC]=sat_carry;
      3'b111: flags_sig[`ALU_FLAG_AC]=0; 
   endcase
end
   
   //overflow flag
always@(*) begin
   case (ctrl_i`ALU_AV)
     2'b00: flags_sig[`ALU_FLAG_AV]=flags_reg[`ALU_FLAG_AV];
     2'b01: flags_sig[`ALU_FLAG_AV]=add_pos_overflow | add_neg_overflow ;
     
     
     2'b10: flags_sig[`ALU_FLAG_AV]=aox_flag_sig[3];
     2'b11: flags_sig[`ALU_FLAG_AV]=0;
     default: begin
	flags_sig[`ALU_FLAG_AV]=flags_reg[`ALU_FLAG_AV];
	if(defined_but_illegal(ctrl_i`ALU_AV,2,"ctrl_i`ALU_AV")) begin
	   $stop;
	end
     end
   endcase
end

   reg spr_write_flags;
   reg [spr_dat_w-1:`MAC_NUM_FLAGS+`ALU_NUM_FLAGS] spr_fl0_extra_store; 

   always@* begin
      spr_dat_o = 0;
      case(spr_adr_i)
	(`SPR_CP_GROUP+`SPR_STATUS_FLAGS): begin
	   spr_write_flags = spr_wren_i;
	   spr_dat_o = {spr_fl0_extra_store,`MAC_NUM_FLAGS'b0,flags_reg};
	end
	default: spr_write_flags = 0;
      endcase // case(spr_adr_i)
   end

   
// register flags
always @(posedge clk_i) begin
   if (!reset_i) begin
      flags_reg<=0;
      spr_fl0_extra_store <= 0;
   end
   else begin
      if (spr_write_flags) begin
	 spr_fl0_extra_store <= spr_dat_i[spr_dat_w-1:`MAC_NUM_FLAGS+`ALU_NUM_FLAGS];
	 flags_reg <= spr_dat_i[3:0];
      end
      else if (condition_check_i) begin
         flags_reg<=flags_sig;
      end
   end // else: !if(!reset_i)
end // always @ (posedge clk_i)

   
   
endmodule
