`include "senior_defines.vh"

module dff
#(parameter dat_w = `SENIOR_NATIVE_WIDTH)
(
input wire clk_i,
input wire reset_i,
input wire [dat_w-1:0] dat_i,
output reg [dat_w-1:0] clocked_dat_o
);

always @(posedge clk_i) begin
    if (!reset_i) begin
       clocked_dat_o<=0;
    end
    else begin
       clocked_dat_o<=dat_i;
    end
end

endmodule