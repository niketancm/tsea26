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
  
  -- Remove the following line and put your code here
  mx_minmax_o <= '0';

end min_max_ctrl_rtl;
