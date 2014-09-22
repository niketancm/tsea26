library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pc_fsm is
  port
    (
      clk_i, reset_i:    in std_logic;
      jump_decision_i:    in std_logic; 
      lc_pfc_loop_flag_i: in std_logic; 
      lc_pfc_loope_i:     in std_logic_vector(15 downto 0);
      ctrl_i:             in std_logic_vector(5 downto 0);
      interrupt:          in std_logic; 
      pc_addr_bus_i:      in std_logic_vector(15 downto 0);

      pfc_pc_add_opa_sel_o:  out std_logic;
      pfc_lc_loopn_sel_o:    out std_logic;
      pfc_pc_sel_o:          out std_logic_vector(2 downto 0);
      pfc_inst_nop_o:        out std_logic);
end pc_fsm;

architecture pc_fsm_rtl of pc_fsm is

  signal ctrl_c1              : std_logic_vector(5 downto 0);
  signal ctrl_c2              : std_logic_vector(5 downto 0);
  signal ctrl_c3              : std_logic_vector(5 downto 0);
  signal s0_state_sel         : std_logic_vector (2 downto 0);
  signal jump_case_sel        : std_logic_vector (1 downto 0);
  signal ctrl_i_PFC_JUMP             : std_logic;
  signal ctrl_c2_PFC_RET             : std_logic;
  signal ctrl_i_PFC_DELAY_SLOT       : std_logic_vector (1 downto 0);

  type StateType is (s0,s1,s3,s4,s5,s6,s7,s8,s9,s10,s13);
  signal next_state           : StateType;
  signal state                : StateType;

begin

  ctrl_i_PFC_DELAY_SLOT <= ctrl_i(4 downto 3);
  ctrl_i_PFC_JUMP <= ctrl_i(2);
  ctrl_c2_PFC_RET <= ctrl_c2(1);
  
--  register generation logic
  process (clk_i)
  begin
    if clk_i'event and clk_i = '1' then
      if  ( reset_i = '0' ) then
        state <= s0 ;
      else
        ctrl_c1 <= ctrl_i ;
        ctrl_c2 <= ctrl_c1 ;
        ctrl_c3 <= ctrl_c2 ;
        state <= next_state ;
      end if;
    end if;
  end process;

--  next state logic

  s0_state_sel <=  ctrl_i_PFC_JUMP & ctrl_i_PFC_DELAY_SLOT;
  
  process (s0_state_sel, state, ctrl_i)
  begin
    next_state <= s0 ;
    case  state  is
      when s0 =>
        case s0_state_sel is
          when "100" =>
            next_state <= s0; -- What is the next state?
          when "101" =>
            next_state <= s0; -- What is the next state?
          when "110" =>
            next_state <= s0; -- What is the next state?
          when "111" =>
            next_state <= s0; 
          when others =>
            next_state <= s0;
        end case;
      when s1 =>
        next_state <= s7 ;
      when s3 =>
        next_state <= s6 ;
      when s4 =>
        next_state <= s8 ;
      when s5 =>
        next_state <= s8 ;
      when s6 =>
        next_state <= s10 ;
      when s7 =>
        next_state <= s9 ;
      when s8 =>
        next_state <= s10 ;
      when s9 =>
        next_state <= s0 ; -- What is the next state?
      when s10 =>
        next_state <= s0 ; -- What is the next state?
      when s13 =>
        next_state <= s0 ;
      when others =>
        next_state <= s0;
    end case;
  end process;

--  output logic

  jump_case_sel <= ctrl_c2_PFC_RET & jump_decision_i;
  
  process (state, jump_case_sel, s0_state_sel)
  begin
    pfc_pc_add_opa_sel_o <= '0';  --Default value
    pfc_pc_sel_o<= "001";         --Default value
    pfc_inst_nop_o<='0';	  --Default value
    pfc_lc_loopn_sel_o<='0';   --Default value
    case  state  is
      when s0 =>
        -- Your code here
      when s1 =>
        -- Empty
      when s3 =>
        -- Empty
      when s4 =>
        -- Your code here
      when s5 =>
        -- Your code here
      when s6 =>
        case  jump_case_sel is
          when "10" | "11" =>
            -- Your code here
          when "01" =>
            -- Your code here
          when "00" =>
            -- Your code here
          when others => --Empty
        end case;
      when s7 =>
        case  jump_case_sel is
          when "10" | "11" =>
            -- Your code here
          when "01" =>
            -- Your code here
          when "00" =>
            -- Empty
          when others => --Empty
        end case;
      when s8 =>
        -- Your code here
        case  jump_case_sel is
          when "10" | "11"=>
            -- Your code here
          when "01" =>
            -- Your code here
          when "00" =>
            -- Your code here
          when others => --Empty
        end case;
      when s9 =>
        -- Your code here
      when s10 =>
        -- Your code here
      when s13 =>
        -- Your code here
      when others =>
    end case;
  end process;

--  case: default


end pc_fsm_rtl;
