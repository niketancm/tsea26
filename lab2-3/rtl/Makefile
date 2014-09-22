SKEL_DIR = skeleton_files
V_SKEL = $(wildcard $(SKEL_DIR)/*.v)
VHD_SKEL = $(wildcard $(SKEL_DIR)/*.vhd)

.PHONY: help init_verilog init_vhdl

help:
	@echo "Usage:"
	@echo "make use_verilog - For Verilog skeletons"
	@echo "make use_vhdl    - For VHDL skeletons"

use_verilog:
	cp -u $(V_SKEL) . 
	rm -rf $(SKEL_DIR)

use_vhdl:
	cp -u $(VHD_SKEL) . 
	rm -rf $(SKEL_DIR)
