// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
// Date        : Tue Jun 07 11:51:26 2016
// Host        : Chetan-PC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {e:/System_on_Chip/Projects/Final/Project
//               2/project_1/project_1.srcs/sources_1/ip/GAME_OVER/GAME_OVER_stub.v}
// Design      : GAME_OVER
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_1,Vivado 2015.4" *)
module GAME_OVER(clka, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,addra[17:0],douta[1:0]" */;
  input clka;
  input [17:0]addra;
  output [1:0]douta;
endmodule
