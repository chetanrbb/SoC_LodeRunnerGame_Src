vlib work
vlib msim

vlib msim/xil_defaultlib

vmap xil_defaultlib msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr \
"../../../../project_1.srcs/sources_1/ip/Opnt3_Icon/Opnt3_Icon_sim_netlist.v" \


vlog -work xil_defaultlib "glbl.v"
