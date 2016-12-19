// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Sat Jun 04 21:04:18 2016
// Host        : Chetan-PC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {E:/System_on_Chip/Projects/Final/Project
//               2/project_1/project_1.srcs/sources_1/ip/world_map_ram/world_map_ram_stub.v}
// Design      : world_map_ram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_1,Vivado 2015.4" *)
module world_map_ram(clka, wea, addra, dina, douta, clkb, web, addrb, dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[18:0],dina[1:0],douta[1:0],clkb,web[0:0],addrb[18:0],dinb[1:0],doutb[1:0]" */;
  input clka;
  input [0:0]wea;
  input [18:0]addra;
  input [1:0]dina;
  output [1:0]douta;
  input clkb;
  input [0:0]web;
  input [18:0]addrb;
  input [1:0]dinb;
  output [1:0]doutb;
endmodule
