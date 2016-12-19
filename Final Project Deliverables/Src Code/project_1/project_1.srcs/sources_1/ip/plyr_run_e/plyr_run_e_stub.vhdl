-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
-- Date        : Tue Jun 07 19:32:46 2016
-- Host        : Chetan-PC running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub {E:/System_on_Chip/Projects/Final/Project
--               2/project_1/project_1.srcs/sources_1/ip/plyr_run_e/plyr_run_e_stub.vhdl}
-- Design      : plyr_run_e
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity plyr_run_e is
  Port ( 
    clka : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );

end plyr_run_e;

architecture stub of plyr_run_e is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,addra[9:0],douta[1:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_3_1,Vivado 2015.4";
begin
end;
