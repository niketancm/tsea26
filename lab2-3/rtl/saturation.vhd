library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

                                                                        
entity saturation is
  port (
    value_i   : in  signed(39 downto 0);
    do_sat_i  : in  std_logic;
    value_o   : out signed(39 downto 0);
    did_sat_o : out std_logic);
end saturation;

architecture saturation_rtl of saturation is
begin  -- saturation_rtl

  -- Remove the following lines and put your code here
  value_o <= value_i;
  did_sat_o <= '0';
  
end saturation_rtl;
