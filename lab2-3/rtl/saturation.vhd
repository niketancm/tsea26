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
sat_logic:process(do_sat_i,value_i)
  begin
    L1:if(do_sat_i = '0') then
      value_o <= value_i;
      did_sat_o <= '0';
    else
      L2:if(value_i(31) = value_i(39)) then
        value_o <= value_i;
        did_sat_o <= '0';
        else                            --Overflow has occured, saturate.
          L3:if(value_i(39) = '1') then     --Saturate to max -ve value.
            value_o <= x"ff80000000";
            did_sat_o <= '1';
          elsif(value_i(39) = '0') then     --Saturate to Max +ve Value.
            value_o <= x"007FFFFFFF";
            did_sat_o <= '1';
        end if L3;
      end if L2;
    end if L1;
end process sat_logic;
end saturation_rtl;
