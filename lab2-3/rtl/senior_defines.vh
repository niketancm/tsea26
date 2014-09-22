`ifndef __SENIOR_DEFINES__
 `define __SENIOR_DEFINES__

`default_nettype none

  //General defines
  //Just dont try to change theese since not all widts depend on theses
 `define SENIOR_NATIVE_WIDTH 16
 `define SENIOR_ADDRESS_WIDTH 16
  
  //SPR defined
  `define SPR_DATA_BUS_WIDTH `SENIOR_NATIVE_WIDTH
  `define SPR_ADR_BUS_WIDTH 5

  `define SPR_AGU_GROUP `SPR_ADR_BUS_WIDTH'd0
  `define SPR_CP_GROUP  `SPR_ADR_BUS_WIDTH'd12
  `define SPR_MAC_GROUP `SPR_ADR_BUS_WIDTH'd18

  `define SPR_CTRL_WIDTH (`SPR_ADR_BUS_WIDTH+2)
  `define SPR_SOURCE     [`SPR_ADR_BUS_WIDTH+1]
  `define SPR_WREN     [`SPR_ADR_BUS_WIDTH]
  `define SPR_ADR  [`SPR_ADR_BUS_WIDTH-1:0]

  `define SPR_SOURCE_RF  1
  `define SPR_SOURCE_IMM 0 //Default value

  `define SPR_STATUS_FLAGS 0
  `define SPR_CONTROL_FLAGS 1
  
  //MAC defines
  `define MAC_ACR_BITS 40
  `define MAC_NUM_GUARDS 8
 `define MAC_ACR_GUARDS 39:32
 `define MAC_ACR_HIGH 31:16
 `define MAC_ACR_LOW 15:0

  `define MAC_NUM_FLAGS 4
 `define MAC_FLAG_MV 3 
 `define MAC_FLAG_MS 2 
 `define MAC_FLAG_MN 1
 `define MAC_FLAG_MZ 0

 `define MAC_SPR_ACR10_GUARDS  0
 `define MAC_SPR_ACR32_GUARDS  1

`define MAC_CLR 5'd0
`define MAC_ADD 5'd1
`define MAC_SUB 5'd2
`define MAC_CMP 5'd3
`define MAC_NEG 5'd4
`define MAC_ABS 5'd5
`define MAC_MUL 5'd6
`define MAC_MAC 5'd7
`define MAC_MDM 5'd8

`define MAC_MOVE 5'd9
`define MAC_MOVE_ROUND 5'd10
`define MAC_NOP 5'd11
  
  
 `define MAC_CTRL_WIDTH     51
 `define MAC_OP       [50:47]  
 `define MAC_OUT_RND       [46]
 `define MAC_ABS_SAT       [45]
 `define MAC_OPAMUL         [44]
 `define MAC_OPBMUL         [43]
 `define MAC_REGOP       [42:40]
 `define MAC_OPBADR      [39:37]
 `define MAC_MUX1        [36:34]
 `define MAC_SCALE       [33:31]
 `define MAC_RND            [30]
 `define MAC_INV         [29:28]
 `define MAC_OPAADR      [27:25]
 `define MAC_SAT            [24]
 `define MAC_GACR01      [23:22]
 `define MAC_HACR0          [21]
 `define MAC_LACR0          [20]
 `define MAC_HACR1          [19]
 `define MAC_LACR1          [18]
 `define MAC_GACR23      [17:16]
 `define MAC_HACR2          [15]
 `define MAC_LACR2          [14]
 `define MAC_HACR3          [13]
 `define MAC_LACR3          [12]
 `define MAC_OPASGN         [11]
 `define MAC_OPBSGN         [10]
 `define MAC_GACR01_MUX1     deprecated
 `define MAC_GACR23_MUX1     deprecated
 `define MAC_MZ              [7]
 `define MAC_MZ_MUX1         [6]
 `define MAC_MN              [5]
 `define MAC_MN_MUX1         [4]
 `define MAC_MS              [3]
 `define MAC_MS_MUX1         [2]
 `define MAC_MV              [1]
 `define MAC_MV_MUX1         [0]

//ALU defines
  `define ALU_NUM_FLAGS 4
 `define ALU_FLAG_AV 3 
 `define ALU_FLAG_AC 2 
 `define ALU_FLAG_AN 1
 `define ALU_FLAG_AZ 0

  `define ALU_ORG  [29:0]
  `define ALU_STUD [32:30]

 `define ALU_CTRL_WIDTH 33
 `define ALU_FUNCTION [32:30]
 `define ALU_ABS_SAT [29]
 `define ALU_OPA   [28:27]
 `define ALU_OPB   [26:25]
 `define ALU_CIN   [24:22]
 `define ALU_CMP      [21]
 `define ALU_OUT   [20:18]
 `define ALU_LED   [17:16]
 `define ALU_SHIFT [15:13]
 `define ALU_LOGIC [12:11]
 `define ALU_AOX   [10: 9]
 `define ALU_AZ     [8: 7]
 `define ALU_AN     [6: 5]
 `define ALU_AC     [4: 2]
 `define ALU_AV     [1: 0]

//AGU defines
  //Large address generators (agl.v)
/* -----\/----- EXCLUDED -----\/-----
 `define AGL_SPR_ARX  0
 `define AGL_SPR_BTM  1
 `define AGL_SPR_TOP  2
 `define AGL_SPR_STP  3

 
 `define AGL_CTRL_WIDTH 12
 `define AGL_MODULO     [11]    
 `define AGL_ARG_SEL      deprecated
 `define AGL_ARG_MUX1     "use spr bus and adr"
 `define AGL_BTM           "use spr bus and adr"
 `define AGL_STP           "use spr bus and adr"
 `define AGL_TOP           "use spr bus and adr"
 `define AGL_SPL_MUX     deprecated //Do not use
 `define AGL_OPA         [3:2]
 `define AGL_MODE        [1:0]
 -----/\----- EXCLUDED -----/\----- */

/* -----\/----- EXCLUDED -----\/-----
  //Small address generators (ags.v)
 `define AGS_SPR_AR  0

 `define AGS_CTRL_WIDTH 5    
 `define AGS_ARG_SEL       deprecated
 `define AGS_ARG_MUX1      "use spr bus and adr"
 `define AGS_OPA         [2:1]
 `define AGS_MODE          [0]

  `define AGX_CTRL_WIDTH 5
  `define AGX_MODULO [4]
  `define AGX_OPA  [3:2]
  `define AGX_MODE [1:0]
 -----/\----- EXCLUDED -----/\----- */
  
  //Overall AGU
 `define AGU_SPR_AR0  0
 `define AGU_SPR_AR1  1
 `define AGU_SPR_AR2  2
 `define AGU_SPR_AR3  3
 `define AGU_SPR_SP   4

 `define AGU_SPR_BTM0  5
 `define AGU_SPR_TOP0  6
 `define AGU_SPR_STP0  7

 `define AGU_SPR_BTM1  8
 `define AGU_SPR_TOP1  9
 `define AGU_SPR_STP1  10
 `define AGU_SPR_BITREV 11

  `define AGU_CTRL_WIDTH 24

`define AGU_PRE_OP_1 [23]  
`define AGU_PRE_OP_0 [22]

  `define AGU_OUT_MODE     [21]
  
  `define AGU_OTHER_VAL1  [20:19]
  `define AGU_MODULO_1      [18]
  `define AGU_BR1           [17]
  `define AGU_AR1_OUT       [16]
  `define AGU_IMM1_VALUE    [15]
  `define AGU_AR1_WREN      [14]   
  `define AGU_SP_EN         [13] 
  `define AGU_AR1_SEL     [12:11]    
  `define AGU_DM1_WREN      [10]


  `define AGU_OTHER_VAL0  [9:8]
  `define AGU_MODULO_0      [7]
  `define AGU_BR0           [6]
  `define AGU_AR0_OUT       [5]
  `define AGU_IMM0_VALUE    [4]
  `define AGU_AR0_WREN      [3]    
  `define AGU_AR0_SEL     [2:1]    
  `define AGU_DM0_WREN      [0]


//Loop constroller defines
  `define LC_SPR_LOOPN 2
  `define LC_SPR_LOOPB 3
  `define LC_SPR_LOOPE 4

  `define LC_CTRL_WIDTH 41
  `define LC_LOOPE_VAL [40:25]
  `define LC_LOOPN_VAL [24:9]
 `define LC_LOOPN      deprecated
 `define LC_SPL_MUX  deprecated //Use SPR bus instead
 `define LC_REPEAT_1 unused
 `define LC_LOOPB      [4]
 `define LC_LOOPE      [3]
 `define LC_LOOPN1     [2]
 `define LC_LOOPB1     [1]
 `define LC_LOOPE1     [0]

  //Register file defines
  `define RF_CTRL_WIDTH 25
 `define RF_OPA            [24:19]
 `define RF_OPB            [18:13]
 `define RF_WRITE_REG_SEL  [12: 8]
 `define RF_WRITE_REG_EN       [7]
 `define RF_SPL_MUX         deprecated
 `define RF_RFIN            "use `WB_MUX_SEL"
 `define RF_READ_CTRL      [24:13]
 `define RF_WRITE_CTRL     [12: 1]
 `define RF_WRITE_REG_SEL_DM [6:2]
 `define RF_WRITE_REG_EN_DM  [1]
 `define RF_DEPRECATED       [0]

  //PC FSM controll
 `define PFC_CTRL_WIDTH 6
  `define PFC_REPEAT_X    [5]
 `define PFC_DELAY_SLOT [4:3]
 `define PFC_JUMP         [2]
 `define PFC_RET          [1]
 `define PFC_CALL         [0]

  //IO defines
 `define IO_CTRL_WIDTH 10
 `define IO_WREN   [9]
 `define IO_RDEN   [8]
 `define IO_ADDR [7:0]
  
  //Forward control
  `define FWD_CTRL_WIDTH 20
  `define FWD_RF_WRITE_CTRL_P5 [19:14]
  `define FWD_WB_MUX_SEL_P5 [13:10]
  `define FWD_RF_WRITE_CTRL_P4 [9:4]
  `define FWD_WB_MUX_SEL_P4 [3:0]

  //Forwarding mux
  `define FWDMUX_CTRL_WIDTH 6
  `define FWDMUX_OPB [5:3]
  `define FWDMUX_OPA [2:0]

  //Write back mux
 `define WB_MUX_CTRL_WIDTH 4
  `define WB_MUX_SEL [3:0]

  //Condition check
  `define COND_LOGIC_CTRL_WIDTH 5
  `define COND_LOGIC_CDT [4:0]


  //Operand select
  `define OPSEL_CTRL_WIDTH 4

  `define OPSEL_OPB [3:2]
  `define OPSEL_OPA [1:0]

  //DM Data Select
  `define DM_DATA_SELECT_CTRL_WIDTH 3

  `define DM0_SELECT [0]
  `define DM1_SELECT [2:1]

  //Instruction decoder defines
  `define ID_PIPE_TYPE_WIDTH 2

  `define ID_IMM_PIPE            deprecated

  //DOUBLE_32B instructions that are loading to rf from memory (MULLD and MACLD)
  `define ID_EARLY_WRITE_E2_PIPE 3

  `define ID_CONV_PIPE           2
  `define ID_E1_PIPE             1
  `define ID_E2_PIPE             0
  `define ID_MEM_LS_PIPE         deprecated
 `endif
