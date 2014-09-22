#!/bin/bash
# Test script that runs one given asm file on both the instruction level
# simulator and the RTL testbench and compares the result.
#
# Files used:
# asm: Assembler
# sim: Instruction level simulator

# TB: Name of RTL testbench
# test.hex: Assembled program. Will be read by the RTL testbench and the 
#           instruction level simulator
# IOS0010: Input to the instruction level simulator
# IOS0011: Output from the instruction level simulator
# rtloutput.hex: Output from the RTL testbench
# vsim: Modelsim executable

LOGFILE=testlog.txt

# Run the test, return 1 for bad match and 0 for match.
function runtest {
    # Remove old outputs
    rm -f IOS0011 IOS0010 rtloutput.hex reffile.hex

    echo "-------------------- STARTING TEST $1 --------------------"

    if [ -f $1.in ]
    then
	ln -sf $1.in IOS0010
    else
	touch IOS0010
    fi

    # Assemble the file to test
    asm/srasm $1 test.hex || return 1

    # Simulate using the instruction level simulator
    sim/srsim -r test.hex || return 1
    cp IOS0011 reffile.hex

    # Start modelsim in batch mode and run the testbench
    vsim  -c -do "util/regression_test.do" dsp_system_top  || return 1

    diff IOS0011 rtloutput.hex >> $LOGFILE
    diff -q IOS0011 rtloutput.hex || return 1
    # If we reach this line, the output from the instruction
    # level simulator and the RTL testbench is identical
    return 0
}

# Empty log file
cp /dev/null $LOGFILE

echo >>$LOGFILE
echo "Single file test $(date)" >>$LOGFILE
echo "###################################" >> $LOGFILE
echo >> $LOGFILE
echo >> $LOGFILE
echo "Starting test $1" >> $LOGFILE
echo >> $LOGFILE
runtest $1 && echo "Test $1 successful" >> $LOGFILE||  echo "Test $1 FAILED" >> $LOGFILE
echo >> $LOGFILE
echo "All tests finished" >> $LOGFILE
echo >>$LOGFILE
echo "-----------------------------------"
cat $LOGFILE
echo "-----------------------------------"

