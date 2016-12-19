        module opp_algo_block
    #(
      parameter SURFACE_SENSOR_DETECTS_HOLE   = 2'd0,
      parameter SURFACE_SENSOR_DETECTS_FLOOR  = 2'd2,
      parameter SURFACE_SENSOR_DETECTS_LADDER = 2'd1,
      parameter SURFACE_SENSOR_RESET          = 2'd3,
      
      parameter BW_SENSOR_DETECTS_LADDER      = 1'd1,
      parameter BW_SENSOR_RESET               = 1'd0,
      
      parameter PROXIMITY_SENSOR_DETECTS_WALL = 1'd1,
      parameter PROXIMITY_SENSOR_RESET        = 1'd0,
      
      //debugging parameters
      parameter DEBUG_OPPONENT_1              = 1'd1,
      parameter DEBUG_OPPONENT_2              = 0'd0,
      parameter DEBUG_OPPONENT_3              = 0'd0,
      
      parameter LED_X_INCREASE_OPP            = 8'b00000_100,  // OPPONENT 1 USES LEDS 8,9 FOR DEBUGGING
      parameter LED_X_DECREASE_OPP            = 8'b00000_011,
      parameter LED_Y_INCREASE_OPP            = 8'b00000_010,
      parameter LED_Y_DECREASE_OPP            = 8'b00000_001,
      
      parameter LED_OPP_PROXIMITY_SENSOR_OBS  = 8'b00_1_00000,
      parameter LED_OPP_BW_SENSOR_            = 8'b000_1_0000,
      parameter LED_OPP_SURFACE_SENSOR_BLACK  = 8'b00000000,   // OPPONENT 1 USES LEDS 14,15 FOR SHOWING PROXIMITY SENSOR DATA
      parameter LED_OPP_SURFACE_SENSOR_WHITE  = 8'b01000000,
      parameter LED_OPP_SURFACE_SENSOR_RED    = 8'b10000000,
      
      
      // motion controls
      parameter INCREASE_X = 3'd4,
      parameter DECREASE_X = 3'd3,
      parameter INCREASE_Y = 3'd2,
      parameter DECREASE_Y = 3'd1,
      parameter STOP       = 3'd0,
      
      // player life parameters
      parameter PLAYER_ALIVE = 1'b0,
      parameter PLAYER_DEAD  = 1'b1,
      
      // interrupt status parameters
      parameter INTERRUPT_IS_HIGH = 1'b1
     )
   (
    output   reg   [2:0]   motion_opp_1,           // motor control to Opponent 1
    output   reg   [2:0]   motion_opp_2,           // motor control to Opponent 2
    output   reg   [2:0]   motion_opp_3,           // motor control to Opponent 3
    
    output   reg           player_death,           // signal to indicate player death
    
    //for debugging
    output   reg   [7:0]   led,
    input                   btnCpuReset,              // red pushbutton input -> db_btns[0]   

    input           [10:0]   locX_player,         // returns X-cordinate of the Player's current location
    input           [10:0]   locY_player,         // returns Y-cordinate of the Player's current location

    input           [10:0]   locX_opp_1,          // returns X-cordinate of Opponent 1 current location
    input          [10:0]   locY_opp_1,          // returns Y-cordinate of Opponent 1 current location

    input           [10:0]   locX_opp_2,          // returns X-cordinate of Opponent 2 current location
    input          [10:0]   locY_opp_2,          // returns Y-cordinate of Opponent 2 current location

    input           [10:0]   locX_opp_3,          // returns X-cordinate of Opponent 3 current location
    input          [10:0]   locY_opp_3,          // returns Y-cordinate of Opponent 3 current location

    input                      proximity_sensor_opp_1,          //  Opponent 1 Sensors
    input                      bw_sensor_opp_1,                 // 
    input           [1:0]   surface_sensor_opp_1,            //  

    input                      proximity_sensor_opp_2,          //  Opponent 2 Sensors
    input                      bw_sensor_opp_2,                 // 
    input           [1:0]   surface_sensor_opp_2,            //  

    input                      proximity_sensor_opp_3,          // Opponent 3 Sensors
    input                      bw_sensor_opp_3,                 // 
    input           [1:0]   surface_sensor_opp_3,
    
    input                  upsysregs                        // interrupt pulse received from the external world
);           

// internal registers for getting the data from outer world
reg   [10:0]   locX_player_intreg;         // returns X-cordinate of the Player's current location
reg   [10:0]   locY_player_intreg;         // returns Y-cordinate of the Player's current location

reg   [10:0]   locX_opp_1_intreg;          // returns X-cordinate of Opponent 1 current location
reg   [10:0]   locY_opp_1_intreg;          // returns Y-cordinate of Opponent 1 current location

reg   [10:0]   locX_opp_2_intreg;          // returns X-cordinate of Opponent 2 current location
reg   [10:0]   locY_opp_2_intreg;          // returns Y-cordinate of Opponent 2 current location

reg   [10:0]   locX_opp_3_intreg;          // returns X-cordinate of Opponent 3 current location
reg   [10:0]   locY_opp_3_intreg;          // returns Y-cordinate of Opponent 3 current location

reg           proximity_sensor_opp_1_intreg;          //  Opponent 1 Sensors
reg             bw_sensor_opp_1_intreg;                 // 
reg   [1:0]   surface_sensor_opp_1_intreg;            //  

reg             proximity_sensor_opp_2_intreg;          //  Opponent 2 Sensors
reg           bw_sensor_opp_2_intreg;                 // 
reg   [1:0]   surface_sensor_opp_2_intreg;            //  

reg           proximity_sensor_opp_3_intreg;          // Opponent 3 Sensors
reg           bw_sensor_opp_3_intreg;                 // 
reg   [1:0]   surface_sensor_opp_3_intreg;

reg   [7:0]  leds_intreg, led_temp;
reg           debug_flag_opponent_1 = DEBUG_OPPONENT_1;
reg           debug_flag_opponent_2 = DEBUG_OPPONENT_2;
reg           debug_flag_opponent_3 = DEBUG_OPPONENT_3;

// variable to indicate player death by an opponents
reg           player_death_by_opp_1;
reg           player_death_by_opp_2;
reg           player_death_by_opp_3;

// when player is alive
initial begin
  player_death_by_opp_1 <= PLAYER_ALIVE;  
  player_death_by_opp_2 <= PLAYER_ALIVE;
  player_death_by_opp_3 <= PLAYER_ALIVE;
  player_death          <= PLAYER_ALIVE;
end

// all the input data is read into the input registers on the positive clock edge
always@(posedge upsysregs) begin
  locX_player_intreg <= locX_player;         // returns X-cordinate of the Player's current location
  locY_player_intreg <= locY_player;         // returns Y-cordinate of the Player's current location
  
  locX_opp_1_intreg  <= locX_opp_1;          // returns X-cordinate of Opponent 1 current location
  locY_opp_1_intreg  <= locY_opp_1;          // returns Y-cordinate of Opponent 1 current location

  locX_opp_2_intreg <= locX_opp_2;          // returns X-cordinate of Opponent 2 current location
  locY_opp_2_intreg <= locY_opp_2;          // returns Y-cordinate of Opponent 2 current location

  locX_opp_3_intreg <= locX_opp_3;          // returns X-cordinate of Opponent 3 current location
  locY_opp_3_intreg <= locY_opp_3;          // returns Y-cordinate of Opponent 3 current location
 
  proximity_sensor_opp_1_intreg <= proximity_sensor_opp_1;          //  Opponent 1 Sensors
  bw_sensor_opp_1_intreg        <= bw_sensor_opp_1;                 // 
  surface_sensor_opp_1_intreg   <= surface_sensor_opp_1;            //  
  
  proximity_sensor_opp_2_intreg <= proximity_sensor_opp_2;          //  Opponent 2 Sensors
  bw_sensor_opp_2_intreg        <= bw_sensor_opp_2;                 // 
  surface_sensor_opp_2_intreg   <= surface_sensor_opp_2;            //  

  proximity_sensor_opp_3_intreg <= proximity_sensor_opp_3;          // Opponent 3 Sensors
  bw_sensor_opp_3_intreg        <= bw_sensor_opp_3;                 // 
  surface_sensor_opp_3_intreg   <= surface_sensor_opp_3;
  
  player_death_by_opp_1         <= player_death_by_opp_1;
  player_death_by_opp_1         <= player_death_by_opp_2;
  player_death_by_opp_1         <= player_death_by_opp_3;    
end

//
task motion_ctrl(output [2:0] motion_op, 
                 input  [1:0] srfc_sensor,
                 input          bw_snsr,
                 input           blk_line_snsr,
                 input           prxmty_snsr, 
                 input     [10:0] locYOpnt, 
                 input  [10:0] locXOpnt,
                 input  [10:0] locYPlyr, 
                 input  [10:0] locXPlyr,
                 input            PlyrDth);
begin 
    // no surface but not on ladder also 
    if ((srfc_sensor == SURFACE_SENSOR_DETECTS_HOLE) && (bw_snsr != BW_SENSOR_DETECTS_LADDER) ) 
    begin
        motion_op <= INCREASE_Y;     // go down forcefully 
    end
    // opponent on surface // opnt locY < plyr Y -> go down if white line found   
    else if (locYOpnt < locYPlyr)  // opp is above the player
    begin
        // check if standing on ladder to go down 
        if (srfc_sensor == SURFACE_SENSOR_DETECTS_LADDER)
        begin
            motion_op <= INCREASE_Y; // go down
        end
        // has to go down but no ladder found // on surface 
        //else if (surface_sensor_opp_1_intreg >= SURFACE_SENSOR_DETECTS_FLOOR)
        if ((locXOpnt < locXPlyr) && (prxmty_snsr != PROXIMITY_SENSOR_DETECTS_WALL))
        begin  // it means no proximity is detected; clear path ahead
             motion_op <= INCREASE_X;
        end
        else 
        begin
             motion_op <= DECREASE_X;
        end
    end 

    else if (locYOpnt > locYPlyr)
    begin
        if (bw_snsr == BW_SENSOR_DETECTS_LADDER)
        begin
            motion_op <= DECREASE_Y;
        end
        
        if ((locXOpnt < locXPlyr) && (prxmty_snsr != PROXIMITY_SENSOR_DETECTS_WALL))
        begin  // it means no proximity is detected; clear path ahead
            motion_op <= INCREASE_X;
        end
        else 
        begin
            motion_op <= DECREASE_X;
        end
    end
     
    else if (locYOpnt == locYPlyr)
    begin
        if ((locXOpnt < locXPlyr) && (prxmty_snsr != PROXIMITY_SENSOR_DETECTS_WALL))
        begin 
            motion_op <= INCREASE_X;
        end 
        else if (locXOpnt > locXPlyr)
            motion_op <= DECREASE_X;
        else 
        begin
            motion_op <= STOP;
            PlyrDth   <= PLAYER_DEAD;
        end                      
    end
end 

// ALGORITHM for Opponent 1
always@(negedge upsysregs) 
begin
    motion_ctrl(motion_opp_1, 
                surface_sensor_opp_1_intreg,
                bw_sensor_opp_1_intreg,
                proximity_sensor_opp_1_intreg, 
                locY_opp_1_intreg, 
                locX_opp_1_intreg,
                locY_player_intreg, 
                locX_player_intreg,
                player_death_by_opp_1);
                
    motion_ctrl(motion_opp_2, 
                surface_sensor_opp_2_intreg,
                bw_sensor_opp_2_intreg,
                proximity_sensor_opp_2_intreg, 
                locY_opp_2_intreg, 
                locX_opp_2_intreg,
                locY_player_intreg, 
                locX_player_intreg,
                player_death_by_opp_2);
    
    motion_ctrl(motion_opp_3, 
                surface_sensor_opp_3_intreg,
                bw_sensor_opp_3_intreg,
                proximity_sensor_opp_3_intreg, 
                locY_opp_3_intreg, 
                locX_opp_3_intreg,
                locY_player_intreg, 
                locX_player_intreg,
                player_death_by_opp_3);
end


always@(*) begin
    player_death = player_death_by_opp_1 | player_death_by_opp_2 | player_death_by_opp_3;
end

endmodule