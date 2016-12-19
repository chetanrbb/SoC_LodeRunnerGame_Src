`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Thomas Kappenman
// 
// Create Date: 03/03/2015 09:33:36 PM
// Design Name: 
// Module Name: PS2Receiver
// Project Name: Nexys4DDR Keyboard Demo
// Target Devices: Nexys4DDR
// Tool Versions: 
// Description: PS2 Receiver module used to shift in keycodes from a keyboard plugged into the PS2 port
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PS2Receiver(
    input clk,
    input kclk,
    input kdata,
    // trial code 
    input PlyrPrxmty,
    input PlyrBlkLine,          // 0- blk, 1- white 
    input [1:0] PlyrSrfc,
    input int_upd_sysres,
    
    output [31:0] keycodeout,
    output [2:0] plyr_mot_out,
    output reg [3:0] led
    );
    
    reg PlyrPrxmty_reg1, PlyrPrxmty_reg2;
    reg PlyrBlkLine_reg1, PlyrBlkLine_reg2;
    reg [1:0] PlyrSrfc_reg1, PlyrSrfc_reg2;
    
    wire kclkf, kdataf;
    reg [7:0]datacur;
    reg [7:0]dataprev;
    reg [3:0]cnt;
    reg [31:0]keycode;
    reg flag;
    reg [2:0] plyr_mot;
    
    initial begin
        keycode[31:0]<=0'h00000000;
        cnt<=4'b0000;
        flag<=1'b0;
    end
    
debouncer debouncer(
    .clk(clk),
    .I0(kclk),
    .I1(kdata),
    .O0(kclkf),
    .O1(kdataf)
);
    
always@(negedge(kclkf))begin
    case(cnt)
    0:;//Start bit
    1:datacur[0]<=kdataf;
    2:datacur[1]<=kdataf;
    3:datacur[2]<=kdataf;
    4:datacur[3]<=kdataf;
    5:datacur[4]<=kdataf;
    6:datacur[5]<=kdataf;
    7:datacur[6]<=kdataf;
    8:datacur[7]<=kdataf;
    9:flag<=1'b1;
    10:flag<=1'b0;
    
    endcase
        if(cnt<=9) cnt<=cnt+1;
        else if(cnt==10) cnt<=0;
        
end

always @(posedge flag)begin
    if (dataprev!=datacur)begin
        keycode[31:24]<=keycode[23:16];
        keycode[23:16]<=keycode[15:8];
        keycode[15:8]<=dataprev;
        keycode[7:0]<=datacur;
        dataprev<=datacur;
    end
    
end


//always @(posedge flag or int_upd_sysres) begin
always @ (*)
begin
    //if(int_upd_sysres)          // check for high edge of int_upd_sysres
    begin
        led[1:0] <= PlyrSrfc;
        if((PlyrSrfc[1:0] == 2'b00) && (PlyrSrfc[1:0] != 2'b01))        // condition will be satisfied when there is no ground
        begin
            plyr_mot <= 8'h02;          // force move down
        end 
        else
        begin
            
            //begin
//                // Condition for: when player moving up the ladder -> there is no surface 
                // but the player is supposed to move up and not move force down
                //led[3] <= 1;
                case(datacur)
                8'h75: begin 
                        if((PlyrBlkLine == 1) || (PlyrSrfc == 2'b01))   // check if white line is available 
                           plyr_mot <= 8'h01;       // move up
                         else
                           plyr_mot <= 2'b00;
                       end
                8'h72: begin
                         if(PlyrSrfc == 2'h01)   // check if white line is available  
                          plyr_mot <= 8'h02;       // move down
                         else
                           plyr_mot <= 2'b00;
                       end
                8'h6b: begin
                    // check if there is wall in front 
                    // if wall is in front then donot move ahead in this direction
                    if(PlyrPrxmty)                  // wall is in front
                    begin
                        plyr_mot <= 8'h00;      //  
                    end
                    // there is no wall in front then move ahead in this direction 
                    else begin 
                        plyr_mot <= 8'h03;       // move left
                    end
                   end 
                8'h74: // check if there is wall in front 
                    // if there is wall in front then donot move frwd
                   begin
                   if(PlyrPrxmty)                  // wall is in front
                   begin
                      plyr_mot <= 8'h00;      //  
                   end
                   // move frwd 
                   else
                      plyr_mot <= 8'h04;       // move right
                   end
                default: plyr_mot <= 8'h00;   // this condition arrives when the key is released    
                endcase
               
                if(dataprev == 8'hF0)      // this condition will arrive when key is released 
                begin
                    plyr_mot <= 2'b00;              // stop motion
                    //datacur <= 8'h00;
                end
                            
            // end
        end
     end 
end
    
assign keycodeout=keycode;
assign plyr_mot_out = plyr_mot; 
    
endmodule
