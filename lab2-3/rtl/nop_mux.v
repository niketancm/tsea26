module nop_mux(
input wire pfc_inst_nop_i,
input wire [31:0] pm_inst_bus_i,
output wire [31:0] pm_inst_bus_o
);


assign pm_inst_bus_o=(!pfc_inst_nop_i)?pm_inst_bus_i:32'b10000001000000000000000000000000;
endmodule
