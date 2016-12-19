`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Portland State University, ECE 540 Embedded System
// Project 2: RoJobot world
// 
// Author: Chetan Bornarkar, Ashish Patil 
// Create Date: 05/01/2016  
//
// Description: This module will display the information of the world map or the icon.
//				The priority is given to icon when its data is received so that it appears that 
//				the icon is on top of the black line 
//				when the information of the icon is not available then the world map is shown 
//				Thus even if the icon has windows in it the windows will be visible on screen using 
//				this algorithm 
//
//////////////////////////////////////////////////////////////////////////////////
module colorizer(
    input           plyr_blnk,
    input           win, 
    input               dth, 
    input 			   clk,
    input               dth_disp, win_disp,
    input 		[1:0]  World,
    input 		[1:0]  Icon,
    input       [1:0]  IconOpnt, IconOpnt2, IconOpnt3, main_scrn_disp_info, 
    input              IconSnd1, IconSnd2, IconSnd3, IconSnd4, IconSnd5,
	input 		 	   video_on,
	input              main_scrn_disp, 
    output reg  [11:0] COLOR  // 3 outs RGB combination together to form a 12 bit colour code
    );
	
	// dummy register to avoid latches formation 
	reg [11:0] dummy;	// for color information 
	
	// The color information is in the format of R,G,B
	parameter BLACK = 12'b000000000000;
	parameter WHITE	= 12'b111111111111;
	parameter RED	= 12'b011100000000;
	parameter GREEN	= 12'b000011110000;
	parameter BLUE 	= 12'b000000001111;
	parameter ORANGE = 12'b111101110000;
	parameter DARKRED = 12'b001100000000;
	
	always @(posedge clk)
	begin
		if (video_on == 0)		// if video off, output black
			COLOR <= BLACK;
		
		// video signal ON 
		else begin
		if(main_scrn_disp)
		begin
		  case (main_scrn_disp_info)		// else, mux 2-bit World to determine 8-bit color
          2'b01    :    COLOR <= WHITE;    // background color for map
          2'b00    :    COLOR <= BLACK; // black line for map outline
          2'b10    :    COLOR <= DARKRED;    // obstacle
          2'b11    :    COLOR <= BLUE;
          endcase
		end
	   else if(win)
		begin
		  case (win_disp)		// else, mux 2-bit World to determine 8-bit color
                          1'b0    :    COLOR <= WHITE;    // background color for map
                          1'b1    :    COLOR <= BLACK; // black line for map outline
                          
                          endcase
		end
		else if(dth)
		begin
		  case (dth_disp)		// else, mux 2-bit World to determine 8-bit color
                  1'b0    :    COLOR <= WHITE;    // background color for map
                  1'b1    :    COLOR <= BLACK; // black line for map outline
                  endcase
		  
				end  
		else if (Icon && plyr_blnk) 	// Icon high priority 
		begin			// if icon is any color but black, pass through
		    if(Icon == 2'b11)
		       COLOR <= ORANGE;
			else if(Icon == 2'b10)
				COLOR <= RED;
				
			else if(Icon == 2'b01)
				COLOR <= BLUE;
			
			//if(Icon == 2'b11)
			else
		        COLOR <=  BLACK;
		end
		else if(IconOpnt)
		begin
		    if(IconOpnt == 2'b01)
               COLOR <= WHITE;
            else if(IconOpnt == 2'b10)
                COLOR <= RED;
            else if(IconOpnt == 2'b11)
                COLOR <= GREEN;
            //if(IconOpnt == 2'b01)
            else
                COLOR <= BLACK;
//            else
//                dummy <= GREEN;        // avoid the latch formation
		end
		// world priority second 
	    else if(IconOpnt2)
        begin
            if(IconOpnt2 == 2'b01)
               COLOR <= WHITE;
            else if(IconOpnt2 == 2'b10)
                COLOR <= RED;
            else if(IconOpnt2 == 2'b11)
                COLOR <= GREEN;
            //if(IconOpnt == 2'b01)
            else
                COLOR <= BLACK;
        end
		else if(IconOpnt3)
        begin
            if(IconOpnt3 == 2'b01)
               COLOR <= WHITE;
            else if(IconOpnt3 == 2'b10)
                COLOR <= RED;
            else if(IconOpnt3 == 2'b11)
                COLOR <= GREEN;
            //if(IconOpnt == 2'b01)
            else
                COLOR <= BLACK;
        end
        else if(IconSnd1)
        begin
            if(IconSnd1 == 2'b01)
               COLOR <= ORANGE;//WHITE;
            
            else
                COLOR <= BLACK;
        end
        else if(IconSnd2)
                begin
                    if(IconSnd2 == 2'b01)
                       COLOR <= ORANGE;
                    else
                        COLOR <= BLACK;
                end
        else if(IconSnd3)
                        begin
                            if(IconSnd3 == 2'b01)
                               COLOR <= ORANGE;
                            //if(IconOpnt == 2'b01)
                            else
                                COLOR <= BLACK;
                        end
        else if(IconSnd4)
                                begin
                                    if(IconSnd4 == 2'b01)
                                       COLOR <= ORANGE;
                                    else
                                        COLOR <= BLACK;
                                end
        else if(IconSnd5)
                                        begin
                                            if(IconSnd5 == 2'b01)
                                               COLOR <= ORANGE;
                                            else
                                                COLOR <= BLACK;
                                        end
        else
		begin
			case (World)		// else, mux 2-bit World to determine 8-bit color
				2'b00	:	COLOR <= WHITE;	// background color for map
				2'b01	:	COLOR <= BLACK; // black line for map outline
				2'b10	:	COLOR <= DARKRED;	// obstacle
				2'b11	:	COLOR <= RED;	
				// all cases are covered so no need of default case 
			endcase
		end
		end
	end
endmodule
