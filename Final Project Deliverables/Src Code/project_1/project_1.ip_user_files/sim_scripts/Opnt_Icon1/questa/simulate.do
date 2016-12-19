onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib Opnt_Icon1_opt

do {wave.do}

view wave
view structure
view signals

do {Opnt_Icon1.udo}

run -all

quit -force
