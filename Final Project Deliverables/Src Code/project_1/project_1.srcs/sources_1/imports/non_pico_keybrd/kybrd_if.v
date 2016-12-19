`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.06.2016 00:46:18
// Design Name: 
// Module Name: k_if
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


module kybrd_if(    
    input clk,
    input kclk,
    input kdata, 
    input prox,
    input line,
    input [1:0] surface,
    output reg [2:0] plyr_mot,
    output [31:0] keycodeout
    );
    
wire [2:0] nxt_stp;

PS2Receiver ps2(
    .clk(clk),
    .kclk(kclk),
    .kdata(kdata),
    .keycodeout(keycodeout),
    .plyr_mot(nxt_stp)
);

always @(posedge clk) begin
    if((surface[1:0] == 2'b00)&&(surface[1:0] != 2'b01)) begin  // floor absent and not on ladder then 
        plyr_mot <= 3'h2;                                       // force down
    end
    else
    begin
    case(nxt_stp)
    3'h0: plyr_mot <= 3'h0;
    3'h1: begin
                if ((line ==1'b1) || (surface >= 2'b01))
                                                                //white line(ladder) detected and surface points to land
                        plyr_mot <= 3'h1;                       // move up
                else
                        plyr_mot <= 3'h0;
          end
    3'h2: begin                                     // if down key is pressed and
                if(surface[1:0] == 2'b01)           //If ladder going down is present
                        plyr_mot <= 3'h2;           // move down
                else
                        plyr_mot <= 3'h0;           //else stop motion
         end
                        
   3'h3: begin                                     //if left key is pressed                 
                //if(prox)                      // and wall is detected
                //        plyr_mot <= 3'h0;          //stop motion
                //else
                        plyr_mot <= 3'h3;           //else move left
         end
  
   3'h4: begin                                     // if right key is pressed
//                if(prox)                     // and wall is detected
//                       plyr_mot <= 3'h0;          //stop motion
//                else
                       plyr_mot <= 3'h4;           //else move right
         end
   3'h5: plyr_mot <= 3'h5;
   default: plyr_mot <= 3'h0;
   endcase
   end
end
    
endmodule
