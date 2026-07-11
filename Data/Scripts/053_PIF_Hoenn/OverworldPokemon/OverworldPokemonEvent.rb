class OverworldPokemonEvent < Game_Event

  attr_accessor :species
  attr_accessor :level

  attr_accessor :behavior_roaming
  attr_accessor :behavior_noticed

  attr_accessor :detection_radius
  attr_accessor :pokemon
  attr_accessor :manual_ow_pokemon
  attr_accessor :current_state
  attr_reader :part_of_pokeradar_chain
  attr_reader :noticed_player_once
  attr_reader :last_facing_direction

  DISTANCE_FOR_DESPAWN = 16
  FLEEING_BEHAVIORS = [:flee, :flee_flying, :teleport_away]

  DISGUISED_POKEMON = [:DITTO, :MEW, :ZORUA, :ZOROARK]
  CASTFORM_FORMS = [:CASTFORM, :CASTFORM_SUNNY, :CASTFORM_RAINY, :CASTFORM_SNOWY]
  UPDATE_TIME = 4 # Nb. of frames for the update_behavior loop

  def setup_pokemon(species, level, terrain, behavior_roaming = nil, behavior_noticed = nil)
    # return unless @map_id == $game_map.map_id
    @species = species
    @level = level
    roll_for_special_encounters
    @behavior_roaming = behavior_roaming if behavior_roaming
    @behavior_noticed = behavior_noticed if behavior_noticed

    @terrain = terrain
    @disguised = false
    species_data = GameData::Species.get(@species)

    @pokemon = Pokemon.new(@species, @level)
    @behavior_species = getBehaviorSpecies(species_data)

    unless behavior_roaming
      @behavior_roaming = get_behavior_for_species(@behavior_species, :behavior_roaming)
      @behavior_roaming = :random unless @behavior_roaming
    end
    unless behavior_noticed
      @behavior_noticed = get_behavior_for_species(@behavior_species, :behavior_noticed)
      @behavior_noticed = nil unless @behavior_noticed
    end

    default_move_speed = calculate_value_from_stat(species_data, :SPEED, 1, 4)
    @roaming_move_speed = POKEMON_BEHAVIOR_DATA[@behavior_species][:roaming_move_speed] || default_move_speed
    @noticed_move_speed = POKEMON_BEHAVIOR_DATA[@behavior_species][:noticed_move_speed] || default_move_speed

    default_frequency = calculate_value_from_stat(species_data, :ATTACK, 1, 5)
    @roaming_frequency = POKEMON_BEHAVIOR_DATA[@behavior_species][:roaming_frequency] || default_frequency
    @noticed_frequency = POKEMON_BEHAVIOR_DATA[@behavior_species][:noticed_frequency] || default_frequency

    @detection_radius = calculate_ow_pokemon_sight_radius(species_data)

    # When the player is next to a Pokemon but not facing it, there is a delay before it battles.
    # The battle will start when the timer reaches @nearby_notice_limit
    # @nearby_notice_limit depends on the size of the pokemon. (usually around 3-5 ticks)
    @nearby_notice_timer = 0
    @nearby_notice_limit = 4 # calculate_value_from_ref_value(species_data.weight.to_f/10,2,12, 8)# weight is multiplied by 10 in the pokemon data for some reason
    @nearby_notice_limit += 1 * @weather_level_at_spawn if @weather_type_at_spawn == :Storm
    @current_state = :ROAMING # Possible values: :ROAMING, :NOTICED_PLAYER, :FLEEING
    @noticed_player_once = false
    @manual_ow_pokemon = false
    #@event.name = "OW/#{species.to_s}/#{level.to_s}"
    weather = $game_weather.get_current_map_weather if $game_weather
    if weather
      @weather_type_at_spawn = weather[0]
      @weather_level_at_spawn = weather[1]
    end

    if DISGUISED_POKEMON.include?(@species) && !@manual_ow_pokemon
      species_data = getRandomPokemonFromRoute(@species, @terrain)
      @disguised = true
    end
    if CASTFORM_FORMS.include?(@species)
      species_data = setCastformToCurrentWeather
    end

    initialize_sprite(@terrain, species_data)
    @disguised_sprite = @roaming_sprite if @disguised
    @is_flying = @character_name == @flying_sprite
    @is_swimming = false
    @step_anime = @is_flying
    @forced_z = 300 if @is_flying && $PokemonGlobal.boat #@always_on_top = @is_flying
    @part_of_pokeradar_chain = is_pokeradar_chain
    if @terrain == :Water
      set_swimming
    end
    apply_shiny_rerolls(@pokemon)

    if @pokemon.shiny?
      pbSEPlay("shiny", 60)
      playAnimation(Settings::SPARKLE_SHORT_ANIMATION_ID, @x, @y)
    end
    set_roaming_movement
    @last_facing_direction = @direction
    @setup_complete = true
  end

  def roll_for_special_encounters
    # Mew encounter
    if rand(15100) < Settings::MEW_OW_ENCOUNTER_CHANCE
      @species = :MEW
      @level = 7
    end
  end

  def make_shiny
    @pokemon.shiny = true
    @pokemon.radar_shiny = true
    species_data = GameData::Species.get(@species)
    initialize_sprite(@terrain, species_data)
  end

  def is_pokeradar_chain
    if $PokemonTemp.pokeradar
      pokeradar_species = $PokemonTemp.pokeradar[0]
      return @species == pokeradar_species
    end
    return false
  end

  def setCastformToCurrentWeather
    case @weather_type_at_spawn
    when :Rain, :Storm, :HeavyRain
      @species = :CASTFORM_RAINY
    when :Sunny, :HarshSun, :Sandstorm
      @species = :CASTFORM_SUNNY
    when :Wind, :StrongWinds, :Snow, :Blizzard
      @species = :CASTFORM_SNOWY
    else
      @species = :CASTFORM
    end
    @pokemon = Pokemon.new(@species, @level)
    return GameData::Species.get(@species)
  end

  def get_behavior_for_species(species, behavior_type)
    behavior = POKEMON_BEHAVIOR_DATA[species][behavior_type]
    if @terrain == :Water
      behavior = :random_dive if behavior == :random_burrow
    else
      behavior = :random if behavior == :random_dive
      behavior = :random if behavior == :water_skip
    end

    if species == :WHISMUR && isWearingHat(HAT_TRUMPET)
      behavior = :uproar
    end
    return behavior
  end

  # Crops land sprite to make it look underwater
  def set_swimming
    # return if @species == :SURSKIT || @species == :SUICUNE
    unless @is_flying
      self.set_animation_speed(2)
      @step_anime = true
      unless @swimming_sprite
        self.forced_bush_depth = 20
        self.calculate_bush_depth
      else
        self.forced_bush_depth = 8
        self.calculate_bush_depth
      end
      @is_swimming = true
    end
  end

  def set_shiny
    @pokemon.shiny = true
    @pokemon.natural_shiny = true
    species_data = GameData::Species.get(@species)
    initialize_sprite(@terrain, species_data)
  end

  # Used for special static pokemon - if need other actions after the pokemon was battled

  def set_post_battle_switch(switch_nb)
    @post_battle_switch = switch_nb if switch_nb.is_a?(Integer)
  end

  def getBehaviorSpecies(species_data)
    if isSpeciesFusion(@species)
      return species_data.get_head_species_symbol
    end
    return @species
  end

  def initialize_sprite(terrain, species_data)
    @land_sprite = getOverworldLandPath(species_data, @pokemon.shiny?)
    @flying_sprite = getOverworldFlyingPath(species_data, @pokemon.shiny?)
    @swimming_sprite = getOverworldSwimmingPath(species_data, @pokemon.shiny?)

    @noticed_sprite = getOverworldNoticedPath(species_data, @pokemon.shiny?)
    @noticed_sprite = @flying_sprite if !@noticed_sprite && @flying_sprite
    @roaming_sprite = @land_sprite
    @roaming_sprite = @disguised_sprite if @disguised_sprite && @disguised

    if terrain == :Water
      initialize_water_sprite
    else
      initialize_land_sprite
    end
  end

  def initialize_water_sprite
    if @flying_sprite
      @character_name = @flying_sprite
    elsif @swimming_sprite
      @character_name = @swimming_sprite
    else
      @character_name = @land_sprite
    end
  end

  def initialize_land_sprite
    if @land_sprite
      @character_name = @land_sprite
    elsif @flying_sprite
      @character_name = @flying_sprite
    end
  end

  def get_current_state
    return @current_state
  end

  ####
  # ACTIONS
  # ###
  def overworldPokemonBattle()
    return if lock?
    return if $PokemonTemp.prevent_ow_battles
    return if instance_variable_get(:@_triggered)
    return if $PokemonTemp.overworld_wild_battle_triggered
    instance_variable_set(:@_triggered, true)
    playAnimation(Settings::EXCLAMATION_ANIMATION_ID, @x, @y) # unless @current_state == :NOTICED_PLAYER #notice animation already plays instead if the state is roaming
    turn_toward_player
    playCry(@species)
    @pokemon.ow_coordinates = [@x, @y]
    $PokemonTemp.overworld_wild_battle_participants = [] if !$PokemonTemp.overworld_wild_battle_participants
    $PokemonTemp.overworld_wild_battle_participants << self
    pbWait(8)
    trigger_overworld_wild_battle
    if @post_battle_switch && @post_battle_switch.is_a?(Integer) && @post_battle_switch >= 1
      $game_switches[@post_battle_switch] = true
    end
    return
  end

  def flee(behavior)
    return if @pokemon.shiny?
    playCry(@species)
    pbSEPlay(SE_FLEE)
    if FLEEING_BEHAVIORS.include?(@behavior_noticed)
      flee_behavior = OW_BEHAVIOR_MOVE_ROUTES[:noticed][@behavior_noticed]
    else
      flee_behavior = OW_BEHAVIOR_MOVE_ROUTES[:noticed][:flee]
    end
    set_custom_move_route(flee_behavior, false)
    check_pokeradar_chain_break
    @through = true
    @detection_radius = 10
    force_move_route(@move_route)
    @always_on_top = true if behavior == :flee_flying
    @current_state = :FLEEING
  end

  def check_pokeradar_chain_break
    return unless $PokemonTemp.pokeradar && @part_of_pokeradar_chain
    remaining_pokeradar_species = false
    $game_map.events.each do |event|
      if event.is_a?(OverworldPokemonEvent)
        remaining_pokeradar_species = true if event.part_of_pokeradar_chain
        break if remaining_pokeradar_species
      end
    end
    unless remaining_pokeradar_species
      pbPokeRadarCancel
    end
  end

  #####
  # Behaviors
  #####
  def noticed_state_different_from_roaming
    return false unless @behavior_noticed
    return false if @behavior_noticed == :still && @behavior_roaming == :still
    return true
  end

  def breakDisguise
    species_data = GameData::Species.get(@species)
    playAnimation(TELEPORT_ANIMATION_ID, @x, @y)
    initialize_sprite(@terrain, species_data)
  end

  def playDetectPlayerAnimation
    return unless @current_state == :ROAMING
    return unless noticed_state_different_from_roaming()

    if @behavior_noticed == :curious
      playAnimation(Settings::QUESTION_MARK_ANIMATION_ID, @x, @y)
    elsif @behavior_noticed == :aggressive
      playAnimation(Settings::ANGRY_ANIMATION_ID, @x, @y)
    elsif @behavior_noticed == :semi_aggressive
      playAnimation(Settings::ANGRY_SHORT_ANIMATION_ID, @x, @y)
    else
      playAnimation(Settings::EXCLAMATION_ANIMATION_ID, @x, @y)
    end
  end

  def update_behavior()
    return unless @setup_complete
    return if @opacity == 0
    return if @current_state == :FLEEING
    return if $game_temp.message_window_showing
    @last_facing_direction = @direction
    distance = distance_from_player()
    is_near_player = distance <= @detection_radius
    if distance >= DISTANCE_FOR_DESPAWN
      despawn unless @manual_ow_pokemon
    end
    if is_near_player
      if should_start_battle? # Battle
        if isRepelActive && pokemon_can_be_repelled
          playAnimation(Settings::EXCLAMATION_ANIMATION_ID, @x, @y)
          flee(@behavior_noticed)
        else
          overworldPokemonBattle
        end
      else
        # check for noticed
        if @current_state == :ROAMING
          if check_detect_trainer
            playDetectPlayerAnimation
            breakDisguise if @disguised
            @noticed_player_once = true
            update_state(:NOTICED_PLAYER)
          end
        end
      end
    else
      if @current_state != :ROAMING
        update_state(:ROAMING)
        back_to_roaming_action
      end
    end
  end

  # Automatically starts a battle if the player is 1 tile away from the Pokemon.
  # If the player is behind or to the side of the pokemon, there is a slight delay
  def should_start_battle?
    return false unless $PokemonTemp.overworld_wild_battle_participants
    should_start = false
    if player_near_event?(1)
      return true if $PokemonTemp.overworld_wild_battle_participants.length >= 1 # Notice immediately if a pokemon is already attacking so that double battles are more likely
      position = playerPositionRelativeToEvent
      if position[:front]
        should_start = true
      elsif position[:back]
        @nearby_notice_timer += 1
        @nearby_notice_timer += 1 if @current_state == :NOTICED_PLAYER
      elsif position[:side]
        @nearby_notice_timer += 2
        should_start = true if @current_state == :NOTICED_PLAYER
      end
      if @nearby_notice_timer > @nearby_notice_limit
        should_start = true
      end
    else
      @nearby_notice_timer = 0
    end
    @nearby_notice_timer = 0 if should_start
    return should_start
  end

  def pokemon_can_be_repelled
    return false if @part_of_pokeradar_chain
    return $Trainer.party[0].level > @pokemon.level && !@pokemon.shiny?
  end

  def turn_generic(*args)
    super(*args)
  end

  # called when a pokemon that has noticed the player goes back to roaming
  def back_to_roaming_action
    case @behavior_noticed
    when :skittish, :shy
      turn_toward_player
    end
  end

  def update_state(new_state)
    @current_state = new_state
    update_movement_type
    set_sprite_to_current_state
  end

  def update_movement_type
    case @current_state
    when :ROAMING
      set_roaming_movement
    when :NOTICED_PLAYER
      set_noticed_movement
    end
    set_sprite_to_current_state
  end

  def check_detect_trainer
    return unless noticed_state_different_from_roaming()
    return if $game_system.map_interpreter.running? || @starting
    # return pbEventCanReachPlayer?(self, $game_player, @detection_radius)
    return pbPlayerInEventCone?(self, $game_player, @detection_radius)
  end

  def pbCheckEventTriggerAfterTurning
    return if $game_system.map_interpreter.running? || @starting
    if @event.name[/trainer\((\d+)\)/i]
      distance = $~[1].to_i
      if @trigger == 2 && pbEventCanReachPlayer?(self, $game_player, distance)
        start if !jumping? && !over_trigger?
      end
    end
  end

  # The rarer the Pokemon, the more skittish it is (larger sight radius)
  def calculate_ow_pokemon_sight_radius(species_data)
    #--- Fog level ---
    fog_level = 0
    fog_level = @weather_level_at_spawn if @weather_level_at_spawn == :Fog

    #--- Base radius limits (no fog) ---
    min_base_radius = 2
    max_base_radius = 6

    #--- Base radius from Speed (1–255) ---
    speed = species_data.base_stats[:SPEED]
    base_radius = min_base_radius + ((speed - 1) / 254.0) * (max_base_radius - min_base_radius)

    #--- Fog effect (quadratic: light fog mild, heavy fog strong) ---
    fog_factor = (fog_level / 10.0) ** 2
    radius = base_radius * (1.0 - fog_factor)

    #--- Absolute minimum visibility ---
    return [radius.round, 1].max
  end

  def calculate_value_from_stat(species_data, stat, min_value, max_value)
    stat_value = species_data.base_stats[stat]
    average_stat = 70.0
    half_range = (max_value - min_value) / 2.0

    # Center on average stat and scale up/down
    normalized = (stat_value - average_stat) / average_stat
    scaled = (min_value + half_range) + normalized * half_range

    return scaled.clamp(min_value, max_value).round
  end

  # Generic version of calculate_value_from_stat. You provide the value.
  # There's an optional curve_factor if it shouldn't be linear
  # > 1 : steeper towards the end
  # < 1 steeper towards the beginning
  def calculate_value_from_ref_value(ref_value, min_value, max_value, curve_factor = 1)
    ref_value = [ref_value, 1].max

    # Logarithmic scaling 0 → 1
    scaled_value = Math.log(ref_value) / curve_factor
    normalized = scaled_value / (1 + scaled_value)

    # Scale to range
    value = min_value + normalized * (max_value - min_value)
    value.round
  end

  def set_sprite_to_current_state
    case @current_state
    when :NOTICED_PLAYER, :FLEEING
      set_sprite(@noticed_sprite) if @noticed_sprite
    when :ROAMING
      playAnimation(TELEPORT_ANIMATION_ID, @x, @y) if @disguised
      set_sprite(@roaming_sprite) if @roaming_sprite
    end
  end

  def set_roaming_sprite
    set_sprite(@roaming_sprite) if @roaming_sprite
  end

  def set_noticed_sprite
    set_sprite(@noticed_sprite) if @noticed_sprite
  end

  def set_sprite(sprite_path)
    @character_name = sprite_path
    @need_refresh = true
  end

  # Static
  def set_noticed_movement
    if isRepelActive
      @move_type = MOVE_TYPE_AWAY_PLAYER
      self.move_frequency = 6
      return
    end

    effective_behavior = @behavior_noticed || @behavior_roaming # fallback on @behavior_roaming if no @behavior_noticed

    case effective_behavior
    when :random
      @move_type = MOVE_TYPE_RANDOM
    when :still
      @move_type = MOVE_TYPE_FIXED
    when :curious
      @move_type = MOVE_TYPE_CURIOUS
    when :semi_aggressive
      @move_type = MOVE_TYPE_TOWARDS_PLAYER
    when :aggressive
      @move_type = MOVE_TYPE_TOWARDS_PLAYER
      self.move_frequency = 6
    when :skittish
      @move_type = MOVE_TYPE_AWAY_PLAYER
      self.move_frequency = 6
    when :flee, :flee_flying, :teleport_away
      flee(effective_behavior)
    else
      category = @behavior_noticed ? :noticed : :roaming
      set_custom_move_route(OW_BEHAVIOR_MOVE_ROUTES[category][effective_behavior])
    end

    @step_anime = true unless effective_behavior == :still
    @move_speed = @noticed_move_speed
  end

  def set_roaming_movement
    if isRepelActive
      @move_type = MOVE_TYPE_AWAY_PLAYER
      self.move_frequency = 3
      return
    end

    case @behavior_roaming
    when :random
      @move_type = MOVE_TYPE_RANDOM
    when :still
      @move_type = MOVE_TYPE_FIXED
    else
      set_custom_move_route(OW_BEHAVIOR_MOVE_ROUTES[:roaming][@behavior_roaming])
    end
    self.move_frequency = 3
    check_weather_roaming_behavior
    @move_speed = @roaming_move_speed
    @step_anime = false unless @is_flying || @is_swimming
  end

  def check_weather_roaming_behavior
    if @weather_type_at_spawn == :Wind || @weather_type_at_spawn == :Storm
      wind_behavior = POKEMON_BEHAVIOR_DATA[@species][:behavior_wind_roaming]
      if wind_behavior
        set_custom_move_route(OW_BEHAVIOR_MOVE_ROUTES[:roaming][wind_behavior])
      end
    elsif @weather_type_at_spawn == :Rain || @weather_type_at_spawn == :Storm
      rain_behavior = POKEMON_BEHAVIOR_DATA[@species][:behavior_rain_roaming]
      if rain_behavior
        set_custom_move_route(OW_BEHAVIOR_MOVE_ROUTES[:roaming][rain_behavior])
      end
    elsif @weather_type_at_spawn == :Sunny
      sun_behavior = POKEMON_BEHAVIOR_DATA[@species][:behavior_sunny_roaming]
      if sun_behavior
        set_custom_move_route(OW_BEHAVIOR_MOVE_ROUTES[:roaming][sun_behavior])
      end
    end
  end

  def set_custom_move_route(move_list, repeating = true)
    @move_type = MOVE_TYPE_CUSTOM
    @move_route = RPG::MoveRoute.new
    @move_route.repeat = repeating
    @move_route.skippable = true
    @move_route.list = move_list
  end

  def despawn
    erase
    $game_map.events.delete(@id)
    $PokemonTemp.overworld_pokemon_on_map&.delete(@id)
    $PokemonTemp.tempEvents&.each { |_, events| events.delete(self) }
    $PokemonTemp.tempEvents&.delete_if { |_, v| v.empty? }
  end

  # Additional move types for OW pokemon
  def update_command_new
    super
    ready_for_next_movement = @stop_count >= self.move_frequency_real
    case @move_type
    when MOVE_TYPE_CURIOUS
      move_type_curious(ready_for_next_movement)
    end
  end

  def pause_movement
    @move_type = MOVE_TYPE_FIXED
    @current_state = :PAUSED
  end

  def update
    super
    if $game_temp.message_window_showing
      pause_movement unless @current_state == :PAUSED
    else
      @behavior_update_counter = (@behavior_update_counter || 0) + 1
      if @behavior_update_counter >= UPDATE_TIME
        @behavior_update_counter = 0
        update_behavior
      end
    end
  end
end

