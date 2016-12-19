-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
-- Date        : Fri Jun 03 21:19:49 2016
-- Host        : Chetan-PC running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub {e:/System_on_Chip/Projects/Final/Project
--               2/project_1/project_1.srcs/sources_1/ip/ICON_PLYR_U/ICON_PLYR_U_stub.vhdl}
-- Design      : ICON_PLYR_U
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ICON_PLYR_U is
  Port ( 
    clka : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );

end ICON_PLYR_U;

architecture stub of ICON_PLYR_U is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,addra[9:0],douta[1:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_3_1,Vivado 2015.4";
begin
end;
