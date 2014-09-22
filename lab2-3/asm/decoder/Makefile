ASM_FILES = layer2.asm main.asm output.asm read_header.asm stream.asm toplevel.asm subband_je.asm testrutiner.asm

toplevel.hex: $(ASM_FILES)
	srasm toplevel.asm

sim: toplevel.hex
	srsim -p 65536 -0 65536 -1 65536 toplevel.hex

clean:
	rm -f toplevel.hex