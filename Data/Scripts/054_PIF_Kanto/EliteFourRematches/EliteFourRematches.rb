# The idea is for each Elite 4 members to have a pool of 12 or so Pokémon (20 for Blue, but he always has his starter) to choose from and each time you rematch them, they pick 6 out
#   of them to give some variety and unpredictabilty o the fights


# todo: Make it work with randomizer and modern mode
# todo: Add reserve Pokemon! Maybe two extra per tier for each e4. Maybe 4 for Blue

#  todo maybe: Analyse the player's team and pick a team that counters it


# Rematch tiers:
# :1 : Unlocked after beating the league the first time (Level range same as first run (50-60) )
# :2 : Unlocked after beating Elite 4 rematch tier 1 (Level range 60-70)
# :3 : Unlocked after beating Mt. Silver  and beating Elite 4 rematch tier 2 (Level range 70-80 )
#  4: Unlocked after completing all the Gym Leader rematches and beating Elite 4 rematch tier 3 (Level range 80-90)
#  5: Unlocked after beating rematch tier 4 (Everything level 100)
def eliteFourRematch(trainer_id, trainer_name, rematch_tier,end_dialog="")
  base_line_level = 50
  base_line_level = 60 if rematch_tier == 2
  base_line_level = 70 if rematch_tier == 3
  base_line_level = 80 if rematch_tier == 4
  base_line_level = 100 if rematch_tier == 5

  available_pokemon = E4_POKEMON_POOL[trainer_id]
  nb_pokemon = rematch_tier >= 3 ? 6 : 5
  nb_pokemon = 5 if trainer_id == :CHAMPION # Rival always has his starter

  selected_pokemon = select_e4_pokemon(available_pokemon, rematch_tier, nb_pokemon)
  party = build_e4_trainer_party(selected_pokemon, base_line_level)
  party << get_rival_starter(base_line_level) if trainer_id == :CHAMPION

  items = [:FULLRESTORE, :FULLRESTORE]
  items.concat([:FULLRESTORE, :FULLRESTORE]) if rematch_tier >= 2
  items.concat([:FULLRESTORE, :FULLRESTORE]) if rematch_tier >= 4
  return customTrainerBattle(trainer_name,trainer_id,party,50,end_dialog,nil,nil,items)
end


def get_rival_starter(base_line_level)
  species = pbGet(VAR_RIVAL_STARTER)
  level = base_line_level +12
  level = 100 if level > 100
  pokemon = Pokemon.new(species,level)
  pokemon.item = :LEFTOVERS
  return pokemon
end

def build_e4_trainer_party(selected_pokemon,base_line_level)
  party = []
  selected_pokemon.each do |pokemon_data|
      party << build_e4_pokemon(pokemon_data,base_line_level)
    end
  return party
end

def build_e4_pokemon(pokemon_data,base_line_level)
  level = pokemon_data[:level] + base_line_level
  level = 100 if level > 100
  species_data = pokemon_data[:species]
  if species_data.is_a?(Array)
    species = fusionOf(species_data[0],species_data[1])
  else
    species = species_data
  end
  pokemon = Pokemon.new(species, level)
  pokemon.ability = pokemon_data[:ability] if pokemon_data[:ability]
  pokemon.item = pokemon_data[:item] if pokemon_data[:item]
  pokemon.nature = pokemon_data[:nature] if pokemon_data[:nature]
  moves = []
  if pokemon_data[:moves]
    pokemon_data[:moves].each do |move_id|
      moves << Pokemon::Move.new(move_id)
    end
  end
  pokemon.moves = moves
  return pokemon
end

# Todo: smart select depending on the player's team
def select_e4_pokemon(all_available_pokemon,tier, number_to_select)
  available_pokemon = []
  all_available_pokemon.each do |pokemon_data|
    available_pokemon << pokemon_data if pokemon_data[:tier] <= tier
  end
  return available_pokemon.sample(number_to_select)
end

def league_rematch_tiers_supported
  game_mode = getCurrentGameModeSymbol
  return true if game_mode == :CLASSIC || game_mode == :DEBUG
  if game_mode == :RANDOMIZED
    return true unless $game_switches[SWITCH_RANDOM_TRAINERS] || $game_switches[SWITCH_RANDOMIZED_GYM_TYPES]
  end

  return false
end



def list_unlocked_league_tiers
  unlocked_tiers =[]
  unlocked_tiers << 1 if $game_switches[SWITCH_LEAGUE_TIER_1]
  unlocked_tiers << 2 if $game_switches[SWITCH_LEAGUE_TIER_2]
  unlocked_tiers << 3 if $game_switches[SWITCH_LEAGUE_TIER_3]
  unlocked_tiers << 4 if $game_switches[SWITCH_LEAGUE_TIER_4]
  unlocked_tiers << 5 if $game_switches[SWITCH_LEAGUE_TIER_5]
  return unlocked_tiers
end
def select_league_tier
  return 0 unless league_rematch_tiers_supported
  #validateE4Data
  available_tiers = list_unlocked_league_tiers
  return 0 if available_tiers.empty?
  #return available_tiers[0] if available_tiers.length == 1

  available_tiers.reverse!
  commands = []
  available_tiers.each do |tier_nb|
    commands << _INTL("Rank {1}",tier_nb)
  end
  cmd_cancel = _INTL("Cancel")
  commands << cmd_cancel
  choice = pbMessage(_INTL("Which League Rematch difficulty tier will you choose?"),commands)
  if commands[choice] == cmd_cancel
    return -1
  end
  return available_tiers[choice]
end

#called when the player just beat the league
def unlock_new_league_tiers
  return unless league_rematch_tiers_supported

  current_tier = pbGet(VAR_LEAGUE_REMATCH_TIER)
  currently_unlocked_tiers = list_unlocked_league_tiers
  tiers_to_unlock = []
  tiers_to_unlock << 1 if current_tier == 0
  tiers_to_unlock << 2 if current_tier == 1
  tiers_to_unlock << 3 if current_tier == 2 && $game_switches[SWITCH_BEAT_MT_SILVER]
  tiers_to_unlock << 4 if current_tier == 3 && $game_variables[VAR_NB_GYM_REMATCHES] >= 16
  tiers_to_unlock << 5 if current_tier == 4
  tiers_to_unlock.each do |tier|
    next if tier == 0
    $game_switches[SWITCH_LEAGUE_TIER_1] = true if tiers_to_unlock.include?(1)
    $game_switches[SWITCH_LEAGUE_TIER_2] = true if tiers_to_unlock.include?(2)
    $game_switches[SWITCH_LEAGUE_TIER_3] = true if tiers_to_unlock.include?(3)
    $game_switches[SWITCH_LEAGUE_TIER_4] = true if tiers_to_unlock.include?(4)
    $game_switches[SWITCH_LEAGUE_TIER_5] = true if tiers_to_unlock.include?(5)
    unless currently_unlocked_tiers.include?(tier)
      pbMEPlay("Key item get")
      pbMessage(_INTL("{1} unlocked \\C[1]Rank {2} League Rematches\\C[0]!",$Trainer.name,tier))
    end
  end
end


def validateE4Data
  E4_POKEMON_POOL.keys.each do |key|
    available_pokemon = E4_POKEMON_POOL[key]
    available_pokemon.each do |pokemon_data|
      build_e4_pokemon(pokemon_data,0)
      echoln "#{pokemon_data[:species]} is valid"
    end
  end
end
