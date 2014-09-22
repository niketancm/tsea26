module clk_gen(
output wire clk_o
);
reg clk_sig;

assign clk_o=clk_sig;

initial
clk_sig=1'b1;

always
begin
    #50 clk_sig= 1'b0;
    #50 clk_sig= 1'b1;
end
endmodule