onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ICON_PLYR_U_opt

do {wave.do}

view wave
view structure
view signals

do {ICON_PLYR_U.udo}

run -all

quit -force
