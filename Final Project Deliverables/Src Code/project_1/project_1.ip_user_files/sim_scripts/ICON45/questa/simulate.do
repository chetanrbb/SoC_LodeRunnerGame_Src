onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ICON45_opt

do {wave.do}

view wave
view structure
view signals

do {ICON45.udo}

run -all

quit -force
