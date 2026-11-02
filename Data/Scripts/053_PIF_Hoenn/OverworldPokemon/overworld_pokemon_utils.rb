#####
# Noticing player
# ###12

def get_base_sprite_path(is_fusion, shiny=false)
  base_path = "Followers/"
  if is_fusion
    base_path += "Fusions/"
  end
  if shiny
    base_path += "Shiny/"
  end
  return base_path
end

def getRoamingSprite(species_data,shiny=false)
  landPath = getOverworldLandPath(species_data,shiny)
  return landPath if landPath

  flyingPath = getOverworldFlyingPath(species_data,shiny)
  return flyingPath if flyingPath
end

def get_ow_sprite_path(species_data,sprite_name,shiny=false)
  species = species_data.species
  is_fusion = isSpeciesFusion(species)
  if is_fusion
    species_name = species_data.get_body_species_symbol.to_s
  else
    species_name = species.to_s
  end
  base_path = get_base_sprite_path(is_fusion, shiny)
  path = "#{base_path}#{species_name}_#{sprite_name}"
  if pbResolveBitmap("Graphics/Characters/#{path}")
    return path
  end
end

def getOverworldLandPath(species_data,shiny=false)
  species = species_data.species
  is_fusion = isSpeciesFusion(species)
  if is_fusion
    species_name = species_data.get_body_species_symbol.to_s
  else
    species_name = species_data.species.to_s
  end
  base_path = get_base_sprite_path(is_fusion, shiny)
  path = "#{base_path}#{species_name}"
  if pbResolveBitmap("Graphics/Characters/#{path}")
    return path
  end
end

def getOverworldFlyingPath(species_data,shiny=false)
  return get_ow_sprite_path(species_data,"fly",shiny)
end

def getOverworldNoticedPath(species_data,shiny=false)
  return get_ow_sprite_path(species_data,"notice",shiny)
end

def getOverworldSwimmingPath(species_data,shiny=false)
  return get_ow_sprite_path(species_data,"swim",shiny)
end

def getOverworldIdleAnimation(species_data,is_flying, shiny=false)
  if is_flying
    return get_ow_sprite_path(species_data,"fly_idle",shiny)
  else
    return get_ow_sprite_path(species_data,"idle",shiny)
  end
end

def getRandomPokemonFromRoute(excluded_species,terrain)
  random_species = excluded_species
  limit = 5
  i=0
  while random_species == excluded_species || i < limit
    terrain_type = getTimeBasedEncounter(terrain)
    wild_pokemon = getRegularEncounter(terrain_type)
    random_species = wild_pokemon[0] if wild_pokemon.is_a?(Array)
    i+=1
  end
  return GameData::Species.get(random_species)
end


#Used when using Roar in the OW. Makes all the pokemon near the player back off.
def scareOffWildPokemon(radius=5)
  pokemon_in_radius = []
  events_in_radius = getEventsInRadius(radius)
  events_in_radius.each do |event|
    pokemon_in_radius << event if event.is_a?(OverworldPokemonEvent)
  end
  pokemon_in_radius.each do |pokemon_event|
    playAnimation(EXCLAMATION_ANIMATION_ID,pokemon_event.x,pokemon_event.y)
    pokemon_event.move_away_from_player
    pokemon_event.move_away_from_player
  end
end