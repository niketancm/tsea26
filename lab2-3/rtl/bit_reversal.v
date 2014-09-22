module bit_reversal
  #(parameter dat_w=5)
    (
     input wire [dat_w-1:0] dat_i,
     input wire [2:0] bitrev,
     output reg [dat_w-1:0] dat_o);

   integer  i;
   
   always@* begin
      dat_o = dat_i;

      //Always keep LSB
      casex(bitrev)
	3'b000: //Reverse 6 bits (keep LSB)
	  for(i=1;i<7;i=i+1)
	     dat_o[i] = dat_i[7-i];
	
	3'b001: //Reverse 7 bits (keep LSB)
	  for(i=1;i<8;i=i+1)
	     dat_o[i] = dat_i[8-i];
	
	3'b010: //Reverse 8 bits (keep LSB)
	  for(i=1;i<9;i=i+1)
	     dat_o[i] = dat_i[9-i];

	3'b011: //Reverse 9 bits (keep LSB)
	  for(i=1;i<10;i=i+1)
	     dat_o[i] = dat_i[10-i];

	3'b100: //Reverse 10 bits (keep LSB)
	  for(i=1;i<11;i=i+1)
	     dat_o[i] = dat_i[11-i];

	3'b101: //Reverse 11 bits (keep LSB)
	  for(i=1;i<12;i=i+1)
	     dat_o[i] = dat_i[12-i];
	
	3'b110: //Reverse 12 bits (keep LSB)
	  for(i=1;i<13;i=i+1)
	     dat_o[i] = dat_i[13-i];

	3'b111: //Reverse 13 bits (keep LSB)
	  for(i=1;i<14;i=i+1)
	     dat_o[i] = dat_i[14-i];
      endcase
   end
endmodule // bit_reversal
