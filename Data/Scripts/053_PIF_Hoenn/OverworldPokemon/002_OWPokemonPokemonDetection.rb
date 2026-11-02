class OverworldPokemonEvent < Game_Event
  alias setup_pokemon_detection setup_pokemon
  RETALIATION_DELAY = 20 # frames of "stunned/reacting" before fighting back

  def setup_pokemon(*args)
    setup_pokemon_detection(*args)
    @currently_seen_events = []
    @previously_seen_events = []
    @target = nil
    @noticed_pokemon_behavior = nil
    @attack_timer = 0
    @retaliation_timer = 0
    @pending_retaliation_target = nil
  end


  #Version that only detects when the Pokemon is actually looking at the pokemon
  #
  # alias turn_generic_pokemon_detection turn_generic
  # def turn_generic(*args)
  #   turn_generic_pokemon_detection(*args)
  #   @currently_seen_events = listEventsInVisionCone
  #   @currently_seen_events.each do |event|
  #     event_pokemon = event[0]
  #     distance = event[1]
  #     noticed_pokemon_behaviors = POKEMON_BEHAVIOR_DATA[@species][:behavior_pokemon]
  #     if noticed_pokemon_behaviors && noticed_pokemon_behaviors.include?(event_pokemon.species)
  #       behavior = noticed_pokemon_behaviors[event_pokemon.species]
  #       playDetectAnimation(behavior)
  #       update_state(:NOTICED_POKEMON)
  #       set_noticed_pokemon_movement(behavior, event_pokemon)
  #     end
  #   end
  #   echoln @currently_seen_events
  # end
  BEHAVIOR_PRIORITY = {
    skittish: 1,
    aggressive: 2,
    shy: 3,
    semi_aggressive: 4,
    curious: 5
  }.freeze

  alias turn_generic_pokemon_detection turn_generic
  def turn_generic(*args)
    turn_generic_pokemon_detection(*args)
    return unless Settings::EXPERIMENTAL_FEATURES
    @currently_seen_events = listEventsInRadius(@detection_radius)

    if @current_state == :NOTICED_POKEMON
      unless target_still_valid?
        update_state(:ROAMING)
        back_to_roaming_action
        return
      end
    end

    behavior_data = POKEMON_BEHAVIOR_DATA[@species]
    noticed_pokemon_behaviors = behavior_data ? behavior_data[:behavior_pokemon] : nil
    sorted_events = @currently_seen_events.sort_by { |_event, distance| distance }

    if sorted_events.empty?
      if @current_state == :NOTICED_POKEMON
        update_state(:ROAMING)
        back_to_roaming_action
        @target = nil
      end
      return
    end

    @pack_size = 0
    nearest_distance = nil
    candidates = []       # [event, behavior] pairs, all at nearest_distance
    pokeblock_candidate = nil

    sorted_events.each do |event_pokemon, distance|
      # Once we've passed the nearest distance that had any qualifying target, stop
      break if nearest_distance && distance > nearest_distance

      if event_pokemon.is_a?(PokeblockEvent)
        pokeblock_candidate ||= event_pokemon
        nearest_distance ||= distance
        next
      end

      next if event_pokemon.pokemon.shiny?

      if noticed_pokemon_behaviors && noticed_pokemon_behaviors.include?(event_pokemon.species)
        candidates << [event_pokemon, noticed_pokemon_behaviors[event_pokemon.species]]
        nearest_distance ||= distance
      elsif event_pokemon.species == @pokemon.species
        @pack_size += 1
      elsif noticed_pokemon_behaviors && noticed_pokemon_behaviors.include?(:everything)
        candidates << [event_pokemon, noticed_pokemon_behaviors[:everything]]
        nearest_distance ||= distance
      end
    end

    if pokeblock_candidate
      unless @current_state == :NOTICED_POKEMON
        playAnimation(HEART_ANIMATION_SHORT_ID, @x, @y)
      end
      update_state(:NOTICED_POKEMON)
      @target = pokeblock_candidate
      @noticed_pokemon_behavior = :eat_pokeblock
      @move_type = MOVE_TYPE_TOWARDS_TARGET
      self.move_frequency = 6
      return
    end

    return if candidates.empty?

    best_event, best_behavior = candidates.min_by { |_event, behavior| BEHAVIOR_PRIORITY[behavior] || 99 }

    playDetectAnimation(best_behavior, false)
    update_state(:NOTICED_POKEMON)
    set_noticed_pokemon_movement(best_behavior, best_event)
  end

  def target_still_valid?
    return false unless @target && !@target.erased
    @currently_seen_events.any? { |event| event[0] == @target }
  end

  def set_noticed_pokemon_movement(behavior, target_event)
    @noticed_pokemon_behavior = behavior if target_event
    @target = target_event
    case behavior
    when :random
      @move_type = MOVE_TYPE_RANDOM
      self.move_frequency = @roaming_frequency
    when :still
      @move_type = MOVE_TYPE_FIXED
    when :curious
      @move_type = MOVE_TYPE_TOWARDS_TARGET
      self.move_frequency = @roaming_frequency
    when :semi_aggressive
      @move_type = MOVE_TYPE_TOWARDS_TARGET
      self.move_frequency = @roaming_frequency
    when :aggressive
      @move_type = MOVE_TYPE_TOWARDS_TARGET
      self.move_frequency = 6
    when :shy
      @move_type = MOVE_TYPE_SHY_FROM_TARGET
      self.move_frequency = @roaming_frequency
    when :skittish
      @move_type = MOVE_TYPE_AWAY_FROM_TARGET
      self.move_frequency = 6
    when :flee, :flee_flying, :teleport_away
      flee(behavior)
    else
      category = @behavior_noticed ? :noticed : :roaming
      set_custom_move_route(OW_BEHAVIOR_MOVE_ROUTES[category][behavior])
    end

    @step_anime = true unless behavior == :still
    @move_speed = @noticed_move_speed
  end


  def update_attack_target
    unless @current_state == :NOTICED_POKEMON &&
      [:aggressive, :semi_aggressive, :eat_pokeblock].include?(@noticed_pokemon_behavior) &&
      adjacent_to?(@target)
      @attack_timer = 0
      return
    end

    @attack_timer += 1
    if @attack_timer >= 80
      attack_pokemon_target
      @attack_timer = 0
    end
  end

  def attack_pokemon_target
    hp_chunk = calculate_damage_on_target

    # Attacks of pokemon's type 1, except if it's type 1. Then type 2 (if it has one) - so that normal/flying uses flying moves.
    attack_type = @pokemon.type1 == :NORMAL && @pokemon.type2 ? @pokemon.type2 : @pokemon.type1
    effectiveness = Effectiveness.calculate(attack_type, @target.pokemon.type1, @target.pokemon.type2) / 8.0

    hp_chunk = (hp_chunk * effectiveness).floor
    #echoln "#{attack_type} on #{@target.pokemon.type1}, #{@target.pokemon.type2} : x#{effectiveness}"

    @target.pokemon.hp -= hp_chunk
    flash_white(@target)
    unless @target.is_a?(PokeblockEvent)
      @target.knock_back(self)
      @target.queue_retaliation_against(self) if @target.pokemon.hp > 0
    end

    if @target.pokemon.hp <= 0
      @target.despawn
      @target = nil
      update_state(:ROAMING)
    end
  end

  def queue_retaliation_against(attacker)
    return unless attacker && !attacker.erased
    @pending_retaliation_target = attacker
    @retaliation_timer = RETALIATION_DELAY
  end

  def update_retaliation
    return unless @pending_retaliation_target
    unless @pending_retaliation_target.erased
      @retaliation_timer -= 1
      if @retaliation_timer <= 0
        target = @pending_retaliation_target
        @pending_retaliation_target = nil
        update_state(:NOTICED_POKEMON)
        set_noticed_pokemon_movement(:aggressive, target)
      end
    else
      @pending_retaliation_target = nil
    end
  end


  #Equivalent of a neutral base 20 damage attack
  # Simplified version of PokeBattle_Move.pbCalcDamage
  def calculate_damage_on_target()
    baseDmg = 20
    atk     = @pokemon.attack
    defense = @target.pokemon.defense
    damage  = (((2.0 * @pokemon.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    return damage
  end
  def flash_white(target, duration = 20, alpha = 200)
    return unless target && $scene && $scene.respond_to?(:spriteset)
    spriteset = $scene.spriteset
    return unless spriteset

    sprite = spriteset.character_sprites.find { |s| s.character == target }
    sprite&.flash(Color.new(255, 255, 255, alpha), duration)
  end

  def knock_back(event_knocking_back)
    turnEventTowardsEvent(self,event_knocking_back)
    original_direction_fix = @direction_fix

    @direction_fix = true
    self.jumpBackward
    #self.move_backward
    @direction_fix = original_direction_fix
  end
  # Orthogonal adjacency check (no diagonals), same rule used when
  # stopping movement toward a target in moveEventTowardsEvent.
  def adjacent_to?(event)
    return false unless event && !event.erased
    dx = event.x - self.x
    dy = event.y - self.y
    (dx == 0 && dy.abs == 1) || (dy == 0 && dx.abs == 1)
  end

  # def update
  #   super
  #   if $game_temp.message_window_showing
  #     pause_movement unless @current_state == :PAUSED
  #   else
  #     update_attack_target
  #     update_retaliation
  #     @behavior_update_counter = (@behavior_update_counter || 0) + 1
  #     if @behavior_update_counter >= UPDATE_TIME
  #       @behavior_update_counter = 0
  #       update_behavior
  #     end
  #   end
  # end

  #-----------------------------------------------------------------------
  # Returns the forward distance (along the facing axis) to (px, py) if it
  # falls inside the vision cone, or nil if it doesn't. Returning the
  # distance instead of a bool lets callers build a hash without
  # recomputing dy/dx a second time.
  #-----------------------------------------------------------------------
  def pbConeDistanceTo(px, py, distance, spread = 1)
    return nil if distance <= 0
    ex = self.x
    ey = self.y
    case self.direction
    when 2 # Facing Down
      dy = py - ey
      return nil if dy <= 0 || dy > distance
      side = (px - ex).abs
      return (side <= dy * spread) ? dy : nil
    when 8 # Facing Up
      dy = ey - py
      return nil if dy <= 0 || dy > distance
      side = (px - ex).abs
      return (side <= dy * spread) ? dy : nil
    when 6 # Facing Right
      dx = px - ex
      return nil if dx <= 0 || dx > distance
      side = (py - ey).abs
      return (side <= dx * spread) ? dx : nil
    when 4 # Facing Left
      dx = ex - px
      return nil if dx <= 0 || dx > distance
      side = (py - ey).abs
      return (side <= dx * spread) ? dx : nil
    else
      return nil
    end
  end

  # Boolean wrapper, kept so existing call sites don't need to change.
  def pbPointInVisionCone?(px, py, distance, spread = 1)
    !pbConeDistanceTo(px, py, distance, spread).nil?
  end

  def pbPlayerInEventCone?(player, distance, spread = 1)
    return false if !player
    pbPointInVisionCone?(player.x, player.y, distance, spread)
  end

  #-----------------------------------------------------------------------
  # { event => distance }
  #-----------------------------------------------------------------------
  def listEventsInVisionCone(distance = @detection_radius, spread = 1)
    seen = {}
    return seen if !$game_map

    #TODO: Maybe. Use this for player also and refactor player detection in base OverworldEvent
    # If not too costly to run this every frame like we do for the player detection...
    #
    # player_distance = pbConeDistanceTo($game_player.x, $game_player.y, distance, spread)
    # seen[$game_player] = player_distance if player_distance

    $game_map.events.each_value do |event|
      next unless event.is_a?(OverworldPokemonEvent)
      next if event == self
      next if event.erased
      d = pbConeDistanceTo(event.x, event.y, distance, spread)
      seen[event] = d if d
    end

    return seen
  end

  #-----------------------------------------------------------------------
  # { event => distance }
  #-----------------------------------------------------------------------
  def listEventsInRadius(radius = @detection_radius)
    seen = {}
    return seen if !$game_map

    $game_map.events.each_value do |event|
      next unless event.is_a?(OverworldPokemonEvent) || event.is_a?(PokeblockEvent)
      next if event == self
      next if event.erased
      d = pbDistanceTo(event.x, event.y, radius)
      seen[event] = d if d
    end

    return seen
  end

  def pbDistanceTo(px, py, radius)
    return nil if radius <= 0
    dx = (px - self.x).abs
    dy = (py - self.y).abs
    dist = dx + dy
    return (dist <= radius) ? dist : nil
  end

  def pbPointInRadius?(px, py, radius)
    !pbDistanceTo(px, py, radius).nil?
  end

  def pbPlayerInEventRadius?(player, radius)
    return false if !player
    pbPointInRadius?(player.x, player.y, radius)
  end


  def check_detect_trainer
    #return unless noticed_state_different_from_roaming()
    return if $game_system.map_interpreter.running? || @starting
    return pbPlayerInEventCone?($game_player, @detection_radius)
  end
end