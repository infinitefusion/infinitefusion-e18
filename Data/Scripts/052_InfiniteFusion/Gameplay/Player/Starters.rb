def obtainStarter(starterIndex = 0)
  if ($game_switches[SWITCH_LEGENDARY_MODE])
    generated_list = pbGet(VAR_LEGENDARY_STARTERS_CHOICES)
    if generated_list.is_a?(Array)
      startersList = generated_list
    else
      startersList = generate_legendary_mode_starters
      pbSet(VAR_LEGENDARY_STARTERS_CHOICES,startersList)
    end
    starter = startersList[starterIndex]
  elsif ($game_switches[SWITCH_RANDOM_STARTERS])
    starter = obtainRandomizedStarter(starterIndex)
  else
    startersList = Settings::DEFAULT_STARTERS
    if $game_switches[SWITCH_JOHTO_STARTERS]
      startersList = Settings::JOHTO_STARTERS
    elsif $game_switches[SWITCH_KANTO_STARTERS]
      startersList = Settings::KANTO_STARTERS
    elsif $game_switches[SWITCH_HOENN_STARTERS]
      startersList = Settings::HOENN_STARTERS
    elsif $game_switches[SWITCH_SINNOH_STARTERS]
      startersList = Settings::SINNOH_STARTERS
    elsif $game_switches[SWITCH_KALOS_STARTERS]
      startersList = Settings::KALOS_STARTERS
    elsif $game_switches[SWITCH_MIXED_STARTERS]
      if $game_temp.starter_options
        startersList = $game_temp.starter_options
      else
        $game_temp.starter_options = generate_mixed_starters_list
        startersList = $game_temp.starter_options
      end
    end
    starter = startersList[starterIndex]
  end
  return GameData::Species.get(starter)
end

def generate_mixed_starters_list
  grass_option = Settings::GRASS_STARTERS.sample
  fire_option = Settings::FIRE_STARTERS.sample
  water_option = Settings::WATER_STARTERS.sample
  return [grass_option, fire_option, water_option]
end

# body0
# head 1
def setRivalStarter(starterIndex1, starterIndex2)
  starter1 = obtainStarter(starterIndex1)
  starter2 = obtainStarter(starterIndex2)

  ensureRandomHashInitialized()
  if $game_switches[SWITCH_RANDOM_WILD_TO_FUSION] || $game_switches[SWITCH_LEGENDARY_MODE] # if fused starters, only take index 1
    starter = obtainStarter(starterIndex1)
  else
    starter_body = starter1.id_number
    starter_head = starter2.id_number
    starter = getFusionSpecies(starter_body, starter_head).id_number
  end
  if $game_switches[SWITCH_RANDOM_STARTER_FIRST_STAGE]
    starterSpecies = GameData::Species.get(starter)
    starter = GameData::Species.get(starterSpecies.get_baby_species(false)).id_number
  end
  pbSet(VAR_RIVAL_STARTER, starter)
  $game_switches[SWITCH_DEFINED_RIVAL_STARTER] = true
  return starter
end

def setStarterEasterEgg
  should_apply_easter_egg = true
  case $Trainer.name.downcase
  when "ash"
    starter = :PIKACHU
    rival_starter_body = :EEVEE
    rival_starter_head = :EEVEE
  when "gary"
    starter = :EEVEE
    rival_starter_body = :PIKACHU
    rival_starter_head = :PIKACHU
  when "god"
    starter = :BIDOOF
    rival_starter_body = :ARCEUS
    rival_starter_head = :OMANYTE
  when "?"
    starter = getSpecies(rand(NB_POKEMON))
    rival_starter_body = getSpecies(rand(NB_POKEMON))
    rival_starter_head = getSpecies(rand(NB_POKEMON))
  when "schrroms", "frogman", "frogzilla", "chardub"
        starter = fusionOf(:POLIWAG,:MACHAMP)
        rival_starter_body = :POLIWAG
        rival_starter_head = :MACHAMP
  else
    should_apply_easter_egg = false
  end

  if should_apply_easter_egg
    pbSet(VAR_PLAYER_STARTER_CHOICE,getDexNumberForSpecies(starter))
    pbSet(VAR_RIVAL_STARTER_HEAD_CHOICE,getDexNumberForSpecies(rival_starter_head))
    pbSet(VAR_RIVAL_STARTER_BODY_CHOICE,getDexNumberForSpecies(rival_starter_body))
    $game_switches[SWITCH_CUSTOM_STARTERS] = true
  end
end