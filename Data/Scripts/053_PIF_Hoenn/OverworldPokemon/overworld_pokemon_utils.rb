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
  species = species_data.species
  is_fusion = isSpeciesFusion(species)
  if is_fusion
    species_name = species_data.get_body_species_symbol.to_s
  else
    species_name = species.to_s
  end
  base_path = get_base_sprite_path(is_fusion, shiny)
  path = "#{base_path}#{species_name}_fly"
  if pbResolveBitmap("Graphics/Characters/#{path}")
    return path
  end
end

def getOverworldNoticedPath(species_data,shiny=false)
  species = species_data.species
  is_fusion = isSpeciesFusion(species)
  if is_fusion
    species_name = species_data.get_body_species_symbol.to_s
  else
    species_name = species.to_s
  end
  base_path = get_base_sprite_path(is_fusion, shiny)
  path = "#{base_path}#{species_name}_notice"
  if pbResolveBitmap("Graphics/Characters/#{path}")
    return path
  end
end

def getOverworldSwimmingPath(species_data,shiny=false)
  species = species_data.species

  is_fusion = isSpeciesFusion(species)
  if is_fusion
    species_name = species_data.get_body_species_symbol.to_s
  else
    species_name = species.to_s
  end
  base_path = get_base_sprite_path(is_fusion, shiny)
  path = "#{base_path}#{species_name}_swim"
  if pbResolveBitmap("Graphics/Characters/#{path}")
    return path
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