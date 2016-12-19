onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib MAIN_SCRN_opt

do {wave.do}

view wave
view structure
view signals

do {MAIN_SCRN.udo}

run -all

quit -force
