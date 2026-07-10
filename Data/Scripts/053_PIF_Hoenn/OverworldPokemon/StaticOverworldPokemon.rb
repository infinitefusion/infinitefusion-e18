OVERWORLD_POKEMON_EVENT_NAME = "OverworldPokemon"
LEGENDARY_EVENT_NAME = "Legendary"
# For adding wild overworld Pokemon as static events.
#
# The event needs to have the name OverworldPokemon and be have a first comment at the top setup like this
# species = :SPECIES      -> :SPECIES is the symbol of the Pokemon this event should be
# min_level = 11              -> A number for the minimum level
# max_level = 20              -> A number for the maximum level
# behavior_roaming        -> (Optional) The roaming behavior if it needs to be different from the default for that pokemon
# behavior_noticed        -> (Optional) The noticed behavior if it needs to be different from the default for that pokemon
# spawn_chance            ->(Optional) Random % chance for the event to actually spawn every time you enter the map
#
# Exemple:
# OverworldPokemon
# species= :SHARPEDO
# level= 99
# behavior_roaming=:still_teleport
# behavior_noticed=:skittish
#
# This will automatically set the events graphic to the Pokemon. The event should be a parrallel process with a script call to overworldPokemonBehavior
# See the EVENT_TEMPLATES map for an example (should be event #10 in there)
#
class Game_Event < Game_Character
  # Returns an array of lines in the first comment block at the top of the event.
  # Returns nil if the first command isn't a comment.
  def first_comment_block
    return nil if !@page || !@page.list || @page.list.empty?
    list = @page.list
    first_cmd = list[0]
    # Only proceed if the first line is a comment (code 108)
    return nil if first_cmd.code != 108

    # Collect first line + continuation lines
    lines = [first_cmd.parameters[0]]
    i = 1
    while i < list.length && list[i].code == 408
      lines << list[i].parameters[0]
      i += 1
    end
    return lines # Array of strings
  end
end

class Game_Map
  alias ow_game_map_create_new_event create_new_game_event

  def create_new_game_event(event)
    # Only process events that actually belong to this map
    unless @map.events[event.id] == event
      return ow_game_map_create_new_event(event)
    end

    if Settings::HOENN && event.name == OVERWORLD_POKEMON_EVENT_NAME
      begin
        game_event = StaticOverworldPokemonEvent.new(@map_id, event, self)
        setup_overworld_pokemon_from_comments(game_event)
        return game_event if game_event
      rescue
        return ow_game_map_create_new_event(event)
      end
    elsif event.name.start_with?(LEGENDARY_EVENT_NAME)
      species = extract_legendary_species_from_event_name(event.name)
      unless is_legendary_active?(species)
        event = ow_game_map_create_new_event(event)
        event.erase
        return event
      end
    end

    return ow_game_map_create_new_event(event)
  end

  def extract_legendary_species_from_event_name(eventName)
    match = eventName.match(/#{Regexp.escape(LEGENDARY_EVENT_NAME)}\(([^)]+)\)/) # Capture anything inside parentheses
    species = match[1] if match && match.length > 0
    return species.to_sym if species
  end

  def setup_overworld_pokemon(event, pokemon, terrain = :Land, behavior_roaming = nil, behavior_noticed = nil)
    event.setup_pokemon(pokemon.species, pokemon.level, terrain, behavior_roaming, behavior_noticed)
    event.set_shiny if pokemon.isShiny?
    event.manual_ow_pokemon = true
  end

  def setup_overworld_pokemon_from_comments(event)
    params = extract_parameters_from_comments(event)
    unless params && params.is_a?(Hash)
      raise "Error: Couldn't setup overworld Pokemon for event #{event.id} in map #{@map_id}"
    end
    spawn_chance = params[:spawn_chance]
    spawn_chance = 100 unless spawn_chance && spawn_chance.is_a?(Integer)
    should_spawn = spawn_chance >= rand(0..100)
    if should_spawn
      species = params[:species]
      min_level = params[:min_level]
      max_level = params[:max_level]
      terrain = params[:terrain] || :Land
      level = choose_level(min_level, max_level)
      ability = params[:ability]
      behavior_roaming = params[:behavior_roaming]
      behavior_noticed = params[:behavior_noticed]

      always_on_top = event.always_on_top
      event.setup_pokemon(species, level, terrain, behavior_roaming, behavior_noticed)
      event.pokemon.ability= ability if ability
      event.set_swimming if params[:swimming]
      event.set_shiny if params[:shiny]
      event.always_on_top = always_on_top
      event.manual_ow_pokemon = true
      event.set_post_battle_switch(params[:post_battle_switch]) if params[:post_battle_switch]
    else
      event.erase
    end
  end

  def extract_parameters_from_comments(event)
    comments = event.first_comment_block
    return nil if !comments || comments.empty?
    result = {}
    comments.each do |line|
      # Matches species = :PIKACHU (all caps after :)
      if line =~ /species\s*=\s*:(\b[A-Z0-9_]+\b)/
        result[:species] = $1.to_sym
        # Matches level = 25 (any integer)
      elsif line =~ /min_level\s*=\s*(\d+)/
        result[:min_level] = $1.to_i
      elsif line =~ /max_level\s*=\s*(\d+)/
        result[:max_level] = $1.to_i
        # Matches behavior_roaming = :random (any ruby symbol)
      elsif line =~ /behavior_roaming\s*=\s*:(\w+)/
        result[:behavior_roaming] = $1.to_sym
        # Matches behavior_noticed = :random (any ruby symbol)
      elsif line =~ /behavior_noticed\s*=\s*:(\w+)/
        result[:behavior_noticed] = $1.to_sym
      elsif line =~ /terrain\s*=\s*:(\w+)/
        result[:terrain] = $1.to_sym
      elsif line =~ /spawn_chance\s*=\s*(\d+)/
        result[:spawn_chance] = $1.to_i
      elsif line =~ /swimming/
        result[:swimming] = true
      elsif line =~ /flying/
        result[:flying] = true
      elsif line =~ /shiny/
        result[:shiny] = true
      elsif line =~ /ability\s*=\s*:(\w+)/
        result[:ability] = $1.to_sym
      elsif line =~ /switch\s*=\s*(\d+)/ # A switch that will be turned on after the pokemon is battled
        result[:post_battle_switch] = $1.to_i
      end
    end
    return result
  end

  def choose_level(min_level, max_level)
    # raise "No level defined" if min_level.nil? && max_level.nil?
    return min_level if max_level.nil?
    return max_level if min_level.nil?
    return max_level if min_level > max_level
    rand(min_level..max_level)
  end

end

