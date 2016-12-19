//	world_if.v - Register interface to the Rojobot external world picoblaze 
//	
//	Copyright Roy Kravitz, 2006-2015, 2016
//
//	Created By:			Roy Kravitz
//	Last Modified:		11-Oct-2014 (RK)
//	
//	Revision History:
//	 -----------------
//	Sep-2006		RK		Created this module
//	Oct-2009		RK		Minor changes (comments only) for conversion to ECE 510
//	Jan-2014		RK		Cleaned up the formatting.  No functional changes	
//	Oct-2014		RK		Changed to synchronous resets.  No other changes
//	
//	Description
//	-----------
//	This module implements a register-based interface to the Rojobot.
//	The Rojobot is implemented in a SOC embedded system using the Xilinx
//	Picoblaze as the CPU and block of logic (in verilog) to implement the world map.
//	  
//	The Rojobot emulator (BOTSIM) is controlled by external logic writing to an 8-bit motor
//	control register of the following format:  
//		lm_spd[2:0], lm_dir, rm_spd[2:0], rm_dir where
//		lm_spd and rm_spd are the speed of the left and write motors
//		lm_dir and rm_dir are motor forward (1) and motor reverse (0)
//
//	A Rojobot-based system design needs access to information about the location of
//	the Rojobot in its simulated world.  This access is in the form of the following
//	8-bit registers:
//			Loc_X		O	X (column) coordinate of Rojobot's current location
//			Loc_y		O 	Y (row) coordinate of Rojobot's current location
//			Sensors		O	Sensor values.  Rojobot contains a proximity sensor (left and right)
//						 	A proximity sensor is set to 1 if Rojobot detects an object in
//						  	front of it.  It also contains a black line sensor (left, center
//						  	and right).  Each black line sensor is set to 0 if there is
//							a black line under it and set to 1 if there is not black line
//							under it.
//			BotInfo		O 	Information on rojobot's current orientation and movement
//
//	There are two additional registers available to the Robobot-based system
//	but they aren't very useful for anything other than debug and they have been
//	deprecated and will be removed at a later date
//			LMDist		O	Left motor distance counter value
//			RMDist		O	Right motor distance counter value
//	
//	Data from the BOTSIM is stored in internal registers
//	as they are written by the PicoBlaze.  The Rojobot interface provides a synchronized
//	view of all of the registers by transferring the contents of the internal registers when
//	internal control signals are asserted by the PicoBlaze by writing the following port addresses:
//		PRW_LOADREGS,	Port Address 0C		; loads system interface registers
//		PRW_LDMOTDIST,  Port Address 0D		; loads motor distance counters
//		PRW_RUNNING,	Port Address 0E		; a way for the PicoBlaze program to indicate it's running
//		Each write to the specific port toggles the control signal (which is reset to deasserted)		  					
//////////

module ProviderPB_if  (
    output reg          move_flg,
    output reg [3:0]    led,
    output reg          intr,
    output reg          main_scrn_disp,
    input               intr_ack,
    
// INPUTS required by the PB
    input       [2:0]   PlyrMotCtl,				// Motor control input
    input       [2:0]   Opnt1MotCtl,
                        Opnt2MotCtl,
                        Opnt3MotCtl,
	input       [1:0]   MapVal,                	// map value for location [row_addr, col_addr]
    
// OUTPUTS updated by the PB
    output reg  [9:0]   ScrollCntr,       // scroll the screen to the left/right
    output reg  [9:0]   PlyrLocX,
    output reg  [8:0]   PlyrLocY,
    output reg  [9:0]   Opnt1LocX,
    output reg  [8:0]   Opnt1LocY,
    output reg  [9:0]   Opnt2LocX,
    output reg  [8:0]   Opnt2LocY,
    output reg  [9:0]   Opnt3LocX,
    output reg  [8:0]   Opnt3LocY,
    output reg          PlyrPrxmty,
                        Opnt1Prxmty,
                        Opnt2Prxmty,
                        Opnt3Prxmty,
    output reg  [1:0]   PlyrOrnt, 
    output reg  [1:0]   Opnt1Ornt,
    output reg  [1:0]   Opnt2Ornt,
    output reg  [1:0]   Opnt3Ornt,
    output reg          PlyrBlkLine, 
    output reg          Opnt1BlkLine,
    output reg          Opnt2BlkLine,
    output reg          Opnt3BlkLine,
    output reg  [1:0]   PlyrSrfc,
                        Opnt1Srfc,
                        Opnt2Srfc,
                        Opnt3Srfc, 
    // read the information for the co-ordinates sent 
    output reg  [9:0]   MapX,			// column address of world map location 	
    output reg  [8:0]   MapY,            // row address of world map location
        
// INTERFACE signals to the PB 
    input 				Wr_Strobe,		// Write strobe - asserted to write I/O data
		 				Rd_Strobe,		// Read strobe - asserted to read I/O data
	input 		[7:0] 	AddrIn,			// I/O port address
	input 		[7:0] 	DataIn,			// Data to be written to I/O register
	output reg	[7:0] 	DataOut,		// I/O register data to picoblaze.clk(clk),						// 25Mhz system clock
	
	input               reset,
	input               clk,
	// update system registers (interrupt request to Application CPU
	output reg          upd_sysregs		// flag from PicoBlaze to indicate that the system registers 									// (LocX, LocY, Sensors, BotInfo)have been updated
	
);

reg [3:0] led_reg;

// internal variaables		
reg             load_sys_regs = 0;
reg             main_scrn_disp_reg = 0;
// holding registers for world.  We want all registers to be updated
// at the same time (from system's point of view) to make sure
// the world view is consistent.
reg     [7:0]   ScrollCntr_reg;
// since the picoblaze register are of 8 bits every register is split in H&L
reg     [7:0]   PlyrLocX_reg_H,
                PlyrLocX_reg_L,
                PlyrLocY_reg_H,
                PlyrLocY_reg_L,
                
                Opnt1LocX_reg_H,
                Opnt1LocX_reg_L,
                Opnt1LocY_reg_H,
                Opnt1LocY_reg_L,
                
                Opnt2LocX_reg_H,
                Opnt2LocX_reg_L,
                Opnt2LocY_reg_H,
                Opnt2LocY_reg_L,
                
                Opnt3LocX_reg_H,
                Opnt3LocX_reg_L,
                Opnt3LocY_reg_H,
                Opnt3LocY_reg_L,
                
                MapX_H, 
                MapX_L,
                MapY_H,
                MapY_L;
     
reg             PlyrPrxmty_reg, 
                Opnt1Prxmty_reg,
                Opnt2Prxmty_reg,
                Opnt3Prxmty_reg;

reg             move_flg_reg;
               
reg [1:0]       PlyrOrnt_reg,    
                Opnt1Ornt_reg,   
                Opnt2Ornt_reg,   
                Opnt3Ornt_reg;
    
reg             PlyrBlkLine_reg, 
                Opnt1BlkLine_reg,
                Opnt2BlkLine_reg,
                Opnt3BlkLine_reg;

reg  [1:0]      PlyrSrfc_reg,    
                Opnt1Srfc_reg,   
                Opnt2Srfc_reg,   
                Opnt3Srfc_reg;   

reg     [31:0]      clk_cnt;             // clock speed reduced for scrolling the image 
wire    [31:0]      top_clk_cnt = (500000/2);         // max clock count value // clk of 10hz 

reg     [9:0]   ScrnSzMax = 10'd512;
reg     [9:0]   ScrnSzMin = 10'd0;                

reg     [9:0]   ScrllIncReg = 0;        // this value increment or dec when the player moves   
reg             setflg = 0;

always @(posedge clk)
begin
    if(move_flg)
    begin
    if(((PlyrLocX + 8'd100) > (ScrnSzMax/2)) && ((ScrnSzMax) < 1023))        // check if player is going right
    begin
        ScrllIncReg = ScrllIncReg + 8'h1;  // scroll to right
        ScrnSzMax = ScrnSzMax + 8'd1;    // screen supports 5122x512
        ScrnSzMin <= ScrnSzMin + 8'd1;
        
         
    end
    else if(((PlyrLocX - 8'd100) < (ScrnSzMax - 9'd511)) && (ScrnSzMax - 9'd511)) // screen sz min = 0
    begin
        ScrllIncReg = ScrllIncReg - 8'd1; 
        ScrnSzMin <= ScrnSzMin - 8'd1;
        ScrnSzMax = ScrnSzMax - 8'd1;
    end
    end
end

always @(posedge clk)
begin
    if((clk_cnt == top_clk_cnt) )
    begin
        clk_cnt <= 0;
        intr <= 1;
    end 
    //else if(intr_ack == 1'b1)
    else
    begin
        intr <= 0;
        clk_cnt <= clk_cnt + 1; 
    end 
//    else
//    begin
//        intr <= intr;
//    end
end 


/*always @ (posedge clk)
begin
    led <= led_reg;
    //scrollcntr <= ScrollCntr_reg;
end
*/// PB: READ THE VALUES 
always @(posedge clk) 
begin
	case (AddrIn[2:0])
		3'b000 :	DataOut <= PlyrMotCtl;
		3'b001 :	DataOut <= Opnt1MotCtl;
		3'b010 :	DataOut <= Opnt2MotCtl;
		3'b011 :	DataOut <= Opnt3MotCtl;
		3'b100 :	DataOut <= MapVal;
		3'b101 :    DataOut <= MapX;
		3'b110 :    DataOut <= MapY;
		default:    DataOut <= 8'bxxxxxxxx;
	endcase
end // always - read registers


// write registers
always @(posedge clk) begin
    //MapX <= {MapX_H[1:0], MapX_L};
    //MapY <= {MapY_H[1:0], MapY_L};
    
	if (reset) begin
 		PlyrLocX_reg_H   <= 0;
        PlyrLocX_reg_L   <= 8'h20;
        PlyrLocY_reg_H   <= 0;
        PlyrLocY_reg_L   <= 8'h90;
                             
        Opnt1LocX_reg_H  <= 0;
        Opnt1LocX_reg_L  <= 8'h90;
        Opnt1LocY_reg_H  <= 0;
        Opnt1LocY_reg_L  <= 8'h90;
                             
        Opnt2LocX_reg_H  <= 8'h01;
        Opnt2LocX_reg_L  <= 8'h80;
        Opnt2LocY_reg_H  <= 8'h01;
        Opnt2LocY_reg_L  <= 8'h77;
                             
        Opnt3LocX_reg_H  <= 0;
        Opnt3LocX_reg_L  <= 8'h8E;
        Opnt3LocY_reg_H  <= 0;
        Opnt3LocY_reg_L  <= 8'h27;
        
        PlyrPrxmty_reg  <= 2'b00;
        Opnt1Prxmty_reg <= 2'b00;
        Opnt2Prxmty_reg <= 2'b00;
        Opnt3Prxmty_reg <= 2'b00;
        
        PlyrOrnt_reg     <= 0;    
        Opnt1Ornt_reg    <= 0;   
        Opnt2Ornt_reg    <= 0;   
        Opnt3Ornt_reg    <= 0;   
                         
        PlyrBlkLine_reg  <= 0; 
        Opnt1BlkLine_reg <= 0;
        Opnt2BlkLine_reg <= 0;
        Opnt3BlkLine_reg <= 0;
                         
        PlyrSrfc_reg     <= 0;    
        Opnt1Srfc_reg    <= 0;   
        Opnt2Srfc_reg    <= 0;   
        Opnt3Srfc_reg    <= 0;   
		upd_sysregs      <= 0;
		load_sys_regs    <= 0;
		move_flg_reg     <= 0;
		ScrollCntr_reg <= 1;
		main_scrn_disp_reg <= 0;
	end
	else begin
		if(Wr_Strobe) begin
		     //led[2] = 1;
			 case (AddrIn[5:0])
				// I/O registers for rojobot simulator HW interface
				6'b000000 :	    PlyrLocX_reg_H   <= DataIn;
				6'b000001 :	    PlyrLocX_reg_L   <= DataIn;
				6'b000010 :	    PlyrLocY_reg_H   <= DataIn;
				6'b000011 :	    PlyrLocY_reg_L   <= DataIn;
				                          
				6'b000100 :	    Opnt1LocX_reg_H  <= DataIn;                                
				6'b000101 :     Opnt1LocX_reg_L  <= DataIn;             
				6'b000110 :	    Opnt1LocY_reg_H  <= DataIn;            
				6'b000111 :     Opnt1LocY_reg_L  <= DataIn;
                                            
				// I/O regis                    
				6'b001000 : 	Opnt2LocX_reg_H  <= DataIn;
				6'b001001 : 	Opnt2LocX_reg_L  <= DataIn;
				6'b001010 : 	Opnt2LocY_reg_H  <= DataIn;
				6'b001011 : 	Opnt2LocY_reg_L  <= DataIn;
                                    
				// I/O regis                    
				6'b001100 : 	Opnt3LocX_reg_H  <= DataIn;
				6'b001101 : 	Opnt3LocX_reg_L  <= DataIn;
				6'b001110 : 	Opnt3LocY_reg_H  <= DataIn;
				6'b001111 : 	Opnt3LocY_reg_L  <= DataIn;
				//6'b010000 :  upd_sysregs      <= DataIn;
				
				6'b010001 :     PlyrPrxmty_reg  <= DataIn;
                                
                6'b010011 :     Opnt1Prxmty_reg <= DataIn;
                6'b010101 :     Opnt2Prxmty_reg <= DataIn;
                6'b010111 :     Opnt3Prxmty_reg <= DataIn;
                                
                6'b011001 :     PlyrOrnt_reg     <= DataIn;
                6'b011010 :     Opnt1Ornt_reg    <= DataIn;
                6'b011011 :     Opnt2Ornt_reg    <= DataIn;
                6'b011100 :     Opnt3Ornt_reg    <= DataIn;
                                
                6'b011101 :     PlyrBlkLine_reg  <= DataIn;
                6'b011110 :     Opnt1BlkLine_reg <= DataIn;
                6'b011111 :     Opnt2BlkLine_reg <= DataIn;
                6'b100000 :     Opnt3BlkLine_reg <= DataIn;
                                    
                6'b100001 :     PlyrSrfc_reg     <= DataIn;
                6'b100010 :     Opnt1Srfc_reg    <= DataIn;
                6'b100011 :     Opnt2Srfc_reg    <= DataIn;
                6'b100100 :     Opnt3Srfc_reg    <= DataIn;
                
                6'b100101 :     upd_sysregs     <= ~upd_sysregs;
                6'b100110 :     load_sys_regs    <= ~load_sys_regs;
                6'b100111 :     MapX[9:8]             <= DataIn;
                6'b101000 :     MapX[7:0]          <= DataIn;
                6'b101001 :     MapY[8]             <= DataIn;
                6'b101010 :     MapY[7:0]          <= DataIn;
                6'b101011 :     ScrollCntr_reg      <= DataIn;
                6'b101101 :     move_flg_reg        <= DataIn;
                6'b101110 :     main_scrn_disp_reg <= DataIn;
                //6'b101100 :     led_reg          <= DataIn;
                default   :     DataOut          <= 8'bxxxxxxxx; 
			endcase    		
		end
	end
end // always - write registers
	
// synchronized system register interface
always @(posedge clk) begin
	if (reset) begin
		PlyrLocX        <= 8'h20;
        PlyrLocY        <= 8'h90;
        Opnt1LocX       <= 8'h90; 
        Opnt1LocY       <= 8'h90;

        Opnt2LocX  <= 8'h01;
        Opnt2LocX  <= 8'h80;
        Opnt2LocY  <= 8'h01;
        Opnt2LocY  <= 8'h77;
                            
        Opnt3LocX  <= 0;
        Opnt3LocX  <= 8'h6E;
        Opnt3LocY  <= 0;
        Opnt3LocY  <= 8'h27;
        
                         
        PlyrPrxmty     <= 0; 
        Opnt1Prxmty    <= 0; 
        Opnt2Prxmty    <= 0; 
        Opnt3Prxmty    <= 0; 
                         
        PlyrOrnt        <= 0; 
        Opnt1Ornt       <= 0; 
        Opnt2Ornt       <= 0; 
        Opnt3Ornt       <= 0; 
                         
        PlyrBlkLine     <= 0; 
        Opnt1BlkLine    <= 1'b0; 
        Opnt2BlkLine    <= 1'b0; 
        Opnt3BlkLine    <= 1'b0; 
                         
        PlyrSrfc        <= 0; 
        Opnt1Srfc       <= 0; 
        Opnt2Srfc       <= 0; 
        Opnt3Srfc       <= 0;  
        ScrollCntr <= 1;
        move_flg   <= 0;
        main_scrn_disp <= 0;
	end
	else if (load_sys_regs) begin  // copy holding registers to system interface registers
	        //led_reg[4] = 1;
	        main_scrn_disp <= main_scrn_disp_reg;
			PlyrLocX <= {PlyrLocX_reg_H[1:0], PlyrLocX_reg_L};       
            PlyrLocY <= {PlyrLocY_reg_H[1:0], PlyrLocY_reg_L};
            Opnt1LocX <= {Opnt1LocX_reg_H[1:0], Opnt1LocX_reg_L};      
            Opnt1LocY <= {Opnt1LocY_reg_H[1:0], Opnt1LocY_reg_L};
            Opnt2LocX <= {Opnt2LocX_reg_H[1:0], Opnt2LocX_reg_L};      
            Opnt2LocY <= {Opnt2LocY_reg_H[1:0], Opnt2LocY_reg_L};     
            Opnt3LocX <= {Opnt3LocX_reg_H[1:0], Opnt3LocX_reg_L};      
            Opnt3LocY <= {Opnt3LocY_reg_H[1:0], Opnt3LocY_reg_L};      
                                  
            PlyrPrxmty <= PlyrPrxmty_reg;      
            Opnt1Prxmty <= Opnt1Prxmty_reg;
            Opnt2Prxmty <= Opnt2Prxmty_reg;     
            Opnt3Prxmty <= Opnt3Prxmty_reg;     
            
            
            PlyrOrnt <= PlyrOrnt_reg;         
            Opnt1Ornt <= Opnt1Ornt_reg;        
            Opnt2Ornt <= Opnt2Ornt_reg;        
            Opnt3Ornt <= Opnt3Ornt_reg;        
                                  
            PlyrBlkLine  <= ~PlyrBlkLine_reg;      
            Opnt1BlkLine <= ~Opnt1BlkLine_reg;     
            Opnt2BlkLine <= ~Opnt2BlkLine_reg;     
            Opnt3BlkLine <= ~Opnt3BlkLine_reg;     
                                  
            PlyrSrfc[1] <= PlyrSrfc_reg[1];         
            Opnt1Srfc[1] <= Opnt1Srfc_reg[1];        
            Opnt2Srfc[1] <= Opnt2Srfc_reg[1];        
            Opnt3Srfc[1] <= Opnt3Srfc_reg[1];
            
            PlyrSrfc[0] <=  ~PlyrSrfc_reg[0];         
            Opnt1Srfc[0] <= ~Opnt1Srfc_reg[0];        
            Opnt2Srfc[0] <= ~Opnt2Srfc_reg[0];        
            Opnt3Srfc[0] <= ~Opnt3Srfc_reg[0];
            
            if(move_flg_reg == 1)
                ScrollCntr   <=   ScrllIncReg;
            else
                ScrollCntr <= ScrollCntr_reg*10;     	  // scroll by offset of 10 pixels                
            		
	        move_flg <= move_flg_reg;
	end
	else begin // refresh registers
	        //led_reg[4] = 0;
	        main_scrn_disp   <=   main_scrn_disp;
	        move_flg         <=   move_flg;
			PlyrLocX         <=   PlyrLocX;                     
            PlyrLocY         <=   PlyrLocY;       
            Opnt1LocX        <=   Opnt1LocX;           
            Opnt1LocY        <=   Opnt1LocY;         
            Opnt2LocX        <=   Opnt2LocX;          
            Opnt2LocY        <=   Opnt2LocY;        
            Opnt3LocX        <=   Opnt3LocX;          
            Opnt3LocY        <=   Opnt3LocY;          
            
            PlyrPrxmty      <=   0;
            Opnt1Prxmty     <=   0;
            Opnt2Prxmty     <=   0;
            Opnt3Prxmty     <=   0;                                                    

//            PlyrPrxmty      <=   PlyrPrxmty;         
//            Opnt1Prxmty     <=   Opnt1Prxmty;       
//            Opnt2Prxmty     <=   Opnt2Prxmty;       
//            Opnt3Prxmty     <=   Opnt3Prxmty;       
                                                    
            PlyrOrnt         <=   PlyrOrnt;            
            Opnt1Ornt        <=   Opnt1Ornt;           
            Opnt2Ornt        <=   Opnt2Ornt;          
            Opnt3Ornt        <=   Opnt3Ornt;          
                                                        
            PlyrBlkLine      <=   PlyrBlkLine;         
            Opnt1BlkLine     <=   Opnt1BlkLine;        
            Opnt2BlkLine     <=   Opnt2BlkLine;        
            Opnt3BlkLine     <=   Opnt3BlkLine;        
                                                      
            PlyrSrfc         <=   PlyrSrfc;            
            Opnt1Srfc        <=   Opnt1Srfc;           
            Opnt2Srfc        <=   Opnt2Srfc;          
            Opnt3Srfc		 <=   Opnt3Srfc;	
            ScrollCntr       <=   ScrollCntr;
            
            led[3]      <= main_scrn_disp;
            led[1:0]    <= Opnt1Srfc;
            led[2]      <= move_flg;
            //led[3]      <= Opnt1Prxmty;    
	end		                 
end // always - synchronized system register interface
endmodule
		
				

