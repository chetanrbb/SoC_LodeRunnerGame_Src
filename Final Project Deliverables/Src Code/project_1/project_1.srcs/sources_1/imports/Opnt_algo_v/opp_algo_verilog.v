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
              
              parameter LED_X_INCREASE_OPP            = 8'b00000_100,  // OPPONENT USES LEDS 8,9 FOR DEBUGGING
              parameter LED_X_DECREASE_OPP            = 8'b00000_011,
              parameter LED_Y_INCREASE_OPP            = 8'b00000_010,
              parameter LED_Y_DECREASE_OPP            = 8'b00000_001,
              
              parameter LED_OPP_PROXIMITY_SENSOR_OBS  = 8'b00_1_00000,
              parameter LED_OPP_BW_SENSOR_            = 8'b000_1_0000,
              parameter LED_OPP_SURFACE_SENSOR_BLACK  = 8'b00000000,   // OPPONENT USES LEDS 14,15 FOR SHOWING PROXIMITY SENSOR DATA
              parameter LED_OPP_SURFACE_SENSOR_WHITE  = 8'b01000000,
              parameter LED_OPP_SURFACE_SENSOR_RED    = 8'b10000000,
              
        //	  parameter LED_X_INCREASE_OPP_2          = 8'b00000000, // OPPONENT 2 USES LEDS 10,11 FOR DEBUGGING
        //      parameter LED_X_DECREASE_OPP_2          = 8'b00000100,
        //      parameter LED_Y_INCREASE_OPP_2          = 8'b00001000,
        //      parameter LED_Y_DECREASE_OPP_2          = 8'b00001100,
              
        //	  parameter LED_X_INCREASE_OPP_3          = 8'b00000000, // OPPONENT 1 USES LEDS 12,13 FOR DEBUGGING
        //      parameter LED_X_DECREASE_OPP_3          = 8'b00010000,
        //      parameter LED_Y_INCREASE_OPP_3          = 8'b00100000,
        //      parameter LED_Y_DECREASE_OPP_3          = 8'b00110000,
              
              // motion controls
              parameter INCREASE_X = 3'd4,
              parameter DECREASE_X = 3'd3,
              parameter INCREASE_Y = 3'd2,
              parameter DECREASE_Y = 3'd1,
              parameter STOP       = 3'd0,
              
              // player life parameters
              parameter PLAYER_ALIVE = 1'b0,
              parameter PLAYER_DEAD  = 1'b1
              
              // interrupt status parameters
              //parameter INTERRUPT_IS_HIGH = 1'b1
             )
           (
            output   reg   [2:0]   motion_opp_1,           // motor control to Opponent 1
            output   reg   [2:0]   motion_opp_2,           // motor control to Opponent 2
            output   reg   [2:0]   motion_opp_3,           // motor control to Opponent 3
            
            output   reg           player_death,           // signal to indicate player death
            
            //for debugging
            output   reg   [7:0]   led,
            input				   btnCpuReset,			  // red pushbutton input -> db_btns[0]   
        
            input	       [10:0]   locX_player,         // returns X-cordinate of the Player's current location
            input	       [10:0]   locY_player,         // returns Y-cordinate of the Player's current location
        
            input	       [10:0]   locX_opp_1,          // returns X-cordinate of Opponent 1 current location
            input          [10:0]   locY_opp_1,          // returns Y-cordinate of Opponent 1 current location
        
            input	       [10:0]   locX_opp_2,          // returns X-cordinate of Opponent 2 current location
            input          [10:0]   locY_opp_2,          // returns Y-cordinate of Opponent 2 current location
        
            input	       [10:0]   locX_opp_3,          // returns X-cordinate of Opponent 3 current location
            input          [10:0]   locY_opp_3,          // returns Y-cordinate of Opponent 3 current location
        
            input	       		   proximity_sensor_opp_1,          //  Opponent 1 Sensors
            input	       		   bw_sensor_opp_1,                 // 
            input	       [1:0]   surface_sensor_opp_1,            //  
        
            input	       		   proximity_sensor_opp_2,          //  Opponent 2 Sensors
            input	       		   bw_sensor_opp_2,                 // 
            input	       [1:0]   surface_sensor_opp_2,            //  
        
            input	       		   proximity_sensor_opp_3,          // Opponent 3 Sensors
            input	       		   bw_sensor_opp_3,                 // 
            input	       [1:0]   surface_sensor_opp_3,
            
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
        reg   	      bw_sensor_opp_1_intreg;                 // 
        reg   [1:0]   surface_sensor_opp_1_intreg;            //  
        
        reg   	      proximity_sensor_opp_2_intreg;          //  Opponent 2 Sensors
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
        
         //DATA processed when upsysregs is high; not when it is going from high to low
         
            always@(upsysregs == 1'b1) begin
                // SHOWING data ON led FOR DEBUGGING OPPONENT 1
              // SHOWING PROXIMITY SENSOR DATA FOR OPPONENT ON LED 14,15
                if(debug_flag_opponent_1) begin
                   if(surface_sensor_opp_1_intreg == SURFACE_SENSOR_DETECTS_HOLE) begin
                      led[7:6] <= 2'd0;
                      led[7:6] <= LED_OPP_SURFACE_SENSOR_BLACK[7:6]; 
                   end
                          
                   if(surface_sensor_opp_1_intreg == SURFACE_SENSOR_DETECTS_LADDER) begin
                      led[7:6] <= 2'd0;
                      led[7:6] <= LED_OPP_SURFACE_SENSOR_WHITE[7:6]; 
                   end
                          
                   if(surface_sensor_opp_1_intreg == SURFACE_SENSOR_DETECTS_FLOOR) begin
                      led[7:6] <= 2'd0;
                      led[7:6] <= LED_OPP_SURFACE_SENSOR_RED[7:6];
                   end
                          
                   if(proximity_sensor_opp_1_intreg == PROXIMITY_SENSOR_DETECTS_WALL)
                      led[5] <= 1'd1;
                   else 
                      led[5] <= 1'd0;
                          
                   if(bw_sensor_opp_1_intreg == BW_SENSOR_DETECTS_LADDER)
                      led[4] <= 1'd1;
                   else
                      led[4] <= 1'd0;
                end // debug end 
            
            //end
        
// ALGORITHM for Opponent 1
// no surface but not on ladder also 
            if (surface_sensor_opp_1_intreg == SURFACE_SENSOR_DETECTS_HOLE) begin
                motion_opp_1 <= INCREASE_Y;     // go down forcefully 
                if(debug_flag_opponent_1)
                begin
                  led[2:0] <= 3'd0;
                  led[2:0] <= LED_Y_INCREASE_OPP[2:0];
                end 
            end
        // opponent on surface 
        // opnt locY < plyr Y -> go down if white line found   
            else if (locY_opp_1_intreg < locY_player_intreg)  // opp is above the player
            begin
                // check if standing on ladder to go down 
                if (surface_sensor_opp_1_intreg == SURFACE_SENSOR_DETECTS_LADDER)
                begin
                    motion_opp_1 <= INCREASE_Y; // go down
                    if(debug_flag_opponent_1)
                    begin
                        led[2:0]<=3'd0;
                        led[2:0] <= LED_Y_INCREASE_OPP[2:0];
                    end 
                end
                // has to go down but no ladder found 
                // on surface 
                else begin    
                    if ((locX_opp_1_intreg <= locX_player_intreg) && (proximity_sensor_opp_1_intreg != PROXIMITY_SENSOR_DETECTS_WALL))
                    begin  // it means no proximity is detected; clear path ahead
                        motion_opp_1 <= INCREASE_X;
                        if(debug_flag_opponent_1)
                        begin
                            led[2:0] <= 3'd0;
                            led[2:0] <= LED_X_INCREASE_OPP[2:0];
                        end 
                    end
                    else 
                    begin
                        motion_opp_1 <= DECREASE_X;
                        if(debug_flag_opponent_1)
                        begin
                            led[2:0]<=3'd0;
                            led[2:0] <= LED_X_DECREASE_OPP[2:0];
                        end 
                    end
                 end
              end 
        
              else if (locY_opp_1_intreg > locY_player_intreg)
              begin
                if (bw_sensor_opp_1_intreg == BW_SENSOR_DETECTS_LADDER)
                begin
                    motion_opp_1 <= DECREASE_Y;
                    if(debug_flag_opponent_1)
                    begin
                        led[2:0]<=3'd0;
                        led[2:0] <= LED_Y_DECREASE_OPP[2:0];
                    end 
                end
                else
                begin
                    if(proximity_sensor_opp_1_intreg != PROXIMITY_SENSOR_DETECTS_WALL)
                    begin  // it means no proximity is detected; clear path ahead
                     if (locX_opp_1_intreg >= locX_player_intreg) begin
                        motion_opp_1 <= DECREASE_X;
                     end
                        if(debug_flag_opponent_1)
                        begin
                            led[2:0]<=3'd0;
                            led[2:0] <= LED_X_DECREASE_OPP[2:0];
                        end 
                    end
                    else 
                    begin
                        motion_opp_1 <= INCREASE_X;
                        if(debug_flag_opponent_1)
                        begin
                            led[2:0]<=3'd0;
                            led[2:0] <= LED_X_INCREASE_OPP[2:0];
                        end 
                    end
                end
             end
             
             else if (locY_opp_1_intreg == locY_player_intreg)
             begin
//               if(surface_sensor_opp_1_intreg == SURFACE_SENSOR_DETECTS_FLOOR)
//                    begin
                        if (proximity_sensor_opp_1_intreg != PROXIMITY_SENSOR_DETECTS_WALL)
                        begin  // it means no proximity is detected; clear path ahead
                          if (locX_opp_1_intreg < locX_player_intreg)  begin 
                            motion_opp_1 <= INCREASE_X;
                            if(debug_flag_opponent_1)
                            begin
                                led[2:0]<=3'd0;
                                led[2:0] <= LED_X_INCREASE_OPP[2:0];
                            end
                            else if (locX_opp_1_intreg > locX_player_intreg) begin
                              motion_opp_1 <= DECREASE_X;
                              if(debug_flag_opponent_1)
                              begin
                                  led[2:0]<=3'd0;
                                  led[2:0] <= LED_X_DECREASE_OPP[2:0];
                              end 
                            end
                            else begin
                              motion_opp_1 <= STOP;
                              player_death_by_opp_1 <= PLAYER_DEAD;
                            end					  
                          end
                        end
                    end
              //end		
        end	
//        // START OF OPP 2 ALGORITHM           
        
//        always@(negedge upsysregs) begin
//                 // SHOWING data ON led FOR DEBUGGING FOR OPPONENT 2
//               // SHOWING PROXIMITY SENSOR DATA FOR OPPONENT ON LED 14,15
//                 if(debug_flag_opponent_2)
//                 begin
//                   if(surface_sensor_opp_2_intreg == SURFACE_SENSOR_DETECTS_HOLE)
//                   begin
//                       led[7:6] <= 2'd0;
//                       led[7:6] <= LED_OPP_SURFACE_SENSOR_BLACK[7:6]; 
//                   end
                       
//                   if(surface_sensor_opp_2_intreg == SURFACE_SENSOR_DETECTS_LADDER)
//                   begin
//                       led[7:6] <= 2'd0;
//                       led[7:6] <= LED_OPP_SURFACE_SENSOR_WHITE[7:6]; 
//                   end
                       
//                   if(surface_sensor_opp_2_intreg == SURFACE_SENSOR_DETECTS_FLOOR)
//                   begin
//                       led[7:6]<=2'd0;
//                       led[7:6] <= LED_OPP_SURFACE_SENSOR_RED[7:6];
//                   end
                       
//                   if(proximity_sensor_opp_2_intreg == PROXIMITY_SENSOR_DETECTS_WALL)
//                       led[5] <= 1'd1;
//                   else 
//                       led[5]<=1'd0;
                       
//                   if(bw_sensor_opp_2_intreg == BW_SENSOR_DETECTS_LADDER)
//                       led[4] <= 1'd1;
//                   else
//                       led[4]<=1'd0;
                   
//                 end // debug end      
        
//        //ALGORITHM FOR OPPONENT 2
//        // no surface but not on ladder also 
//            if ( (surface_sensor_opp_2_intreg == SURFACE_SENSOR_DETECTS_HOLE) && (bw_sensor_opp_2_intreg != BW_SENSOR_DETECTS_LADDER) )
//            begin
//                motion_opp_2 <= INCREASE_Y;     // go down forcefully 
//                if(debug_flag_opponent_1)
//                begin
//                  led[2:0]<=3'd0;
//                  led[2:0] <= LED_Y_INCREASE_OPP[2:0];
//                end 
//            end
//        // opponent on surface 
//        // opnt locY < plyr Y -> go down if white line found   
//            else if (locY_opp_2_intreg < locY_player_intreg)  // opp is above the player
//            begin
//                // check if standing on ladder to go down 
//                if (surface_sensor_opp_2_intreg == SURFACE_SENSOR_DETECTS_LADDER)
//                begin
//                    motion_opp_2 <= INCREASE_Y; // go down
//                    if(debug_flag_opponent_2)
//                    begin
//                        led[2:0]<=3'd0;
//                        led[2:0] <= LED_Y_INCREASE_OPP[2:0];
//                    end 
//                end
//                // has to go down but no ladder found 
//                // on surface 
//                else if (surface_sensor_opp_2_intreg == SURFACE_SENSOR_DETECTS_FLOOR)
//                begin   // floor can be red or orange
//        //            // CODE CHANGED BY CHETAN
//        //            // since the opponent is on floor but has to go down it will search the player location 
//        //            // if player on left then move left  
//        //            // also check if there is no wall in front
//        //            //  
//        //            if ((locX_opp_2_intreg > locX_player_intreg) && (proximity_sensor_opp_2_intreg != PROXIMITY_SENSOR_DETECTS_WALL))
//        //            begin
//        //                motion_opp_2 <= DECREASE_X;
//        //            end
//        //            else // the player is on the right side 
//        //                motion_opp_2 <= INCREASE_X;
                        
//        //            // END OF CODE CHANGE BY CHETAN
//        // above code addition is integrated in the following if-else condition 
//                    if ((locX_opp_2_intreg < locX_player_intreg) && (proximity_sensor_opp_2_intreg != PROXIMITY_SENSOR_DETECTS_WALL))
//                    begin  // it means no proximity is detected; clear path ahead
//                        motion_opp_2 <= INCREASE_X;
//                        if(debug_flag_opponent_2)
//                        begin
//                            led[2:0]<=3'd0;
//                            led[2:0] <= LED_X_INCREASE_OPP[2:0];
//                        end 
//                    end
//                    else 
//                    begin
//                        motion_opp_2 <= DECREASE_X;
//                        if(debug_flag_opponent_2)
//                        begin
//                            led[2:0]<=3'd0;
//                            led[2:0] <= LED_X_DECREASE_OPP[2:0];
//                        end 
//                    end
//                 end
//              end 
        
//              else if (locY_opp_2_intreg > locY_player_intreg)
//              begin
//                if (bw_sensor_opp_2_intreg == BW_SENSOR_DETECTS_LADDER)
//                begin
//                    motion_opp_2 <= DECREASE_Y;
//                    if(debug_flag_opponent_2)
//                    begin
//                        led[2:0]<=3'd0;
//                        led[2:0] <= LED_Y_DECREASE_OPP[2:0];
//                    end 
//                end
//                else if ((surface_sensor_opp_2_intreg == SURFACE_SENSOR_DETECTS_FLOOR) || (surface_sensor_opp_2_intreg == SURFACE_SENSOR_DETECTS_LADDER))
//                begin
//                    if(proximity_sensor_opp_2_intreg != PROXIMITY_SENSOR_DETECTS_WALL)
//                    begin  // it means no proximity is detected; clear path ahead
//                     if (locX_opp_2_intreg > locX_player_intreg) begin
//                        motion_opp_2 <= DECREASE_X;
//                     end
//                        if(debug_flag_opponent_2)
//                        begin
//                            led[2:0] <= 3'd0;
//                            led[2:0] <= LED_X_DECREASE_OPP[2:0];
//                        end 
//                    end
//                    else 
//                    begin
//                        motion_opp_2 <= INCREASE_X;
//                        if(debug_flag_opponent_2)
//                        begin
//                            led[2:0]<=3'd0;
//                            led[2:0] <= LED_X_INCREASE_OPP[2:0];
//                        end 
//                    end
//                end
//             end
             
//             else if (locY_opp_2_intreg == locY_player_intreg)
//             begin
//               if(surface_sensor_opp_2_intreg == SURFACE_SENSOR_DETECTS_FLOOR)
//                    begin
//                        if (proximity_sensor_opp_2_intreg != PROXIMITY_SENSOR_DETECTS_WALL)
//                        begin  // it means no proximity is detected; clear path ahead
//                          if (locX_opp_2_intreg < locX_player_intreg) begin 
//                            motion_opp_2 <= INCREASE_X;
//                            if(debug_flag_opponent_2)
//                            begin
//                                led[2:0]<=3'd0;
//                                led[2:0] <= LED_X_INCREASE_OPP[2:0];
//                            end
//                            else if (locX_opp_2_intreg > locX_player_intreg) begin
//                              motion_opp_2 <= DECREASE_X;
//                              if(debug_flag_opponent_2)
//                              begin
//                                  led[2:0]<=3'd0;
//                                  led[2:0] <= LED_X_DECREASE_OPP[2:0];
//                              end 
//                            end
//                            else begin
//                              motion_opp_2 <= STOP;
//                              player_death_by_opp_2 <= PLAYER_DEAD;
//                            end					  
//                          end
//                        end
//                    end
//             end		
//        end

//// START OF OPPONENT ALGORITHM 3
//always@(negedge upsysregs) begin
//         // SHOWING data ON led FOR DEBUGGING FOR OPPONENT 2
//       // SHOWING PROXIMITY SENSOR DATA FOR OPPONENT ON LED 14,15
//         if(debug_flag_opponent_3)
//         begin
//           if(surface_sensor_opp_3_intreg == SURFACE_SENSOR_DETECTS_HOLE)
//           begin
//               led[7:6] <= 2'd0;
//               led[7:6] <= LED_OPP_SURFACE_SENSOR_BLACK[7:6]; 
//           end
               
//           if(surface_sensor_opp_3_intreg == SURFACE_SENSOR_DETECTS_LADDER)
//           begin
//               led[7:6] <= 2'd0;
//               led[7:6] <= LED_OPP_SURFACE_SENSOR_WHITE[7:6]; 
//           end
               
//           if(surface_sensor_opp_3_intreg == SURFACE_SENSOR_DETECTS_FLOOR)
//           begin
//               led[7:6] <= 2'd0;
//               led[7:6] <= LED_OPP_SURFACE_SENSOR_RED[7:6];
//           end
               
//           if(proximity_sensor_opp_3_intreg == PROXIMITY_SENSOR_DETECTS_WALL)
//               led[5] <= 1'd1;
//           else 
//               led[5]<=1'd0;
               
//           if(bw_sensor_opp_3_intreg == BW_SENSOR_DETECTS_LADDER)
//               led[4] <= 1'd1;
//           else
//               led[4]<=1'd0;
           
//         end // debug end      

////ALGORITHM FOR OPPONENT 3
//// no surface but not on ladder also 
//    if ((surface_sensor_opp_3_intreg == SURFACE_SENSOR_DETECTS_HOLE) && (bw_sensor_opp_3_intreg != BW_SENSOR_DETECTS_LADDER)) begin
//        motion_opp_3 <= INCREASE_Y;     // go down forcefully 
//        if(debug_flag_opponent_3)
//        begin
//          led[2:0] <= 3'd0;
//          led[2:0] <= LED_Y_INCREASE_OPP[2:0];
//        end 
//    end
//// opponent on surface 
//// opnt locY < plyr Y -> go down if white line found   
//    else if (locY_opp_3_intreg < locY_player_intreg)  // opp is above the player
//    begin
//        // check if standing on ladder to go down 
//        if (surface_sensor_opp_3_intreg == SURFACE_SENSOR_DETECTS_LADDER)
//        begin
//            motion_opp_3 <= INCREASE_Y; // go down
//            if(debug_flag_opponent_3)
//            begin
//                led[2:0] <= 3'd0;
//                led[2:0] <= LED_Y_INCREASE_OPP[2:0];
//            end 
//        end
//        // has to go down but no ladder found 
//        // on surface 
//        else if (surface_sensor_opp_3_intreg == SURFACE_SENSOR_DETECTS_FLOOR)
//        begin   // floor can be red or orange
////            // CODE CHANGED BY CHETAN
////            // since the opponent is on floor but has to go down it will search the player location 
////            // if player on left then move left  
////            // also check if there is no wall in front
////            //  
////            if ((locX_opp_2_intreg > locX_player_intreg) && (proximity_sensor_opp_2_intreg != PROXIMITY_SENSOR_DETECTS_WALL))
////            begin
////                motion_opp_2 <= DECREASE_X;
////            end
////            else // the player is on the right side 
////                motion_opp_2 <= INCREASE_X;
                
////            // END OF CODE CHANGE BY CHETAN
//// above code addition is integrated in the following if-else condition 
//            if ((locX_opp_3_intreg < locX_player_intreg) && (proximity_sensor_opp_3_intreg != PROXIMITY_SENSOR_DETECTS_WALL))
//            begin  // it means no proximity is detected; clear path ahead
//                motion_opp_3 <= INCREASE_X;
//                if(debug_flag_opponent_3)
//                begin
//                    led[2:0] <= 3'd0;
//                    led[2:0] <= LED_X_INCREASE_OPP[2:0];
//                end 
//            end
//            else 
//            begin
//                motion_opp_3 <= DECREASE_X;
//                if(debug_flag_opponent_3)
//                begin
//                    led[2:0] <= 3'd0;
//                    led[2:0] <= LED_X_DECREASE_OPP[2:0];
//                end 
//            end
//         end
//      end 

//      else if (locY_opp_3_intreg > locY_player_intreg)
//      begin
//        if (bw_sensor_opp_3_intreg == BW_SENSOR_DETECTS_LADDER)
//        begin
//            motion_opp_3 <= DECREASE_Y;
//            if(debug_flag_opponent_3)
//            begin
//                led[2:0] <= 3'd0;
//                led[2:0] <= LED_Y_DECREASE_OPP[2:0];
//            end 
//        end
//        else if ((surface_sensor_opp_3_intreg == SURFACE_SENSOR_DETECTS_FLOOR) || (surface_sensor_opp_3_intreg == SURFACE_SENSOR_DETECTS_LADDER))
//        begin
//            if(proximity_sensor_opp_3_intreg != PROXIMITY_SENSOR_DETECTS_WALL)
//            begin  // it means no proximity is detected; clear path ahead
//             if (locX_opp_3_intreg > locX_player_intreg) begin
//                motion_opp_3 <= DECREASE_X;
//             end
//                if(debug_flag_opponent_3)
//                begin
//                    led[2:0] <= 3'd0;
//                    led[2:0] <= LED_X_DECREASE_OPP[2:0];
//                end 
//            end
//            else 
//            begin
//                motion_opp_3 <= INCREASE_X;
//                if(debug_flag_opponent_3)
//                begin
//                    led[2:0] <= 3'd0;
//                    led[2:0] <= LED_X_INCREASE_OPP[2:0];
//                end 
//            end
//        end
//     end
     
//     else if (locY_opp_3_intreg == locY_player_intreg)
//     begin
//       if(surface_sensor_opp_3_intreg == SURFACE_SENSOR_DETECTS_FLOOR)
//            begin
//                if (proximity_sensor_opp_3_intreg != PROXIMITY_SENSOR_DETECTS_WALL)
//                begin  // it means no proximity is detected; clear path ahead
//                  if (locX_opp_3_intreg < locX_player_intreg) begin 
//                    motion_opp_3 <= INCREASE_X;
//                    if(debug_flag_opponent_3)
//                    begin
//                        led[2:0] <= 3'd0;
//                        led[2:0] <= LED_X_INCREASE_OPP[2:0];
//                    end
//                    else if (locX_opp_3_intreg > locX_player_intreg) begin
//                      motion_opp_3 <= DECREASE_X;
//                      if(debug_flag_opponent_3)
//                      begin
//                          led[2:0]<=3'd0;
//                          led[2:0] <= LED_X_DECREASE_OPP[2:0];
//                      end 
//                    end
//                    else begin
//                      motion_opp_3 <= STOP;
//                      player_death_by_opp_3 <= PLAYER_DEAD;
//                    end                      
//                  end
//                end
//            end
//     end        
//end

//     always@(*) begin
//            player_death = player_death_by_opp_1 | player_death_by_opp_2 | player_death_by_opp_3;
//     end
        
endmodule