library ieee;
use ieee.std_logic_1164.all;

entity min_max_ctrl is
  port (
    function_i  : in  std_logic_vector(2 downto 0);
    opa_sign_i  : in  std_logic;
    opb_sign_i  : in  std_logic;
    carry_i     : in  std_logic;
    mx_minmax_o : out std_logic);
end min_max_ctrl;

architecture min_max_ctrl_rtl of min_max_ctrl is
begin  -- min_max_ctrl_rtl

 min_max_logic:process(function_i,opa_sign_i,opb_sign_i,carry_i)
   begin
 --Max instruction, assuming that the data is unsigned data.
L1: if(function_i = "110") then
  if(carry_i = '0') then --check for carry in
    mx_minmax_o <= '0';
  else
    mx_minmax_o <= '1';
  end if;
--MIN instruction  
    elsif(function_i = "111") then
          if(carry_i = '0') then --check for carry in
          mx_minmax_o <= '1';
        else
          mx_minmax_o <= '0';
        end if;
   end if L1;
 end process;
end min_max_ctrl_rtl;
