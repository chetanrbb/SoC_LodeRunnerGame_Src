onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib Opnt1_Icon_U_opt

do {wave.do}

view wave
view structure
view signals

do {Opnt1_Icon_U.udo}

run -all

quit -force
