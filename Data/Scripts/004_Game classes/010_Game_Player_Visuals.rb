class Game_Player < Game_Character
  @@bobFrameSpeed = 1.0/15

  def fullPattern
    case self.direction
    when 2 then return self.pattern
    when 4 then return self.pattern + 4
    when 6 then return self.pattern + 8
    when 8 then return self.pattern + 12
    end
    return 0
  end

  def setDefaultCharName(chname,pattern,lockpattern=false)
    return if pattern<0 || pattern>=16
    @defaultCharacterName = chname
    @direction = [2,4,6,8][pattern/4]
    @pattern = pattern%4
    @lock_pattern = lockpattern
  end

  def pbCanRun?
    return false if $game_temp.in_menu || $game_temp.in_battle ||
                    @move_route_forcing || $game_temp.message_window_showing ||
                    pbMapInterpreterRunning?
    input = ($PokemonSystem.runstyle == 1) ^ Input.press?(Input::ACTION)
    return input && $Trainer.has_running_shoes && !jumping? &&
       !$PokemonGlobal.diving && !$PokemonGlobal.surfing &&
       !$PokemonGlobal.bicycle && !$game_player.pbTerrainTag.must_walk
  end

  def pbIsRunning?
    return moving? && !@move_route_forcing && pbCanRun?
  end

  #Override the player's graphics
  # Path from Graphics/Characters/player/
  def setPlayerGraphicsOverride(filename)
    @defaultCharacterName="overrides/#{filename}"
  end

  def removeGraphicsOverride
    @defaultCharacterName = ""
  end

  def hasGraphicsOverride?
    return @defaultCharacterName!=""
  end

  def character_name
    @defaultCharacterName = "" if !@defaultCharacterName
    return @defaultCharacterName if hasGraphicsOverride?
    if !@move_route_forcing && $Trainer.character_ID>=0
      meta = GameData::Metadata.get_player($Trainer.character_ID)
      if meta && !$PokemonGlobal.bicycle && !$PokemonGlobal.diving && !$PokemonGlobal.surfing
        charset = 1   # Display normal character sprite

        player_is_moving = moving?
        if pbCanRun? && (player_is_moving || @wasmoving) && Input.dir4!=0 && meta[4] && meta[4]!=""
          charset = 4   # Display running character sprite
        end

        newCharName = pbGetPlayerCharset(meta,charset)
        @character_name = newCharName if newCharName
        @wasmoving = player_is_moving
      end
    end
    return @character_name
  end

  def update_command
    self.move_speed = 0.5 if $game_switches[SWITCH_SUPER_SLOW_SPEED]

    if $game_player.pbTerrainTag.ice
      reset_bike_speed
      self.move_speed = 4
    elsif !@move_route_forcing && $PokemonGlobal
      if $PokemonGlobal.bicycle
        self.move_speed = current_bicycle_speed
      elsif pbCanRun? || $PokemonGlobal.surfing
        reset_bike_speed
        self.move_speed = 4
      else
        reset_bike_speed
        self.move_speed = 3
      end
    end

    super
  end

  def current_bicycle_speed
    if $game_player.pbTerrainTag.must_walk
      reset_bike_speed
      return 3
    end

    if $game_switches[SWITCH_RACE_BIKE]
      reset_bike_speed
      return Input.press?(Input::ACTION) ? 5 : 5.6
    end

    if Settings::KANTO
      reset_bike_speed
      return 5
    end

    # Settings::HOENN — accelerating bike
    mach_max_speed = 5.333
    mach_starting_speed = 4.2
    mach_acceleration = 0.05
    acro_speed = 5.0

    if Input.press?(Input::ACTION)
      bikeOnFence unless $PokemonGlobal.bike_trick
      @bike_speed = acro_speed
      @bike_idle_frames = 0
      check_bunny_hops
      $PokemonGlobal.bike_trick = true
    elsif moving?
      @bike_speed = [(@bike_speed || mach_starting_speed) + mach_acceleration, mach_max_speed].min
      @bike_idle_frames = 0
      stop_bunny_hops
    else
      @bike_idle_frames = (@bike_idle_frames || 0) + 1
      @bike_speed = mach_starting_speed if @bike_idle_frames > 3
      $PokemonGlobal.bike_trick = false
      stop_bunny_hops
    end
    @bike_speed = acro_speed if $game_player.floating
    @bike_was_moving = moving?
    return @bike_speed || mach_starting_speed
  end

  def check_bunny_hops
    @bike_hops_timer = 0 unless @bike_hops_timer
    if @bike_hops_unlocked
      if Input.press?(Input::ACTION)
        $game_player.bike_hops = true
      else
        @bike_hops_unlocked = false
        $game_player.bike_hops = false
      end
    else
      if moving?
        @bike_hops_timer = 0
        $game_player.bike_hops = false
      else
        @bike_hops_timer += 1
        if @bike_hops_timer >= 16
          @bike_hops_unlocked = true
          $game_player.bike_hops = true
        end
      end
    end
  end

  def stop_bunny_hops
    @bike_hops_timer = 0
    @bike_hops_unlocked = false
    $game_player.bike_hops = false
  end
  def reset_bike_speed
    @bike_speed = nil
  end

  def update_pattern
    if $PokemonGlobal.surfing || $PokemonGlobal.diving
      p = ((Graphics.frame_count%60)*@@bobFrameSpeed).floor
      @pattern = p if !@lock_pattern
      @pattern_surf = p
      @bob_height = (p>=2) ? 2 : 0
    else
      @bob_height = 0
      super
    end
  end
end


=begin
class Game_Character
  alias update_old2 update

  def update
    if self.is_a?(Game_Event)
      if @dependentEvents
        for i in 0...@dependentEvents.length
          if @dependentEvents[i][0]==$game_map.map_id &&
             @dependentEvents[i][1]==self.id
            self.move_speed_real = $game_player.move_speed_real
            break
          end
        end
      end
    end
    update_old2
  end
end
=end
