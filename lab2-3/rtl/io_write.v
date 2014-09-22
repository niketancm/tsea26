`include "senior_defines.vh"

module io_write
#(parameter nat_w = `SENIOR_NATIVE_WIDTH,
  parameter [255*8-1:0] FILENAME = "RTL.hex")
(
input wire clk_i,
input wire reset_i,
input wire id_io_wr_en_i,
input wire [nat_w-1:0] io_wr_data_i
);

   
//local declarations
integer file;

initial
begin
    file=$fopen(FILENAME, "w");
    $fclose(file);
end

//append to file 
always @(posedge clk_i)
begin
    if (reset_i==1'b1)
    begin
        if (id_io_wr_en_i==1'b1)
        begin
            file=$fopen("rtloutput.hex", "a");
            $fdisplay(file, "%x", io_wr_data_i);
            $fclose(file);        
        end    
    end
    else 
    begin
        file=$fopen("rtloutput.hex", "w");
        $fclose(file);
    end
end
endmodule