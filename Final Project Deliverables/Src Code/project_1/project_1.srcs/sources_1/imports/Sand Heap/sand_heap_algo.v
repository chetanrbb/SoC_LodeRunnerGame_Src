module sand_heap
   #(
     parameter SAND_HEAP_PRESENT = 1'b0
     )
   (
   input       [9:0] scrll_cntr,
   input            move_flg, 
   input 			 reset, 
   input 			 updt_clk, 
   input       [9:0] locX_player,
   input       [9:0] locY_player,
   output reg         sand_heap_1_signal,
   output reg         sand_heap_2_signal,
   output reg         sand_heap_3_signal,
   output reg         sand_heap_4_signal,
   output reg         sand_heap_5_signal,
   
   output reg  [9:0]  sand_heap_1_locX,
   output reg  [9:0]  sand_heap_1_locY,
   output reg  [9:0]  sand_heap_2_locX,
   output reg  [9:0]  sand_heap_2_locY,
   output reg  [9:0]  sand_heap_3_locX,
   output reg  [9:0]  sand_heap_3_locY,
   output reg  [9:0]  sand_heap_4_locX,
   output reg  [9:0]  sand_heap_4_locY, 
   output reg  [9:0]  sand_heap_5_locX,
   output reg  [9:0]  sand_heap_5_locY,
   output reg          win_flg,
   output reg  [2:0]  score
   );
   
   //internal variables for default sanh heap locations
   reg  [9:0]  sand_heap_1_locX_reg = 10'd366;
   reg  [9:0]  sand_heap_1_locY_reg = 10'd379;
   reg  [9:0]  sand_heap_2_locX_reg = 10'd187;
   reg  [9:0]  sand_heap_2_locY_reg = 10'd263;
   reg  [9:0]  sand_heap_3_locX_reg = 10'd634;
   reg  [9:0]  sand_heap_3_locY_reg = 10'd263;
   reg  [9:0]  sand_heap_4_locX_reg = 10'd323;
   reg  [9:0]  sand_heap_4_locY_reg = 10'd147;
   reg  [9:0]  sand_heap_5_locX_reg = 10'd839;
   reg  [9:0]  sand_heap_5_locY_reg = 10'd43;
   
   reg  sand_heap_1_signal_reg ;
   reg  sand_heap_2_signal_reg ;
   reg  sand_heap_3_signal_reg ;
   reg  sand_heap_4_signal_reg ;
   reg  sand_heap_5_signal_reg ;
   
   // counter for sand heaps
///////////////////////////////////////////////////////////////////////////
// instantiate sand heap icon ROM here
//////////////////////////////////////////////////////////////////////////   
always @ (posedge updt_clk)
begin
    if(reset) 
    begin
    sand_heap_1_signal  <= 1;
    sand_heap_2_signal  <= 1;
    sand_heap_3_signal  <= 1;
    sand_heap_4_signal  <= 1;
    sand_heap_5_signal  <= 1; 
    end
    else
    begin
    sand_heap_1_locX <= sand_heap_1_locX_reg;
        sand_heap_1_locY <= sand_heap_1_locY_reg;
        sand_heap_2_locX <= sand_heap_2_locX_reg;
        sand_heap_2_locY <= sand_heap_2_locY_reg;
        sand_heap_3_locX <= sand_heap_3_locX_reg;
        sand_heap_3_locY <= sand_heap_3_locY_reg;
        sand_heap_4_locX <= sand_heap_4_locX_reg;
        sand_heap_4_locY <= sand_heap_4_locY_reg;
        sand_heap_5_locX <= sand_heap_5_locX_reg;
        sand_heap_5_locY <= sand_heap_5_locY_reg;
    sand_heap_1_signal  <= sand_heap_1_signal_reg;
    sand_heap_2_signal  <= sand_heap_2_signal_reg;
    sand_heap_3_signal  <= sand_heap_3_signal_reg;
    sand_heap_4_signal  <= sand_heap_4_signal_reg;
    sand_heap_5_signal  <= sand_heap_5_signal_reg;
    end
end

always @ (posedge updt_clk)
begin
  if(reset)
  begin
	score <= 3'd0;
	sand_heap_1_signal_reg <= 1;
    sand_heap_2_signal_reg <= 1;
    sand_heap_3_signal_reg <= 1;
    sand_heap_4_signal_reg <= 1;
    sand_heap_5_signal_reg <= 1;
    
    sand_heap_1_locX_reg = 10'd366;
    sand_heap_1_locY_reg = 10'd379;
    sand_heap_2_locX_reg = 10'd187;
    sand_heap_2_locY_reg = 10'd263;
    sand_heap_3_locX_reg = 10'd634;
    sand_heap_3_locY_reg = 10'd263;
    sand_heap_4_locX_reg = 10'd323;
    sand_heap_4_locY_reg = 10'd147;
    sand_heap_5_locX_reg = 10'd839;
    sand_heap_5_locY_reg = 10'd43; 
    
  end
  else if(move_flg)
  begin 
  if((locY_player < 5'd20) && (locY_player > 0))
    win_flg = 1;
  else
    win_flg = 0;
  if((sand_heap_1_locX == locX_player) && (((sand_heap_1_locY + 5'd16) >= locY_player) 
                                            && ((sand_heap_1_locY + 5'd31) < (locY_player + 5'd31))))
  begin
      sand_heap_1_signal_reg <= SAND_HEAP_PRESENT;
      score = score + 1'd1;
  end
  if((sand_heap_2_locX == locX_player) && (((sand_heap_2_locY + 5'd16) >= locY_player)
                                        && ((sand_heap_2_locY + 5'd31) < (locY_player + 5'd31))))
  begin
      sand_heap_2_signal_reg <= SAND_HEAP_PRESENT;
      score = score + 1'd1;
  end
  if((sand_heap_3_locX == locX_player) && (((sand_heap_3_locY + 5'd16) >= locY_player)
                                        && ((sand_heap_3_locY + 5'd31) < (locY_player + 5'd31))))begin
      sand_heap_3_signal_reg <= SAND_HEAP_PRESENT;
      score = score + 1'd1;
  end
  if((sand_heap_4_locX == locX_player) && (((sand_heap_4_locY + 5'd16) >= locY_player)
                                        && ((sand_heap_4_locY + 5'd31) < (locY_player + 5'd31))))begin
      sand_heap_4_signal_reg <= SAND_HEAP_PRESENT;
      score = score + 1'd1;
  end
  if((sand_heap_5_locX == locX_player) && (((sand_heap_5_locY + 5'd16) >= locY_player)
                                        && ((sand_heap_5_locY + 5'd31) < (locY_player + 5'd31))))begin
      sand_heap_5_signal_reg <= SAND_HEAP_PRESENT;
      score = score + 1'd1;
  end
  end 
end 
         
endmodule 