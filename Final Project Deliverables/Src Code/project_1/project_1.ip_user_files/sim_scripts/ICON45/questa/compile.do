vlib work
vlib msim

vlib msim/xil_defaultlib

vmap xil_defaultlib msim/xil_defaultlib

vlog -work xil_defaultlib -64 \
"../../../../project_1.srcs/sources_1/ip/ICON45/ICON45_sim_netlist.v" \


vlog -work xil_defaultlib "glbl.v"

