def generateEggGroupTeam(eggGroup)
  teamComplete = false
  generatedTeam = []
  while !teamComplete
    species = rand(PBSpecies.maxValue)
    if getPokemonEggGroups(species).include?(eggGroup)
      generatedTeam << species
    end
    teamComplete = generatedTeam.length == 3
  end
  return generatedTeam
end

def generateSimpleTrainerParty(teamSpecies, level)
  team = []
  for species in teamSpecies
    poke = Pokemon.new(species, level)
    team << poke
  end
  return team
end

def Kernel.getRoamingMap(roamingArrayPos)
  curmap = $PokemonGlobal.roamPosition[roamingArrayPos]
  mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
  text = mapinfos[curmap].name #,(curmap==$game_map.map_id) ? _INTL("(this map)") : "")
  return text
end

def Kernel.getItemNamesAsString(list)
  strList = ""
  for i in 0..list.length - 1
    id = list[i]
    name = PBItems.getName(id)
    strList += name
    if i != list.length - 1 && list.length > 1
      strList += ","
    end
  end
  return strList
end

def getCurrentLevelCap()
  if Settings::KANTO
    current_max_level = Settings::LEVEL_CAPS_KANTO[$Trainer.badge_count]
  else
    current_max_level = Settings::LEVEL_CAPS_HOENN[$Trainer.badge_count]
  end
  current_max_level *= Settings::HARD_MODE_LEVEL_MODIFIER if $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
  current_max_level *= Settings::EASY_MODE_LEVEL_MODIFIER if $game_switches[SWITCH_GAME_DIFFICULTY_EASY] && Settings::HOENN

  return current_max_level&.floor || 100
end

def pokemonExceedsLevelCap(pokemon)
  return false if $Trainer.badge_count >= Settings::NB_BADGES
  current_max_level = getCurrentLevelCap()
  return pokemon.level >= current_max_level
end




def setForcedAltSprites(forcedSprites_map)
  $PokemonTemp.forced_alt_sprites = forcedSprites_map
end