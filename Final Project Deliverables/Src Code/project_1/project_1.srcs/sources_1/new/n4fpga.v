`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Portland State University, ECE 540: Project 2 
// Author: Chetan Bornakar, Ashish Patil 
//
// Version: V1.0
// 
// Create Date: 04/22/2016 
// Project Name: Simulate rojobot world 
// Module Name: n4fpga
//
// Description:
// ------------
// Top level module for the ECE 540 Project 2 reference design
// on the Nexys4 FPGA Board (Xilinx XC7A100T-CSG324)
//
// The pushbuttons to control the Rojobot wheels:
//	btnl			Left wheel forward
//	btnu			Left wheel reverse
//	btnr			Right wheel forward
//	btnd			Right wheel reverse
//  btnc			Not used in this design
//	btnCpuReset		CPU RESET Button - System reset.  Asserted low by Nexys 4 board
//
//	sw[15:0]		are used to glow the led respective to the switches
//
// 
//////////////////////////////////////////////////////////////////////////////////


module n4fpga(
    input clk,                              // 100 Mhz clock from on-board oscillator
    input btnL, btnR, btnU, btnD, btnC,     // pushbuttons -left, rigth, up, down, center
    input btnCpuReset,                      // reset pushbutton
    input [15:0] sw,                        // slide switches input
    input PS2Clk,			// wire connect to PS2Receiver
    input PS2Data,
                
    output [15:0] led,                      // led output 
    output [6:0] seg,                       // seven segments of each display 
    output [7:0] an,                        // eight displays 
    output dp,                              // decimal points of the display
    output [3:0] vgaRed,                    // color information on the vga pins
           [3:0] vgaBlue,
           [3:0]vgaGreen,
    output Hsync, Vsync,                     // horizontal and vertical sync pulses of vga  
    output RsTx
);

reg CLK50MHZ=0;    
wire [31:0]keycode;
wire [2:0] next_step;
//wire locked;
//seven segmentdisplay wires
wire [7:0] segs_int;
wire [7:0] decepts;
wire [63:0] digits_out;

// parameters
parameter SIMULATE = 0;
// internal variables
wire        vga_r0, vga_r1, vga_r2, vga_r3,     // viga signal for red color
            vga_b0, vga_b1, vga_b2, vga_b3,     // vga signal for blue color
            vga_g0, vga_g1, vga_g2, vga_g3,     // vga signal for green color
            vga_vs, vga_hs;                     // horizontal and vertical pulses 
wire [15:0] db_sw;                          // debounce switches
wire [5:0]  db_btns;                        // debounce buttons
wire        sysclk;                         // 100Mhz clock 
wire        sysreset;                       // system reset
// for every digit a 5 bit code is required  
wire [4:0]  dig7, dig6, dig5, dig4,         // seven segment displays 
            dig3, dig2, dig1, dig0;
               // 
wire [7:0]  decpts;                         // decimal points 
reg         clk_2hz_en;                     // signal at 2hz 

// Picoblaze interface 
wire [11:0] address;                        // address lines required by PB
wire [17:0] instruction;                    // instruction lines required by PB
wire        bram_enable;                    // RAM access signal for PB
wire [7:0]  port_id,                        // data available on port address PB
            out_port,                       // data provided by PB on these address
            in_port;                        // data read by PB from these ports                 
wire        write_strobe;                   // strobe signal when data is sent to PB
wire        read_strobe;                    // strobe signal generated when data is read 
wire        interrupt;                      // interrupt signal to PB 
wire        interrupt_ack;                  // interrupt acknowledge signal from PB indicating that interrupt is addressed
wire        kcpsm6_sleep;                   // turn the KCPSM6 to sleep 
wire        kcpsm6_reset;                   // reset the KCPSM6
wire        cpu_reset;                      // reset signal from nexys 4
wire        rdl;                            // 
wire        int_upd_sysres;                 // interrupt update signal provided by bot to generate interrupt to PB

// Picoblaze IO registers
wire [7:0]  sw_high, sw_low;                // status of switches {15:0]
wire [7:0]  led_high, led_low;              // status of LED's[15:0]

// video connectors
wire [9:0] vid_row,                         // control the vga pins for row
           vid_col;                         // control the vga pins for column
wire [1:0] vid_pixel_out;                   // image information  

wire [2:0] Plyr_motion_ctl;                      // motion control signals of robot
wire [2:0] Opnt1_motion_ctl,
           Opnt2_motion_ctl,
           Opnt3_motion_ctl;
           
wire [9:0] Plyr_LocX,		// X-coordinate of rojobot's location	
           Opnt1_LocX,
           Opnt2_LocX,
           Opnt3_LocX;    

wire [8:0] Plyr_LocY,        // Y-coordinate of rojobot's location
           Opnt1_LocY,
           Opnt2_LocY,
           Opnt3_LocY;
                
wire [1:0] Plyr_Srfc,    // Either player is on surface or not 
           Opnt1_Srfc, // Either opponent is on surface or not
           Opnt2_Srfc,
           Opnt3_Srfc; 
            
wire       Plyr_BlkLine,   // either the player is on black line or white line
           Opnt1_BlkLine,  // either the opponent is on black line or white line 
           Opnt2_BlkLine,
           Opnt3_BlkLine;
            
wire  Plyr_Prxmty,
           Opnt1_Prxmty,
           Opnt2_Prxmty,
           Opnt3_Prxmty;
               // orientation of the player and the opponents 
wire [1:0] Plyr_Ornt, 
           Opnt1_Ornt,
           Opnt2_Ornt,
           Opnt3_Ornt;             

wire       main_scrn_disp;

wire [7:0] botinfo, sensors, lmdist, rmdist; // information about robot's orientation, sensors, distance travelled 
wire       hsync, vsync, video_on;          // control the horizontal and vertical synch pulses and video enable signal
wire [9:0] pixel_row, pixel_clmn;           // information about which is the current raster pixel row and column
// map the world map image of 128x128 to 512x512 by reading 1 pixel of map and plotting it on 4 pixels on screen
wire [8:0] pixel_row_conv, pixel_clmn_conv; // to scale the image from 128x128 to 512x512, 4 pixels of screen are provided with one pixel info
wire       move_flg;
wire       dth, win ;                             // flag set when the player dies 
//
assign sysreset = db_btns[0] ;              // btnCpuReset is asserted low so invert it
assign sw_high = db_sw[15:8];               // monitor the swithces status
assign sw_low = db_sw[7:0];                 // 
assign led = {led_high, led_low};           // concatenate the led signals

assign dp = segs_int[7];                    // control the decimal points of all segment disp
assign seg = segs_int[6:0];                 // seven segments display control 

assign kcpsm6_sleep = 1'b0;                 // disable the sleep of KCPSM6 
assign kcpsm6_reset = sysreset | rdl;       // reset the KCPSM6 when the CPU_Reset button is pressed

// assign the vga signals to the vga port connector on the board 
assign vgaRed[0] = vga_r0, vgaRed[1] = vga_r1, vgaRed[2] = vga_r2, vgaRed[3] = vga_r3,
       vgaBlue[0] = vga_b0, vgaBlue[1] = vga_b1, vgaBlue[2] = vga_b2, vgaBlue[3] = vga_b3,
       vgaGreen[0] = vga_g0, vgaGreen[1] = vga_g1, vgaGreen[2] = vga_g2, vgaGreen[3] = vga_g3,
       Hsync = vga_hs, Vsync = vga_vs;

assign dp = segs_int[7];
assign seg = segs_int[6:0];
assign decepts = 8'b1100111;


wire disp_vga_clk;          // clock of 25Mhz for 512x512 resolution 
wire locked;         
wire icon_dth, icon_win;       // 
wire [1:0] w_icon, w_icon_opnt, w_icon_opnt2, w_icon_opnt3, 
           icon_map, 
           icon_snd1, icon_snd2, icon_snd3, icon_snd4, icon_snd5;          // information about the icon 
wire          main_scrn_dsp;
wire    [9:0] scrll_cntr;
wire    [2:0] score;
wire    [9:0] sndhp1locX,
              sndhp1locY,
              sndhp2locX,
              sndhp2locY,
              sndhp3locX,
              sndhp3locY,
              sndhp4locX,
              sndhp4locY,
              sndhp5locX,
              sndhp5locY;

wire          sndhp1,
              sndhp2,
              sndhp3,
              sndhp4,
              sndhp5;              
wire    dthgen;             
wire        dth_disp;        

wire plyr_blnk;      
// map the world map image 128x128 to 512x512
assign pixel_row_conv = (pixel_row);      
assign pixel_clmn_conv = (pixel_clmn);

always @(posedge(sysclk))begin
    CLK50MHZ<=~CLK50MHZ;
end

//PS2Receiver keyboard (
//.clk(sysclk),
//.kclk(PS2Clk),
//.kdata(PS2Data),
//.plyr_mot(Plyr_motion_ctl),
//.PlyrPrxmty(Plyr_Prxmty),
//.PlyrSrfc(Plyr_Srfc),
//.PlyrBlkLine(Plyr_BlkLine),
//.key_pressed(key_pressed),
//.keycodeout(keycode[31:0])
////.led(led_low[7:4]),
////.int_upd_sysres(int_upd_sysres)
//);

kybrd_if kbrd(    
    .clk(clk),
    .kclk(PS2Clk),
    .kdata(PS2Data), 
    .prox(Plyr_Prxmty),
    .line(Plyr_BlkLine),
    .surface(Plyr_Srfc),
    .plyr_mot(Plyr_motion_ctl),
    .keycodeout(keycode[31:0])
    );

clk_wiz_0 instance_name
(
   // Clock in ports
    .clk_in1(clk),              // input clk_in1
    // Clock out ports
    .clk_out1(sysclk),          // output clk_out1 100Mhz
    .clk_out2(disp_vga_clk),    // output clk_out2 25Mhz
    // Status and control signals
    .locked(locked)             // output locked
);      
    
debounce
#(
    .RESET_POLARITY_LOW(1),
    .SIMULATE(SIMULATE)
) DB
(
    .clk(sysclk),
    .pbtn_in({btnC,btnL,btnU,btnR,btnD,btnCpuReset}),
    .switch_in(sw),
    .pbtn_db(db_btns),
    .swtch_db(db_sw)
);

//always @ (posedge clk)
//begin
//  Plyr_motion_ctl = 1;
//  Opnt1_motion_ctl = 3;
//  Opnt2_motion_ctl = 3;
//  Opnt3_motion_ctl = 3;
//end  
// instantiate the 7-segment, 8-digit display
sevensegment
#(
    .RESET_POLARITY_LOW(1),
    .SIMULATE(SIMULATE)
) SSB
(
    // inputs for control signals
   .d0({1'b0,keycode[3:0]}),
   .d1({1'b0,keycode[7:4]}),
   .d2({1'b0,keycode[11:8]}),
   .d3({1'b0,keycode[15:12]}),
   .d4({2'b0,Plyr_motion_ctl}),
   .d5({1'b0,4'hA}),
   .d6({1'b0,4'hC}),
   .d7({1'b0,4'hF}),                        // digits to be displayed
   .dp(decepts),                                                    // decimal points to be displayed
 // outputs to seven segment display
    .seg(segs_int),
    .an(an),
    // clock and reset signals (100 MHz clock, active high reset)
    .clk(sysclk),
    .reset(sysreset)
);

// a=x+b
// instantiate the vga driver controller 
dtg vga_dtg(
	.clock(disp_vga_clk),  // send 25Mhz clock for 512x512 
	.rst(~sysreset),       // if 0 then clear the pointers 
	.horiz_sync(vga_hs),   // sync pulses 
	.vert_sync(vga_vs), 
	.video_on(video_on),   // video signal control  		
	.pixel_row(pixel_row), // information about current raster pixel on X and Y 
	.pixel_column(pixel_clmn)
);

// icon file 
Icon icon(
    .dth(dth),
    .win(win),
    .main_scrn(main_scrn_disp),
    .plyr_mot(Plyr_motion_ctl),
    .opnt1_mot(Opnt1_motion_ctl),
    .opnt2_mot(Opnt2_motion_ctl),
    .opnt3_mot(Opnt3_motion_ctl),
    
    .scrll_cntr(scrll_cntr),
	.clk(disp_vga_clk),    // send the 25Mhz clock 
	
	.PlyrLocX(Plyr_LocX),	       // read loc X and Y of robot 
	.PlyrLocY(Plyr_LocY),
	.PlyrOrnt(Plyr_Ornt),
	
	.Opnt1LocX(Opnt1_LocX),
	.Opnt1LocY(Opnt1_LocY),
	.Opnt1Ornt(Opnt1_Ornt),
	
	.Opnt2LocX(Opnt2_LocX),
    .Opnt2LocY(Opnt2_LocY),
    .Opnt2Ornt(Opnt2_Ornt),
    
    .Opnt3LocX(Opnt3_LocX),
    .Opnt3LocY(Opnt3_LocY),
	.Opnt3Ornt(Opnt3_Ornt),
	
	.sndhp1locX(sndhp1locX),
    .sndhp1locY(sndhp1locY),
    .sndhp2locX(sndhp2locX),
    .sndhp2locY(sndhp2locY),
    .sndhp3locX(sndhp3locX),
    .sndhp3locY(sndhp3locY),
    .sndhp4locX(sndhp4locX),
    .sndhp4locY(sndhp4locY),
    .sndhp5locX(sndhp5locX),
    .sndhp5locY(sndhp5locY),
              
    .sndhp1sig(sndhp1),   
    .sndhp2sig(sndhp2),   
    .sndhp3sig(sndhp3),   
    .sndhp4sig(sndhp4),   
    .sndhp5sig(sndhp5),   
    
	.pixel_row(pixel_row),     // read the current raster's pixel row/clmn info
	.pixel_col(pixel_clmn),    //  
	// outputs 
	.icon(w_icon),          // information of icon color
	.icon_opnt1(w_icon_opnt),
	.icon_opnt2(w_icon_opnt2),
	.icon_opnt3(w_icon_opnt3),
	.icon_map(icon_map),
	//.icon_map(icon_map),
	.icon_dth(icon_dth),
	.icon_win(icon_win),
	.icon_snd1(icon_snd1),
	.icon_snd2(icon_snd2),
	.icon_snd3(icon_snd3),
	.icon_snd4(icon_snd4),
	.icon_snd5(icon_snd5),
	.dth_icon_disp(dth_disp),
	.win_icon_disp(win_disp)
	);
// colorizer 
colorizer clrzr(
    .plyr_blnk(plyr_blnk),  // super power 
    .win(win_disp),
    .dth(dth_disp),
    .clk(disp_vga_clk),     // send 25Mhz clock information 
    .World(vid_pixel_out),  // world map color information  
    .Icon(w_icon),          // icon color information
    .IconOpnt(w_icon_opnt), 
    .IconOpnt2(w_icon_opnt2),
    .IconOpnt3(w_icon_opnt3),
    .main_scrn_disp(main_scrn_disp),
    .main_scrn_disp_info(icon_map),
    .dth_disp(icon_dth),
    .win_disp(icon_win),
    .IconSnd1(icon_snd1),
    .IconSnd2(icon_snd2),
    .IconSnd3(icon_snd3),
    .IconSnd4(icon_snd4),
    .IconSnd5(icon_snd5),
    
	.video_on(video_on),    // control the video signal
    .COLOR({vga_r0, vga_r1, vga_r2, vga_r3,  
            vga_g0, vga_g1, vga_g2, vga_g3, 
            vga_b0, vga_b1, vga_b2, vga_b3})  // 3 outs RGB combination together to form a 12 bit colour code
    );

// instantiate the bot module 
provider prvdr_inst(
    .plyr_blnk(plyr_blnk),
    .plyr_dth(dthgen),
    .dth(dth),
    //.win(win),
    .main_scrn_disp(main_scrn_disp),
    .move_flg(move_flg),
    .Plyr_MotCtl_in(Plyr_motion_ctl),		// Player motio
    .Opnt1_MotCtl_in(Opnt1_motion_ctl),    // 
    .Opnt2_MotCtl_in(Opnt2_motion_ctl),       
    .Opnt3_MotCtl_in(Opnt3_motion_ctl),      
     
	.Plyr_LocX(Plyr_LocX),		// X-coordinate of 
    .Opnt1_LocX(Opnt1_LocX),            
    .Opnt2_LocX(Opnt2_LocX),            
    .Opnt3_LocX(Opnt3_LocX),	      
         
	.Plyr_LocY(Plyr_LocY),		// Y-coordinate 
    .Opnt1_LocY(Opnt1_LocY),         
    .Opnt2_LocY(Opnt2_LocY),         
    .Opnt3_LocY(Opnt3_LocY),         

    .Plyr_Srfc(Plyr_Srfc),	// Either
    .Opnt1_Srfc(Opnt1_Srfc), // Eithe
    .Opnt2_Srfc(Opnt2_Srfc),         
    .Opnt3_Srfc(Opnt3_Srfc),         

    .Plyr_BlkLine(Plyr_BlkLine),   // e
    .Opnt1_BlkLine(Opnt1_BlkLine),  // e
    .Opnt2_BlkLine(Opnt2_BlkLine),      
    .Opnt3_BlkLine(Opnt3_BlkLine),      

    .Plyr_Prxmty(Plyr_Prxmty),      
    .Opnt1_Prxmty(Opnt1_Prxmty),     
    .Opnt2_Prxmty(Opnt2_Prxmty),     
    .Opnt3_Prxmty(Opnt3_Prxmty),     
    
    .Plyr_Ornt(Plyr_Ornt),          
    .Opnt1_Ornt(Opnt1_Ornt),         
    .Opnt2_Ornt(Opnt2_Ornt),         
    .Opnt3_Ornt(Opnt3_Ornt),         
                        

	// system interface registers
						
	// interface to the video logic
	.vid_row(pixel_row_conv),		// video logic row address
	.vid_col(pixel_clmn_conv),		// video logic column address

	.vid_pixel_out(vid_pixel_out),	// pixel (location) value

	// interface to the system
	.clk(sysclk),			// system clock
	.reset(~sysreset),			// system reset
	.upd_sysregs(int_upd_sysres),		// flag from PicoBlaze to indicate that the system registers 
	.led(led_low),										// (LocX, LocY, Sensors, BotInfo)have been updated
    .ScrollCntr(scrll_cntr)
);

sand_heap sndhp(
   .win_flg(win),
  .scrll_cntr(scrll_cntr),
  .reset(~sysreset), 
  .move_flg(move_flg),
  .updt_clk(int_upd_sysres), 
  .locX_player(Plyr_LocX),
  .locY_player(Plyr_LocY),
  .sand_heap_1_signal(sndhp1),
  .sand_heap_2_signal(sndhp2),
  .sand_heap_3_signal(sndhp3),
  .sand_heap_4_signal(sndhp4),
  .sand_heap_5_signal(sndhp5),
  
  .sand_heap_1_locX(sndhp1locX),
  .sand_heap_1_locY(sndhp1locY),
  .sand_heap_2_locX(sndhp2locX),
  .sand_heap_2_locY(sndhp2locY),
  .sand_heap_3_locX(sndhp3locX),
  .sand_heap_3_locY(sndhp3locY),
  .sand_heap_4_locX(sndhp4locX),
  .sand_heap_4_locY(sndhp4locY),
  .sand_heap_5_locX(sndhp5locX),
  .sand_heap_5_locY(sndhp5locY),
  .score(score)
);

//assign led_high[2] = int_upd_sysres;
// opponent movement 
opp_algo_block_ch opp_mvmnt(
    .clk(clk),
      .reset(~sysreset),
      .player_death(dthgen),
      .move_flg(move_flg),
      
      .motion_opp_1(Opnt1_motion_ctl),           // m
      .motion_opp_2(Opnt2_motion_ctl),           // m
      .motion_opp_3(Opnt3_motion_ctl),           // m
      
      .opnt1_ornt(Opnt1_Ornt),
      .opnt2_ornt(Opnt2_Ornt),
      .opnt3_ornt(Opnt3_Ornt),
                      
      .locX_player(Plyr_LocX),         // ret               
      .locY_player(Plyr_LocY),         // return

      .locX_opp_1(Opnt1_LocX),          // ret              
      .locY_opp_1(Opnt1_LocY),          //               
                                    
      .locX_opp_2(Opnt2_LocX),          // ret
      .locY_opp_2(Opnt2_LocY),              
                                    
      .locX_opp_3(Opnt3_LocX),         // ret
      .locY_opp_3(Opnt3_LocY),              
                                    
     .proximity_sensor_opp_1(Opnt1_Prxmty),          
     .bw_sensor_opp_1(Opnt1_BlkLine),                 
     .surface_sensor_opp_1(Opnt1_Srfc),            
                                    
     .proximity_sensor_opp_2(Opnt2_Prxmty),          
     .bw_sensor_opp_2(Opnt2_BlkLine),                 
     .surface_sensor_opp_2(Opnt2_Srfc),            
                                    
     .proximity_sensor_opp_3(Opnt3_Prxmty),          
     .bw_sensor_opp_3(Opnt3_BlkLine),                 
     .surface_sensor_opp_3(Opnt3_Srfc),            
     .led(led_high),                               
     .upsysregs(int_upd_sysres)                      
);

endmodule
