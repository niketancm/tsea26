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

adder_logic:process(function_i,opa_sign_i)
  begin
--ADD instruction
    I1: if(function_i= "000") then
      mx_opa_inv_o <= '0';
      mx_ci_o <= "00";
--ADDC instructionruction
      elsif(function_i = "001") then
        mx_opa_inv_o <= '0';
        mx_ci_o <= "10";
--SUB instruction
      elsif(function_i= "010") then
        mx_opa_inv_o <= '1';
        mx_ci_o <= "01";
--SUBC instruction
        elsif(function_i = "011") then
          mx_opa_inv_o <= '1';
          mx_ci_o <= "10";
--CMP instruction
          elsif(function_i = "101") then
            mx_opa_inv_o <= '1';
            mx_ci_o <= "01";            
--ABS instruction
        elsif(function_i= "100") then
          if(opa_sign_i = '0') then
            mx_opa_inv_o <= '0';
            mx_ci_o <= "00";
          elsif(opa_sign_i= '1') then
            mx_opa_inv_o <= '1';
            mx_ci_o <= "01";
          end if;
--MAX instruciton
        elsif(function_i= "110") then
          mx_opa_inv_o <= '1';
          mx_ci_o <= "01";
--MIN instruciton
        elsif(function_i= "111") then
          mx_opa_inv_o <= '1';
          mx_ci_o <= "01";        
        end if I1;
      end process adder_logic;
end adder_ctrl_rtl;
