onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib snd_hp_opt

do {wave.do}

view wave
view structure
view signals

do {snd_hp.udo}

run -all

quit -force
