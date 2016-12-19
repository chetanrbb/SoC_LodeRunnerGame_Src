`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/25/2016 06:22:48 PM
// Design Name: 
// Module Name: maze_map_if
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module maze_map_if(
    input                 clk,
    input                 reset,
    input                 wr_strobe,
    input                 rd_strobe,
    input 		[7:0]     AddrIn,			// I/O port address
    input       [7:0]     DataIn,            // Data to be written to I/O register
    output reg  [7:0]     DataOut,        // I/O register data to picoblaze

    input [2:0] plyr_motctl,
    input [2:0] opnt_motctl_1,
    input [2:0] opnt_motctl_2,
    input [2:0] opnt_motctl_3,
    input [1:0] map_info,
    
    // outupt signals from the interface
    // the location of the players and the opponents is taken for the map of 1024x512 size 
    output reg  [9:0]     plyr_locX, opnt_locX_1, opnt_locX_2, opnt_locX_3,
    output reg  [8:0]     plyr_locY, opnt_locY_1, opnt_locY_2, opnt_locY_3,
    // this register is used to latch the data 
    output reg            intr_updt_reg, 
    // blk line or white line sensor for the player and the opponent 
    output reg  [1:0]     blk_wht_snsr_plyr, blk_wht_snsr_opnt1, blk_wht_snsr_opnt2, blk_wht_snsr_opnt3,
    // proximity sensor for the player and the opponent 
    output reg  [1:0]     prxmty_snsr_plyr, prxmty_snsr_opnt_1, prxmty_snsr_opnt_2, prxmty_snsr_opnt_3,
    // oreintation of the player adn the opponent 
    output reg  [1:0]     plyr_ornt, opnt_ornt_1, opnt_ornt_2, opnt_ornt_3,
    // map co-ordinates s
    output reg  [9:0]     map_rw_addr, 
    output reg  [4:0]     map_clmn_addr,
    // scrolling of the map  
    output reg  [4:0]     scroll_cntr  
    );
    
    // latch these signals so that the rec will see constant data values all the time
    reg  [9:0]     reg_plyr_locX, reg_opnt_locX_1, reg_opnt_locX_2, reg_opnt_locX_3;
    reg  [8:0]     reg_plyr_locY, reg_opnt_locY_1, reg_opnt_locY_2, reg_opnt_locY_3;
    reg  [1:0]     reg_blk_wht_snsr_plyr, reg_blk_wht_snsr_opnt1, reg_blk_wht_snsr_opnt2, reg_blk_wht_snsr_opnt3;
    reg  [1:0]     reg_prxmty_snsr_plyr, reg_prxmty_snsr_opnt_1, reg_prxmty_snsr_opnt_2, reg_prxmty_snsr_opnt_3;
    reg  [1:0]     reg_plyr_ornt, reg_opnt_ornt_1, reg_opnt_ornt_2, reg_opnt_ornt_3;

    reg  [4:0]     reg_scroll_cntr;
    
    // OUTPUT 
    // DATA send by the picoblaze 
    always @ (posedge clk)
    begin
        if(reset)
        begin
            reg_plyr_locX   <= 0;
            reg_opnt_locX_1 <= 0;
            reg_opnt_locX_2 <= 0;
            reg_opnt_locX_3 <= 0;
            reg_plyr_locY   <= 0;
            reg_opnt_locY_1 <= 0;
            reg_opnt_locY_2 <= 0;
            reg_opnt_locY_3 <= 0;
            int_updt_reg    <= 0;
            reg_blk_wht_snsr_plyr <= 0;
            reg_blk_wht_snsr_opnt1 <= 0;
            reg_blk_wht_snsr_opnt2 <= 0;
            reg_blk_wht_snsr_opnt3 <= 0;
            reg_prxmty_snsr_plyr <= 0;
            reg_prxmty_snsr_opnt_1 <= 0;
            reg_prxmty_snsr_opnt_2 <= 0;
            reg_prxmty_snsr_opnt_3 <= 0;
            reg_plyr_ornt <= 0;
            reg_opnt_ornt_1 <= 0;
            reg_opnt_ornt_2 <= 0;
            reg_opnt_ornt_3 <= 0;
            reg_scroll_cntr <= 0;
        end 
        else 
        begin
            case (AddrIn[4:0])
            // location of the player on the map 
            5'b00000: reg_plyr_locX <= DataIn;
            5'b00001: reg_plyr_locY <= DataIn;
            // location of opponent 1 on the map
            5'b00010: reg_opnt_locX_1 <= DataIn;
            5'b00011: reg_opnt_locY_1 <= DataIn;
            // location of opponent 2 on the map
            5'b00100: reg_opnt_locX_2 <= DataIn;
            5'b00101: reg_opnt_locY_2 <= DataIn;
            // opponent location on the map
            5'b00110: reg_opnt_locX_3 <= DataIn;
            5'b00111: reg_opnt_locY_3 <= DataIn;
            // white line sensor 
            5'b01000: reg_blk_wht_snsr_plyr <= DataIn;
            5'b01001: reg_blk_wht_snsr_opnt1 <= DataIn;
            5'b01010: reg_blk_wht_snsr_opnt2 <= DataIn;
            5'b01011: reg_blk_wht_snsr_opnt3 <= DataIn;
            // proximity sensor 
            5'b01100: reg_prxmty_snsr_plyr <= DataIn;
            5'b01101: reg_prxmty_snsr_opnt_1 <= DataIn;
            5'b01110: reg_prxmty_snsr_opnt_2 <= DataIn;
            5'b01111: reg_prxmty_snsr_opnt_3 <= DataIn;
            // orientation of the player and opponents
            5'b10000: reg_plyr_ornt <= DataIn;
            5'b10001: reg_opnt_ornt_1 <= DataIn;
            5'b10010: reg_opnt_ornt_2 <= DataIn;
            5'b10011: reg_opnt_ornt_3 <= DataIn;
            
            5'b10100: int_updt_reg <= ~int_updt_reg;    // latch the data 
            5'b10101: reg_scroll_cntr <= DataIn;
            default:  DataOut <= 8'bxxxxxxxx;    
            endcase
        end
    end 
        
    // Data requested by the picoblaze 
    // INPUT
    always @ (posedge clk)
    begin
        case (AddrIn[2:0])
        // input 0: player motion ctrl
        3'b000: DataOut <= {5'b00000, plyr_motctl};
        // input 1: opnt 1 motion ctrl 
        3'b001: DataOut <= {5'b00000, opnt_motctl_1};     
        // input 2: opnt 2 motion ctrl
        3'b010: DataOut <= {5'b00000, opnt_motctl_2};
        // input 3: opnt 3 motion ctrl 
        3'b011: DataOut <= {5'b00000, opnt_motctl_3};
        // map information
        3'b100: DataOut <= {6'b000000, map_info};
        // default cases
        default: DataOut <= 8'bxxxxxxxx;
        endcase 
    end
    
    // latch the data from the internal register to the output register 
    always @(posedge clk)
    begin
        if(reset)
        begin
            plyr_locX   <= 0;
            opnt_locX_1 <= 0;
            opnt_locX_2 <= 0;
            opnt_locX_3 <= 0;
            plyr_locY   <= 0;
            opnt_locY_1 <= 0;
            opnt_locY_2 <= 0;
            opnt_locY_3 <= 0;
            blk_wht_snsr_plyr <= 0;
            blk_wht_snsr_opnt1 <= 0;
            blk_wht_snsr_opnt2 <= 0;
            blk_wht_snsr_opnt3 <= 0;
            prxmty_snsr_plyr <= 0;
            prxmty_snsr_opnt_1 <= 0;
            prxmty_snsr_opnt_2 <= 0;
            prxmty_snsr_opnt_3 <= 0;
            plyr_ornt <= 0;
            opnt_ornt_1 <= 0;
            opnt_ornt_2 <= 0;
            opnt_ornt_3 <= 0;    
        end
        else if(int_updt_reg)       // check if latch flag is enabled 
        begin
            plyr_locX           <= reg_plyr_locX   ;
            opnt_locX_1         <= reg_opnt_locX_1;
            opnt_locX_2         <= reg_opnt_locX_2;
            opnt_locX_3         <= reg_opnt_locX_3;
            plyr_locY           <= reg_plyr_locY;
            opnt_locY_1         <= reg_opnt_locY_1;
            opnt_locY_2         <= reg_opnt_locY_2;
            opnt_locY_3         <= reg_opnt_locY_3;
            blk_wht_snsr_plyr   <= reg_blk_wht_snsr_plyr;                          
            blk_wht_snsr_opnt1  <= reg_blk_wht_snsr_opnt1;
            blk_wht_snsr_opnt2  <= reg_blk_wht_snsr_opnt2;
            blk_wht_snsr_opnt3  <= reg_blk_wht_snsr_opnt3;
            prxmty_snsr_plyr    <= reg_prxmty_snsr_plyr;
            prxmty_snsr_opnt_1  <= reg_prxmty_snsr_opnt_1;
            prxmty_snsr_opnt_2  <= reg_prxmty_snsr_opnt_2;
            prxmty_snsr_opnt_3  <= reg_prxmty_snsr_opnt_3;
            plyr_ornt           <= reg_plyr_ornt;   
            opnt_ornt_1         <= reg_opnt_ornt_1; 
            opnt_ornt_2         <= reg_opnt_ornt_2; 
            opnt_ornt_3         <= reg_opnt_ornt_3; 
        end
    end                                        
    
    // update the scroll counter 
    always @ (posedge clk)
    begin
        if(reset)
            reg_scroll_cntr <= 0;
        else
        begin
            scroll_cntr <= reg_scroll_cntr; 
        end 
    end 
endmodule
