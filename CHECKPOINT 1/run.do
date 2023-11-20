vlib work
vlog -sv +define+DEBUG_CODE parse.sv
vsim -c -voptargs=+acc +NAME_OF_THE_FILE=trace1cp1.txt checkpoint1 -do "run -all"
