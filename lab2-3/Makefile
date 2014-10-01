
# These files are always present
VERILOG_FILES = rtl/acr_reg.v rtl/addressing_mode_decoder.v rtl/addr_mux.v rtl/agu_rf.v rtl/alu.v rtl/bit_reversal.v rtl/clk_gen.v rtl/combined_agu.v rtl/condition_logic.v rtl/dff.v rtl/dsp_core.v rtl/dsp_system_top.v rtl/fwd_ctrl.v rtl/fwdmux.v rtl/id_decode_logic.v rtl/id_pipeline_logic.v rtl/instruction_decoder.v rtl/io_read.v rtl/io.v rtl/io_write.v rtl/loop_controller.v rtl/mac.v rtl/nop_mux.v rtl/operand_select.v rtl/program_counter.v rtl/register_file.v rtl/reset_gen.v rtl/tb_memories.v rtl/write_back_mux.v rtl/mac_scale.v

# These files may be present
VERILOG_FILES += $(wildcard rtl/adder_ctrl.v) $(wildcard rtl/min_max_ctrl.v) $(wildcard rtl/pc_fsm.v) $(wildcard rtl/rounding_vector.v) $(wildcard rtl/saturation.v) $(wildcard rtl/mac_dp.v)

VHDL_FILES = $(wildcard rtl/adder_ctrl.vhd) $(wildcard rtl/min_max_ctrl.vhd) $(wildcard rtl/pc_fsm.vhd) $(wildcard rtl/rounding_vector.vhd) $(wildcard rtl/saturation.vhd) $(wildcard rtl/mac_dp.vhd)
TEST = 

.PHONY: all clean compile_rtl vsim decoder_ref decoder_vsim use_verilog \
	use_vhdl lab_ref lab_vsim

help:
	@echo "Read the lab manual"

clean:
	# make -C decoder clean
	make -C util clean
	rm -rf work

work:
	vlib work


compile_rtl: work
	vlog -cover bcst -incr +acc $(VERILOG_FILES) +incdir+rtl/
ifneq ($(strip $(VHDL_FILES)),)
	vcom -cover bcst $(VHDL_FILES) +acc
endif

vsim: compile_rtl
	vsim -coverage dsp_system_top

decoder_vsim: decoder_ref
	vsim -c -do 'run -all; quit -f' dsp_system_top
	make -C util
	util/convertsamples rtloutput.hex rtlaudio.wav 44100

decoder_ref: compile_rtl
	rm -f IOS0010
	ln -sf asm/decoder/IOS0010 IOS0010
	rm -f rtloutput.hex IOS0011 reffile.hex
	make -C asm/decoder
	cp asm/decoder/toplevel.hex test.hex
	srsim -r test.hex
	cp IOS0011 reffile.hex

lab_vsim: lab_ref
	vsim -coverage dsp_system_top


ifeq ($(TEST),)
lab_ref:
	$(error TEST has not been set)
else
lab_ref: asm/$(TEST) compile_rtl 
	touch asm/$(TEST).in
	cp asm/$(TEST).in IOS0010
	rm -f rtloutput.hex IOS0011 reffile.hex
	srasm asm/$(TEST) test.hex
	srsim -r test.hex
	cp IOS0011 reffile.hex
endif

asm/$(TEST):
	$(error Can not find: asm/$(TEST))

use_verilog:
	make -C rtl $@

use_vhdl:
	make -C rtl $@


synth_macdp:
	mkdir -p rtl_synthesis
	cp util/dc_synthesize.tcl rtl_synthesis
	cp rtl/mac_dp.v* rtl_synthesis
	cp rtl/mac_scale.v rtl_synthesis
	cp rtl/saturation.v* rtl_synthesis
	cp rtl/senior_defines.vh rtl_synthesis
	cd rtl_synthesis;dc_shell -f dc_synthesize.tcl

