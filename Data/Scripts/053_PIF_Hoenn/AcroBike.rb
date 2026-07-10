class Game_Player < Game_Character
  attr_accessor :bike_hops

  alias acroBike_update update
  def update
    acroBike_update
    check_bike_hopping
  end

  def check_bike_hopping
    return unless $PokemonGlobal.bicycle
    return unless @bike_hops
    return if jumping?
    unless $game_map.valid?(@x, @y)
      $game_player.stop_bunny_hops
      return
    end
    unless pbMapInterpreterRunning? || $game_temp.message_window_showing ||
      $PokemonTemp.miniupdate || $game_temp.in_menu
      pbSEPlay("jump",40)
      dir = Input.dir4
      if dir > 0
        turn_generic(dir)
        if can_move_in_direction?(@direction, true) && !event_at_destination?(dir)
          jumpForward
          $Trainer.stats.incr_nb_bike_hops_steps
        else
          jump(0, 0)
        end
      else
        jump(0, 0)
      end
    end
  end

  def event_at_destination?(dir)
    x_offset = (dir == 4) ? -1 : (dir == 6) ? 1 : 0
    y_offset = (dir == 8) ? -1 : (dir == 2) ? 1 : 0
    dest_x = @x + x_offset
    dest_y = @y + y_offset
    for event in $game_map.events.values
      next unless event.active?
      return true if event.at_coordinate?(dest_x, dest_y)
    end
    return false
  end
end
