//	bot.v - BOTSIM (Rojobot) top level
//
//	Copyright Roy Kravitz, 2006-2015, 2016
//
//	Created By:			Roy Kravitz
//	Last Modified:		11-Oct-2014 (RK)
//	
//	Revision History:
//	-----------------
//	Sep-2006		RK		Created this module
//	Oct-2009		RK		Minor changes for changeover to ECE510
//	Oct-2012		RK		Modified for Nexys3 and kcpsm6
//	Jan-2014		RK		Cleaned up the formatting.  No functional changes	
//	Oct-2014		RK		Checked for Nexys4 and Vivado compatibility.  No changes.
//	
//	Description
//	-----------
//	This module is the top level module for the BOTSIM (Rojobot).  The BOTSIN interfaces
//	to the Application CPU via an 8-bit register interface.  These registers are available
//	as outputs from the module.  Input to the BOTSIM is through a single 8-bit
//	motor control register which contains values for the left and right wheel speed and direction
//	
//	This module also provides a register-based interface to video logic.
//	
//	The BOTSIM contains a picoblaze and its program ROM, world map logic (including the Dual-port RA
//	containing the map) and the register-based interface to the picoblaze.
//  The picoblaze implements the rojobot and the world it moves around in.
//
//	NOTE:  The kcpsm6 and program ROM variables and instantiations are taken from kcpsm6_design_template.v
//
//////////

module provider(
    // system interface registers
    input               plyr_dth,
    output reg          dth,
    
    output reg          plyr_blnk, 
    output              main_scrn_disp,
	output           [3:0]   led,
	output                  move_flg, 
	input 		[2:0]		Plyr_MotCtl_in,		// Player motion control input
	input       [2:0]       Opnt1_MotCtl_in,    // Read the motion ctrl of opponent 
	                        Opnt2_MotCtl_in, 
	                        Opnt3_MotCtl_in,  
	// since the screen size is of 1024x512 we need 10 bits for X and 9 bits for Y axis	
	// the output of the module willl be updated by the PB 
	output		[9:0] 		Plyr_LocX,		// X-coordinate of rojobot's location	
	                        Opnt1_LocX,
	                        Opnt2_LocX,
	                        Opnt3_LocX,	
    
    output  	[8:0]		Plyr_LocY,		// Y-coordinate of rojobot's location
                            Opnt1_LocY,
                            Opnt2_LocY,
                            Opnt3_LocY,
    // Provide the surface sensor values for player and three opponents 
    output       [1:0]      Plyr_Srfc,	// Either player is on surface or not 
                            Opnt1_Srfc, // Either opponent is on surface or not
                            Opnt2_Srfc,
                            Opnt3_Srfc, 
    // provide the black line sensor readings for the player and opponents 
    output                  Plyr_BlkLine,   // either the player is on black line or white line
                            Opnt1_BlkLine,  // either the opponent is on black line or white line 
                            Opnt2_BlkLine,
                            Opnt3_BlkLine,
    // provide the proximity value for the player and the opponent 
    output                  Plyr_Prxmty,
                            Opnt1_Prxmty,
                            Opnt2_Prxmty,
                            Opnt3_Prxmty,
    // orientation of the player and the opponents 
    output      [1:0]       Plyr_Ornt, 
                            Opnt1_Ornt,
                            Opnt2_Ornt,
                            Opnt3_Ornt,
                                                                                     
						
	// interface to the video logic
	input 		[9:0]		vid_row,		// video logic row address
							vid_col,		// video logic column address

	output 		[1:0]		vid_pixel_out,	// pixel (location) value

	// interface to the system
	input					clk,			// system clock
							reset,			// system reset
	output					upd_sysregs,		// flag from PicoBlaze to indicate that the system registers 
											// (LocX, LocY, Sensors, BotInfo)have been updated
    output   [9:0]   ScrollCntr   
);

// internal variables for picoblaze and program ROM signals
// signal names taken from kcpsm6_design_template.v
wire	[11:0]		address;
wire	[17:0]		instruction;
wire				bram_enable;
wire				rdl;

wire	[7:0]		port_id;
wire	[7:0]		out_port;
wire	[7:0]		in_port;
wire				write_strobe;
wire				read_strobe;
wire				intr;
wire				intr_ack;
wire				kcpsm6_sleep; 
wire				kcpsm6_reset;
//wire                move_flg;

// updated by the PB and sent to the map module to read hte map info about the locX and LocY
// these will be used to read the value of the surface/proximity/line sensor for both the 
// player and the opponent  
// the map is of 1024x512 hence the row = 9 and col = 10 bits 
wire 	[1:0]		map_loc_info;		// location value from world map
wire 	[9:0]		map_col_addr;		// column address to map logic
wire    [8:0]		map_row_addr;		// row address to map logic
// to roll the screen from the count of 512 to 1024 the counter will be incremented by 10 
// total counts needed to increment the counter will be 50
// the screen will scroll from the left to right and then 
wire    [9:0]       scroll_cntr; 
reg     [9:0]   clkcntr, clkcntr2; 
reg             plyr_blnk_flg;
                
reg     intrpt_gen;

// global assigns
assign kcpsm6_reset = reset;			// Picoblaze is reset w/ global reset signal
assign kcpsm6_sleep = 1'b0;				// kcpsm6 sleep mode is not used
assign interrupt = intrpt_gen;				// kcpsm6 interrupt is not used	
assign ScrollCntr = scroll_cntr;


//////////////////////////////////////////////////////////////////////////////
// This module is the interface between the main provider module and the PB 
// It will read the motion control signals generated by the player and opponent
// According to th emotion it will move the player and the opponent 
// It will then read the surface, proximity and black/white line information for 
// both the player and the opponent. 
// This information will be providied to both the player and opponents so that 
// they can decide their next motion accordingly. 
// This module also interacts with the maze map to read the information which 
// is requeseted by the PB 
//////////////////////////////////////////////////////////////////////////////
// instantiate the interface used to interact with the PB 
// this interface will interact with the PB and the main module of provider

//
always @ (posedge clk)
begin
if(reset)
begin
   dth = 0; 
end
else 
begin
    if(Plyr_MotCtl_in == 3'd5)  // checcck if power butn pressed
    begin 
    plyr_blnk_flg = 1;
    end 
    
    if(plyr_blnk_flg)
    begin
      if(clkcntr2 >= 50000000)
        begin
            plyr_blnk_flg = 0;
            clkcntr2 = 0;
        end
        else 
            clkcntr2 = clkcntr2 + 1;
        
        if(clkcntr >= 5000000)
        begin
            plyr_blnk = ~plyr_blnk;
            clkcntr = 0;
        end
        else
            clkcntr = clkcntr + 1;
    end
    else 
        plyr_blnk = 1;
        
    if(plyr_dth && (plyr_blnk_flg == 0))
    begin
        if(((Opnt1_LocY + 5'd31) == Plyr_LocY) && (Opnt1_LocX ==Plyr_LocX))
        begin
            dth = 1;
        end
        else if ((Opnt1_LocY  == (Plyr_LocY + 5'd31)) && (Opnt1_LocX == Plyr_LocX)) // opp is above the player
            dth = 1;
        else if ((Plyr_LocY == Opnt1_LocY) && ((Plyr_LocX + 5'd31 == Opnt1_LocX) || (Plyr_LocX == Opnt1_LocX + 5'd31)))
            dth = 1;
        // opnt2 chk
        else if(((Opnt2_LocY + 5'd31) == Plyr_LocY) && (Opnt2_LocX ==Plyr_LocX))
                begin
                    dth = 1;
                end
                else if ((Opnt2_LocY  == (Plyr_LocY + 5'd31)) && (Opnt2_LocX == Plyr_LocX)) // opp is above the player
                    dth = 1;
                else if ((Plyr_LocY == Opnt2_LocY) && ((Plyr_LocX + 5'd31 == Opnt2_LocX) || (Plyr_LocX == Opnt2_LocX + 5'd31)))
                    dth = 1;
        
        // opnt 3
        else if(((Opnt3_LocY + 5'd31) == Plyr_LocY) && (Opnt3_LocX ==Plyr_LocX))
                begin
                    dth = 1;
                end
                else if ((Opnt3_LocY  == (Plyr_LocY + 5'd31)) && (Opnt3_LocX == Plyr_LocX)) // opp is above the player
                    dth = 1;
                else if ((Plyr_LocY == Opnt3_LocY) && ((Plyr_LocX + 5'd31 == Opnt3_LocX) || (Plyr_LocX == Opnt3_LocX + 5'd31)))
                    dth = 1;
        else 
            dth = 0;
       end
//       else if((Plyr_LocY  < 5'd20) && Plyr_LocY)
//            win = 1;
//       else
//       begin
//          // dth = 0;
//           win = 0;
//       end    
end 
end

ProviderPB_if  prvdr_pb_if(
    .main_scrn_disp(main_scrn_disp),
    .move_flg(move_flg),
    .intr_ack(intr_ack),
    .intr(intr),
    .led(led),
// INPUTS required by the PB
    .PlyrMotCtl(Plyr_MotCtl_in),				// Motor control input
    .Opnt1MotCtl(Opnt1_MotCtl_in),
    .Opnt2MotCtl(Opnt2_MotCtl_in),
    .Opnt3MotCtl(Opnt3_MotCtl_in),
	.MapVal(map_loc_info),			// map value for location [row_addr, col_addr]
    
// OUTPUTS updated by the PB
    .ScrollCntr(scroll_cntr),       // scroll the screen to the left/right
    .PlyrLocX(Plyr_LocX),
    .PlyrLocY(Plyr_LocY),
    .Opnt1LocX(Opnt1_LocX),
    .Opnt1LocY(Opnt1_LocY),
    .Opnt2LocX(Opnt2_LocX),
    .Opnt2LocY(Opnt2_LocY),
    .Opnt3LocX(Opnt3_LocX),
    .Opnt3LocY(Opnt3_LocY),
    .PlyrPrxmty(Plyr_Prxmty),
    .Opnt1Prxmty(Opnt1_Prxmty),
    .Opnt2Prxmty(Opnt2_Prxmty),
    .Opnt3Prxmty(Opnt3_Prxmty),
    .PlyrOrnt(Plyr_Ornt),
    .Opnt1Ornt(Opnt1_Ornt),
    .Opnt2Ornt(Opnt2_Ornt),
    .Opnt3Ornt(Opnt3_Ornt),
    .PlyrBlkLine(Plyr_BlkLine),
    .Opnt1BlkLine(Opnt1_BlkLine),
    .Opnt2BlkLine(Opnt2_BlkLine),
    .Opnt3BlkLine(Opnt3_BlkLine),
    .PlyrSrfc(Plyr_Srfc),
    .Opnt1Srfc(Opnt1_Srfc),
    .Opnt2Srfc(Opnt2_Srfc),
    .Opnt3Srfc(Opnt3_Srfc),
    // read the information for the co-ordinates sent 
    .MapX(map_col_addr),			// column address of world map location 	
    .MapY(map_row_addr),            // row address of world map location
        
// INTERFACE signals to the PB 
    .Wr_Strobe(write_strobe),		// Write strobe - asserted to write I/O data
	.Rd_Strobe(read_strobe),		// Read strobe - asserted to read I/O data
	.AddrIn(port_id),
	.DataIn(out_port),				// Data to be written to I/O register
	.DataOut(in_port),				// Data to be read from I/O register
	.clk(clk),						// 25Mhz system clock
    .reset(reset),                    // system reset
	// update system registers (interrupt request to Application CPU
	.upd_sysregs(upd_sysregs)		// flag from PicoBlaze to indicate that the system registers 									// (LocX, LocY, Sensors, BotInfo)have been updated
);

// INSTANTIATE THE PROVIDER PB
kcpsm6 #(
	.interrupt_vector	(12'h3FF),
	.scratch_pad_memory_size(64),
	.hwbuild		(8'h00))
PROVIDERCPU (
	.address 		(address),
	.instruction 	(instruction),
	.bram_enable 	(bram_enable),
	.port_id 		(port_id),
	.write_strobe 	(write_strobe),
	.k_write_strobe (),				// Constant Optimized writes are not used in this implementation
	.out_port 		(out_port),
	.read_strobe 	(read_strobe),
	.in_port 		(in_port),
	.interrupt 		(intr),
	.interrupt_ack 	(intr_ack),				// Interrupt is not used in this implementation
	.reset 			(kcpsm6_reset),
	.sleep			(kcpsm6_sleep),
	.clk 			(clk)
);  

provider_mod PROVIDER(
  //proj2demo BOTSIMPGM( 
	.enable 		(bram_enable),
	.address 		(address),
	.instruction 	(instruction),
	.clk 			(clk));

		
// instantiate the world map logic
maze 	MAZE (
    //input scroll counter -> updated by PB 
    .scroll_cntr(scroll_cntr),
	// interface to external world emulator
	.wrld_col_addr(map_col_addr),		// column address of world map location
	.wrld_row_addr(map_row_addr),		// row address of world map location
	.wrld_loc_info(map_loc_info),		// map value for location [row_addr, col_addr]

	// interface to the video logic
	.vid_row(vid_row),					// video logic row address
	.vid_col(vid_col),					// video logic column address
	.vid_pixel_out(vid_pixel_out),		// pixel (location) value

	// interface to the system
	.clk(clk),							// system clock
	.reset(reset)						// system reset
);
				
endmodule
						
