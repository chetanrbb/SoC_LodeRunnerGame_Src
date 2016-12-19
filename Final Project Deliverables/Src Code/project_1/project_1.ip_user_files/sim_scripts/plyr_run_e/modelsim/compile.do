vlib work
vlib msim

vlib msim/xil_defaultlib

vmap xil_defaultlib msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr \
"../../../../project_1.srcs/sources_1/ip/plyr_run_e/plyr_run_e_sim_netlist.v" \


vlog -work xil_defaultlib "glbl.v"

