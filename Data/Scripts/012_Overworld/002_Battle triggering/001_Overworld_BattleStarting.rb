#===============================================================================
# Battle preparation
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :nextBattleBGM
  attr_accessor :nextBattleME
  attr_accessor :nextBattleCaptureME
  attr_accessor :nextBattleBack
end

class PokemonTemp
  attr_accessor :encounterTriggered
  attr_accessor :encounterType
  attr_accessor :evolutionLevels
  attr_accessor :battle_npc_used_items

  def battleRules
    @battleRules = {} if !@battleRules
    return @battleRules
  end

  def clearBattleRules
    self.battleRules.clear
  end

  def recordBattleRule(rule, var = nil)
    rules = self.battleRules
    case rule.to_s.downcase
    when "single", "1v1", "1v2", "2v1", "1v3", "3v1",
      "double", "2v2", "2v3", "3v2", "triple", "3v3"
      rules["size"] = rule.to_s.downcase
    when "birdboss" then rules["birdboss"] = true
    when "canlose" then rules["canLose"] = true
    when "cannotlose" then rules["canLose"] = false
    when "canrun" then rules["canRun"] = true
    when "cannotrun" then rules["canRun"] = false
    when "roamerflees" then rules["roamerFlees"] = true
    when "noexp" then rules["expGain"] = false
    when "nomoney" then rules["moneyGain"] = false
    when "switchstyle" then rules["switchStyle"] = true
    when "setstyle" then rules["switchStyle"] = false
    when "anims" then rules["battleAnims"] = true
    when "noanims" then rules["battleAnims"] = false
    when "surprise" then rules["surprise"] = true
    when "terrain"
      terrain_data = GameData::BattleTerrain.try_get(var)
      rules["defaultTerrain"] = (terrain_data) ? terrain_data.id : nil
    when "weather"
      weather_data = GameData::BattleWeather.try_get(var)
      rules["defaultWeather"] = (weather_data) ? weather_data.id : nil
    when "environment", "environ"
      environment_data = GameData::Environment.try_get(var)
      rules["environment"] = (environment_data) ? environment_data.id : nil
    when "backdrop", "battleback" then rules["backdrop"] = var
    when "base" then rules["base"] = var
    when "outcome", "outcomevar" then rules["outcomeVar"] = var
    when "nopartner" then rules["noPartner"] = true
    when "favoredmoves" then rules["favoredMoves"] = var
    when "windside" then rules["windSide"] = var

    else
      raise _INTL("Battle rule \"{1}\" does not exist.", rule)
    end
  end
end

def setBattleRule(*args)
  r = nil
  for arg in args
    if r
      $PokemonTemp.recordBattleRule(r, arg)
      r = nil
    else
      case arg.downcase
      when "terrain", "weather", "environment", "environ", "backdrop",
        "battleback", "base", "outcome", "outcomevar"
        r = arg
        next
      end
      $PokemonTemp.recordBattleRule(arg)
    end
  end
  raise _INTL("Argument {1} expected a variable after it but didn't have one.", r) if r
end

def pbNewBattleScene
  return PokeBattle_Scene.new
end

def getWaterBattleBackgroundFromMetadata(metadata)
  battle_bg = metadata.battle_background_water
  echoln metadata.battle_background_water

  return battle_bg if battle_bg
  return "water" #Default fallback when none defined
end

def getBattleBackgroundFromMetadata(metadata)
  # if battle bg specified, return that
  battle_bg = metadata.battle_background
  return battle_bg if battle_bg
  # if no battle bg specified, dedude from environment
  battle_env = metadata.battle_environment
  case battle_env
  when :Cave
    return "Cave"
  when :Grass
    return "Field"
  when :Rock
    return "Mountain"
  when :Underwater
    return "Underwater"
  when :StillWater
    return "Water"
  when :MovingWater
    return "Water"
  when :Forest
    return "Forest"
  end

  # if is city
  if metadata.teleport_destination && metadata.announce_location && metadata.outdoor_map
    return "City"
  end

end

# Sets up various battle parameters and applies special rules.
def pbPrepareBattle(battle)
  battleRules = $PokemonTemp.battleRules
  # The size of the battle, i.e. how many Pokémon on each side (default: "single")
  battle.setBattleMode(battleRules["size"]) if !battleRules["size"].nil? || $game_switches[SWITCH_NEW_GAME_PLUS]
  battle.setBattleMode("1v3") if !battleRules["birdboss"].nil?

  # Whether the game won't black out even if the player loses (default: false)
  battle.canLose = battleRules["canLose"] if !battleRules["canLose"].nil?
  # Whether the player can choose to run from the battle (default: true)
  battle.canRun = battleRules["canRun"] if !battleRules["canRun"].nil?
  # Whether wild Pokémon always try to run from battle (default: nil)
  battle.rules["alwaysflee"] = battleRules["roamerFlees"]
  # Whether Pokémon gain Exp/EVs from defeating/catching a Pokémon (default: true)
  battle.expGain = battleRules["expGain"] if !battleRules["expGain"].nil?
  # Whether the player gains/loses money at the end of the battle (default: true)
  battle.moneyGain = battleRules["moneyGain"] if !battleRules["moneyGain"].nil?
  #For wild Pokemon that are caught off guard - skips their first turn
  battle.caughtOffGuard = battleRules["surprise"] if !battleRules["surprise"].nil?
  # Whether the player is able to switch when an opponent's Pokémon faints
  battle.switchStyle = ($PokemonSystem.battlestyle == 0)
  battle.switchStyle = battleRules["switchStyle"] if !battleRules["switchStyle"].nil?
  # Whether battle animations are shown
  battle.showAnims = ($PokemonSystem.battlescene == 0)
  battle.showAnims = battleRules["battleAnims"] if !battleRules["battleAnims"].nil?
  # Terrain
  battle.defaultTerrain = battleRules["defaultTerrain"] if !battleRules["defaultTerrain"].nil?
  battle.favored_moves = battleRules["favoredMoves"] if !battleRules["favoredMoves"].nil?
  battle.wind_side = battleRules["windSide"] if !battleRules["windSide"].nil?

  # Weather
  if battleRules["defaultWeather"].nil?
    case GameData::Weather.get($game_screen.weather_type).category
    when :Rain
      battle.defaultWeather = :Rain
    when :Hail
      battle.defaultWeather = :Hail
    when :Sandstorm
      battle.defaultWeather = :Sandstorm
    when :Sun
      battle.defaultWeather = :Sun
    when :StrongWinds
      battle.defaultWeather = :StrongWinds
    end
  else
    battle.defaultWeather = battleRules["defaultWeather"]
  end
  # Environment
  if battleRules["environment"].nil?
    battle.environment = pbGetEnvironment
  else
    battle.environment = battleRules["environment"]
  end
  # Backdrop graphic filename
  if !battleRules["backdrop"].nil?
    backdrop = battleRules["backdrop"]
  elsif $PokemonGlobal.nextBattleBack
    backdrop = $PokemonGlobal.nextBattleBack
  elsif $PokemonGlobal.surfing
    back = getWaterBattleBackgroundFromMetadata(GameData::MapMetadata.get($game_map.map_id))
    backdrop = back if back && back != ""
  elsif GameData::MapMetadata.exists?($game_map.map_id)
    back = getBattleBackgroundFromMetadata(GameData::MapMetadata.get($game_map.map_id))
    backdrop = back if back && back != ""
  end

  if !backdrop
    isOutdoor = GameData::MapMetadata.get($game_map.map_id).outdoor_map rescue false
    backdrop = "indoorA" if !isOutdoor
    backdrop = "Field" if isOutdoor
  end

  battle.backdrop = backdrop
  # Choose a name for bases depending on environment
  if battleRules["base"].nil?
    environment_data = GameData::Environment.try_get(battle.environment)
    base = environment_data.battle_base if environment_data
  else
    base = battleRules["base"]
  end
  battle.backdropBase = base if base
  # Time of day

  if Settings::TIME_SHADING
    timeNow = pbGetTimeNow
    if PBDayNight.isNight?(timeNow);
      battle.time = 2
    elsif PBDayNight.isEvening?(timeNow);
      battle.time = 1
    else
      ; battle.time = 0
    end
  end
end

# Used to determine the environment in battle, and also the form of Burmy/
# Wormadam.
def pbGetEnvironment
  ret = :None
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  ret = map_metadata.battle_environment if map_metadata && map_metadata.battle_environment
  if $PokemonTemp.encounterType &&
    GameData::EncounterType.get($PokemonTemp.encounterType).type == :fishing
    terrainTag = $game_player.pbFacingTerrainTag
  else
    terrainTag = $game_player.terrain_tag
  end
  tile_environment = terrainTag.battle_environment
  if ret == :Forest && [:Grass, :TallGrass].include?(tile_environment)
    ret = :ForestGrass
  else
    ret = tile_environment if tile_environment
  end
  return ret
end

Events.onStartBattle += proc { |_sender|
  # Record current levels of Pokémon in party, to see if they gain a level
  # during battle and may need to evolve afterwards
  $PokemonTemp.evolutionLevels = []
  for i in 0...$Trainer.party.length
    $PokemonTemp.evolutionLevels[i] = $Trainer.party[i].level
  end
}

def pbCanDoubleBattle?
  return $PokemonGlobal.partner || $Trainer.able_pokemon_count >= 2
end

def pbCanTripleBattle?
  return true if $Trainer.able_pokemon_count >= 3
  return $PokemonGlobal.partner && $Trainer.able_pokemon_count >= 2
end

#===============================================================================
# Start a wild battle
#===============================================================================
def pbWildBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose = $PokemonTemp.battleRules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.able_pokemon_count == 0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $Trainer.pokemon_count > 0
    pbSet(outcomeVar, 1) # Treat it as a win
    $PokemonTemp.clearBattleRules
    $PokemonGlobal.nextBattleBGM = nil
    $PokemonGlobal.nextBattleME = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack = nil
    $PokemonTemp.forced_alt_sprites = nil
    pbMEStop
    return 1 # Treat it as a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate wild Pokémon based on the species and level
  foeParty = []
  sp = nil
  for arg in args
    if arg.is_a?(Pokemon)
      foeParty.push(arg)
      Events.onWildPokemonCreate.trigger(nil, arg)
    elsif arg.is_a?(Array)
      species = GameData::Species.get(arg[0]).id
      pkmn = pbGenerateWildPokemon(species, arg[1])
      foeParty.push(pkmn)
    elsif sp
      species = GameData::Species.get(sp).id
      pkmn = pbGenerateWildPokemon(species, arg)
      foeParty.push(pkmn)
      sp = nil
    else
      sp = arg
    end
  end
  raise _INTL("Expected a level after being given {1}, but one wasn't found.", sp) if sp
  # Calculate who the trainers and their party are
  playerTrainers = [$Trainer]
  playerParty = $Trainer.party
  playerPartyStarts = [0]
  room_for_partner = (foeParty.length > 1)
  if !room_for_partner && $PokemonTemp.battleRules["size"] &&
    !["single", "1v1", "1v2", "1v3"].include?($PokemonTemp.battleRules["size"])
    room_for_partner = true
  end
  if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && room_for_partner
    ally = NPCTrainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
    ally.id = $PokemonGlobal.partner[2]
    ally.party = $PokemonGlobal.partner[3]
    playerTrainers.push(ally)
    playerParty = []
    $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
    playerPartyStarts.push(playerParty.length)
    ally.party.each { |pkmn| playerParty.push(pkmn) }
    setBattleRule("double") if !$PokemonTemp.battleRules["size"]
  end
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_Battle.new(scene, playerParty, foeParty, playerTrainers, nil)
  battle.party1starts = playerPartyStarts
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  $PokemonTemp.clearBattleRules
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(foeParty), (foeParty.length == 1) ? 0 : 2, foeParty) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision, canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    4 - Wild Pokémon was caught
  #    5 - Draw
  pbSet(outcomeVar, decision)
  return decision
end

def pbWildDoubleBattleSpecific(pokemon1, pokemon2, outcomeVar = 1, canRun = true, canLose = false)
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  setBattleRule("double")
  # Perform the battle
  decision = pbWildBattleCore(pokemon1, pokemon2)
  return (decision != 2 && decision != 5)
end

def pbWildBattleSpecific(pokemon, outcomeVar = 1, canRun = true, canLose = false)
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  # Perform the battle
  decision = pbWildBattleCore(pokemon)
  # Used by the Poké Radar to update/break the chain
  # Events.onWildBattleEnd.trigger(nil,species,level,decision)
  # Return false if the player lost or drew the battle, and true if any other result
  Events.onWildBattleEnd.trigger(nil, pokemon.species, pokemon.level, decision)
  return (decision != 2 && decision != 5)
end

def pb1v2WildBattleSpecific(pokemon1, pokemon2,
                            outcomeVar = 1, canRun = true, canLose = false)
  checkEncounterChallenges([pokemon1, pokemon2])
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose

  if $PokemonGlobal.partner
    setBattleRule("double")
  else
    setBattleRule("1v2")
  end
  # Perform the battle
  decision = pbWildBattleCore(pokemon1, pokemon2)

  Events.onWildBattleEnd.trigger(nil, pokemon1.species, pokemon1.level, decision)
  Events.onWildBattleEnd.trigger(nil, pokemon2.species, pokemon2.level, decision)

  # Return false if the player lost or drew the battle, and true if any other result
  return (decision != 2 && decision != 5)
end

def pb1v3WildBattleSpecific(pokemon1, pokemon2, pokemon3,
                            outcomeVar = 1, canRun = true, canLose = false)
  checkEncounterChallenges([pokemon1, pokemon2, pokemon3])
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose

  if $PokemonGlobal.partner
    setBattleRule("2v3")
  else
    setBattleRule("1v3")
  end
  # Perform the battle
  decision = pbWildBattleCore(pokemon1, pokemon2, pokemon3)

  Events.onWildBattleEnd.trigger(nil, pokemon1.species, pokemon1.level, decision)
  Events.onWildBattleEnd.trigger(nil, pokemon2.species, pokemon2.level, decision)
  Events.onWildBattleEnd.trigger(nil, pokemon3.species, pokemon3.level, decision)

  # Return false if the player lost or drew the battle, and true if any other result
  return (decision != 2 && decision != 5)
end

#===============================================================================
# Standard methods that start a wild battle of various sizes
#===============================================================================
# Used when walking in tall grass, hence the additional code.
def pbWildBattle(species, level, outcomeVar = 1, canRun = true, canLose = false)
  if !species
    displayRandomizerErrorMessage()
    return
  end
  species = GameData::Species.get(species).id
  dexnum = getDexNumberForSpecies(species)
  if $game_switches[SWITCH_RANDOM_WILD] #Randomized wild pokemon
    if $game_switches[SWITCH_RANDOM_STATIC_ENCOUNTERS] && dexnum <= NB_POKEMON
      newSpecies = $PokemonGlobal.psuedoBSTHash[dexnum]
      if !newSpecies
        displayRandomizerErrorMessage()
      else
        species = getSpecies(newSpecies)
      end
    end
  end

  # Potentially call a different pbWildBattle-type method instead (for roaming
  # Pokémon, Safari battles, Bug Contest battles)
  handled = [nil]
  Events.onWildBattleOverride.trigger(nil, species, level, handled)
  return handled[0] if handled[0] != nil
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  # Perform the battle
  decision = pbWildBattleCore(species, level)
  # Used by the Poké Radar to update/break the chain
  Events.onWildBattleEnd.trigger(nil, species, level, decision)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision != 2 && decision != 5)
end

def pbDoubleWildBattle(species1, level1, species2, level2,
                       outcomeVar = 1, canRun = true, canLose = false)
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  setBattleRule("double")
  # Perform the battle
  decision = pbWildBattleCore(species1, level1, species2, level2)

  Events.onWildBattleEnd.trigger(nil, species1, level1, decision)
  Events.onWildBattleEnd.trigger(nil, species2, level2, decision)

  # Return false if the player lost or drew the battle, and true if any other result
  return (decision != 2 && decision != 5)
end

def pbTripleWildBattle(species1, level1, species2, level2, species3, level3,
                       outcomeVar = 1, canRun = true, canLose = false)
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  setBattleRule("triple")
  # Perform the battle
  decision = pbWildBattleCore(species1, level1, species2, level2, species3, level3)

  Events.onWildBattleEnd.trigger(nil, species1, level1, decision)
  Events.onWildBattleEnd.trigger(nil, species2, level2, decision)
  Events.onWildBattleEnd.trigger(nil, species3, level3, decision)

  # Return false if the player lost or drew the battle, and true if any other result
  return (decision != 2 && decision != 5)
end

def pb1v2WildBattle(species1, level1, species2, level2,
                    outcomeVar = 1, canRun = true, canLose = false)
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose

  if $PokemonGlobal.partner
    setBattleRule("double")
  else
    setBattleRule("1v2")
  end
  # Perform the battle
  decision = pbWildBattleCore(species1, level1, species2, level2)

  Events.onWildBattleEnd.trigger(nil, species1, level1, decision)
  Events.onWildBattleEnd.trigger(nil, species2, level2, decision)

  # Return false if the player lost or drew the battle, and true if any other result
  return (decision != 2 && decision != 5)
end

def pb1v3WildBattle(species1, level1, species2, level2, species3, level3,
                    outcomeVar = 1, canRun = true, canLose = false)
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose

  if $PokemonGlobal.partner
    setBattleRule("2v3")
  else
    setBattleRule("1v3")
  end
  # Perform the battle
  decision = pbWildBattleCore(species1, level1, species2, level2, species3, level3)

  Events.onWildBattleEnd.trigger(nil, species1, level1, decision)
  Events.onWildBattleEnd.trigger(nil, species2, level2, decision)
  Events.onWildBattleEnd.trigger(nil, species3, level3, decision)

  # Return false if the player lost or drew the battle, and true if any other result
  return (decision != 2 && decision != 5)
end

#===============================================================================
# Start a trainer battle
#===============================================================================
def pbTrainerBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose = $PokemonTemp.battleRules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.able_pokemon_count == 0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    pbMessage(_INTL("AFTER WINNING...")) if $DEBUG && $Trainer.able_pokemon_count > 0
    pbSet(outcomeVar, ($Trainer.able_pokemon_count == 0) ? 0 : 1) # Treat it as undecided/a win
    $PokemonTemp.battle_npc_used_items = []
    $PokemonTemp.clearBattleRules
    $PokemonGlobal.nextBattleBGM = nil
    $PokemonGlobal.nextBattleME = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack = nil
    $PokemonTemp.forced_alt_sprites = nil
    pbMEStop
    return ($Trainer.able_pokemon_count == 0) ? 0 : 1 # Treat it as undecided/a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate trainers and their parties based on the arguments given
  foeTrainers = []
  foeItems = []
  foeEndSpeeches = []
  foeParty = []
  foePartyStarts = []
  for arg in args
    if arg.is_a?(NPCTrainer)
      foeTrainers.push(arg)
      foePartyStarts.push(foeParty.length)
      arg.party.each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(arg.lose_text)
      foeItems.push(arg.items)
    elsif arg.is_a?(Array) # [trainer type, trainer name, ID, speech (optional)]
      trainer = pbLoadTrainer(arg[0], arg[1], arg[2])
      if !trainer && $game_switches[SWITCH_MODERN_MODE] # retry without modern mode
        $game_switches[SWITCH_MODERN_MODE] = false
        trainer = pbLoadTrainer(arg[0], arg[1], arg[2])
        $game_switches[SWITCH_MODERN_MODE] = true
      end

      pbMissingTrainer(arg[0], arg[1], arg[2]) if !trainer
      return 0 if !trainer

      # infinite fusion edit
      name_override = arg[4]
      type_override = arg[5]
      if type_override != nil
        trainer.trainer_type = type_override
      end
      if name_override != nil
        trainer.name = name_override
      end
      #####
      Events.onTrainerPartyLoad.trigger(nil, trainer)
      foeTrainers.push(trainer)
      foePartyStarts.push(foeParty.length)
      trainer.party.each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(arg[3] || trainer.lose_text)
      foeItems.push(trainer.items)
    else
      raise _INTL("Expected NPCTrainer or array of trainer data, got {1}.", arg)
    end
  end
  # Calculate who the player trainer(s) and their party are
  playerTrainers = [$Trainer]
  playerParty = $Trainer.party
  playerPartyStarts = [0]
  room_for_partner = (foeParty.length > 1)
  if !room_for_partner && $PokemonTemp.battleRules["size"] &&
    !["single", "1v1", "1v2", "1v3"].include?($PokemonTemp.battleRules["size"])
    room_for_partner = true
  end
  if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && room_for_partner
    ally = NPCTrainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
    ally.id = $PokemonGlobal.partner[2]
    ally.party = $PokemonGlobal.partner[3]
    playerTrainers.push(ally)
    playerParty = []
    $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
    playerPartyStarts.push(playerParty.length)
    ally.party.each { |pkmn| playerParty.push(pkmn) }
    setBattleRule("double") if !$PokemonTemp.battleRules["size"]
  end
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_Battle.new(scene, playerParty, foeParty, playerTrainers, foeTrainers)
  battle.party1starts = playerPartyStarts
  battle.party2starts = foePartyStarts
  battle.items = foeItems
  battle.endSpeeches = foeEndSpeeches
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  $PokemonTemp.clearBattleRules
  # End the trainer intro music
  Audio.me_stop
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetTrainerBattleBGM(foeTrainers), (battle.singleBattle?) ? 1 : 3, foeTrainers) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision, canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    5 - Draw
  pbSet(outcomeVar, decision)
  return decision
end

def convert_pokemon_to_pokemon_hash(pokemon)
  pokemon_hash = Hash.new
  pokemon_hash[:species] = pokemon.species
  pokemon_hash[:level] = pokemon.level
  return pokemon_hash
end

# party: array of pokemon team
# [[:SPECIES,level], ... ]
#
def customTrainerBattle(trainerName, trainerType, party_array, default_level = 50, endSpeech = "", sprite_override = nil, custom_appearance = nil, items = [], canLose = false)
  trainer = NPCTrainer.new(trainerName, trainerType, sprite_override, custom_appearance)
  trainer.lose_text = endSpeech
  trainer.items = items
  party = []
  party_array.each { |pokemon|
    if pokemon.is_a?(Pokemon)
      party << pokemon
    elsif pokemon.is_a?(Symbol)
      party << Pokemon.new(pokemon, default_level, trainer)
    end
  }
  trainer.party = party
  Events.onTrainerPartyLoad.trigger(nil, trainer)

  $PokemonTemp.battleRules["canLose"] = canLose
  decision = pbTrainerBattleCore(trainer)
  # Return true if the player won the battle, and false if any other result
  return (decision == 1)
end

# trainer: array [trainer_name,trainer_type,party_array]
def rematchable_trainer_battle(rematchable_trainers = [], default_level = 50, canLose = true)
  battle_trainers = []
  rematchable_trainers.each do |trainer|
    trainer_data = GameData::Trainer.try_get(trainer.trainerType, trainer.trainerName, 0)
    party = []
    trainer.currentTeam.each { |pokemon|
      break if party.length >= 6
      if pokemon.is_a?(Pokemon)
        pokemon.heal
        party << pokemon
      elsif pokemon.is_a?(Symbol)
        party << Pokemon.new(pokemon, default_level, trainer)
      end
    }
    loseDialog = trainer_data ? trainer_data.rematch_lose_text : "..."

    npc_trainer = NPCTrainer.new(trainer.trainerName, trainer.trainerType, nil, trainer.custom_appearance)
    npc_trainer.lose_text = loseDialog
    npc_trainer.items = trainer.list_battle_items
    npc_trainer.party = party
    Events.onTrainerPartyLoad.trigger(nil, npc_trainer)
    battle_trainers << npc_trainer
  end
  $PokemonTemp.setBattleRule("double") if battle_trainers.length > 1
  $PokemonTemp.battleRules["canLose"] = canLose
  $PokemonTemp.battleRules["moneyGain"] = false
  decision = pbTrainerBattleCore(*battle_trainers)
  return (decision == 1)
end

# def generateTrainerRematch(trainer, allow_double=true)
#   trainer_data = GameData::Trainer.try_get(trainer.trainerType, trainer.trainerName, 0)
#
#   loseDialog = trainer_data&.loseText_rematch ? trainer_data.loseText_rematch :  "..."
#   player_won = false
#   if trainer.getLinkedTrainer && allow_double #perma-double battles (twins, etc.)
#     pbMultiTrainerBattle([])
#   end
#   if customTrainerBattle(trainer.trainerName,trainer.trainerType, trainer.currentTeam,nil,loseDialog)
#     updated_trainer = makeRebattledTrainerTeamGainExp(trainer,true)
#     updated_trainer = healRebattledTrainerPokemon(updated_trainer)
#     player_won=true
#   else
#     updated_trainer =makeRebattledTrainerTeamGainExp(trainer,false)
#   end
#   updated_trainer.set_pending_action(false)
#   updated_trainer = evolveRebattledTrainerPokemon(updated_trainer)
#   trainer.increase_friendship(5)
#   return updated_trainer, player_won
# end

#Event_id and map_id when the trainer's event with the graphics is a different one from the one that's starting the battle
def pbMoveTutorBattle(trainerID, trainerName, moves, scaleLevel=true, event_id=nil, map_id=nil)
  if moves && moves.is_a?(Array)
    favored_moves = moves
  else
    favored_moves = [moves]
  end

  if scaleLevel
    $game_switches[Settings::OVERRIDE_BATTLE_LEVEL_SWITCH] = true
    $game_switches[SWITCH_DONT_RANDOMIZE] = true
  end

  pbSet(Settings::OVERRIDE_BATTLE_LEVEL_VALUE_VAR, $Trainer.highest_level_pokemon_in_party)

  $PokemonTemp.recordBattleRule("favoredMoves", favored_moves) if favored_moves
  res = pbTrainerBattle(trainerID, trainerName, nil, false, 0, false, 1, nil, nil, event_id, map_id)

  $game_switches[Settings::OVERRIDE_BATTLE_LEVEL_SWITCH] = false
  $game_switches[SWITCH_DONT_RANDOMIZE] = false
  return res
end

def scaledLevelBattle(trainerId,trainerName,event_id=nil, map_id=nil)
  $game_switches[Settings::OVERRIDE_BATTLE_LEVEL_SWITCH] = true
  pbSet(Settings::OVERRIDE_BATTLE_LEVEL_VALUE_VAR, $Trainer.highest_level_pokemon_in_party)
  res = pbTrainerBattle(trainerId, trainerName, nil, false, 0, false, 1, nil, nil, event_id, map_id)
  $game_switches[Settings::OVERRIDE_BATTLE_LEVEL_SWITCH] = false
  $game_switches[SWITCH_DONT_RANDOMIZE] = false
  return res
end

# def pbTrainerBattle(trainerID, trainerName,endSpeech=nil,
#                     doubleBattle=false, trainerPartyID=0,
#                     canLose=false, outcomeVar=1,
#                     name_override = nil, trainer_type_overide = nil,
#                     event_id = nil, map_id = nil)

#===============================================================================
# Standard methods that start a trainer battle of various sizes
#===============================================================================
# Used by most trainer events, which can be positioned in such a way that
# multiple trainer events spot the player at once. The extra code in this method
# deals with that case and can cause a double trainer battle instead.
def pbTrainerBattle(trainerID, trainerName, endSpeech = nil,
                    doubleBattle = false, trainerPartyID = 0, canLose = false, outcomeVar = 1,
                    name_override = nil, trainer_type_overide = nil,
                    event_id = nil, map_id = nil)

  # level override applies to every pokemon

  # If there is another NPC trainer who spotted the player at the same time, and
  # it is possible to have a double battle (the player has 2+ able Pokémon or
  # has a partner trainer), then record this first NPC trainer into
  # $PokemonTemp.waitingTrainer and end this method. That second NPC event will
  # then trigger and cause the battle to happen against this first trainer and
  # themselves.
  if !$PokemonTemp.waitingTrainer && pbMapInterpreterRunning? &&
    ($Trainer.able_pokemon_count > 1 ||
      ($Trainer.able_pokemon_count > 0 && $PokemonGlobal.partner))
    thisEvent = pbMapInterpreter.get_character(0)
    # Find all other triggered trainer events
    triggeredEvents = $game_player.pbTriggeredTrainerEvents([2], false)
    otherEvent = []
    for i in triggeredEvents
      next if i.id == thisEvent.id
      next if $game_self_switches[[$game_map.map_id, i.id, "A"]]
      otherEvent.push(i)
    end
    # Load the trainer's data, and call an event w0hich might modify it
    trainer = pbLoadTrainer(trainerID, trainerName, trainerPartyID)
    if !trainer && $game_switches[SWITCH_MODERN_MODE] # retry without modern mode
      $game_switches[SWITCH_MODERN_MODE] = false
      trainer = pbLoadTrainer(trainerID, trainerName, trainerPartyID)
      $game_switches[SWITCH_MODERN_MODE] = true
    end
    pbMissingTrainer(trainerID, trainerName, trainerPartyID) if !trainer
    return false if !trainer
    Events.onTrainerPartyLoad.trigger(nil, trainer)
    # If there is exactly 1 other triggered trainer event, and this trainer has
    # 6 or fewer Pokémon, record this trainer for a double battle caused by the
    # other triggered trainer event
    if otherEvent.length == 1 && trainer.party.length <= Settings::MAX_PARTY_SIZE
      trainer.lose_text = endSpeech if endSpeech && !endSpeech.empty?
      $PokemonTemp.waitingTrainer = [trainer, thisEvent.id, trainerID, trainerName]
      return false
    end
  end
  if $PokemonTemp.waitingTrainer
    waiting_type = $PokemonTemp.waitingTrainer[2]
    waiting_name = $PokemonTemp.waitingTrainer[3]
    if waiting_type == trainerID && waiting_name == trainerName
      $PokemonTemp.waitingTrainer = nil
    end
  end

  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("canLose") if canLose
  setBattleRule("double") if doubleBattle || $PokemonTemp.waitingTrainer
  # Perform the battle
  if $PokemonTemp.waitingTrainer
    decision = pbTrainerBattleCore($PokemonTemp.waitingTrainer[0],
                                   [trainerID, trainerName, trainerPartyID, endSpeech]
    )
  else
    decision = pbTrainerBattleCore([trainerID, trainerName, trainerPartyID, endSpeech, name_override, trainer_type_overide])
  end
  # Finish off the recorded waiting trainer, because they have now been battled
  if decision == 1 && $PokemonTemp.waitingTrainer # Win
    pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1], "A", true)
    $Trainer.stats&.incr_nb_battles_won
  end
  $PokemonTemp.waitingTrainer = nil
  # Return true if the player won the battle, and false if any other result
  return (decision == 1)
end

def pbDoubleTrainerBattle(trainerID1, trainerName1, trainerPartyID1, endSpeech1,
                          trainerID2, trainerName2, trainerPartyID2 = 0, endSpeech2 = nil,
                          canLose = false, outcomeVar = 1)
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("canLose") if canLose
  setBattleRule("double")
  # Perform the battle
  decision = pbTrainerBattleCore(
    [trainerID1, trainerName1, trainerPartyID1, endSpeech1],
    [trainerID2, trainerName2, trainerPartyID2, endSpeech2]
  )
  # Return true if the player won the battle, and false if any other result
  return (decision == 1)
end

def pbTripleTrainerBattle(trainerID1, trainerName1, trainerPartyID1, endSpeech1,
                          trainerID2, trainerName2, trainerPartyID2, endSpeech2,
                          trainerID3, trainerName3, trainerPartyID3 = 0, endSpeech3 = nil,
                          canLose = false, outcomeVar = 1)
  # Set some battle rules
  setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
  setBattleRule("canLose") if canLose
  setBattleRule("triple")
  # Perform the battle
  decision = pbTrainerBattleCore(
    [trainerID1, trainerName1, trainerPartyID1, endSpeech1],
    [trainerID2, trainerName2, trainerPartyID2, endSpeech2],
    [trainerID3, trainerName3, trainerPartyID3, endSpeech3]
  )
  # Return true if the player won the battle, and false if any other result
  return (decision == 1)
end

#===============================================================================
# After battles
#===============================================================================
def pbAfterBattle(decision, canLose)
  $Trainer.party.each do |pkmn|
    pkmn.statusCount = 0 if pkmn.status == :POISON # Bad poison becomes regular
    pkmn.makeUnmega
    pkmn.makeUnprimal
  end
  if $PokemonGlobal.partner
    $Trainer.heal_party
    $PokemonGlobal.partner[3].each do |pkmn|
      pkmn.heal
      pkmn.makeUnmega
      pkmn.makeUnprimal
    end
  end
  if decision == 2 || decision == 5 # if loss or draw
    if canLose
      $Trainer.party.each { |pkmn| pkmn.heal }
      (Graphics.frame_rate / 4).times { Graphics.update }
    end
  end
  Events.onEndBattle.trigger(nil, decision, canLose)
  $game_player.straighten
  $PokemonTemp.pokemon_is_weather_encounter = false
end

Events.onEndBattle += proc { |_sender, e|
  decision = e[0]
  canLose = e[1]
  if Settings::CHECK_EVOLUTION_AFTER_ALL_BATTLES || (decision != 2 && decision != 5) # not a loss or a draw
    if $PokemonTemp.evolutionLevels
      pbEvolutionCheck($PokemonTemp.evolutionLevels)
      $PokemonTemp.evolutionLevels = nil
    end
  end
  case decision
  when 1, 4 # Win, capture
    $Trainer.pokemon_party.each do |pkmn|
      pbPickup(pkmn)
      pbHoneyGather(pkmn)
    end
    pickUpTypeItemSetBonus()
    nurseOutfitHeal()
    qmarkMaskCheck()
  when 2, 5 # Lose, draw
    if !canLose
      $game_system.bgm_unpause
      $game_system.bgs_unpause
      pbStartOver
    end
  end
}

Events.onWildBattleEnd += proc { |_sender, e|
  species = e[0]
  result = e[2]
  if result == 1
    check_obtain_hat_after_battle(species)
  end
}

def pbEvolutionCheck(currentLevels, scene = nil)
  for i in 0...currentLevels.length
    pkmn = $Trainer.party[i]
    next if !pkmn || (pkmn.hp == 0 && !Settings::CHECK_EVOLUTION_FOR_FAINTED_POKEMON)
    next if currentLevels[i] && pkmn.level == currentLevels[i]
    next if pkmn.evolve_from_party
    newSpecies = pkmn.check_evolution_on_level_up()
    next if !newSpecies

    evo = PokemonEvolutionScene.new
    evo.pbStartScreen(pkmn, newSpecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
end

def pbDynamicItemList(*args)
  ret = []
  for i in 0...args.length
    ret.push(args[i]) if GameData::Item.exists?(args[i])
  end
  return ret
end

# Try to gain an item after a battle if a Pokemon has the ability Pickup.
def pbPickup(pkmn)
  return if pkmn.egg? || !pkmn.hasAbility?(:PICKUP)
  return if pkmn.hasItem?
  return unless rand(100) < 10 # 10% chance
  # Common items to find (9 items from this list are added to the pool)
  pickupList = pbDynamicItemList(
    :POTION,
    :ANTIDOTE,
    :SUPERPOTION,
    :GREATBALL,
    :REPEL,
    :ESCAPEROPE,
    :DNASPLICERS,
    :DNAREVERSER,
    :FUSIONREPEL,
    :FUSIONBALL,
    :FULLHEAL,
    :HYPERPOTION,
    :ULTRABALL,
    :REVIVE,
    :RARECANDY,
    :SUNSTONE,
    :MOONSTONE,
    :HEARTSCALE,
    :FULLRESTORE,
    :MAXREVIVE,
    :PPUP,
    :MAXELIXIR
  )
  # Rare items to find (2 items from this list are added to the pool)
  pickupListRare = pbDynamicItemList(
    :HYPERPOTION,
    :NUGGET,
    :KINGSROCK,
    :FULLRESTORE,
    :ETHER,
    :IRONBALL,
    :DESTINYKNOT,
    :ELIXIR,
    :DESTINYKNOT,
    :LEFTOVERS,
    :DESTINYKNOT
  )
  return if pickupList.length < 18
  return if pickupListRare.length < 11
  # Generate a pool of items depending on the Pokémon's level
  items = []
  pkmnLevel = [100, pkmn.level].min
  itemStartIndex = (pkmnLevel - 1) / 10
  itemStartIndex = 0 if itemStartIndex < 0
  for i in 0...9
    items.push(pickupList[itemStartIndex + i])
  end
  for i in 0...2
    items.push(pickupListRare[itemStartIndex + i])
  end
  # Probabilities of choosing each item in turn from the pool
  chances = [30, 10, 10, 10, 10, 10, 10, 4, 4, 1, 1] # Needs to be 11 numbers
  chanceSum = 0
  chances.each { |c| chanceSum += c }
  # Randomly choose an item from the pool to give to the Pokémon
  rnd = rand(chanceSum)
  cumul = 0
  chances.each_with_index do |c, i|
    cumul += c
    next if rnd >= cumul
    pkmn.item = items[i]
    break
  end
end

# Try to gain a Honey item after a battle if a Pokemon has the ability Honey Gather.
def pbHoneyGather(pkmn)
  return if !GameData::Item.exists?(:HONEY)
  return if pkmn.egg? || !pkmn.hasAbility?(:HONEYGATHER) || pkmn.hasItem?
  chance = 5 + ((pkmn.level - 1) / 10) * 5
  return unless rand(100) < chance
  pkmn.item = :HONEY
end
