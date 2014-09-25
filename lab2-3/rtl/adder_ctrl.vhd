library ieee;
use ieee.std_logic_1164.all;

entity adder_ctrl is
  port (
    function_i   : in  std_logic_vector(2 downto 0);
    opa_sign_i   : in  std_logic;
    mx_opa_inv_o : out std_logic;
    mx_ci_o      : out std_logic_vector(1 downto 0));
end adder_ctrl;

architecture adder_ctrl_rtl of adder_ctrl is
begin  -- adder_ctrl_rtl

  -- Remove the following lines and put your code here
  mx_opa_inv_o <= '0';
  mx_ci_o <= "00";

end adder_ctrl_rtl;
