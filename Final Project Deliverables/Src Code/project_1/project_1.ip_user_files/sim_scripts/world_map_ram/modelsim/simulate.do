onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.world_map_ram xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {world_map_ram.udo}

run -all

quit -force
