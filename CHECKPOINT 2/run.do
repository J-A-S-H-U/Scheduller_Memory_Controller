vlib work
vlog -sv +define+DEBUG_CODE checkpoint2.sv
vsim -c  +NAME_OF_THE_FILE=trace1cp1.txt checkpoint2 -do "run -all"
