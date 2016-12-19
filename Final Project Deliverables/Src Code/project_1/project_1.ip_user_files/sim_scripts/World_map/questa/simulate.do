onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib World_map_opt

do {wave.do}

view wave
view structure
view signals

do {World_map.udo}

run -all

quit -force
