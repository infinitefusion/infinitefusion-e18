# Higher values: pickier
TRAINER_CLASS_PICKINESS = {
  # TIER 1: Masters (2.4-3.0)
  CHAMPION_Steven: 3.0,
  ELITEFOUR_Drake: 2.8,
  ELITEFOUR_Glacia: 2.8,
  ELITEFOUR_Phoebe: 2.8,
  ELITEFOUR_Sidney: 2.8,
  TEAM_AQUA_BOSS: 2.8,
  TEAM_MAGMA_BOSS: 2.8,
  LEADER_Wallace: 2.7,
  LEADER_Juan: 2.7,
  LEADER_Roxanne: 2.6,
  LEADER_Brawly: 2.6,
  LEADER_Wattson: 2.6,
  LEADER_Flannery: 2.6,
  LEADER_Norman: 2.6,
  LEADER_Winona: 2.6,
  LEADER_Tate: 2.6,
  LEADER_Liza: 2.6,
  PROFESSOR: 2.5,
  EXPERT_M: 2.5,
  EXPERT_F: 2.5,

  # TIER 2: Professionals & wealthy (1.9 - 2.3)
  COOLTRAINER_M: 2.3,
  COOLTRAINER_F: 2.3,
  COOLTRAINER_M2: 2.3,
  COOLTRAINER_F2: 2.3,
  DRAGONTAMER: 2.3,
  LADY: 2.4,
  GENTLEMAN: 2.3,
  SOCIALITE: 2.3,
  RICHBOY: 2.3,
  COLLECTOR: 2.3,
  BEAUTY: 2.2,
  KIMONOGIRL: 2.2,
  SAGE: 2.1,
  COOLCOUPLE: 2.1,
  ENGINEER: 2.0,
  PAINTER: 2.0,
  SCIENTIST: 2.0,
  POKEMONRANGER_M: 2.0,
  POKEMONRANGER_F: 2.0,
  PSYCHIC_M: 2.0,
  PSYCHIC_F: 2.0,
  TEACHER: 2.0,
  NURSE: 2.0,
  POKEMONBREEDER_F: 1.9,
  POKEMONBREEDER_M: 1.9,
  SUPERNERD: 1.9,

  # TIER 3: Hobbyists (1.5 - 1.8)
  AROMALADY: 1.8,
  JUGGLER: 1.8,
  POLICE: 1.8,
  PARASOLLADY: 1.8,
  SECRETBASEEXPERT: 1.8,
  CHANNELER: 1.7,
  BLACKBELT: 1.7,
  HAUNTEDGIRL: 1.7,
  CRUSHKIN: 1.7,
  POKEMANIAC: 1.6,
  BUGMANIAC: 1.6,
  POKEFAN_M: 1.6,
  POKEFAN_F: 1.6,
  CRUSHGIRL: 1.6,
  YOUNGCOUPLE: 1.6,
  YOUNGCOUPLE_M: 1.6,
  YOUNGCOUPLE_F: 1.6,
  WORKER: 1.6,
  PYROMANIAC: 1.6,
  SKIER_F: 1.6,
  GAMBLER: 1.5,
  HIKER: 1.5,
  RUINMANIAC: 1.5,
  TAMER: 1.5,
  CLOWN: 1.5,
  FARMER: 1.5,
  REPORTER: 1.5,
  CAMERAMAN: 1.5,
  TRIATHLETE_BIKE_M: 1.5,
  TRIATHLETE_BIKE_F: 1.5,
  TRIATHLETE_SWIM_M: 1.5,
  TRIATHLETE_SWIM_F: 1.5,
  TRIATHLETE_RUN_M: 1.5,
  TRIATHLETE_RUN_F: 1.5,

  # TIER 4: Average joes (1.1 - 1.4)
  BIRDKEEPER: 1.4,
  FISHERMAN: 1.4,
  ROCKER: 1.4,
  ROUGHNECK: 1.4,
  SCHOOLMATE_SR: 1.4,
  BURGLAR: 1.3,
  CUEBALL: 1.3,
  SAILOR: 1.3,
  SISANDBRO: 1.3,
  DELIVERYMAN: 1.3,
  HAUNTEDGIRL_YOUNG: 1.3,
  SURFER: 1.3,
  DIVER_M: 1.3,
  DIVER_F: 1.3,
  SWIMMER_M: 1.3,
  SWIMMER_F: 1.3,
  SWIMMER2_M: 1.3,
  SWIMMER2_F: 1.3,
  BIKER: 1.2,
  CAMPER: 1.2,
  PICNICKER: 1.2,
  STREETTHUG: 1.2,
  DELINQUENT: 1.2,
  SCHOOLBOY: 1.2,
  SCHOOLGIRL: 1.2,
  NINJABOY: 1.2,
  BUGCATCHER: 1.1,
  BUGCATCHER_F: 1.1,
  SCHOOLMATE_JR: 1.1,

  # TIER 5: Novices & children
  LASS: 1.0,
  PLAYER: 1.0,
  TWINS: 1.0,
  TWIN_1: 1.0,
  TWIN_2: 1.0,
  YOUNGSTER: 0.9,
  TUBER_M: 0.8,
  TUBER_F: 0.8,
  TUBER2_M: 0.8,
  TUBER2_F: 0.8,
  PRESCHOOLER_M: 0.6,
  PRESCHOOLER_F: 0.6
}

def evaluate_pokemon_worth(pkmn, compare_level: nil, favorite_type: nil)
  species_data = pkmn.species_data
  return 0 unless species_data
  level = pkmn.level
  level_diff = compare_level ? (level - compare_level) : 0
  level_score = level * 2 + [level_diff, 0].max * 1.5 # bonus if player's level is higher

  base_stats_score = species_data.base_stats.values.sum / 10.0
  rarity_score = (255 - species_data.catch_rate) / 5.0
  iv_score = (pkmn.iv&.values&.sum || 0) / 4.0
  shiny_score = pkmn.shiny? ? 50 : 0
  fusion_bonus = pkmn.isFusion? ? 40 : 0

  type_exists = GameData::Type.exists?(favorite_type) || nil
  type_bonus = (type_exists && pkmn.hasType?(favorite_type)) ? 30 : 0

  score = level_score +
    base_stats_score +
    rarity_score +
    iv_score +
    shiny_score +
    fusion_bonus +
    type_bonus

  echoln("#{pkmn.name} - Score : #{score}")
  return score
end

def offerPokemonForTrade(player_pokemon, npc_party, trainer_class, favorite_type)
  player_score = evaluate_pokemon_worth(player_pokemon, favorite_type: favorite_type)
  pickiness = TRAINER_CLASS_PICKINESS[trainer_class] || 1.0

  # Evaluate all NPC Pokémon scores
  npc_scores = npc_party.map do |npc_pkmn|
    [npc_pkmn, evaluate_pokemon_worth(npc_pkmn, compare_level: player_pokemon.level, favorite_type: favorite_type)]
  end
  best_npc_pokemon, best_score = npc_scores.max_by { |_, score| score }
  return best_npc_pokemon if player_score > best_score

  max_difference = [player_score, 100].min * pickiness
  candidates = npc_scores.select do |npc_pkmn, npc_score|
    (npc_score - player_score).abs <= max_difference
  end

  return nil if candidates.empty?
  candidates.min_by do |_, npc_score|
    (npc_score - player_score).abs
  end.first
end

def doNPCTrainerTrade(trainer)
  echoln "Time since last trade: #{trainer.getTimeSinceLastTrade}"
  unless trainer.isNextTradeReady?
    pbMessage(_INTL("The trainer is not ready to trade yet. Wait a little bit before you make your offer."))
    return trainer
  end
  return generateTrainerTradeOffer(trainer)
end

# prefered type depends on the trainer class
#
def generateTrainerTradeOffer(trainer)
  wanted_types = BattledTrainer::TRAINER_CLASS_FAVORITE_TYPES[trainer.trainerType]
  wanted_types = [:NORMAL] if !wanted_types || wanted_types.empty?
  if wanted_types.include?(:ANY)
    pbChoosePokemon(1, 2)
  else
    wanted_types_string = wanted_types.map { |type|
      type_name = GameData::Type.get(type).name
      "\\C[1]#{type_name}\\C[0]"
    }.join(", ")

    trainerClassName = GameData::TrainerType.get(trainer.trainerType).name
    trainerName = pbGetMessageFromHash(MessageTypes::TrainerNames, trainer.trainerName)
    pbMessage(_INTL("{1} {2} is looking for Pokémon of the following type(s):\\n{3}\\nWhich Pokémon do you want to trade?",
                    trainerClassName, trainerName, wanted_types_string))
    pbChoosePokemon(1, 2,
                    proc { |pokemon|
                      pokemon.hasOneOfTheseTypes?(wanted_types) &&
                      !pokemon.egg?
                    })
  end
  chosen_index = pbGet(1)
  if chosen_index && chosen_index >= 0
    chosen_pokemon = $Trainer.party[chosen_index]
    offered_pokemon = offerPokemonForTrade(chosen_pokemon, trainer.currentTeam, trainer.trainerType, trainer.favorite_type)
    if !offered_pokemon
      pbMessage(_INTL("{1} {2} does not want to trade...", trainerClassName, trainerName))
      return trainer
    end

    pif_sprite = BattleSpriteLoader.new.get_pif_sprite_from_species(offered_pokemon.species)
    message = _INTL("{1} {2} is offering {3} (Level {4}) for your {5}.", trainerClassName, trainerName, offered_pokemon.name, offered_pokemon.level, chosen_pokemon.name)
    showPokemonInPokeballWithMessage(pif_sprite, message)

    if pbConfirmMessage(_INTL("Trade away {1} for {2} {3}'s {4}?", chosen_pokemon.name, trainerClassName, trainerName, offered_pokemon.name))
      pbStartTrade(chosen_index, offered_pokemon, offered_pokemon.name, trainer.trainerName, 0)
      updated_party = trainer.currentTeam
      trainer.increase_friendship(10) if  GameData::Type.exists?(trainer.favorite_type) && offered_pokemon.hasType?(trainer.favorite_type)
      updated_party.delete(offered_pokemon)
      updated_party << chosen_pokemon.clone

      trainer.previous_trade_timestamp = Time.now
      trainer.increase_friendship(20)
      trainer.process_party_pokemon_held_items
      return trainer
    end
  end
  return trainer
  trainer.set_pending_action(false) if trainer
  return trainer
end
