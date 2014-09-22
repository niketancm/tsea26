module reset_gen(
output wire reset_o
);

reg reset_sig;

assign reset_o=reset_sig;

initial
reset_sig=1'b0;

always
begin
    #220 reset_sig= 1'b1;
end
endmodule