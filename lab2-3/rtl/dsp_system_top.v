`default_nettype none

module dsp_system_top;

wire clk;
wire reset;
wire [15:0] io_data_out;
wire io_wr_strb;
wire [15:0] io_data_in;
wire [7:0] io_addr_out;
wire io_rd_strb;

wire [15:0] pm_addr;
wire [31:0] pm_data;

wire [15:0] dm0_addr;
wire [15:0] dm0_datai;
wire [15:0] dm0_datao;
wire        dm0_wr_en;

wire [15:0] dm1_addr;
wire [15:0] dm1_datai;
wire [15:0] dm1_datao;
wire        dm1_wr_en;



clk_gen clock_generate(
      .clk_o (clk)
      );    
      
reset_gen reset_generate(
      .reset_o (reset)
      );

   //For debug purposes to keep track of the instructuion in the pipeline
   reg [31:0] pm_data_p1;
   reg [31:0] pm_data_p2;
   reg [31:0] pm_data_p3;
   reg [31:0] pm_data_p4;
   reg [31:0] pm_data_p5;
   reg [31:0] pm_data_p6;
   reg [15:0] pc;

   //For pipeline display in simulation   
   always@* begin
      pm_data_p2 = dsp_core.pm_inst_bus;
      pc = mem.xpm_addr_ff;
      pm_data_p1 = mem.xpm_data;
   end
   
   //For pipeline display in simulation   
   always@(posedge clk) begin
      pm_data_p3 <= pm_data_p2;
      pm_data_p4 <= pm_data_p3;
      pm_data_p5 <= pm_data_p4;
      pm_data_p6 <= pm_data_p5;
   end
      
dsp_core dsp_core(
      .clk_i  (clk),
      .reset_i (reset),
      
      .io_data_o (io_data_out),
      .io_wr_strobe_o (io_wr_strb),
      
      .io_data_i (io_data_in),
      .io_rd_strobe_o (io_rd_strb),
	   .io_addr_o (io_addr_out),


	   .pm_addr_o        (pm_addr),
	   .pm_data_i        (pm_data),

	   .dm0_addr_o		(dm0_addr),
	   .dm0_data_o		(dm0_datao),
	   .dm0_wr_en_o	(dm0_wr_en),
	   .dm0_data_i		(dm0_datai),

	   .dm1_addr_o		(dm1_addr),
	   .dm1_data_o		(dm1_datao),
	   .dm1_wr_en_o	(dm1_wr_en),
	   .dm1_data_i		(dm1_datai)
	
);    

tb_memories mem(
	.clk_i			(clk),
	.reset_i		(reset),

	// Program memory
	.xpm_data_o	(pm_data),
	.xpm_addr_i	(pm_addr),

	// DM0
	.xdm0_data_o	(dm0_datai),
	.xdm0_addr_i	(dm0_addr),
	.xdm0_data_i	(dm0_datao),
	.xdm0_wr_en_i	(dm0_wr_en),
		   
	// DM1
	.xdm1_addr_i	(dm1_addr),
	.xdm1_data_i	(dm1_datao),
	.xdm1_wr_en_i	(dm1_wr_en),
	.xdm1_data_o	(dm1_datai)
);
  

always @(posedge clk) begin
   

      if(io_wr_strb) begin
	 case(io_addr_out)
	   8'b00010001: begin end
	   8'b00010010: begin
	      $display("End of program found");
	      $finish; 
	   end
	   8'b00010011: $stop;
	   8'h21: begin end
	   8'h22: begin end
	   default: $display("Unknown IO write request");
	 endcase // case (io_addr_out)
      end
   end // always @ (posedge clk)


io_write #(.FILENAME("rtloutput.hex"))
  write_out_file(
      .clk_i (clk),
      .reset_i (reset),
      .io_wr_data_i (io_data_out),
      .id_io_wr_en_i (io_wr_strb && (io_addr_out == 8'b00010001))
      );

io_read  #(.FILENAME("IOS0010"))
  read_in_file(
      .clk_i (clk),
      .reset_i (reset),
      .io_rd_data_o (io_data_in),
      .id_io_rd_en_i (io_rd_strb)
      );       

   wire [15:0] refdata;
io_read #(.FILENAME("reffile.hex")) 
  read_ref_file(
      .clk_i (clk),
      .reset_i (reset),
      .io_rd_data_o (refdata),
      .id_io_rd_en_i (io_wr_strb && (io_addr_out == 8'b00010001))
      );

   //Compare reference data with RTL generated data
    always @(posedge clk) begin
       if (io_wr_strb && (io_addr_out == 8'h11)) begin
	  //Comment out the following line for less output
	  $display("Comparing %x and %x",refdata,io_data_out);
	  if(refdata !== io_data_out) begin
	     $display("*** ERROR: reference data does not match output data");
	     //$finish;
	     $stop;
	  end
       end

       if (io_wr_strb && (io_addr_out == 8'h21)) begin
	  $display("Port 0x21: %x",io_data_out);
	  $stop;
       end

       if (io_wr_strb && (io_addr_out == 8'h22)) begin
	  $display("Port 0x22: %x",io_data_out);
       end
    end
   
      

endmodule