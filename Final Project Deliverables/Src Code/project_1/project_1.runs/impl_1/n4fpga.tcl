proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_param xicom.use_bs_reader 1
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.cache/wt} [current_project]
  set_property parent.project_path {E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.xpr} [current_project]
  set_property ip_repo_paths {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.cache/ip}} [current_project]
  set_property ip_output_repo {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.cache/ip}} [current_project]
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/synth_1/n4fpga.dcp}}
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/clk_wiz_0_synth_1/clk_wiz_0.dcp}}
  set_property netlist_only true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/clk_wiz_0_synth_1/clk_wiz_0.dcp}}]
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/World_map_synth_1/World_map.dcp}}
  set_property netlist_only true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/World_map_synth_1/World_map.dcp}}]
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/ICON_Plyr_synth_1/ICON_Plyr.dcp}}
  set_property netlist_only true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/ICON_Plyr_synth_1/ICON_Plyr.dcp}}]
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/Opnt_Icon1_synth_1/Opnt_Icon1.dcp}}
  set_property netlist_only true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/Opnt_Icon1_synth_1/Opnt_Icon1.dcp}}]
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/plyr_run_e_synth_1/plyr_run_e.dcp}}
  set_property netlist_only true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/plyr_run_e_synth_1/plyr_run_e.dcp}}]
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/ICON_PLYR_U_synth_1/ICON_PLYR_U.dcp}}
  set_property netlist_only true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/ICON_PLYR_U_synth_1/ICON_PLYR_U.dcp}}]
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/Opnt1_Icon_U_synth_1/Opnt1_Icon_U.dcp}}
  set_property netlist_only true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/Opnt1_Icon_U_synth_1/Opnt1_Icon_U.dcp}}]
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/Opnt1_Icon_R_synth_1/Opnt1_Icon_R.dcp}}
  set_property netlist_only true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/Opnt1_Icon_R_synth_1/Opnt1_Icon_R.dcp}}]
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/MAIN_SCRN_synth_1/MAIN_SCRN.dcp}}
  set_property netlist_only true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/MAIN_SCRN_synth_1/MAIN_SCRN.dcp}}]
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/snd_hp_synth_1/snd_hp.dcp}}
  set_property netlist_only true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/snd_hp_synth_1/snd_hp.dcp}}]
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/GAME_OVER_synth_1/GAME_OVER.dcp}}
  set_property netlist_only true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/GAME_OVER_synth_1/GAME_OVER.dcp}}]
  add_files -quiet {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/GAME_WIN_synth_1/GAME_WIN.dcp}}
  set_property netlist_only true [get_files {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.runs/GAME_WIN_synth_1/GAME_WIN.dcp}}]
  read_xdc -mode out_of_context -ref clk_wiz_0 -cells inst {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_ooc.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_ooc.xdc}}]
  read_xdc -prop_thru_buffers -ref clk_wiz_0 -cells inst {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_board.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_board.xdc}}]
  read_xdc -ref clk_wiz_0 -cells inst {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc}}]
  read_xdc -mode out_of_context -ref World_map {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/World_map/World_map_ooc.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/World_map/World_map_ooc.xdc}}]
  read_xdc -mode out_of_context -ref ICON_Plyr {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/ICON_Plyr/ICON_Plyr_ooc.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/ICON_Plyr/ICON_Plyr_ooc.xdc}}]
  read_xdc -mode out_of_context -ref Opnt_Icon1 {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/Opnt_Icon1/Opnt_Icon1_ooc.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/Opnt_Icon1/Opnt_Icon1_ooc.xdc}}]
  read_xdc -mode out_of_context -ref plyr_run_e {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/plyr_run_e/plyr_run_e_ooc.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/plyr_run_e/plyr_run_e_ooc.xdc}}]
  read_xdc -mode out_of_context -ref ICON_PLYR_U {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/ICON_PLYR_U/ICON_PLYR_U_ooc.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/ICON_PLYR_U/ICON_PLYR_U_ooc.xdc}}]
  read_xdc -mode out_of_context -ref Opnt1_Icon_U {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/Opnt1_Icon_U/Opnt1_Icon_U_ooc.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/Opnt1_Icon_U/Opnt1_Icon_U_ooc.xdc}}]
  read_xdc -mode out_of_context -ref Opnt1_Icon_R {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/Opnt1_Icon_R/Opnt1_Icon_R_ooc.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/Opnt1_Icon_R/Opnt1_Icon_R_ooc.xdc}}]
  read_xdc -mode out_of_context -ref MAIN_SCRN {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/MAIN_SCRN/MAIN_SCRN_ooc.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/MAIN_SCRN/MAIN_SCRN_ooc.xdc}}]
  read_xdc -mode out_of_context -ref snd_hp {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/snd_hp/snd_hp_ooc.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/snd_hp/snd_hp_ooc.xdc}}]
  read_xdc -mode out_of_context -ref GAME_OVER {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/GAME_OVER/GAME_OVER_ooc.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/GAME_OVER/GAME_OVER_ooc.xdc}}]
  read_xdc -mode out_of_context -ref GAME_WIN -cells U0 {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/GAME_WIN/GAME_WIN_ooc.xdc}}
  set_property processing_order EARLY [get_files {{e:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/sources_1/ip/GAME_WIN/GAME_WIN_ooc.xdc}}]
  read_xdc {{E:/System_on_Chip/Projects/Final/Project 2/project_1/project_1.srcs/constrs_1/imports/constraints/nexys4fpga_novideo.xdc}}
  link_design -top n4fpga -part xc7a100tcsg324-1
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  catch {write_debug_probes -quiet -force debug_nets}
  opt_design 
  write_checkpoint -force n4fpga_opt.dcp
  report_drc -file n4fpga_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  catch {write_hwdef -file n4fpga.hwdef}
  place_design 
  write_checkpoint -force n4fpga_placed.dcp
  report_io -file n4fpga_io_placed.rpt
  report_utilization -file n4fpga_utilization_placed.rpt -pb n4fpga_utilization_placed.pb
  report_control_sets -verbose -file n4fpga_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force n4fpga_routed.dcp
  report_drc -file n4fpga_drc_routed.rpt -pb n4fpga_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file n4fpga_timing_summary_routed.rpt -rpx n4fpga_timing_summary_routed.rpx
  report_power -file n4fpga_power_routed.rpt -pb n4fpga_power_summary_routed.pb
  report_route_status -file n4fpga_route_status.rpt -pb n4fpga_route_status.pb
  report_clock_utilization -file n4fpga_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force n4fpga.mmi }
  write_bitstream -force n4fpga.bit 
  catch { write_sysdef -hwdef n4fpga.hwdef -bitfile n4fpga.bit -meminfo n4fpga.mmi -file n4fpga.sysdef }
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

