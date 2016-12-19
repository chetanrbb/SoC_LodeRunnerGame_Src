onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib Opnt1_Icon_R_opt

do {wave.do}

view wave
view structure
view signals

do {Opnt1_Icon_R.udo}

run -all

quit -force
