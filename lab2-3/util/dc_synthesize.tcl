sh date

# set some per design variables
set TOPLEVEL  "mac_dp"
set LOG_PATH  "synth/dc_test_synth/log/"
set GATE_PATH "synth/dc_test_synth/gate/"
set RTL_PATH  "synth/dc_test_synth/verilog/"
set VERILOGFILES "~/sleipnir/rtl/"

set target_library {/sw/mentor/libraries/cmos065_522/CORE65LPLVT_5.1/libs/CORE65LPLVT_bc_1.30V_m40C_10y.db}
set link_library $target_library 


proc dir_exists {name} {
    if { [catch {set type [file type $name] } ]  } {
	return 0;
    } 
    if { $type == "directory" } {
	return 1;
    }
    return 0;

}

if {[dir_exists $TOPLEVEL.out]} {
    sh rm -r ./$TOPLEVEL.out
}
sh mkdir ./$TOPLEVEL.out

set power_preserve_rtl_hier_names true

if [file exists mac_dp.v] {
    read_verilog mac_dp.v
    read_verilog saturation.v
    analyze -format verilog mac_dp.v
    analyze -format verilog saturation.v
} else {
    read_vhdl mac_dp.vhd
    read_vhdl saturation.vhd
    analyze -format vhdl mac_dp.vhd
    analyze -format vhdl saturation.vhd
}

read_verilog mac_scale.v
analyze -format verilog mac_scale.v

current_design mac_dp

elaborate mac_dp

# Set timing constaints, this says that a max of .5ns of delay from
# input to output is alowable 
set_max_delay .5 -to [all_outputs]


# If this were a clocked piece of logic we could set a clock
#  period to shoot for like this 
set_clock_gating_style  -max_fanout 16

create_clock clk_i -period 2.000


optimize_registers -sync_trans multiclass 

# Check for warnings/errors 
check_design

# ungroup everything 
ungroup -flatten -all

# flatten it all, this forces all the hierarchy to be flattened out 
set_flatten true -effort high
uniquify

# This forces the compiler to spend as much effort (and time)
# compiling this RTL to achieve timing possible. 
compile_ultra -gate_clock

# Now that the compile is complete report on the results 

check_design > ./$TOPLEVEL.out/check_design.rpt

report_constraint -all_violators -verbose  > constraint.rpt
report_wire_load > wire_load_model_used.rpt
report_area > area.rpt
report_qor > qor.rpt
report_timing -max_paths 1000 > timing.rpt
report_ultra_optimization > ultraopt.rpt
report_power -verbose > power_estimate.rpt
report_design > ./$TOPLEVEL.out/design_information.rpt
report_resources > ./$TOPLEVEL.out/resources.rpt

# Finally write the post synthesis netlist out to a verilog file 
write -f verilog $TOPLEVEL -output synthesized_netlist.v -hierarchy



quit
