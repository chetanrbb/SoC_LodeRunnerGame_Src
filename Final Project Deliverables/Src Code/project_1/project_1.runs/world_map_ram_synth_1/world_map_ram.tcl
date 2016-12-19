# 
# Synthesis run script generated by Vivado
# 

set_param xicom.use_bs_reader 1
set_msg_config -id {Common 17-41} -limit 10000000
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7a100tcsg324-1

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.cache/wt} [current_project]
set_property parent.project_path {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.xpr} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property vhdl_version vhdl_2k [current_fileset]
read_ip {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/world_map_ram/world_map_ram.xci}}
set_property used_in_implementation false [get_files -all {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/world_map_ram/world_map_ram.dcp}}]
set_property is_locked true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/world_map_ram/world_map_ram.xci}}]

synth_design -top world_map_ram -part xc7a100tcsg324-1 -mode out_of_context
rename_ref -prefix_all world_map_ram_
write_checkpoint -noxdef world_map_ram.dcp
catch { report_utilization -file world_map_ram_utilization_synth.rpt -pb world_map_ram_utilization_synth.pb }
if { [catch {
  file copy -force {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/world_map_ram_synth_1/world_map_ram.dcp} {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/world_map_ram/world_map_ram.dcp}
} _RESULT ] } { 
  send_msg_id runtcl-3 error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
  error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
}
if { [catch {
  write_verilog -force -mode synth_stub {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/world_map_ram/world_map_ram_stub.v}
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}
if { [catch {
  write_vhdl -force -mode synth_stub {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/world_map_ram/world_map_ram_stub.vhdl}
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}
if { [catch {
  write_verilog -force -mode funcsim {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/world_map_ram/world_map_ram_sim_netlist.v}
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}
if { [catch {
  write_vhdl -force -mode funcsim {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/world_map_ram/world_map_ram_sim_netlist.vhdl}
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if {[file isdir {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.ip_user_files/ip/world_map_ram}]} {
  catch { 
    file copy -force {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/world_map_ram/world_map_ram_stub.v}} {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.ip_user_files/ip/world_map_ram}
  }
}

if {[file isdir {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.ip_user_files/ip/world_map_ram}]} {
  catch { 
    file copy -force {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/world_map_ram/world_map_ram_stub.vhdl}} {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.ip_user_files/ip/world_map_ram}
  }
}
