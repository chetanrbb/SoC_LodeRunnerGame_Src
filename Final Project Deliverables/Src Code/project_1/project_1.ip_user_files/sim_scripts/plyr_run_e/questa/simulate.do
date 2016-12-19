onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib plyr_run_e_opt

do {wave.do}

view wave
view structure
view signals

do {plyr_run_e.udo}

run -all

quit -force
