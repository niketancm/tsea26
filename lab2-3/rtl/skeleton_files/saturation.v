
module saturation
  (
    input wire [39:0]   value_i,
    input wire 		do_sat_i,
    output wire [39:0] 	value_o,
    output wire 	did_sat_o
   );

   // Remove the following lines and put your code here
   assign 		value_o = value_i;
   assign 		did_sat_o = 0;

endmodule // saturation
