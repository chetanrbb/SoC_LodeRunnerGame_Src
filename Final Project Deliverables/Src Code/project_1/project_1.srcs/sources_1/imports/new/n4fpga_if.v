// n4fpga_if.v - interface the picoblaze with the nexys 4 board 
//
// Author: Chetan Bornarkar, Ashish Patil 
// 
// Description:
// ------------
// This module provides the information from the bot.v to the picoblaze and vice-versa.
// This module also connects the KCPSM6 to the picoblaze. 
// It passes the information from the bot.v like location, sensor, orientaion, 
// distnace travelled to the picoblaze. 
// The picoblaze then controls the bot.v by sending the data to the motion_ctl signal
// of the bot.v   
// The picoblaze also controls the display on LED's and 7 segment displays by showing 
// the distance travelled and orientation and motion of the robot. 
// 
// 
///////////////////////////////////////////////////////////////////////////


module nexys4_if#(
    parameter integer RESET_POLARITY_LOW = 1
)
(
// interface signals with KCPSM6 and picoblaze 
    input             wrstrb, 
                      rdstrb, 
                      k_wrstrb,
                      sysclk,
    input      [7:0]  port_id,            // read the data from the bot.v
                      io_data_in,         // data requested by the picoblaze 
    
    input      [7:0]  locX, locY,         // store location of bot 
                      botinfo, sensors,   // store orientation and sensor information
                      lmdist, rmdist,     // store distance travelled 
               
    input      [4:0]  db_btns,            // read the buttons status
    input      [15:0] db_sw,              // read the switches status 
                      
    output reg [7:0]  io_data_out,        // data sent by the picoblaze
    output reg [7:0]  motctl,             // control the motion control 
    output reg [4:0]  dig0, dig1, dig2,   // display the information on seven seg 
					  dig3, dig4, dig5, 
					  dig6, dig7,         // seven segment digit display
    output reg [7:0]  dec_pts,            // control the decimal points of the seven seg
    output reg [7:0]  led_op_high,        // control the leds[15:8]
                      led_op_low,         // control the leds[7:0]
	
	// interrupt signals 
	input             intr_ack,           // rev the signal from the picoblaze	
    input 		      intreq_upd_sysreg,  // this signal is gen at every 2 sec
	output reg        interrupt           // send the signal to picoblaze 
);
// data requested by the picoblze 
// send the data through data_out port
// take the note of the input ports used by the picoblaze
always @(posedge sysclk)
begin
// input signals 
// one hot encoded for input signal
    case (port_id[4:0])
        // read the push buttons status
        5'h0:  io_data_out <= {3'b000, db_btns};
        5'h10: io_data_out <=  {3'b000, db_btns};
        // read the slide swithces status 
        5'h1:  io_data_out <=  db_sw[7:0];
        5'h11: io_data_out <=  db_sw[15:8];
        // read the location X readings 
        5'hA:  io_data_out <=  locX;
        5'h1A: io_data_out <=  locX;
        // read the location Y readings from bot.v
        5'hB:  io_data_out <=  locY;
        5'h1B: io_data_out <=  locY;
        // read the bot information from bot.v
        5'hC:  io_data_out <=  botinfo;
        5'h1C: io_data_out <=  botinfo;
        // read the sensor information from bot.v
        5'hD:  io_data_out <=  sensors;
        5'h1D: io_data_out <=  sensors;
        // read the distance travelled by left motor 
        5'hE:  io_data_out <=  lmdist;  
        5'h1E: io_data_out <=  lmdist;
        // read the distance travelled by right motor 
        5'hF:  io_data_out <=  rmdist;
        5'h1F: io_data_out <=  rmdist;
		// default condition to acoid latch 
		default: io_data_out <= 8'bxxxxxxxx;
    endcase
end 

// data sent by the picoblaze 
// take the note of the ports used by the picoblaze 
always @(posedge sysclk)
begin
    if (wrstrb == 1)  // check if the write strobe is generated
    begin
       case (port_id[4:0])  // 
            5'h2:  led_op_low   <= io_data_in;   // show the data on the led's
            // show data on seven segment disp [3:0]
            5'h3:  dig3         <= io_data_in;   
            5'h4:  dig2         <= io_data_in;
            5'h5:  dig1         <= io_data_in;
            5'h6:  dig0         <= io_data_in;
            // show data on seven segment disp [7:4]
            5'h13: dig7         <= io_data_in;
            5'h14: dig6         <= io_data_in;
            5'h15: dig5         <= io_data_in;
            5'h16: dig4         <= io_data_in;
            // control the decimap points of lower seven segment displays              
            5'h7:  dec_pts[3:0] <= io_data_in[3:0];
            // control the dec points of higher seven segment displays 
            5'h17: dec_pts[7:4] <= io_data_in[3:0];
            // contorl the motion control register which drives the robot 
            5'h9:  motctl       <= io_data_in;
            5'h19: motctl       <= io_data_in;
            // display the output on the leds[15:8]
            5'h12: led_op_high  <= io_data_in;
            
            default: led_op_high <= 4'h8;	// breadcrump for debugging
       endcase
    end
end

// interrupt generation 
always @ (posedge sysclk) 
begin
	if (intr_ack == 1'b1)          // check if the interupt was acknowledged by PB 
		begin
			interrupt <= 1'b0;     // clear the interrupt signal 
		end
	// data available on bot.v	
	else if (intreq_upd_sysreg == 1'b1) // chcek if interrupt generation was req by bot.v
	begin
		interrupt <= 1'b1;        // enable the interrupt to PB
	end
	
	else
	begin
		interrupt <= interrupt;   // avoid latch 
	end
end // always
endmodule
