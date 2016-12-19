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
    output [31:0] keycodeout,
    output reg [2:0] plyr_mot
    );
    
    
    wire kclkf, kdataf;
    reg [7:0]datacur;
    reg [7:0]dataprev;
    reg [3:0]cnt;
    reg [31:0]keycode;
    reg flag;
    
    initial begin
        keycode[31:0]<=0'h00000000;
        cnt<=4'b0000;
        flag<=1'b0;
    end
    
debouncer debounce(
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
        // merge the logic here 
    end
end
    
assign keycodeout=keycode;
 
always @ (posedge flag)
begin
    if(dataprev == 8'hF0)
        plyr_mot <= 3'h00;
    else
    begin
    case(datacur)
               8'h75: plyr_mot <= 3'h01;       // move up
                       
               8'h72: plyr_mot <= 3'h02;       // move down
                        
               8'h6b: plyr_mot <= 3'h03;       // move left
                    
               8'h74: plyr_mot <= 3'h04;       // move right
               
               8'h1A: plyr_mot <= 3'h05;       // Z - superpower

               default: plyr_mot <= 3'h00;   // this condition arrives when the key is released    
        endcase
     end
end
endmodule
