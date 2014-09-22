onerror {resume}
quietly WaveActivateNextPane {} 0
quietly virtual signal -install /dsp_system_top/dsp_core/instruction_decoder { /dsp_system_top/dsp_core/instruction_decoder/spr_ctrl_o[4:0]} spr_adr
quietly virtual function -install /dsp_system_top/dsp_core -env /dsp_system_top/dsp_core/MAC { &{/dsp_system_top/dsp_core/ALU/spr_fl0_extra_store,/dsp_system_top/dsp_core/MAC/flags_reg[3], /dsp_system_top/dsp_core/MAC/flags_reg[2], /dsp_system_top/dsp_core/MAC/flags_reg[1], /dsp_system_top/dsp_core/MAC/flags_reg[0], /dsp_system_top/dsp_core/ALU/flags_reg[3], /dsp_system_top/dsp_core/ALU/flags_reg[2], /dsp_system_top/dsp_core/ALU/flags_reg[1], /dsp_system_top/dsp_core/ALU/flags_reg[0] }} fl0
add wave -noupdate -format Logic -height 15 /dsp_system_top/clk
add wave -noupdate -format Logic -height 15 /dsp_system_top/reset
add wave -noupdate -divider {INSTR PIPE}
add wave -noupdate -format Literal -height 15 -label pc -radix unsigned /dsp_system_top/pc
add wave -noupdate -format Literal -height 15 -label pm_data_p1 -radix hexadecimal /dsp_system_top/pm_data_p1
add wave -noupdate -format Literal -height 15 -label pm_data_p2 -radix hexadecimal /dsp_system_top/pm_data_p2
add wave -noupdate -format Literal -height 15 -label pm_data_p3 -radix hexadecimal /dsp_system_top/pm_data_p3
add wave -noupdate -format Literal -height 15 -label pm_data_p4 -radix hexadecimal /dsp_system_top/pm_data_p4
add wave -noupdate -format Literal -height 15 -label pm_data_p5 -radix hexadecimal /dsp_system_top/pm_data_p5
add wave -noupdate -format Literal -height 15 -label pm_data_p6 -radix hexadecimal /dsp_system_top/pm_data_p6
add wave -noupdate -divider {INSTR DECODED}
add wave -noupdate -format Literal -height 15 -label agu_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/decode_logic/agu_ctrl_o
add wave -noupdate -format Literal -height 15 -label alu_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/decode_logic/alu_ctrl_o
add wave -noupdate -format Literal -height 15 -label mac_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/decode_logic/mac_ctrl_o
add wave -noupdate -format Literal -height 15 -label cond_logic_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/decode_logic/cond_logic_ctrl_o
add wave -noupdate -format Literal -height 15 -label loop_counter_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/decode_logic/loop_counter_ctrl_o
add wave -noupdate -format Literal -height 15 -label io_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/decode_logic/io_ctrl_o
add wave -noupdate -format Literal -height 15 -label pc_fsm_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/decode_logic/pc_fsm_ctrl_o
add wave -noupdate -format Literal -height 15 -label rf_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/decode_logic/rf_ctrl_o
add wave -noupdate -format Literal -height 15 -label wb_mux_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/decode_logic/wb_mux_ctrl_o
add wave -noupdate -format Literal -height 15 -label imm_val_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/decode_logic/imm_val_o
add wave -noupdate -format Literal -height 15 -label spr_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/decode_logic/spr_ctrl_o
add wave -noupdate -format Literal -height 15 -label dm_data_select_ctrl_o /dsp_system_top/dsp_core/instruction_decoder/decode_logic/dm_data_select_ctrl_o
add wave -noupdate -divider {INSTR PIPELINED}
add wave -noupdate -format Literal -height 15 -label agu_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/agu_ctrl_o
add wave -noupdate -format Literal -height 15 -label alu_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/alu_ctrl_o
add wave -noupdate -format Literal -height 15 -label cond_logic_ctrl_p4_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/cond_logic_ctrl_p4_o
add wave -noupdate -format Literal -height 15 -label cond_logic_ctrl_p5_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/cond_logic_ctrl_p5_o
add wave -noupdate -format Literal -height 15 -label imm_val_p3_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/imm_val_p3_o
add wave -noupdate -format Literal -height 15 -label imm_val_p4_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/imm_val_p4_o
add wave -noupdate -format Literal -height 15 -label imm_val_p5_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/imm_val_p5_o
add wave -noupdate -format Literal -height 15 -label io_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/io_ctrl_o
add wave -noupdate -format Literal -height 15 -label loop_counter_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/loop_counter_ctrl_o
add wave -noupdate -format Literal -height 15 -label mac_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/mac_ctrl_o
add wave -noupdate -format Literal -height 15 -label pc_fsm_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/pc_fsm_ctrl_o
add wave -noupdate -format Literal -height 15 -label rf_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/rf_ctrl_o
add wave -noupdate -format Literal -height 15 -label wb_mux_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/wb_mux_ctrl_o
add wave -noupdate -format Literal -height 15 -label spr_ctrl_o -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/spr_ctrl_o
add wave -noupdate -format Literal -height 15 -label dm_data_select_ctrl_o /dsp_system_top/dsp_core/instruction_decoder/dm_data_select_ctrl_o
add wave -noupdate -format Literal -height 15 -label spr_adr -radix hexadecimal /dsp_system_top/dsp_core/instruction_decoder/spr_adr
add wave -noupdate -divider {SPR REGISTERS}
add wave -noupdate -format Literal -height 15 -label {ar0 (sr[0])} -radix hexadecimal {/dsp_system_top/dsp_core/agu/ar_rf[0]}
add wave -noupdate -format Literal -height 15 -label {ar1 (sr[1])} -radix hexadecimal {/dsp_system_top/dsp_core/agu/ar_rf[1]}
add wave -noupdate -format Literal -height 15 -label {ar2 (sr[2])} -radix hexadecimal {/dsp_system_top/dsp_core/agu/ar_rf[2]}
add wave -noupdate -format Literal -height 15 -label {ar3 (sr[3])} -radix hexadecimal {/dsp_system_top/dsp_core/agu/ar_rf[3]}
add wave -noupdate -format Literal -height 15 -label {sp (sr[4])} -radix hexadecimal /dsp_system_top/dsp_core/agu/sp
add wave -noupdate -format Literal -height 15 -label {bot0 (sr[5])} -radix hexadecimal {/dsp_system_top/dsp_core/agu/btm/rf[0]}
add wave -noupdate -format Literal -height 15 -label {top0 (sr[6])} -radix hexadecimal {/dsp_system_top/dsp_core/agu/top/rf[0]}
add wave -noupdate -format Literal -height 15 -label {step0 (sr[7])} -radix hexadecimal {/dsp_system_top/dsp_core/agu/stp/rf[0]}
add wave -noupdate -format Literal -height 15 -label {bot1 (sr[8])} -radix hexadecimal {/dsp_system_top/dsp_core/agu/btm/rf[1]}
add wave -noupdate -format Literal -height 15 -label {top1 (sr[9])} -radix hexadecimal {/dsp_system_top/dsp_core/agu/top/rf[1]}
add wave -noupdate -format Literal -height 15 -label {step1 (sr[10])} -radix hexadecimal {/dsp_system_top/dsp_core/agu/stp/rf[1]}
add wave -noupdate -format Literal -height 15 -label {bitrev (sr[11])} -radix hexadecimal /dsp_system_top/dsp_core/agu/bitrev_rf
add wave -noupdate -format Literal -height 15 -label {fl0 (sr[12])} -radix hexadecimal /dsp_system_top/dsp_core/fl0
add wave -noupdate -format Literal -height 15 -label {loopn (sr[13])} -radix hexadecimal /dsp_system_top/dsp_core/loop_counter/loopn_reg
add wave -noupdate -format Literal -height 15 -label {loopb (sr[14])} -radix hexadecimal /dsp_system_top/dsp_core/loop_counter/loopb_reg
add wave -noupdate -format Literal -height 15 -label {loope (sr[15])} -radix hexadecimal /dsp_system_top/dsp_core/loop_counter/loope_reg
add wave -noupdate -divider {REGISTER FILE}
add wave -noupdate -format Literal -height 15 -label theRF -radix hexadecimal /dsp_system_top/dsp_core/register_file/theRF
add wave -noupdate -format Literal -height 15 -label dat_a_o -radix hexadecimal /dsp_system_top/dsp_core/register_file/dat_a_o
add wave -noupdate -format Literal -height 15 -label dat_b_o -radix hexadecimal /dsp_system_top/dsp_core/register_file/dat_b_o
add wave -noupdate -format Literal -height 15 -label dat_i -radix hexadecimal /dsp_system_top/dsp_core/register_file/dat_i
add wave -noupdate -divider MAC
add wave -noupdate -format Literal -height 15 -label ACR0 -radix hexadecimal /dsp_system_top/dsp_core/MAC/ACR0/register
add wave -noupdate -format Literal -height 15 -label ACR1 -radix hexadecimal /dsp_system_top/dsp_core/MAC/ACR1/register
add wave -noupdate -format Literal -height 15 -label ACR2 -radix hexadecimal /dsp_system_top/dsp_core/MAC/ACR2/register
add wave -noupdate -format Literal -height 15 -label ACR3 -radix hexadecimal /dsp_system_top/dsp_core/MAC/ACR3/register
add wave -noupdate -divider {MEM IF}
add wave -noupdate -format Logic -height 15 -label dm0_wr_en_o -radix hexadecimal /dsp_system_top/dsp_core/dm0_wr_en_o
add wave -noupdate -format Literal -height 15 -label dm0_addr_o -radix hexadecimal /dsp_system_top/dsp_core/dm0_addr_o
add wave -noupdate -format Literal -height 15 -label dm0_data_i -radix hexadecimal /dsp_system_top/dsp_core/dm0_data_i
add wave -noupdate -format Literal -height 15 -label dm0_data_o -radix hexadecimal /dsp_system_top/dsp_core/dm0_data_o
add wave -noupdate -format Logic -height 15 -label dm1_wr_en_o -radix hexadecimal /dsp_system_top/dsp_core/dm1_wr_en_o
add wave -noupdate -format Literal -height 15 -label dm1_addr_o -radix hexadecimal /dsp_system_top/dsp_core/dm1_addr_o
add wave -noupdate -format Literal -height 15 -label dm1_data_i -radix hexadecimal /dsp_system_top/dsp_core/dm1_data_i
add wave -noupdate -format Literal -height 15 -label dm1_data_o -radix hexadecimal /dsp_system_top/dsp_core/dm1_data_o
add wave -noupdate -divider ALU
add wave -noupdate -format Literal -height 15 -label opa_i -radix hexadecimal /dsp_system_top/dsp_core/ALU/opa_i
add wave -noupdate -format Literal -height 15 -label opb_i -radix hexadecimal /dsp_system_top/dsp_core/ALU/opb_i
add wave -noupdate -format Literal -height 15 -label result_o -radix hexadecimal /dsp_system_top/dsp_core/ALU/result_o
add wave -noupdate -divider {OP SEL}
add wave -noupdate -format Literal -height 15 -label rf_b_i -radix hexadecimal /dsp_system_top/dsp_core/opsel/rf_b_i
add wave -noupdate -format Literal -height 15 -label rf_a_i -radix hexadecimal /dsp_system_top/dsp_core/opsel/rf_a_i
add wave -noupdate -format Literal -height 15 -label imm_val_i -radix hexadecimal /dsp_system_top/dsp_core/opsel/imm_val_i
add wave -noupdate -format Literal -height 15 -label op_b_o -radix hexadecimal /dsp_system_top/dsp_core/opsel/op_b_o
add wave -noupdate -format Literal -height 15 -label op_a_o -radix hexadecimal /dsp_system_top/dsp_core/opsel/op_a_o
add wave -noupdate -divider {LOOP CONTROL}
add wave -noupdate -format Literal -height 15 -label loopb_reg -radix hexadecimal /dsp_system_top/dsp_core/loop_counter/loopb_reg
add wave -noupdate -format Literal -height 15 -label loope_reg -radix hexadecimal /dsp_system_top/dsp_core/loop_counter/loope_reg
add wave -noupdate -format Literal -height 15 -label loopn_reg -radix hexadecimal /dsp_system_top/dsp_core/loop_counter/loopn_reg
add wave -noupdate -divider {CDT P4}
add wave -noupdate -format Literal -height 15 -label mac_flags_i /dsp_system_top/dsp_core/condition_logic_p4/mac_flags_i
add wave -noupdate -format Literal -height 15 -label alu_flags_i /dsp_system_top/dsp_core/condition_logic_p4/alu_flags_i
add wave -noupdate -format Logic -height 15 -label condition_check_o /dsp_system_top/dsp_core/condition_logic_p4/condition_check_o
add wave -noupdate -divider {CDT P5}
add wave -noupdate -format Literal -height 15 -label mac_flags_i /dsp_system_top/dsp_core/condition_logic_p5/mac_flags_i
add wave -noupdate -format Literal -height 15 -label alu_flags_i /dsp_system_top/dsp_core/condition_logic_p5/alu_flags_i
add wave -noupdate -format Logic -height 15 -label condition_check_o /dsp_system_top/dsp_core/condition_logic_p5/condition_check_o
add wave -noupdate -divider OTHERS
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3774 ns} 0}
configure wave -namecolwidth 281
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {3373 ns} {5115 ns}
