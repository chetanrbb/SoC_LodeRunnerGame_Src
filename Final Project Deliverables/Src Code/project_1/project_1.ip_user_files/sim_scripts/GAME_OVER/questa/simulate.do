onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib GAME_OVER_opt

do {wave.do}

view wave
view structure
view signals

do {GAME_OVER.udo}

run -all

quit -force
