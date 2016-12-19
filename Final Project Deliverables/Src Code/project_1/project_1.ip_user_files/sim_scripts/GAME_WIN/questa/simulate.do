onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib GAME_WIN_opt

do {wave.do}

view wave
view structure
view signals

do {GAME_WIN.udo}

run -all

quit -force
