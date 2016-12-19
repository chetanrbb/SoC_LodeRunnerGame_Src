`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Portland State University, ECE 540 Embedded System
// Project 2: Simulate RoJobot on VGA screen 
// 
// Author: Chetan Bornarkar, Ashish Patil 
// Module Name:    Icon 
// Create Date:    05/01/2016 
//
// Description: The icon module will read the loc X and Y of the robot and then scale and map the icon image 
//				on the screen. The output of this module is the icon information. If the raster pixel row and column 
//				lie in the area of the icon 16x16 in this case then this module outputs the information of the icon.
//
//
// Used By: Colorizer module: This module has the priority to the icon information and then to the world information. 
//			If the crrent raster pixel row and column are not in the area of the robot's X & Y location then the icon 
// 			information is not given by Icon module and world map is shown. 
//			But when the raster pixel row and col lie in the robots X & Y (magnified) region then the ICon module provides
//			icon's information. This information is then shown on the screen rather than the world information. 
//
//////////////////////////////////////////////////////////////////////////////////

 module Icon(
    input           win, 
    input              dth,             // this input is generated if player dies
    input              main_scrn,
    input       [2:0]  plyr_mot,
                       opnt1_mot,
                       opnt2_mot,
                       opnt3_mot,
                       
    input       [9:0]  scrll_cntr,
	input       	   clk, 
	input 		[9:0]  PlyrLocX,	
	input 		[8:0]  PlyrLocY,
	input       [1:0]  PlyrOrnt,
	
	input 		[9:0]  Opnt1LocX,	
    input       [9:0]  Opnt1LocY,
    input       [1:0]  Opnt1Ornt, 
    
    input 		[9:0]  Opnt2LocX,	
    input       [9:0]  Opnt2LocY,
    input       [1:0]  Opnt2Ornt,
    
    input 		[9:0]  Opnt3LocX,	
    input       [9:0]  Opnt3LocY,
    input       [1:0]  Opnt3Ornt,
    
	input 		[9:0]  pixel_row, pixel_col,
	
	input       [9:0] sndhp1locX, 
                      sndhp1locY,
                      sndhp2locX,
                      sndhp2locY,
                      sndhp3locX,
                      sndhp3locY,
                      sndhp4locX,
                      sndhp4locY,
                      sndhp5locX,
                      sndhp5locY,
                      
    input             sndhp1sig,
                      sndhp2sig,
                      sndhp3sig,
                      sndhp4sig,
                      sndhp5sig,
    output reg        dth_icon_disp, win_icon_disp,
    output reg [1:0] icon_map, 
    output reg icon_dth, icon_win,
	output reg 	[1:0]  icon, icon_opnt1, icon_opnt2, icon_opnt3,  
	output reg         icon_snd1, icon_snd2, icon_snd3, icon_snd4, icon_snd5
	);
	
	//wire [9:0] locX_mgnfy, locY_mgnfy;	// remapping robot location to VGA display resolution
	//reg  [9:0] align_locX, align_locY;	// position of image's left top conner pixel
	reg  [18:0] pixel_address_main_scrn;
	reg  [9:0] pixel_address, 
	           pixel_address_ovr_scrn,
	           pixel_address_win_scrn,
	           pixel_address_opnt1,
	           pixel_address_opnt2, 
	           pixel_address_opnt3,
	           pixel_address_sand; 			// currently design to have 2 images (256 byte each) in ROM
	
	reg 	   enable;
//	reg    dth_icon_disp;
//	reg   win_icon_disp;
	wire [1:0] plyr_info_s,  
	           plyr_info_r,
	           plyr_info_u,	           
	           
	           opnt1_info_s,
	           opnt1_info_r,
	           opnt1_info_u,
	           
	           opnt2_info_s,
	           opnt2_info_r,
	           opnt2_info_u,
	           
	           opnt3_info_r,
	           opnt3_info_u,
	           opnt3_info_s,
	           
	           main_scrn_info,
	           ovr_scrn_info,
	           win_scrn_info;
    wire       snd_info1, snd_info2, snd_info3, snd_info4, snd_info5; 
	           
	reg  [4:0] x,y;						// x and y indexing into rom image
	reg  [4:0] x1, y1, x2, y2, x3, y3, y4, x4, y5, y6, y7, x5, x6, x7, y8, x8;
	
	reg  [4:0] x_scrl,y_scrl;						// x and y indexing into rom image
    reg  [4:0] x1_scrl, y1_scrl, x2_scrl, y2_scrl, x3_scrl, y3_scrl;
	reg        tgl_icn;
	//
	
	reg     [31:0]      clk_cnt;             // clock speed reduced for scrolling the image 
    wire    [31:0]      top_clk_cnt = 5000000;        // max clock count value // clk of 10hz 
    
    reg     [9:0]   opnt1_locX_reg, opnt2_locX_reg, opnt3_locX_reg;
    
    always @(posedge clk)
    begin
        if((clk_cnt == top_clk_cnt) )
        begin
            clk_cnt <= 0;
            tgl_icn <= ~tgl_icn;
        end 
        //else if(intr_ack == 1'b1)
        else
        begin
            //tgl_icn <= 0;
            clk_cnt <= clk_cnt + 1; 
        end 
    end 
  
    snd_hp sndhp1inst(
        .clka(clk),
        .addra(pixel_address_sand),
        .douta(snd_info1)
    );
    
    snd_hp sndhp2inst(
            .clka(clk),
            .addra(pixel_address_sand),
            .douta(snd_info2)
        );
      
    snd_hp sndhp3inst(
                .clka(clk),
                .addra(pixel_address_sand),
                .douta(snd_info3)
            );
          
     snd_hp sndhp4inst(
                    .clka(clk),
                    .addra(pixel_address_sand),
                    .douta(snd_info4)
                );
                
     snd_hp sndhp5inst(
                        .clka(clk),
                        .addra(pixel_address_sand),
                        .douta(snd_info5)
                    );
    MAIN_SCRN mnscrn(
        .clka(clk),
        .addra(pixel_address_main_scrn),
        .douta(main_scrn_info)
    );

    GAME_WIN gmwnscrn(
        .clka(clk),
        .addra(pixel_address_win_scrn),
        .douta(win_scrn_info)
    );
    
    GAME_OVER gmovrscrn(
        .clka(clk),
        .addra(pixel_address_ovr_scrn),
        .douta(ovr_scrn_info)
    );
    
	ICON_Plyr plyr_s(				// Instantiate the Icon modules created using the IP 
		.clka(clk),
		.addra(pixel_address),
		.douta(plyr_info_s)
	);
	
	plyr_run_e plyr_run(
		.clka(clk),
        .addra(pixel_address),
        .douta(plyr_info_r)
	);
	
	ICON_PLYR_U plyr_u(				// Instantiate the Icon modules created using the IP 
       .clka(clk),
       .addra(pixel_address),
       .douta(plyr_info_u)
    );
	
	
	Opnt_Icon1 opnt1(			// Instantitate the Icon module for 45 degree direction created using the IP
       .clka(clk),
       .addra(pixel_address_opnt1),
       .douta(opnt1_info_s)
    );
    
    Opnt1_Icon_R opnt1_r(
       .clka(clk),
       .addra(pixel_address_opnt1),
       .douta(opnt1_info_r)
    );
    
    Opnt1_Icon_U opnt1_u(
        .clka(clk),
        .addra(pixel_address_opnt1),
        .douta(opnt1_info_u)
    );
          
    Opnt_Icon1 opnt2(			// Instantitate the Icon module for 45 degree direction created using the IP
        .clka(clk),
        .addra(pixel_address_opnt2),
        .douta(opnt2_info_s)
    );
    
    Opnt1_Icon_R opnt2_r(
        .clka(clk),
        .addra(pixel_address_opnt2),
        .douta(opnt2_info_r)
    );
    
    Opnt1_Icon_U opnt2_u(
        .clka(clk),
        .addra(pixel_address_opnt2),
        .douta(opnt2_info_u)
    );
          
    Opnt_Icon1 opnt3(			// Instantitate the Icon module for 45 degree direction created using the IP
        .clka(clk),
        .addra(pixel_address_opnt3),
        .douta(opnt3_info_s)
    );
    
    Opnt1_Icon_R opnt3_r(
        .clka(clk),
        .addra(pixel_address_opnt3),
        .douta(opnt3_info_r)
    );
    
    Opnt1_Icon_U opnt3_u(
        .clka(clk),
        .addra(pixel_address_opnt3),
        .douta(opnt3_info_u)
    );

	always @ (posedge clk) begin
		// get the starting point of the icon to be shown on the screen
		if(main_scrn) // main screen is to be displayed 
		begin
		  pixel_address_main_scrn <= {pixel_row[8:0], pixel_col[8:0]}; 
		  icon_map <= main_scrn_info;
		  //icon_map <= 2'b01;
		end
		else if(dth)
		begin
		  dth_icon_disp <= 1;
		  pixel_address_ovr_scrn <= {pixel_row[8:0], pixel_col[8:0]};  // disp the end screen
		  dth_icon_disp <= ovr_scrn_info;
		end
		else if (win)
		begin
           win_icon_disp <= 1;
           pixel_address_win_scrn <= {pixel_row[8:0], pixel_col[8:0]};  // disp the end screen
           win_icon_disp <= win_scrn_info;
        end
		else //if(!dth)//if(main_scrn == 0)
		begin
		    y <= (pixel_row[8:0] - PlyrLocY); 
		    x <= (pixel_col[9:0] - PlyrLocX);
		    y1 <= (pixel_row[8:0]- Opnt1LocY);
		    x1 <= (pixel_col[9:0]- Opnt1LocX);
		    
		    y2 <= (pixel_row[8:0]- Opnt2LocY);
            x2 <= (pixel_col[9:0]- Opnt2LocX);
            
            y3 <= (pixel_row[8:0]- Opnt3LocY);
            x3 <= (pixel_col[9:0]- Opnt3LocX);
            
            y4 <= (pixel_row[8:0]- sndhp1locY);
            x4 <= (pixel_col[9:0]- sndhp1locX);
            
            y5 <= (pixel_row[8:0]- sndhp2locY);
            x5 <= (pixel_col[9:0]- sndhp2locX);
            
            y6 <= (pixel_row[8:0]- sndhp3locY);
            x6 <= (pixel_col[9:0]- sndhp3locX);
            
            y7 <= (pixel_row[8:0]- sndhp4locY);
            x7 <= (pixel_col[9:0]- sndhp4locX);
                        
            y8 <= (pixel_row[8:0]- sndhp5locY);
            x8 <= (pixel_col[9:0]- sndhp5locX);
                                    
            if(sndhp1sig)
            begin
                if( (pixel_col >= sndhp1locX)  
                && (pixel_col  <= ((sndhp1locX) + 5'd31))
                && (pixel_row  >= sndhp1locY)
                && (pixel_row <= sndhp1locY + 5'd31))
                begin
                     pixel_address_sand <= {x4, y4};    // 0 degree
                    icon_snd1 <= snd_info1;
                end
                else 
                begin 
                    pixel_address_sand <= 0;
                    icon_snd1 <= 0;
                end 
            end 
            
            if(sndhp2sig)
            begin                 
                if( (pixel_col >= sndhp2locX)  
                && (pixel_col  <= ((sndhp2locX) + 5'd31))
                && (pixel_row  >= sndhp2locY)
                && (pixel_row <= sndhp2locY + 5'd31))
                begin
                   pixel_address_sand <= {y5, x5};    // 0 degree
                   icon_snd2 <= snd_info2;
                end
                else 
                begin 
                   pixel_address_sand <= 0;
                   icon_snd2 <= 0;
                end
            end 
            
            if(sndhp3sig)
            begin     
               if( (pixel_col >= sndhp3locX)  
                 && (pixel_col  <= ((sndhp3locX) + 5'd31))
                 && (pixel_row  >= sndhp3locY)
                 && (pixel_row <= sndhp3locY + 5'd31))
                begin
                    pixel_address_sand <= {x6, y6};    // 0 degree
                    icon_snd3 <= snd_info3;
                end
                else 
                begin 
                            pixel_address_sand <= 0;
                            icon_snd3 <= 0;
                end
            end 
            
            if(sndhp4sig)
            begin            
            if( (pixel_col >= sndhp4locX)  
             && (pixel_col  <= ((sndhp4locX) + 5'd31))
             && (pixel_row  >= sndhp4locY)
             && (pixel_row <= sndhp4locY + 5'd31))
            begin
               pixel_address_sand <= {y7, x7};    // 0 degree
               icon_snd4 <= snd_info4;
            end
            else 
                        begin 
                            pixel_address_sand <= 0;
                            icon_snd4 <= 0;
                        end
            end 
            
            if(sndhp5sig)
            begin
            if( (pixel_col >= sndhp5locX)  
             && (pixel_col  <= ((sndhp5locX) + 5'd31))
             && (pixel_row  >= sndhp5locY)
             && (pixel_row <= sndhp5locY + 5'd31))
            begin
               pixel_address_sand <= {x8, y8};    // 0 degree
               icon_snd5 <= snd_info5;
            end
            else 
             begin
                 pixel_address_sand <= 0;
                 icon_snd5 <= 0;
             end
            end 
        // OPNT1 
        opnt1_locX_reg <= Opnt1LocX;
            
		if( (pixel_col >= opnt1_locX_reg)  
           && (pixel_col  <= ((Opnt1LocX) + 10'd31))
           && (pixel_row  >= Opnt1LocY)
           && (pixel_row <= Opnt1LocY + 10'd31))
          
          begin
              if(opnt1_mot == 3'b000)
              begin
                if(Opnt1Ornt == 2'd2)  // right
                   pixel_address_opnt1 <= {y1, x1};    // 0 degree
                else // left 
                   pixel_address_opnt1 <= {y1, 5'b11111 - x1};     // 180 degrees
                icon_opnt1 <= opnt1_info_s;
              end
              else 
              begin
//                  pixel_address_opnt <= {y1,x1};     
//                  icon_opnt <= pxl_info_opnt;
              case (Opnt1Ornt[1:0])	// read the orientation of the bot 
                   // For UP 
                   2'd0:    begin    
                            if(tgl_icn)
                                pixel_address_opnt1 <= {y1, x1};    // 0 degree
                            else 
                                pixel_address_opnt1 <= {y1, 5'b11111 - x1};    // 0 degree
                            icon_opnt1 <= opnt1_info_u;
                            end
                            
                   // For Right  
                   2'd2:    begin
                            pixel_address_opnt1 <= {y1, x1};    // 0 degree
                            if(tgl_icn)
                                icon_opnt1 <= opnt1_info_s;
                            else 
                                icon_opnt1 <= opnt1_info_r;
                            end
                            
                   // For Down 
                   2'd1:    begin 
                            if(tgl_icn)
                                pixel_address_opnt1 <= {y1, x1};    // 0 degree
                            else 
                                pixel_address_opnt1 <= {y1, 5'b11111 - x1};    // 0 degree
                            icon_opnt1 <= opnt1_info_u;
                            end
                            
                   // For Left  
                   2'd3:    begin
                            pixel_address_opnt1 <= {y1, 5'b11111 - x1};     // 180 degrees
                            if(tgl_icn)
                                icon_opnt1 <= opnt1_info_s;
                            else 
                                icon_opnt1 <= opnt1_info_r;
                            end
               endcase     
               end
        end
        else    // else for if1
        begin
            pixel_address_opnt1 <= 0;
            icon_opnt1 <= 0;
        end // end of if 1
        
        // OPNT2
//        if(pixel_col >= Opnt2LocY)
//            opnt2_locX_reg <= Opnt2LocX + (scrll_cntr/10);
//        else 
            opnt2_locX_reg <= Opnt2LocX;
                    
        if( (pixel_col >= opnt2_locX_reg)
            && (pixel_col  <= ((Opnt2LocX) + 10'd31))
            && (pixel_row  >= Opnt2LocY)
            && (pixel_row  <= (Opnt2LocY + 10'd31)))
          
          begin
          if(opnt2_mot == 3'b000)
          begin
            if(Opnt2Ornt == 2'd2)  // right
               pixel_address_opnt2 <= {y2, x2};    // 0 degree
            else // left 
               pixel_address_opnt2 <= {y2, 5'b11111 - x2};     // 180 degrees
            icon_opnt2 <= opnt2_info_s;
          end
          else 
          begin
//              pixel_address_opnt2 <= {y2,x2};     
//              icon_opnt2 <= pxl_info_opnt2;
          case (Opnt2Ornt[1:0])	// read the orientation of the bot 
               // For UP 
               2'd0:    begin
                        if(tgl_icn)
                            pixel_address_opnt2 <= {y2, x2};    // 0 degree
                        else 
                            pixel_address_opnt2 <= {y2, 5'b11111 - x2};    // 0 degree
                        icon_opnt2 <= opnt2_info_u;
                        end
                        
               // For Right  
               2'd2:    begin
                        pixel_address_opnt2 <= {y2, x2};    // 0 degree
                        if(tgl_icn)
                            icon_opnt2 <= opnt2_info_s;
                        else 
                            icon_opnt2 <= opnt2_info_r;
                        end
                        
               // For Down 
               2'd1:    begin 
                        if(tgl_icn)
                            pixel_address_opnt2 <= {y2, x2};    // 0 degree
                        else 
                            pixel_address_opnt2 <= {y2, 5'b11111 - x2};    // 0 degree
                        icon_opnt2 <= opnt2_info_u;
                        end
                        
               // For Left  
               2'd3:    begin
                        pixel_address_opnt2 <= {y2, 5'b11111 - x2};     // 180 degrees
                        if(tgl_icn)
                            icon_opnt2 <= opnt2_info_s;
                        else 
                            icon_opnt2 <= opnt2_info_r;
                        end
           endcase     
           end
          end
          else 
          begin
              pixel_address_opnt2 <= 0;
              icon_opnt2 <= 0;
          end
        
        // OPNT3        
//        if(pixel_col >= Opnt3LocX)
//            opnt3_locX_reg <= Opnt3LocX + (scrll_cntr/pixel_col);//(scrll_cntr/pixel_col);
//        else 
//            opnt3_locX_reg <= Opnt3LocX;
                            
        if( ((pixel_col  )>= Opnt3LocX)
             && ((pixel_col) <= ((Opnt3LocX) + 10'd31))
             && (pixel_row >= Opnt3LocY)
             && (pixel_row <= (Opnt3LocY + 10'd31)))
           
           begin
           if(opnt3_mot == 3'b000)
           begin
             if(Opnt3Ornt == 2'd2)  // right
                pixel_address_opnt3 <= {y3, x3};    // 0 degree
             else // left 
                pixel_address_opnt3 <= {y3, 5'b11111 - x3};     // 180 degrees
             icon_opnt3 <= opnt3_info_s;
           end
           else 
           begin
               //pixel_address_opnt3 <= {y3,x3};     
               //icon_opnt3 <= pxl_info_opnt3;
               case (Opnt3Ornt[1:0])	// read the orientation of the bot 
                   // For UP 
                   2'd0:    begin
                            if(tgl_icn)
                                pixel_address_opnt3 <= {y3, x3};    // 0 degree
                            else 
                                pixel_address_opnt3 <= {y3, 5'b11111 - x3};    // 0 degree
                            icon_opnt3 <= opnt3_info_u;
                            end
                            
                   // For Right  
                   2'd2:    begin
                            pixel_address_opnt3 <= {y3, x3};    // 0 degree
                            if(tgl_icn)
                                icon_opnt3 <= opnt3_info_s;
                            else 
                                icon_opnt3 <= opnt3_info_r;
                            end
                            
                   // For Down 
                   2'd1:    begin 
                            if(tgl_icn)
                                pixel_address_opnt3 <= {y3, x3};    // 0 degree
                            else 
                                pixel_address_opnt3 <= {y3, 5'b11111 - x3};    // 0 degree
                            icon_opnt3 <= opnt3_info_u;
                            end
                            
                   // For Left  
                   2'd3:    begin
                            pixel_address_opnt3 <= {y3, 5'b11111 - x3};     // 180 degrees
                            if(tgl_icn)
                                icon_opnt3 <= opnt3_info_s;
                            else 
                                icon_opnt3 <= opnt3_info_r;
                            end
               endcase
               end     
           end
           else 
           begin
               pixel_address_opnt3 <= 0;
               icon_opnt3 <= 0;
           end
        
        // PLYR   
		   // check if the raster pixel information is in the area of the icon's 16x16 area 
		if( (pixel_col ) >= PlyrLocX  
		     && (pixel_col ) <= (PlyrLocX + 10'd31)
		     && (pixel_row ) >= PlyrLocY
		     && (pixel_row ) <= (PlyrLocY + 10'd31)
		   ) 
		   begin
		       if(plyr_mot == 3'd0)   // stop 
		       begin
		          if(PlyrOrnt == 2'd3)
		              pixel_address <= {y, x};    // 0 degree
		          else
		              pixel_address <= {y, 5'b11111 - x};    // 0 degree
		          icon <= plyr_info_s;
		       end
		       else 
		       begin
			   case (PlyrOrnt[1:0])	// read the orientation of the bot 
                   // For UP 
                   2'd0:    begin
                            if(tgl_icn)
                                pixel_address <= {y, x};    // 0 degree
                            else 
                                pixel_address <= {y, 5'b11111 - x};    // 0 degree
                            icon <= plyr_info_u;
                            end
                            
                   // For Right  
                   2'd3:    begin
                            pixel_address <= {y, x};    // 0 degree
                            if(tgl_icn)
                                icon <= plyr_info_s;
                            else 
                                icon <= plyr_info_r;
                            end
                            
                   // For Down 
                   2'd1:    begin 
                            if(tgl_icn)
                                pixel_address <= {y, x};    // 0 degree
                            else 
                                pixel_address <= {y, 5'b11111 - x};    // 0 degree
                            icon <= plyr_info_u;
                            end
                            
                   // For Left  
                   2'd2:    begin
                            pixel_address <= {y, 5'b11111 - x};     // 180 degrees
                            if(tgl_icn)
                                icon <= plyr_info_s;
                            else 
                                icon <= plyr_info_r;
                            end
               endcase
               end
  		   end
		   else begin	// the raster pixel x & Y donot match the area of the icons location 
			   pixel_address <= 0;
			   icon <= 0;	        // 0 means transparent	
		   end
       end
//       else 
//                 begin
//                     icon <= 0;
//                 end
	end
	
endmodule

