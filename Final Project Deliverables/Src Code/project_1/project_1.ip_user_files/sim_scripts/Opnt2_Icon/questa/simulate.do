onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib Opnt2_Icon_opt

do {wave.do}

view wave
view structure
view signals

do {Opnt2_Icon.udo}

run -all

quit -force
