# frozen_string_literal: true
HOENN_RIVAL_EVENT_NAME = "HOENN_RIVAL"
TEMPLATE_CHARACTER_FILE = "NPC_template"

HOENN_MOM_BRENDAN_CHARNAME = "NPC_Hoenn_BrendanMom"
HOENN_MOM_MAY_CHARNAME = "NPC_Hoenn_MayMom"
HOENN_MAX_CHARNAME = "NPC_Hoenn_Max"

class Player < Trainer
  attr_accessor :rival_appearance

  alias pokemonEssentials_player_initialize initialize

  def initialize(*args)
    pokemonEssentials_player_initialize(*args)
  end

  def init_rival_appearance(skin_color = 1, hair)
    if isPlayerMale
      @rival_appearance = TrainerAppearance.new(skin_color,
                                                HAT_MAY,
                                                CLOTHES_MAY,
                                                hair,
                                                0, 0, 0)
    else
      @rival_appearance = TrainerAppearance.new(skin_color,
                                                HAT_BRENDAN,
                                                CLOTHES_BRENDAN,
                                                hair,
                                                0, 0, 0)
    end
  end

  def rival_appearance
    @rival_appearance = init_rival_appearance(1, nil) if !@rival_appearance
    return @rival_appearance
  end

  def rival_appearance=(value)
    @rival_appearance = value
  end
end

BATTLED_TRAINER_RIVAL_KEY = "rival"

def get_hoenn_character_name(name)
  return pbGetMessageFromHash(MessageTypes::TrainerNames, name)
end

def get_rival_name
  rival_name = get_hoenn_character_name("Brendan") if isPlayerFemale
  rival_name = get_hoenn_character_name("May") if isPlayerMale
  return rival_name
end

def init_rival_name
  rival_name = get_rival_name
  @name = rival_name
  return rival_name
end

def set_rival_hat(hat)
  $Trainer.rival_appearance = TrainerAppearance.new(
    $Trainer.rival_appearance.skin_color,
    hat,
    $Trainer.rival_appearance.clothes,
    $Trainer.rival_appearance.hair,
    $Trainer.rival_appearance.hair_color,
    $Trainer.rival_appearance.clothes_color,
    $Trainer.rival_appearance.hat_color,
  )
end

class Sprite_Character
  alias PIF_typeExpert_checkModifySpriteGraphics checkModifySpriteGraphics

  def checkModifySpriteGraphics(character)
    PIF_typeExpert_checkModifySpriteGraphics(character)
    return if character == $game_player
    unless character.visible?
      @bitmap_override = nil
      updateBitmap
      return
    end
    setSpriteToAppearance($Trainer.rival_appearance) if isPlayerFemale && character.name.start_with?(HOENN_RIVAL_EVENT_NAME) && character.character_name == TEMPLATE_CHARACTER_FILE
    setSpriteToAppearance($Trainer.rival_appearance) if isPlayerMale && character.name.start_with?(HOENN_RIVAL_EVENT_NAME) && character.character_name == TEMPLATE_CHARACTER_FILE

    if character.character_name == HOENN_MOM_BRENDAN_CHARNAME
      skinColor = $Trainer.skin_tone if isPlayerMale
      skinColor = $Trainer.rival_appearance.skin_color if isPlayerFemale
      sprite_path = "Graphics/Characters/player/family/NPC_Hoenn_Mom_Brendan_#{skinColor.to_s}"
      setSpriteToStaticAppearance(sprite_path)
    end

    if character.character_name == HOENN_MOM_MAY_CHARNAME
      skinColor = $Trainer.skin_tone if isPlayerFemale
      skinColor = $Trainer.rival_appearance.skin_color if isPlayerMale
      sprite_path = "Graphics/Characters/player/family/NPC_Hoenn_Mom_May_#{skinColor.to_s}"
      setSpriteToStaticAppearance(sprite_path)
    end

    if character.character_name == HOENN_MAX_CHARNAME
      sprite_path = "Graphics/Characters/player/family/NPC_Hoenn_Max_#{$Trainer.rival_appearance.skin_color.to_s}"
      setSpriteToStaticAppearance(sprite_path)
    end
  end
end

def get_hoenn_rival_starter
  case get_rival_starter_type()
  when :GRASS
    return obtainStarter(0)
  when :FIRE
    return obtainStarter(1)
  when :WATER
    return obtainStarter(2)
  else
    # fallback, should not happen
    return obtainStarter(0)
  end
end

def get_rival_starter_type()
  player_chosen_starter_index = pbGet(VAR_HOENN_CHOSEN_STARTER_INDEX)
  case player_chosen_starter_index
  when 0 # GRASS
    return :FIRE
  when 1 # FIRE
    return :WATER
  when 2 # WATER
    return :GRASS
  end
end

def get_other_starter
  case get_rival_starter_type()
  when :GRASS
    return obtainStarter(1)
  when :FIRE
    return obtainStarter(2)
  when :WATER
    return obtainStarter(0)
  else
    # fallback, should not happen
    return obtainStarter(0)
  end
end


def updateRivalTeamForSecondBattle()

  rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  rival_starter = rival_trainer.currentTeam[0]
  rival_starter_species = rival_starter.species

  echoln rival_starter_species
  player_chosen_starter_index = pbGet(VAR_HOENN_CHOSEN_STARTER_INDEX)
  team = []

  fused_starter= false
  if isSpeciesFusion(rival_starter_species)
    fused_starter = true
    starter_species = rival_starter_species
  end

  case player_chosen_starter_index
  when 0 # GRASS
    if isPlayerFemale()
      other_pokemon_species = :WINGULL
      starter_species = getFusionSpeciesSymbol(:LOTAD, rival_starter_species) unless fused_starter #lotad/torchic
    else
      other_pokemon_species = :WAILMER
      starter_species = getFusionSpeciesSymbol(rival_starter_species, :SHROOMISH) unless fused_starter #torchic/shroomish
    end
  when 1 # FIRE
    if isPlayerFemale()
      other_pokemon_species = :LOTAD
      starter_species = getFusionSpeciesSymbol(:SLUGMA, rival_starter_species) unless fused_starter  #Slugma/Mudkip
    else
      other_pokemon_species = :SHROOMISH
      starter_species = getFusionSpeciesSymbol(rival_starter_species, :NUMEL) unless fused_starter  #Mudkip/Numel
    end

  when 2 # WATER
    if isPlayerFemale()
      other_pokemon_species = :NUMEL
      starter_species = getFusionSpeciesSymbol(rival_starter_species, :WINGULL) unless fused_starter #treecko/wingull
    else
      other_pokemon_species = :SLUGMA
      starter_species = getFusionSpeciesSymbol(:WAILMER, rival_starter_species) unless fused_starter #+wailmer/treecko
    end
  end
  team << Pokemon.new(other_pokemon_species, 12, rival_trainer.trainerName)
  team << Pokemon.new(starter_species, 15, rival_trainer.trainerName)

  rival_trainer.currentTeam = team
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer
  $game_switches[SWITCH_RIVAL_BATTLE_2] = true
end

# This sets up the rival's main team for the game
# For later battles, we can just add Pokemon and gain exp the same way as other
# trainer rematches
#
# Basically, rival catches a pokemon the type of their rival's starter - fuses it with their starters
# Has a team composed of fire/grass, water/grass, water/fire pokemon
def updateRivalTeamForThirdBattle()
  updateRivalTeamForSecondBattle unless $game_switches[SWITCH_RIVAL_BATTLE_2]
  rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  rival_trainer.friendship_level = 2
  if rival_trainer.currentTeam.length >= 2 #Intended
    rival_starter = rival_trainer.currentTeam[1]
  else  #For compatibility with older version
    rival_starter = rival_trainer.currentTeam[0]
  end
  starter_species = rival_starter.species

  rival_starter.level = 20
  team = []
  team << rival_starter
  rival_trainer.currentTeam = team
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer

  # twice so that starter evolves both head and body
  # evolution_species = rival_starter.check_evolution_on_level_up(false)
  # echoln evolution_species
  # if evolution_species
  #   starter_species = evolution_species
  # end

  player_chosen_starter_index = pbGet(VAR_HOENN_CHOSEN_STARTER_INDEX)
  case player_chosen_starter_index
  when 0 # GRASS
    if isPlayerFemale()
      fire_grass_pokemon = starter_species
      water_fire_pokemon = getFusionSpeciesSymbol(:NUMEL, :WINGULL)
      water_grass_pokemon = getFusionSpeciesSymbol(:WAILMER, :SHROOMISH)
    end
    if isPlayerMale()
      fire_grass_pokemon = starter_species
      water_fire_pokemon = getFusionSpeciesSymbol(:LOMBRE, :WINGULL)
      water_grass_pokemon = getFusionSpeciesSymbol(:SLUGMA, :WAILMER)
    end
    contains_starter = [fire_grass_pokemon]
    other_pokemon = [water_fire_pokemon, water_grass_pokemon]

  when 1 # FIRE
    if isPlayerFemale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:SHROOMISH, :NUMEL)
      water_fire_pokemon = getFusionSpeciesSymbol(:LOMBRE, :WAILMER)
      water_grass_pokemon = starter_species
    end
    if isPlayerMale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:LOMBRE, :SLUGMA,)
      water_fire_pokemon = getFusionSpeciesSymbol(:SHROOMISH, :WINGULL,)
      water_grass_pokemon = starter_species
    end
    contains_starter = [water_grass_pokemon]
    other_pokemon = [water_fire_pokemon, fire_grass_pokemon]

  when 2 # WATER
    if isPlayerFemale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:SLUGMA, :SHROOMISH)
      water_fire_pokemon = starter_species
      water_grass_pokemon = getFusionSpeciesSymbol(:WAILMER, :NUMEL)
    end
    if isPlayerMale()
      fire_grass_pokemon = getFusionSpeciesSymbol(:LOMBRE, :NUMEL,)
      water_fire_pokemon = starter_species
      water_grass_pokemon = getFusionSpeciesSymbol(:SLUGMA, :WINGULL)
    end
    contains_starter = [water_fire_pokemon]
    other_pokemon = [water_grass_pokemon, fire_grass_pokemon]
  end

  team = []

  team << Pokemon.new(other_pokemon[0], 22, rival_trainer.trainerName)
  team << Pokemon.new(other_pokemon[1], 22, rival_trainer.trainerName)
  team << Pokemon.new(contains_starter[0], 24, rival_trainer.trainerName)

  rival_trainer.currentTeam = team

  evolveRivalTeam
  evolveRivalTeam
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer
end

def levelUpRivalTeam(experience = 0)
  rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  updated_trainer = makeRebattledTrainerTeamGainExp(rival_trainer, false, experience)
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = updated_trainer
end

def evolveRivalTeam()
  rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  updated_trainer = evolveRebattledTrainerPokemon(rival_trainer)
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = updated_trainer
end

def addPokemonToRivalTeam(species, level)
  rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  rival_trainer.currentTeam << Pokemon.new(species, level, rival_trainer.trainerName)
  $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer
end

def initializeRivalBattledTrainer
  trainer_type = :RIVAL1
  trainer_name = pbGet(VAR_RIVAL_NAME)
  trainer_appearance = $Trainer.rival_appearance
  rivalBattledTrainer = BattledTrainer.new(trainer_type, trainer_name, 0, BATTLED_TRAINER_RIVAL_KEY)
  rivalBattledTrainer.set_custom_appearance(trainer_appearance)
  rivalBattledTrainer.friendship_level = 1
  team = []
  team << Pokemon.new(get_hoenn_rival_starter, 5, trainer_name)
  rivalBattledTrainer.currentTeam = team
  return rivalBattledTrainer
end

def rivalRematch(loseDialog)
  trainer = getRebattledTrainerFromKey(BATTLED_TRAINER_RIVAL_KEY)
  updated_trainer = healRebattledTrainerPokemon(trainer)
  $PokemonTemp.battleRules["moneyGain"] = false
  player_won = hoennRivalBattle(loseDialog)
  checkTrainerRematchChallenges()
  # trainer
  updated_trainer = makeRebattledTrainerTeamGainExp(updated_trainer, player_won)
  updated_trainer = healRebattledTrainerPokemon(updated_trainer)
  updated_trainer.set_pending_action(false)
  updated_trainer = evolveRebattledTrainerPokemon(updated_trainer)
  updateRebattledTrainerWithKey(BATTLED_TRAINER_RIVAL_KEY,updated_trainer)
end

def rivalTrade
  trainer = getRebattledTrainerFromKey(BATTLED_TRAINER_RIVAL_KEY)
  trainer = doNPCTrainerTrade(trainer)
  updateRebattledTrainerWithKey(BATTLED_TRAINER_RIVAL_KEY,trainer)
end

def hoennRivalBattle(loseDialog = "...", canLose = false, items = [])
  $PokemonGlobal.battledTrainers = {} if !$PokemonGlobal.battledTrainers
  if !$PokemonGlobal.battledTrainers.has_key?(BATTLED_TRAINER_RIVAL_KEY)
    rival_trainer = initializeRivalBattledTrainer()
    rival_trainer.setFavorite(true)
    rival_trainer.setLocation(_INTL("On the move!"))

    $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY] = rival_trainer
  else
    rival_trainer = $PokemonGlobal.battledTrainers[BATTLED_TRAINER_RIVAL_KEY]
  end
  return customTrainerBattle(rival_trainer.trainerName, rival_trainer.trainerType, rival_trainer.currentTeam, rival_trainer, loseDialog, nil, $Trainer.rival_appearance, items, canLose)
end
