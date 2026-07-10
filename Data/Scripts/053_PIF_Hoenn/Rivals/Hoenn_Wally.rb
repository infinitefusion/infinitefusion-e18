BATTLED_TRAINER_WALLY_KEY = "wally"

SWITCH_WALLY_CATCHING_POKEMON = 2022
SWITCH_WALLY_GAVE_POKEMON = 2023
SWITCH_WALLY_SAW_CAUGHT_POKEMON = 2123
SWITCH_WALLY_GAVE_POKEMON_DIALOGUE = 2024
SWITCH_DIED_WITH_WALLY = 2120
COMMON_EVENT_WALLY_FOLLOWING_DIALOGUE = 199

def wally_initialize()
  trainer_type = :RIVAL2
  trainer_name = "Wally"
  battledTrainer = BattledTrainer.new(trainer_type, trainer_name, 0, BATTLED_TRAINER_WALLY_KEY)
  battledTrainer.currentTeam = [] # team
  battledTrainer.setFavorite(true)
  battledTrainer.friendship_level=1
  battledTrainer.setOverworldSprite("NPC_Hoenn_Wally")
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY] = battledTrainer
  return battledTrainer
end

def wally_add_pokemon(pokemon_species, level, original_trainer = nil)
  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
  pokemon = Pokemon.new(pokemon_species, level, original_trainer)
  trainer.currentTeam.unshift(pokemon)
  updateRebattledTrainerWithKey(BATTLED_TRAINER_WALLY_KEY, trainer)
end

def wally_add_pokemon_directly(pokemon)
  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
  trainer.currentTeam.unshift(pokemon)
  updateRebattledTrainerWithKey(BATTLED_TRAINER_WALLY_KEY, trainer)
end

def wally_update_team_mauville
  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
  trainer.currentTeam.each do |pokemon|
    pokemon.level = 19
    pokemon.reset_moves
  end
  trainer = evolveRebattledTrainerPokemon(trainer)

  wally_add_pokemon(fusionOf(:MAGNEMITE, :ROSELIA), 16)
  updateRebattledTrainerWithKey(BATTLED_TRAINER_WALLY_KEY, trainer)
end

def get_wally_starter()
  wallyTeam = get_wally_team
  wallyStarter=wallyTeam.last  #starter is the oldest so whatever is at the end
  unless wallyStarter #failsafe
    wallyStarter=wallyTeam[-1]
  end
  return wallyStarter
end

def get_wally_starter_name(variable=1)
  wallyStarter = get_wally_starter
  pbSet(variable,wallyStarter.name)
end
def wally_battle()
  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
  return rematchable_trainer_battle([trainer],nil,false)
end

def wally_remove_pokemon(pokemon_species)
  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
  trainer.currentTeam.each { |pokemon|
    if pokemon.species == pokemon_species
      trainer.currentTeam.delete(pokemon)
      updateRebattledTrainerWithKey(BATTLED_TRAINER_WALLY_KEY, trainer)
      return
    end
  }
end

def get_wally_team
  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
  return trainer.currentTeam
end

def wally_fuse_pokemon(with_fusion_screen = true)

  head_pokemon_index = 1
  body_pokemon_index = 0

  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]

  head_pokemon = trainer.currentTeam[head_pokemon_index]
  body_pokemon = trainer.currentTeam[body_pokemon_index]

  return if head_pokemon.isFusion? || body_pokemon.isFusion?
  npcTrainerFusionScreenPokemon(head_pokemon.clone, body_pokemon.clone) if with_fusion_screen

  fusion_species = getFusedPokemonIdFromSymbols(body_pokemon.species, head_pokemon.species)
  level = (body_pokemon.level + head_pokemon.level) / 2
  fused_pokemon = Pokemon.new(fusion_species, level)


  if body_pokemon.isShiny? || head_pokemon.isShiny?
    fused_pokemon.shiny= true
    if body_pokemon.radar_shiny || head_pokemon.radar_shiny
      fused_pokemon.radar_shiny = true
    end
    if !(body_pokemon.debug_shiny || head_pokemon.debug_shiny)
      fused_pokemon.natural_shiny = true if fused_pokemon.natural_shiny
    end
  end

  echoln fused_pokemon.shiny?

  trainer.currentTeam.delete(body_pokemon)
  trainer.currentTeam.delete(head_pokemon)
  trainer.currentTeam.push(fused_pokemon)

  updateRebattledTrainerWithKey(BATTLED_TRAINER_WALLY_KEY, trainer)
end

def npcTrainerFusionScreenPokemon(headPokemon, bodyPokemon)
  fusionScene = PokemonFusionScene.new
  newSpecies = getFusedPokemonIdFromSymbols(bodyPokemon.species, headPokemon.species)

  newDexNumber = getDexNumberForSpecies(newSpecies)
  if fusionScene.pbStartScreen(bodyPokemon, headPokemon, newDexNumber, :DNASPLICERS)
    fusionScene.pbFusionScreen(false, false, false, false)
    fusionScene.pbEndScreen
  end
end

def npcTrainerFusionScreen(headSpecies, bodySpecies)
  fusionScene = PokemonFusionScene.new
  newid = getFusedPokemonIdFromSymbols(bodySpecies, headSpecies)
  fusionScene.pbStartScreen(Pokemon.new(bodySpecies, 100), Pokemon.new(headSpecies, 100), newid, :DNASPLICERS)
end

def getWallyTrainer()
  return $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
end

def wally_follow(eventId)
  trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_WALLY_KEY]
  partnerWithTrainer(eventId, $game_map.map_id, trainer, BATTLED_TRAINER_WALLY_KEY, COMMON_EVENT_WALLY_FOLLOWING_DIALOGUE)
end

def wally_unfollow()
  unpartnerWithTrainer()
end


