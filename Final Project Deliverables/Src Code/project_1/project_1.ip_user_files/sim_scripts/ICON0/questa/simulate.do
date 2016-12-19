onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ICON0_opt

do {wave.do}

view wave
view structure
view signals

do {ICON0.udo}

run -all

quit -force
