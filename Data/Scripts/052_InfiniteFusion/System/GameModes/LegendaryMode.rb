# frozen_string_literal: true

GYM_TRAINERS = []
GYM_LEADER_MAX_RETRIES = 20
# def generate_legendaries_mode_trainers()
#   echoln "Converting trainers to legendary mode..."
#   trainers_list = getTrainersDataMode.list_all
#   for trainer_array in trainers_list
#     trainer = trainer_array[1]
#     echoln "------"
#     echoln "Processing [#{trainer.id}#] {trainer.traiàner_type} ##{trainer.real_name}"
#     new_party=[]
#     old_party = trainer.pokemon
#     for pokemon in old_party
#       species = pokemon[:species]
#       new_species = convert_species_to_legendary(species)
#       #echoln "#{get_readable_fusion_name(species)} -> #{get_readable_fusion_name(new_species)}"
#     end
#
#   end
# end

def initializeLegendaryMode()
  $game_variables[VAR_CURRENT_GYM_TYPE] = -1
  $game_switches[SWITCH_RANDOM_TRAINERS] = true
  $game_switches[SWITCH_RANDOMIZE_GYMS_SEPARATELY] = true
  $game_switches[SWITCH_GYM_RANDOM_EACH_BATTLE] = false
  $game_switches[SWITCH_RANDOM_GYM_PERSIST_TEAMS] = true
  $game_switches[SWITCH_LEGENDARY_MODE] = true
  $game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE] = true
  addLegendaryEggsToPC
  $PokemonSystem.hide_custom_eggs = true
  $PokemonSystem.type_icons = true
end

def convert_species_to_legendary(dex_number)
  species = GameData::Species.get(dex_number).species
  dex_number = getDexNumberForSpecies(species)
  return species if isTripleFusion?(dex_number)
  isFusion = isFusion(dex_number)
  new_species = isFusion ? convert_fusion_to_legendary(species) : convert_unfused_to_legendary(species)
  echoln "#{get_readable_fusion_name(species)} -> #{get_readable_fusion_name(new_species)}"
  return new_species
end

# Takes an unfused Pokemon and fuses it with a random legendary
def convert_unfused_to_legendary(unfused_species)
  legendary_species = LEGENDARIES_LIST.sample
  pokemon_to_fuse = [unfused_species, legendary_species].shuffle

  head_species = pokemon_to_fuse[0]
  body_species = pokemon_to_fuse[1]

  fusion_species = getFusionSpecies(body_species, head_species)
  if customSpriteExists(body_species, head_species) # && pokemonHasCorrectType(fusion_species)
    return fusion_species.species
  else
    # Try again
    return convert_unfused_to_legendary(unfused_species)
  end
end

def convert_fusion_to_legendary(species, nb_retries = 0)
  permissive_type_validation = nb_retries >= GYM_LEADER_MAX_RETRIES
  if isInGym? && !permissive_type_validation
    getNewLegendaryFusionForGymType(species, nb_retries)
  else
    getNewLegendaryFusion(species, nb_retries)
  end

end

def getNewLegendaryFusion(original_species, nb_retries = 0)
  head_species = get_head_id_from_symbol(original_species)
  body_species = get_body_id_from_symbol(original_species)

  if rand(2) == 0
    head_species = LEGENDARIES_LIST.sample
  else
    body_species = LEGENDARIES_LIST.sample
  end

  if customSpriteExists(body_species, head_species)
    return getFusionSpecies(body_species, head_species).species
  else
    # Try again
    return getNewLegendaryFusion(original_species, nb_retries + 1)
  end
end

# In gyms, the game tries to figure out which of the head and body is of the
# gym's type and replaces the other one with a legendary.
# If there isn't one, it will eventually go in permissive mode and
# replace either one
def getNewLegendaryFusionForGymType(original_species, nb_retries = 0)
  return getNewLegendaryFusion(original_species, nb_retries) if nb_retries > GYM_LEADER_MAX_RETRIES

  head_species_id = get_head_id_from_symbol(original_species)
  body_species_id = get_body_id_from_symbol(original_species)

  head_species = GameData::Species.get(head_species_id)
  body_species = GameData::Species.get(body_species_id)

  gym_type = getLeaderType()
  base_pokemon_with_gym_type = [head_species, body_species].select do |species|
    GameData::Species.get(species).hasType?(gym_type)
  end
  return getNewLegendaryFusion(original_species, nb_retries) if base_pokemon_with_gym_type.empty?

  if base_pokemon_with_gym_type.length == 2
    pokemon_to_be_kept = base_pokemon_with_gym_type.sample
    pokemon_to_be_replaced = (base_pokemon_with_gym_type - [pokemon_to_be_kept]).first
  elsif base_pokemon_with_gym_type.length == 1
    # Only one has the gym type — keep it
    pokemon_to_be_kept = base_pokemon_with_gym_type.first
    pokemon_to_be_replaced = (pokemon_to_be_kept == head_species) ? body_species : head_species
  else  #Neither have the type, just pick at random
    pokemon_to_be_kept = base_pokemon_with_gym_type.sample
    pokemon_to_be_replaced = (base_pokemon_with_gym_type - [pokemon_to_be_kept]).first
  end

  echoln "gymType: #{gym_type} - body_species: #{body_species.species} head_species: #{head_species.species}, kept: #{pokemon_to_be_kept.species}"

  legendary_species = LEGENDARIES_LIST.sample
  return getNewLegendaryFusion(original_species, nb_retries)  unless pokemon_to_be_replaced
  if pokemon_to_be_replaced.species == head_species.species
    head_species_id = legendary_species
  else
    body_species_id = legendary_species
  end
  echoln "picked #{head_species_id}/#{body_species_id}"
  echoln "custom sprite exists: #{customSpriteExists(body_species_id, head_species_id)}"
  if customSpriteExists(body_species_id, head_species_id)
    return getFusionSpecies(body_species_id, head_species_id).species
  else
    return getNewLegendaryFusionForGymType(original_species, nb_retries + 1)
  end

end

def isInGym?()
  return $game_variables[VAR_CURRENT_GYM_TYPE] != -1 && $game_variables[VAR_CURRENT_GYM_TYPE]<= GYM_TYPES_ARRAY.length
end

def pokemonHasCorrectType(species)
  return true if !isInGym? # not in a gym
  leaderType = getLeaderType()
  if leaderType == nil
    return true
  else
    return species.hasType?(leaderType)
  end
end

def addLegendaryEggsToPC()
  legendaries_species = LEGENDARIES_LIST.shuffle
  legendaries_species.each do |species|
    pokemon = Pokemon.new(species, Settings::EGG_LEVEL)
    pokemon.steps_to_hatch = pokemon.species_data.hatch_steps/2
    pokemon.name = "Egg"
    $PokemonStorage.pbStoreCaught(pokemon)
  end
end

def generate_legendary_mode_starters
  grass_option = getFusionSpecies(Settings::GRASS_STARTERS.sample,LEGENDARIES_LIST.sample)
  fire_option = getFusionSpecies(Settings::FIRE_STARTERS.sample,LEGENDARIES_LIST.sample)
  water_option = getFusionSpecies(Settings::WATER_STARTERS.sample,LEGENDARIES_LIST.sample)
  return [grass_option, fire_option, water_option]
end
