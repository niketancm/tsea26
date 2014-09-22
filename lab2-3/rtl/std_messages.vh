parameter strLen_tp = 64;

function write_nol_ws;
      input [8*strLen_tp:1] inString;
      integer 	i;
      reg [7:0] char;
      integer write_rest;
      begin
	 write_rest = 0;
	 for(i = strLen_tp; i>=1; i = i-1) begin
	    char[7] = inString[i*8-0];
	    char[6] = inString[i*8-1];
	    char[5] = inString[i*8-2];
	    char[4] = inString[i*8-3];
	    char[3] = inString[i*8-4];
	    char[2] = inString[i*8-5];
	    char[1] = inString[i*8-6];
	    char[0] = inString[i*8-7];
	    if((char != 0) || write_rest) begin
	       $write("%s",char);
	       write_rest = 1;
	    end
	 end // for (i = strLen; i>=1; i = i-1)
      write_nol_ws = 0;
      end
endfunction // write_nol_ws

function write_num_bits;
      input [7:0] num_bits;
      input [40:0] theVal;
      integer i;
      begin
	 for(i = 40;i>=0;i=i-1) begin
	    if(i < num_bits) begin
	       $write("%b",theVal[i]);
	    end
	 end
      write_num_bits = 0;
      end
endfunction // write_num_bits

function error_illegal_val;
      input [40:0] illegal_signal;
      input [7:0] illegal_num_bits;
      input [8*strLen_tp:1] illegal_name;
      reg dummy;
      begin
	 $write("Error:%m: Illegal value [");
	 dummy = write_nol_ws(illegal_name);
	 $write("=");
	 dummy = write_num_bits(illegal_num_bits,illegal_signal);
	 $write("]\n");
      error_illegal_val = 0;
      end
endfunction // error_illegal_val

function defined_but_illegal;
      input [40:0] data;
      input [7:0] num_bits;
      input [8*strLen_tp:1] name;
      reg dummy;
      begin
	 if((^data) !== 1'bx) begin
	    dummy = error_illegal_val(data,num_bits,name);
	    defined_but_illegal = 1;
	 end
	 else begin
	    defined_but_illegal = 0;
	 end
      end
endfunction // defined_but_illegal


