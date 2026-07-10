# Todo: Templates that depend on the type of Pokemon

# Skittish (can run away, large detection radius)
# Normal (just hangs out)
# Aggressive (goes towards player when in detection radius)
# still (cocoons, etc.) - doesn't move at all
#
# Flying: Wingull, Taillow, Hoppip, etc. when over water
#

# A special type of event that is a Pokemon visible in the overworld. It flees if the player gets too close.
# Can either spawn naturally or be static

def should_spawn_overworld_pokemon?
  return false unless can_spawn_overworld_pokemon?
  $PokemonTemp.overworld_pokemon_on_map = [] unless $PokemonTemp.overworld_pokemon_on_map
  return false unless $PokemonGlobal.stepcount % (5 + ($PokemonTemp.overworld_pokemon_on_map.length * 5)) == 0
  return rand(100) > 25 # true
end

def can_spawn_overworld_pokemon?
  return false unless $PokemonSystem.overworld_encounters || $PokemonTemp.pokeradar
  return false if $PokemonTemp.prevent_ow_encounters
  return true
end

def playOverworldPokemonSpawnAnimation(event, terrain)
  case terrain
  when :Land
    playAnimation(Settings::GRASS_ANIMATION_ID, event.x, event.y)
  when :Cave
    playAnimation(Settings::DUST_ANIMATION_ID, event.x, event.y)
  when :Water
    playAnimation(PUDDLE_ANIMATION_ID, event.x, event.y)
  end
end

def create_overworld_pokemon_event(pokemon, position, terrain, behavior_roaming = nil, behavior_noticed = nil)
  template_event = TEMPLATE_EVENT_OW_POKEMON_NORMAL

  species = pokemon[0]
  level = pokemon[1]
  event = $PokemonTemp.createTempEvent(template_event, $game_map.map_id, position, nil, DynamicOverworldPokemonEvent) do |event|
    event.setup_pokemon(species, level, terrain, behavior_roaming, behavior_noticed)
  end
  return unless event
  event.direction = [DIRECTION_LEFT, DIRECTION_RIGHT, DIRECTION_DOWN, DIRECTION_UP].sample
  playOverworldPokemonSpawnAnimation(event, terrain)
  return event
end

def get_overworld_pokemon_group_size(species, max_group_size)
  catch_rate = GameData::Species.get(species).catch_rate
  t = (catch_rate - 1) / 254.0
  t = Math.sqrt(t) # invert to favor smaller groups

  # Base group size, biased toward smaller numbers
  base = 1 + (t * (max_group_size - 1) * 0.5) # multiply by 0.5 to shrink toward 1–2

  # Random variation: mostly negative or zero, rarely positive
  variation = if rand < 0.6
                -1
              elsif rand < 0.9
                0
              else
                1
              end

  size = (base.round + variation).clamp(1, max_group_size)
  return size
end

def printPokemonOnCurrentMap
  event_names = []
  $PokemonTemp.overworld_pokemon_on_map.each do |key|
    event = $game_map.events[key]
    event_names << "[#{event.id}]#{event.name}"
  end
end

# shortcut for calling from events
# wild_pokemon: [species, level]
def spawn_ow_pokemon(species, level, max_quantity = 1, radius = 10, coordinates = nil)
  wild_pokemon = [species, level]
  return spawn_random_overworld_pokemon_group(wild_pokemon, radius, max_quantity, coordinates)
end

#Bypasses map limit
def spawn_pokemon_group(species, min_level, max_level, quantity=1, radius=10, min_distance=3, max_attempts=10)
  spawn_count=0
  (1..quantity).each {
    attempts = 0
    position = find_spawn_position(radius, min_distance)
    unless position
      while attempts <= max_attempts
        position = find_spawn_position(radius, min_distance)
        attempts += 1
        break if position
      end
      next unless position
    end
    offset_x = rand(-2..2)
    offset_y = rand(-2..2)
    new_position = [position[0] + offset_x, position[1] + offset_y]
    terrain = get_spawning_terrain
    begin
      if can_spawn_pokemon_there(new_position[0], new_position[1], terrain)
        level = rand(min_level..max_level)
        wild_pokemon = [species, level]
        spawn_overworld_pokemon(wild_pokemon, new_position, terrain)
        spawn_count+=1
        echoln spawn_count
      end
    rescue Exception => e
      echoln e.message
    end
  }
end

def spawn_random_overworld_pokemon_group(wild_pokemon = nil, radius = 10, max_group_size = 4, position = nil, terrain = nil)
  return unless $PokemonEncounters && $PokemonGlobal
  unless wild_pokemon && position
    if ($PokemonGlobal.surfing || $PokemonGlobal.boat) && $PokemonEncounters.has_water_encounters?
      terrain = :Water
      position = find_random_surfable_coordinates_near_player(radius, radius, 3, max_nb_tries = 10)
    elsif $PokemonEncounters.has_cave_encounters?
      terrain = :Cave
      position = find_random_walkable_coordinates_near_player(radius, radius, 3, max_nb_tries = 10)
    elsif $PokemonEncounters.has_land_encounters?
      position, terrain = find_random_tall_grass_coordinates_near_player(radius, radius, 3, max_nb_tries = 10)
    end
    encounter_type = getTimeBasedEncounter(terrain)
    return unless encounter_type && position
    wild_pokemon = getRegularEncounter(encounter_type) if !wild_pokemon
  end
  $PokemonTemp.overworld_pokemon_on_map = [] unless $PokemonTemp.overworld_pokemon_on_map
  if $PokemonTemp.overworld_pokemon_on_map.length >= Settings::OVERWORLD_POKEMON_LIMIT
    despawn_overworld_pokemon($PokemonTemp.overworld_pokemon_on_map[0], terrain)
  end
  return unless wild_pokemon
  species = wild_pokemon[0]
  number_to_spawn = get_overworld_pokemon_group_size(species, max_group_size)
  echoln "Spawning a group of #{number_to_spawn} #{species}"
  spawned_events = []
  for i in 0...number_to_spawn
    next if $PokemonTemp.overworld_pokemon_on_map.length >= Settings::OVERWORLD_POKEMON_LIMIT
    offset_x = rand(-2..2)
    offset_y = rand(-2..2)
    new_position = [position[0] + offset_x, position[1] + offset_y]
    begin
      if can_spawn_pokemon_there(new_position[0], new_position[1], terrain)
        event = spawn_overworld_pokemon(wild_pokemon, new_position, terrain)
        spawned_events << event
      else
        echoln "Couldn't spawn pokemon at #{new_position[0]}, #{new_position[1]}"
      end
    rescue
      next
    end
  end
  return spawned_events
end

def get_spawning_terrain
  if ($PokemonGlobal.surfing || $PokemonGlobal.boat) && $PokemonEncounters.has_water_encounters?
    terrain = :Water
  elsif $PokemonEncounters.has_cave_encounters?
    terrain = :Cave
  elsif $PokemonEncounters.has_land_encounters?
    position, terrain = find_random_tall_grass_coordinates_near_player(5, 5, 3, max_nb_tries = 10)
  end
  return terrain
end

def find_spawn_position(radius, min_distance=1)
  if ($PokemonGlobal.surfing || $PokemonGlobal.boat) && $PokemonEncounters.has_water_encounters?
    terrain = :Water
    position = find_random_surfable_coordinates_near_player(radius, radius, 3, max_nb_tries = 10)
  elsif $PokemonEncounters.has_cave_encounters?
    terrain = :Cave
    position = find_random_walkable_coordinates_near_player(radius, radius, 3, max_nb_tries = 10)
  elsif $PokemonEncounters.has_land_encounters?
    position, terrain = find_random_tall_grass_coordinates_near_player(radius, radius, 3, max_nb_tries = 10)
  end
  return unless position

  player_x = $game_player.x
  player_y = $game_player.y

  dx = position[0] - player_x
  dy = position[1] - player_y
  distance = Math.sqrt(dx * dx + dy * dy)

  if distance >= min_distance && can_spawn_pokemon_there(position[0], position[1], terrain)
    return position
  end
  return nil
end

def can_spawn_pokemon_there(x, y, terrain)
  if terrain == :Water
    return $game_map.OWPokemonPassable?(x, y, DIRECTION_ALL) && $game_map.terrain_tag(x, y).can_surf
  end
  return $game_map.OWPokemonPassable?(x, y, DIRECTION_ALL)
end


#fisme: broken
def spawn_overworld_pokemon(wild_pokemon, position, terrain, behavior_roaming = nil, behavior_noticed = nil)
  event = create_overworld_pokemon_event(wild_pokemon, position, terrain,
                                         behavior_roaming, behavior_noticed)
  $PokemonTemp.overworld_pokemon_on_map << event.id if event
  return event
end

def despawn_overworld_pokemon(event_id, terrain)
  event = $game_map.events[event_id]
  if !event
    clearOverworldPokemon
    return
  end
  if event.pokemon.shiny? # re-add it ad the end of the list instead
    $PokemonTemp.overworld_pokemon_on_map.delete(event.id)
    $PokemonTemp.overworld_pokemon_on_map << event.id
    event_id = $PokemonTemp.overworld_pokemon_on_map[0]
    event = $game_map.events[event_id]
  end
  return unless event
  event.despawn
  playOverworldPokemonSpawnAnimation(event, terrain)
end

class PokemonTemp
  attr_accessor :overworld_wild_battle_participants
  attr_accessor :overworld_wild_battle_triggered

  attr_accessor :overworld_pokemon_on_map

  attr_accessor :prevent_ow_encounters
  attr_accessor :prevent_ow_battles # For cutscenes where we stil want Pokemon to spawn but shouldn't encounter them (ex: Mr. Briney boat ride)

end

Events.onStepTaken += proc { |sender, e|
  next unless $scene.is_a?(Scene_Map)
  next unless Settings::GAME_ID == :IF_HOENN
  next if isRepelActive()
  if should_spawn_overworld_pokemon?
    spawn_random_overworld_pokemon_group
  end
}

Events.onMapChanging += proc { |_sender, e|
  next unless Settings::HOENN
  clearOverworldPokemon
}

def clearOverworldPokemon
  echoln "Clearing Overworld Pokemon"
  $game_map.events.clone.each do |id, event|
    if event.is_a?(DynamicOverworldPokemonEvent)
      event.despawn
    end
  end
  $PokemonTemp.pbClearTempEvents
  $PokemonTemp.overworld_pokemon_on_map = []
  $PokemonTemp.overworld_wild_battle_triggered = false
  $PokemonTemp.overworld_wild_battle_participants = []
end

