`include "senior_defines.vh"

module io_read
  #(parameter nat_w = `SENIOR_NATIVE_WIDTH,
   parameter [255*8-1:0] FILENAME = "RTLin.hex")
(
input wire clk_i,
input wire reset_i,
input wire id_io_rd_en_i,
output wire [nat_w-1:0] io_rd_data_o
);

//local declarations
integer file, r;
reg [nat_w-1:0] in_data;


initial
begin
   file=$fopen(FILENAME, "r");
   // Read the first value from the file immediately   
   r=$fscanf(file, "%x", in_data);
end

assign io_rd_data_o=in_data;

//read from file
always @(posedge clk_i)
begin
    if (reset_i==1'b1)
    begin
        if (id_io_rd_en_i==1'b1)
        begin
            if (r==1) r=$fscanf(file, "%x", in_data);
        end    
    end
end
endmodule