MOVE_TYPE_FIXED = 0
MOVE_TYPE_RANDOM = 1
MOVE_TYPE_TOWARDS_PLAYER = 2
MOVE_TYPE_AWAY_PLAYER = 4

MOVE_TYPE_CURIOUS = 5
MOVE_TYPE_SHY = 6

class Game_Character
  # @stop_count : nb frames since last movement

  #wait until next frequency frame
  def wait
    @stop_count = 0
  end

  def move_type_curious(next_movement_ready = false)
    if next_movement_ready
      if distance_from_player > 1
        move_toward_player
      else
        roll = rand(6)
        if roll == 0
          turn_random
        elsif roll == 1
          jump(0,0)
        else
          turn_toward_player
        end
      end
    end
  end

  # def move_type_shy(next_movement_ready = false)
  #   if next_movement_ready
  #     move_type_away_from_player
  #     turn_toward_player
  #   end
  # end


  # def move_type_bounce_random(frames_since_last_movement, next_movement_ready = false)
  #   echoln @stop_count
  #   if next_movement_ready
  #     case rand(6)
  #     when 0..3 then
  #       turn_random
  #       jump_forward(1)
  #     when 4 then
  #       jump_forward(1)
  #     when 5 then
  #       wait
  #     end
  #   else
  #     if @stop_count % 15 == 0
  #       jump(0, 0, false)
  #     end
  #   end
  # end
end