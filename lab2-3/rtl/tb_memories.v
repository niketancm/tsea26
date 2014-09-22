module tb_memories
(
 input wire clk_i,
 input wire reset_i,
    input wire [15:0] xpm_addr_i,
    output reg [31:0] xpm_data_o,

    input wire [15:0] xdm0_addr_i,
    input wire [15:0] xdm0_data_i,
    input wire xdm0_wr_en_i,
    output reg [15:0] xdm0_data_o,

    input wire [15:0] xdm1_addr_i,
    input wire [15:0] xdm1_data_i,
    input wire xdm1_wr_en_i,
    output reg [15:0] xdm1_data_o
);

   integer file;
   integer count;
   

   reg [0:79*8-1] line;
   integer 	  finished;

   integer 	  writeprogrammem;

   integer 	  programmemoffset;
   integer 	  dm0offset;
   integer 	  lineno;
   integer 	  i;
   
   
   reg [31:0] 	  val;
   reg [31:0] 	  xpm_data;

   // The memories
   reg [31:0] 	  program_mem [0:65535];
   reg [15:0] 	  data_mem0 [0:65535];
   reg [15:0] 	  data_mem1 [0:65535];

   reg [15:0] 	  xdm0_addr_ff;
   reg [15:0] 	  xdm1_addr_ff;
   reg [15:0] 	  xpm_addr_ff;

   always@(posedge clk_i) begin
      if(!reset_i) begin
	 xpm_addr_ff <= 0;
      end
      else begin
	 xdm0_addr_ff <= xdm0_addr_i;
	 xdm1_addr_ff <= xdm1_addr_i;
	 xpm_addr_ff <= xpm_addr_i;
      end
   end
   
   always @* begin
//      if(reset_i == 1'b1) 
      xpm_data = program_mem[xpm_addr_ff];
/* -----\/----- EXCLUDED -----\/-----
      else
	xpm_data_o <= {32{1'bx}};
 -----/\----- EXCLUDED -----/\----- */
   end

   always @(posedge clk_i) begin
//      if(reset_i == 1'b1) 
      xpm_data_o <= xpm_data;
/* -----\/----- EXCLUDED -----\/-----
      else
	xpm_data_o <= {32{1'bx}};
 -----/\----- EXCLUDED -----/\----- */
   end

   always @(posedge clk_i) begin
      if(xdm0_wr_en_i) begin
	 data_mem0[xdm0_addr_i] <= xdm0_data_i;
      end
   end

   always @(posedge clk_i) begin
      xdm0_data_o=data_mem0[xdm0_addr_ff];
   end

   always @(posedge clk_i) begin
      if(xdm1_wr_en_i) begin
	 data_mem1[xdm1_addr_i] <= xdm1_data_i;
      end
   end

   always @(posedge clk_i)  begin
      xdm1_data_o=data_mem1[xdm1_addr_ff];
   end
   
   

   
   initial begin
      file = $fopen("test.hex","r");
      finished = 0;
      writeprogrammem = 0;
      programmemoffset = 0;
      dm0offset = 0;
      lineno = 0;

      for(i=0; i < 65536;i = i + 1) begin
	 program_mem[i] = 32'h0;
	 data_mem0[i] = 16'h0;
	 data_mem1[i] = 16'h0;
      end
      
      while(!finished) begin
	 lineno = lineno+1;

	 count = $fgets(line,file);
	 if(count == 0) begin
	    finished = 1;

	 end else begin
	    line = line << (79 - count) * 8;

	    if(line[0:7] == ";") begin
	       // skip comments
	    end else if(line[0:4*8-1] == "code") begin
	       writeprogrammem = 1;
	    end else if(line[0:4*8-1] == "rom0") begin
	       writeprogrammem = 0;
	    end else if(line[0:9*8-1] == "org 32768") begin
	       dm0offset = 16'd32768;
	    end else if($sscanf(line,"%08x",val) == 1) begin
	       if(writeprogrammem) begin
		  program_mem[programmemoffset] = val;
		  programmemoffset = programmemoffset + 1;
	       end else begin
		  data_mem0[dm0offset] = val[15:0];
		  dm0offset = dm0offset + 1;
	       end
	    end else begin
	       $display("%m: Error at line %d, could not understand \"%s\"",lineno,line);
	       $stop;
	    end
	 end // else: !if(count == 0)
      end // while (!finished)
   end // initial begin



endmodule // test
