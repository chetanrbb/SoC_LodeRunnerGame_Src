onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ICON_Plyr_opt

do {wave.do}

view wave
view structure
view signals

do {ICON_Plyr.udo}

run -all

quit -force
