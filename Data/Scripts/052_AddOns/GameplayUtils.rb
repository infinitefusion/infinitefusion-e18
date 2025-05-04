# todo: make the flower disappear from the tileset somehow?
def oricorioEventPickFlower(flower_color)
  quest_progression = pbGet(VAR_ORICORIO_FLOWERS)
  if flower_color == :PINK
    if !$game_switches[SWITCH_ORICORIO_QUEST_PINK]
      pbMessage(_INTL("Woah! A Pokémon jumped out of the flower!"))
      pbWildBattle(:FOMANTIS, 10)
    end
    $game_switches[SWITCH_ORICORIO_QUEST_PINK] = true
    pbMessage(_INTL("It's a flower with pink nectar."))
    pbSEPlay("MiningAllFound")
    pbMessage(_INTL("{1} picked some of the pink flowers.", $Trainer.name))
  elsif flower_color == :RED && quest_progression == 1
    $game_switches[SWITCH_ORICORIO_QUEST_RED] = true
    pbMessage(_INTL("It's a flower with red nectar."))
    pbSEPlay("MiningAllFound")
    pbMessage(_INTL("{1} picked some of the red flowers.", $Trainer.name))
  elsif flower_color == :BLUE && quest_progression == 2
    $game_switches[SWITCH_ORICORIO_QUEST_BLUE] = true
    pbMessage(_INTL("It's a flower with blue nectar."))
    pbSEPlay("MiningAllFound")
    pbMessage(_INTL("{1} picked some of the blue flowers.", $Trainer.name))
  end

end

def changeOricorioFlower(form = 1)
  if $PokemonGlobal.stepcount % 25 == 0
    if !hatUnlocked?(HAT_FLOWER) && rand(2) == 0
      obtainHat(HAT_FLOWER)
      $PokemonGlobal.stepcount += 1
    else
      pbMessage(_INTL("Woah! A Pokémon jumped out of the flower!"))
      pbWildBattle(:FOMANTIS, 10)
      $PokemonGlobal.stepcount += 1
    end
  end
  return if !($Trainer.has_species_or_fusion?(:ORICORIO_1) || $Trainer.has_species_or_fusion?(:ORICORIO_2) || $Trainer.has_species_or_fusion?(:ORICORIO_3) || $Trainer.has_species_or_fusion?(:ORICORIO_4))
  message = ""
  form_name = ""
  if form == 1
    message = "It's a flower with red nectar. "
    form_name = "Baile"
  elsif form == 2
    message = "It's a flower with yellow nectar. "
    form_name = "Pom-pom"
  elsif form == 3
    message = "It's a flower with pink nectar. "
    form_name = "Pa'u"
  elsif form == 4
    message = "It's a flower with blue nectar. "
    form_name = "Sensu"
  end

  message = message + "Show it to a Pokémon?"
  if pbConfirmMessage(message)
    pbChoosePokemon(1, 2,
                    proc { |poke|
                      !poke.egg? &&
                        (Kernel.isPartPokemon(poke, :ORICORIO_1) ||
                          Kernel.isPartPokemon(poke, :ORICORIO_2) ||
                          Kernel.isPartPokemon(poke, :ORICORIO_3) ||
                          Kernel.isPartPokemon(poke, :ORICORIO_4))
                    })
    if (pbGet(1) != -1)
      poke = $Trainer.party[pbGet(1)]
      if changeOricorioForm(poke, form)
        pbMessage(_INTL("{1} switched to the {2} style", poke.name, form_name))
        pbSet(1, poke.name)
      else
        pbMessage(_INTL("{1} remained the same...", poke.name, form_name))
      end
    end
  end
end

def changeOricorioForm(pokemon, form = nil)
  oricorio_forms = [:ORICORIO_1, :ORICORIO_2, :ORICORIO_3, :ORICORIO_4]
  body_id = pokemon.isFusion? ? get_body_species_from_symbol(pokemon.species) : pokemon.species
  head_id = pokemon.isFusion? ? get_head_species_from_symbol(pokemon.species) : pokemon.species

  oricorio_body = oricorio_forms.include?(body_id)
  oricorio_head = oricorio_forms.include?(head_id)

  if form == 1
    body_id = :ORICORIO_1 if oricorio_body
    head_id = :ORICORIO_1 if oricorio_head
  elsif form == 2
    body_id = :ORICORIO_2 if oricorio_body
    head_id = :ORICORIO_2 if oricorio_head
  elsif form == 3
    body_id = :ORICORIO_3 if oricorio_body
    head_id = :ORICORIO_3 if oricorio_head
  elsif form == 4
    body_id = :ORICORIO_4 if oricorio_body
    head_id = :ORICORIO_4 if oricorio_head
  else
    return false
  end

  head_number = getDexNumberForSpecies(head_id)
  body_number = getDexNumberForSpecies(body_id)

  newForm = pokemon.isFusion? ? getSpeciesIdForFusion(head_number, body_number) : head_id
  $Trainer.pokedex.set_seen(newForm)
  $Trainer.pokedex.set_owned(newForm)

  pokemon.species = newForm
  return true
end

# tradedPoke = pbGet(154)
# party=[tradedPoke]
# customTrainerBattle("Eusine",
#                     :MYSTICALMAN,
#                     party,
#                     tradedPoke.level,
#                     "Okay, okay I'll give it back!" )

def fossilsGuyBattle(level = 20, end_message = "")
  team = getFossilsGuyTeam(level)
  customTrainerBattle("Miguel",
                      :SUPERNERD,
                      team,
                      level,
                      end_message
  )

end

def getFossilsGuyTeam(level)
  base_poke_evolution_level = 20
  fossils_evolution_level_1 = 30
  fossils_evolution_level_2 = 50

  fossils = []
  base_poke = level <= base_poke_evolution_level ? :B88H109 : :B89H110
  team = []
  team << Pokemon.new(base_poke, level)

  # Mt. Moon fossil
  if $game_switches[SWITCH_PICKED_HELIC_FOSSIL]
    fossils << :KABUTO if level < fossils_evolution_level_1
    fossils << :KABUTOPS if level >= fossils_evolution_level_1
  elsif $game_switches[SWITCH_PICKED_DOME_FOSSIL]
    fossils << :OMANYTE if level < fossils_evolution_level_1
    fossils << :OMASTAR if level >= fossils_evolution_level_1
  end

  # S.S. Anne fossil
  if $game_switches[SWITCH_PICKED_LILEEP_FOSSIL]
    fossils << :ANORITH if level < fossils_evolution_level_1
    fossils << :ARMALDO if level >= fossils_evolution_level_1

  elsif $game_switches[SWITCH_PICKED_ANORITH_FOSSIL]
    fossils << :LILEEP if level < fossils_evolution_level_1
    fossils << :CRADILY if level >= fossils_evolution_level_1
  end
  # Celadon fossil
  if $game_switches[SWITCH_PICKED_ARMOR_FOSSIL]
    fossils << :CRANIDOS if level < fossils_evolution_level_2
    fossils << :RAMPARDOS if level >= fossils_evolution_level_2

  elsif $game_switches[SWITCH_PICKED_SKULL_FOSSIL]
    fossils << :SHIELDON if level < fossils_evolution_level_2
    fossils << :BASTIODON if level >= fossils_evolution_level_2
  end

  skip_next = false
  for index in 0..fossils.length
    if index == fossils.length - 1
      team << Pokemon.new(fossils[index], level)
    else
      if skip_next
        skip_next = false
        next
      end
      head_poke = fossils[index]
      body_poke = fossils[index + 1]
      if head_poke && body_poke
        newPoke = getFusionSpecies(dexNum(body_poke), dexNum(head_poke))
        team << Pokemon.new(newPoke, level)
        skip_next = true
      end
    end
  end
  return team
end

def playPokeFluteAnimation
  # return if $Trainer.outfit != 0
  # $game_player.setDefaultCharName("players/pokeflute", 0, false)
  # Graphics.update
  # Input.update
  # pbUpdateSceneMap
end

def restoreDefaultCharacterSprite(charset_number = 0)
  meta = GameData::Metadata.get_player($Trainer.character_ID)
  $game_player.setDefaultCharName(nil, 0, false)
  $game_player.character_name = meta[1]
  Graphics.update
  Input.update
  pbUpdateSceneMap
end

def setDifficulty(index)
  $Trainer.selected_difficulty = index
  case index
  when 0 # EASY
    $game_switches[SWITCH_GAME_DIFFICULTY_EASY] = true
    $game_switches[SWITCH_GAME_DIFFICULTY_HARD] = false
  when 1 # NORMAL
    $game_switches[SWITCH_GAME_DIFFICULTY_EASY] = false
    $game_switches[SWITCH_GAME_DIFFICULTY_HARD] = false
  when 2 # HARD
    $game_switches[SWITCH_GAME_DIFFICULTY_EASY] = false
    $game_switches[SWITCH_GAME_DIFFICULTY_HARD] = true
  end
end

# Old menu for changing difficulty - unused
def change_game_difficulty(down_only = false)
  message = "The game is currently on " + get_difficulty_text() + " difficulty."
  pbMessage(message)

  choice_easy = "Easy"
  choice_normal = "Normal"
  choice_hard = "Hard"
  choice_cancel = "Cancel"

  available_difficulties = []
  currentDifficulty = get_current_game_difficulty
  if down_only
    if currentDifficulty == :HARD
      available_difficulties << choice_hard
      available_difficulties << choice_normal
      available_difficulties << choice_easy
    elsif currentDifficulty == :NORMAL
      available_difficulties << choice_normal
      available_difficulties << choice_easy
    elsif currentDifficulty == :EASY
      available_difficulties << choice_easy
    end
  else
    available_difficulties << choice_easy
    available_difficulties << choice_normal
    available_difficulties << choice_hard
  end
  available_difficulties << choice_cancel
  index = pbMessage("Select a new difficulty", available_difficulties, available_difficulties[-1])
  choice = available_difficulties[index]
  case choice
  when choice_easy
    $game_switches[SWITCH_GAME_DIFFICULTY_EASY] = true
    $game_switches[SWITCH_GAME_DIFFICULTY_HARD] = false
  when choice_normal
    $game_switches[SWITCH_GAME_DIFFICULTY_EASY] = false
    $game_switches[SWITCH_GAME_DIFFICULTY_HARD] = false
  when choice_hard
    $game_switches[SWITCH_GAME_DIFFICULTY_EASY] = false
    $game_switches[SWITCH_GAME_DIFFICULTY_HARD] = true
  when choice_cancel
    return
  end

  message = "The game is currently on " + get_difficulty_text() + " difficulty."
  pbMessage(message)
end

def Kernel.getPlateType(item)
  return :FIGHTING if item == PBItems::FISTPLATE
  return :FLYING if item == PBItems::SKYPLATE
  return :POISON if item == PBItems::TOXICPLATE
  return :GROUND if item == PBItems::EARTHPLATE
  return :ROCK if item == PBItems::STONEPLATE
  return :BUG if item == PBItems::INSECTPLATE
  return :GHOST if item == PBItems::SPOOKYPLATE
  return :STEEL if item == PBItems::IRONPLATE
  return :FIRE if item == PBItems::FLAMEPLATE
  return :WATER if item == PBItems::SPLASHPLATE
  return :GRASS if item == PBItems::MEADOWPLATE
  return :ELECTRIC if item == PBItems::ZAPPLATE
  return :PSYCHIC if item == PBItems::MINDPLATE
  return :ICE if item == PBItems::ICICLEPLATE
  return :DRAGON if item == PBItems::DRACOPLATE
  return :DARK if item == PBItems::DREADPLATE
  return :FAIRY if item == PBItems::PIXIEPLATE
  return -1
end

def Kernel.listPlatesInBag()
  list = []
  list << PBItems::FISTPLATE if $PokemonBag.pbQuantity(:FISTPLATE) >= 1
  list << PBItems::SKYPLATE if $PokemonBag.pbQuantity(:SKYPLATE) >= 1
  list << PBItems::TOXICPLATE if $PokemonBag.pbQuantity(:TOXICPLATE) >= 1
  list << PBItems::EARTHPLATE if $PokemonBag.pbQuantity(:EARTHPLATE) >= 1
  list << PBItems::STONEPLATE if $PokemonBag.pbQuantity(:STONEPLATE) >= 1
  list << PBItems::INSECTPLATE if $PokemonBag.pbQuantity(:INSECTPLATE) >= 1
  list << PBItems::SPOOKYPLATE if $PokemonBag.pbQuantity(:SPOOKYPLATE) >= 1
  list << PBItems::IRONPLATE if $PokemonBag.pbQuantity(:IRONPLATE) >= 1
  list << PBItems::FLAMEPLATE if $PokemonBag.pbQuantity(:FLAMEPLATE) >= 1
  list << PBItems::SPLASHPLATE if $PokemonBag.pbQuantity(:SPLASHPLATE) >= 1
  list << PBItems::MEADOWPLATE if $PokemonBag.pbQuantity(:MEADOWPLATE) >= 1
  list << PBItems::ZAPPLATE if $PokemonBag.pbQuantity(:ZAPPLATE) >= 1
  list << PBItems::MINDPLATE if $PokemonBag.pbQuantity(:MINDPLATE) >= 1
  list << PBItems::ICICLEPLATE if $PokemonBag.pbQuantity(:ICICLEPLATE) >= 1
  list << PBItems::DRACOPLATE if $PokemonBag.pbQuantity(:DRACOPLATE) >= 1
  list << PBItems::DREADPLATE if $PokemonBag.pbQuantity(:DREADPLATE) >= 1
  list << PBItems::PIXIEPLATE if $PokemonBag.pbQuantity(:PIXIEPLATE) >= 1
  return list
end

def getArceusPlateType(heldItem)
  return :NORMAL if heldItem == nil
  case heldItem
  when :FISTPLATE
    return :FIGHTING
  when :SKYPLATE
    return :FLYING
  when :TOXICPLATE
    return :POISON
  when :EARTHPLATE
    return :GROUND
  when :STONEPLATE
    return :ROCK
  when :INSECTPLATE
    return :BUG
  when :SPOOKYPLATE
    return :GHOST
  when :IRONPLATE
    return :STEEL
  when :FLAMEPLATE
    return :FIRE
  when :SPLASHPLATE
    return :WATER
  when :MEADOWPLATE
    return :GRASS
  when :ZAPPLATE
    return :ELECTRIC
  when :MINDPLATE
    return :PSYCHIC
  when :ICICLEPLATE
    return :ICE
  when :DRACOPLATE
    return :DRAGON
  when :DREADPLATE
    return :DARK
  when :PIXIEPLATE
    return :FAIRY
  else
    return :NORMAL
  end
end

def getGenericPokemonCryText(pokemonSpecies)
  case pokemonSpecies
  when 25
    return "Pika!"
  when 16, 17, 18, 21, 22, 144, 145, 146, 227, 417, 418, 372 # birds
    return "Squawk!"
  when 163, 164
    return "Hoot!" # owl
  else
    return "Guaugh!"
  end
end

def Kernel.setRocketPassword(variableNum)
  abilityIndex = rand(233)
  speciesIndex = rand(PBSpecies.maxValue - 1)

  word1 = PBSpecies.getName(speciesIndex)
  word2 = GameData::Ability.get(abilityIndex).name
  password = _INTL("{1}'s {2}", word1, word2)
  pbSet(variableNum, password)
end

def obtainBadgeMessage(badgeName)
  Kernel.pbMessage(_INTL("\\me[Badge get]{1} obtained the {2}!", $Trainer.name, badgeName))
end

KANTO_OUTDOOR_MAPS = [
  78, # Route 1
  185, # Secret Garden
  86, # Route 2
  90, # Route 2 (north)
  655, # Hidden Forest
  40, # Viridian River
  490, # Route 3
  106, # Route 4
  12, # Route 5
  16, # Route 6
  413, # Route 7
  409, # Route 8
  351, # Route 9 (east)
  495, # Route 9 (west)
  154, # Route 10
  155, # Route 11
  159, # Route 12
  440, # Route 14
  444, # Route 15
  712, # Creepy house
  438, # Route 16
  146, # Route 17
  517, # Route 18
  437, # Route 13
  57, # Route 19
  227, # Route 19 (underwater)
  56, # Route 19 (surf race)
  58, # Route 20
  480, # Route 20 underwater 1
  228, # Route 20 underwater 2
  171, # Route 22
  8, # Route 24
  9, # Route 25
  143, # Route 23
  145, # Route 26
  147, # Route 27
  58, # Route 21
  # CITIES
  42, # Pallet Town
  79, # Viridian City
  1, # Cerulean City
  387, # Cerulean City (race)
  19, # Vermillion City
  36, # S.S. Anne deck
  95, # Celadon city
  436, # Celadon city dept store (roof)
  472, # Fuchsia city
  50, # Lavender town
  108, # Saffron city
  98, # Cinnabar island
  167, # Crimson city
  303, # indigo plateau
  380, # Pewter city
  827, # Mt. Moon summit
  #
  # DUNGEONS
  #
  102, # Mt. Moon
  103, # Mt. Moon
  105, # Mt. Moon
  496, # Mt Moon
  104, # Mt. Moon
  494, # Mt. Moon Square
  140, # Diglett cave
  398, # Diglett cave
  399, # Diglett cave
  349, # Rock tunnel
  350, # Rock tunnel
  512, # Rock tunnel (outdoor)
  445, # Safari Zone 1
  484, # Safari Zone 2
  485, # Safari Zone 3
  486, # Safari Zone 4
  487, # Safari Zone 5
  491, # Viridian Forest
  529, # Mt. Silver entrance
  777, # Mt. Silver outdoor 1
  781, # Mt. Silver outdoor 2
  782, # Mt. Silver
  783, # Mt. Silver summit
  400, # Pokemon Tower
  401, # Pokemon Tower
  402, # Pokemon Tower
  403, # Pokemon Tower
  467, # Pokemon Tower
  468, # Pokemon Tower
  469, # Pokemon Tower

]
KANTO_DARKNESS_STAGE_1 = [
  50, # Lavender town
  409, # Route 8
  351, # Route 9 (east)
  495, # Route 9 (west)
  154, # Route 10
  108, # Saffron city
  1, # Cerulean City
  387, # Cerulean City (race)
  106, # Route 4
  8, # Route 24
  9, # Route 25
  400, # Pokemon Tower
  401, # Pokemon Tower
  402, # Pokemon Tower
  403, # Pokemon Tower
  467, # Pokemon Tower
  468, # Pokemon Tower
  469, # Pokemon Tower
  159, # Route 12
  349, # Rock tunnel
  350, # Rock tunnel
  512, # Rock tunnel (outdoor)
  12, # Route 5

]
KANTO_DARKNESS_STAGE_2 = [
  95, # Celadon city
  436, # Celadon city dept store (roof)
  143, # Route 23
  167, # Crimson city
  413, # Route 7
  438, # Route 16
  146, # Route 17
  106, # Route 4
  19, # Vermillion City
  36, # S.S. Anne deck
  16, # Route 6
  437, # Route 13
  155, # Route 11
  140, # Diglett cave
  398, # Diglett cave
  399, # Diglett cave
]
KANTO_DARKNESS_STAGE_3 = [
  472, # Fuchsia city
  445, # Safari Zone 1
  484, # Safari Zone 2
  485, # Safari Zone 3
  486, # Safari Zone 4
  487, # Safari Zone 5
  444, # Route 15
  440, # Route 14
  712, # Creepy house
  517, # Route 18
  57, # Route 19
  227, # Route 19 (underwater)
  56, # Route 19 (surf race)
  58, # Route 20
  480, # Route 20 underwater 1
  228, # Route 20 underwater 2
  98, # Cinnabar island
  58, # Route 21
  827, # Mt. Moon summit
]
KANTO_DARKNESS_STAGE_4 = KANTO_OUTDOOR_MAPS

def darknessEffectOnCurrentMap()
  return if !$game_switches
  return if !$game_switches[SWITCH_KANTO_DARKNESS]
  return darknessEffectOnMap($game_map.map_id)
end

def darknessEffectOnMap(map_id)
  return if !$game_switches
  return if !$game_switches[SWITCH_KANTO_DARKNESS]
  return if !KANTO_OUTDOOR_MAPS.include?(map_id)
  dark_maps = []
  dark_maps += KANTO_DARKNESS_STAGE_1 if $game_switches[SWITCH_KANTO_DARKNESS_STAGE_1]
  dark_maps += KANTO_DARKNESS_STAGE_2 if $game_switches[SWITCH_KANTO_DARKNESS_STAGE_2]
  dark_maps += KANTO_DARKNESS_STAGE_3 if $game_switches[SWITCH_KANTO_DARKNESS_STAGE_3]
  dark_maps = KANTO_OUTDOOR_MAPS if $game_switches[SWITCH_KANTO_DARKNESS_STAGE_4]
  return dark_maps.include?(map_id)
end

def apply_darkness()
  $PokemonTemp.darknessSprite = DarknessSprite.new
  darkness = $PokemonTemp.darknessSprite
  darkness.radius = 276
  while darkness.radius > 64
    Graphics.update
    Input.update
    pbUpdateSceneMap
    darkness.radius -= 4
  end
  $PokemonGlobal.flashUsed = false
  $PokemonTemp.darknessSprite.dispose
  Events.onMapSceneChange.trigger(self, $scene, true)
end

def isInMtMoon()
  mt_moon_maps = [102, 103, 105, 496, 104]
  return mt_moon_maps.include?($game_map.map_id)
end

def getMtMoonDirection()
  maps_east = [380, # Pewter city
               490, # Route 3
               303, # indigo plateau
               145, # Route 26
               147, # Route 27
  ]
  maps_south = [
    8, # Route 24
    9, # Route 25
    143, # Route 23
    167, # Crimson city
  ]
  maps_west = [
    106, # route 4
    1, # cerulean
    495, # route 9
    351, # route 9
    10 # cerulean cape
  ]
  return 2 if maps_south.include?($game_map.map_id)
  return 4 if maps_west.include?($game_map.map_id)
  return 6 if maps_east.include?($game_map.map_id)
  return 8 # north (most maps)
end

def has_species_or_fusion?(species, form = -1)
  return $Trainer.pokemon_party.any? { |p| p && p.isSpecies?(species) || p.isFusionOf(species) }
end

# Solution: position of boulders [[x,y],[x,y],etc.]
def validate_regirock_ice_puzzle(solution)
  for boulder_position in solution
    x = boulder_position[0]
    y = boulder_position[1]
    # echoln ""
    # echoln x.to_s + ", " + y.to_s
    # echoln $game_map.event_at_position(x,y)
    return false if !$game_map.event_at_position(x, y)
  end
  echoln "all boulders in place"
  return true
end

def unpress_all_regirock_steel_switches()
  switch_ids = [75, 77, 76, 67, 74, 68, 73, 72, 70, 69]
  regi_map = 813
  switch_ids.each do |event_id|
    pbSetSelfSwitch(event_id, "A", false, regi_map)
  end
end

def validate_regirock_steel_puzzle()
  expected_pressed_switches = [75, 77, 74, 68, 73, 69]
  expected_unpressed_switches = [76, 67, 72, 70]
  switch_ids = [75, 77, 76, 67,
                74, 68,
                73, 72, 70, 69]

  pressed_switches = []
  unpressed_switches = []
  switch_ids.each do |switch_id|
    is_pressed = pbGetSelfSwitch(switch_id, "A")
    if is_pressed
      pressed_switches << switch_id
    else
      unpressed_switches << switch_id
    end
  end

  for event_id in switch_ids
    is_pressed = pbGetSelfSwitch(event_id, "A")
    return false if !is_pressed && expected_pressed_switches.include?(event_id)
    return false if is_pressed && expected_unpressed_switches.include?(event_id)
  end
  return true
end

def registeel_ice_press_switch(letter)
  order = pbGet(VAR_REGI_PUZZLE_SWITCH_PRESSED)
  solution = "ssBSBGG" # GGSBBss"
  registeel_ice_reset_switches() if !order.is_a?(String)
  order << letter
  pbSet(VAR_REGI_PUZZLE_SWITCH_PRESSED, order)
  if order == solution
    echoln "OK"
    pbSEPlay("Evolution start", nil, 130)
  elsif order.length >= solution.length
    registeel_ice_reset_switches()
  end
  echoln order
end

def registeel_ice_reset_switches()
  switches_events = [66, 78, 84, 85, 86, 87, 88]
  switches_events.each do |switch_id|
    pbSetSelfSwitch(switch_id, "A", false)
    echoln "reset" + switch_id.to_s
  end
  pbSet(VAR_REGI_PUZZLE_SWITCH_PRESSED, "")
end

def regirock_steel_move_boulder()

  switches_position = [
    [16, 21], [18, 21], [20, 21], [22, 21],
    [16, 23], [22, 23],
    [16, 25], [18, 25], [20, 25], [22, 25]
  ]
  boulder_event = get_self
  old_x = boulder_event.x
  old_y = boulder_event.y
  stepped_off_switch = switches_position.find { |position| position[0] == old_x && position[1] == old_y }

  pbPushThisBoulder()
  boulder_event = get_self

  if stepped_off_switch
    switch_event = $game_map.get_event_at_position(old_x, old_y, [boulder_event.id])
    echoln switch_event.id if switch_event
    pbSEPlay("Entering Door", nil, 80)
    pbSetSelfSwitch(switch_event.id, "A", false) if switch_event
  end

  stepped_on_switch = switches_position.find { |position| position[0] == boulder_event.x && position[1] == boulder_event.y }
  if stepped_on_switch
    switch_event = $game_map.get_event_at_position(boulder_event.x, boulder_event.y, [boulder_event.id])
    echoln switch_event.id if switch_event
    pbSEPlay("Entering Door")
    pbSetSelfSwitch(switch_event.id, "A", true) if switch_event
  end
end

def displayRandomizerErrorMessage()
  Kernel.pbMessage(_INTL("The randomizer has encountered an error. You should try to re-randomize your game as soon as possible."))
  Kernel.pbMessage(_INTL("You can do this on the top floor of Pokémon Centers."))
end

# ex:Game_Event.new
# forced_sprites = {"1.133" => "a"}
# setForcedAltSprites(forced_sprites)
#
def setForcedAltSprites(forcedSprites_map)
  $PokemonTemp.forced_alt_sprites = forcedSprites_map
end

def unlock_easter_egg_hats()
  if $Trainer.name == "Ash"
    $Trainer.hat = HAT_ASH
    $Trainer.unlock_hat(HAT_ASH)
  end
  if $Trainer.name == "Frogman"
    $Trainer.hat = HAT_FROG
    $Trainer.unlock_hat(HAT_FROG)
  end
end

def setupStartingOutfit()
  $Trainer.hat = nil
  $Trainer.clothes = STARTING_OUTFIT
  unlock_easter_egg_hats()
  gender = pbGet(VAR_TRAINER_GENDER)
  if gender == GENDER_FEMALE
    $Trainer.unlock_clothes(DEFAULT_OUTFIT_FEMALE, true)
    $Trainer.unlock_hat(DEFAULT_OUTFIT_FEMALE, true)
    $Trainer.hair = "3_" + DEFAULT_OUTFIT_FEMALE if !$Trainer.hair # when migrating old savefiles

  elsif gender == GENDER_MALE
    $Trainer.unlock_clothes(DEFAULT_OUTFIT_MALE, true)
    $Trainer.unlock_hat(DEFAULT_OUTFIT_MALE, true)

    echoln $Trainer.hair
    $Trainer.hair = ("3_" + DEFAULT_OUTFIT_MALE) if !$Trainer.hair # when migrating old savefiles
    echoln $Trainer.hair
  end
  $Trainer.unlock_hair(DEFAULT_OUTFIT_MALE, true)
  $Trainer.unlock_hair(DEFAULT_OUTFIT_FEMALE, true)
  $Trainer.unlock_clothes(STARTING_OUTFIT, true)
end

def give_date_specific_hats()
  current_date = Time.new
  # Christmas
  if (current_date.day == 24 || current_date.day == 25) && current_date.month == 12
    if !$Trainer.unlocked_hats.include?(HAT_SANTA)
      pbCallBub(2, @event_id, true)
      pbMessage("Hi! We're giving out a special hat today for the holidays season. Enjoy!")
      obtainHat(HAT_SANTA)
    end
  end

  # April's fool
  if (current_date.day == 1 && current_date.month == 4)
    if !$Trainer.unlocked_hats.include?(HAT_CLOWN)
      pbCallBub(2, @event_id, true)
      pbMessage("Hi! We're giving out this fun accessory for this special day. Enjoy!")
      obtainHat(HAT_CLOWN)
    end
  end
end

def playMeloettaBandMusic()
  unlocked_members = []
  unlocked_members << :DRUM if $game_switches[SWITCH_BAND_DRUMMER]
  unlocked_members << :AGUITAR if $game_switches[SWITCH_BAND_ACOUSTIC_GUITAR]
  unlocked_members << :EGUITAR if $game_switches[SWITCH_BAND_ELECTRIC_GUITAR]
  unlocked_members << :FLUTE if $game_switches[SWITCH_BAND_FLUTE]
  unlocked_members << :HARP if $game_switches[SWITCH_BAND_HARP]

  echoln unlocked_members
  echoln (unlocked_members & [:DRUM, :AGUITAR, :EGUITAR, :FLUTE, :HARP])

  track = "band/band_1"
  if unlocked_members == [:DRUM, :AGUITAR, :EGUITAR, :FLUTE, :HARP]
    track = "band/band_full"
  else
    if unlocked_members.include?(:FLUTE)
      track = "band/band_5a"
    elsif unlocked_members.include?(:HARP)
      track = "band/band_5b"
    else
      if unlocked_members.include?(:EGUITAR) && unlocked_members.include?(:AGUITAR)
        track = "band/band_4"
      elsif unlocked_members.include?(:AGUITAR)
        track = "band/band_3a"
      elsif unlocked_members.include?(:EGUITAR)
        track = "band/band_3b"
      elsif unlocked_members.include?(:DRUM)
        track = "band/band_2"
      end
    end
  end
  echoln track
  pbBGMPlay(track)
end

def setPokemonMoves(pokemon, move_ids = [])
  moves = []
  move_ids.each { |move_id|
    moves << Pokemon::Move.new(move_id)
  }
  pokemon.moves = moves
end

def isTuesdayNight()
  day = getDayOfTheWeek()
  hour = pbGetTimeNow().hour
  echoln hour
  return (day == :TUESDAY && hour >= 20) || (day == :WEDNESDAY && hour < 5)
end

def apply_concert_lighting(light, duration = 1)
  tone = Tone.new(0, 0, 0)
  case light
  when :GUITAR_HIT
    tone = Tone.new(-50, -100, -50)
  when :VERSE_1
    tone = Tone.new(-90, -110, -50)
  when :VERSE_2_LIGHT
    tone = Tone.new(-40, -80, -30)
  when :VERSE_2_DIM
    tone = Tone.new(-60, -100, -50)
  when :CHORUS_1
    tone = Tone.new(0, -80, -50)
  when :CHORUS_2
    tone = Tone.new(0, -50, -80)
  when :CHORUS_3
    tone = Tone.new(0, -80, -80)
  when :CHORUS_END
    tone = Tone.new(-68, 0, -102)
  when :MELOETTA_1
    tone = Tone.new(-60, -50, 20)
  end
  $game_screen.start_tone_change(tone, duration)
end

def replaceFusionSpecies(pokemon, speciesToChange, newSpecies)
  currentBody = pokemon.species_data.get_body_species_symbol()
  currentHead = pokemon.species_data.get_head_species_symbol()
  should_update_body = currentBody == speciesToChange
  should_update_head = currentHead == speciesToChange

  echoln speciesToChange
  echoln currentBody
  echoln currentHead

  return if !should_update_body && !should_update_head

  newSpeciesBody = should_update_body ? newSpecies : currentBody
  newSpeciesHead = should_update_head ? newSpecies : currentHead

  newSpecies = getFusionSpecies(newSpeciesBody, newSpeciesHead)
  echoln newSpecies.id_number
  pokemon.species = newSpecies
end

def changeSpeciesSpecific(pokemon, newSpecies)
  pokemon.species = newSpecies
  $Trainer.pokedex.set_seen(newSpecies)
  $Trainer.pokedex.set_owned(newSpecies)
end

def getNextLunarFeatherHint()
  nb_feathers = pbGet(VAR_LUNAR_FEATHERS)
  case nb_feathers
  when 0
    return "Find the first feather in the northernmost dwelling in the port of exquisite sunsets..."
  when 1
    return "Amidst a nursery for Pokémon youngsters, the second feather hides, surrounded by innocence."
  when 2
    return "Find the next one in the inn where water meets rest"
  when 3
    return "Find the next one inside the lone house in the city at the edge of civilization."
  when 4
    return "The final feather lies back in the refuge for orphaned Pokémon..."
  else
    return "Lie in the bed... Bring me the feathers..."
  end
end

def clearAllSelfSwitches(mapID, switch = "A", newValue = false)
  map = $MapFactory.getMap(mapID, false)
  map.events.each { |event_array|
    event_id = event_array[0]
    pbSetSelfSwitch(event_id, switch, newValue, mapID)
  }
end

#@formatter:off
def get_constellation_variable(pokemon)
  case pokemon
  when :IVYSAUR;
    return VAR_CONSTELLATION_IVYSAUR
  when :WARTORTLE;
    return VAR_CONSTELLATION_WARTORTLE
  when :ARCANINE;
    return VAR_CONSTELLATION_ARCANINE
  when :MACHOKE;
    return VAR_CONSTELLATION_MACHOKE
  when :RAPIDASH;
    return VAR_CONSTELLATION_RAPIDASH
  when :GYARADOS;
    return VAR_CONSTELLATION_GYARADOS
  when :ARTICUNO;
    return VAR_CONSTELLATION_ARTICUNO
  when :MEW;
    return VAR_CONSTELLATION_MEW
    # when :POLITOED;   return  VAR_CONSTELLATION_POLITOED
    # when :URSARING;   return  VAR_CONSTELLATION_URSARING
    # when :LUGIA;      return  VAR_CONSTELLATION_LUGIA
    # when :HOOH;       return  VAR_CONSTELLATION_HOOH
    # when :CELEBI;     return  VAR_CONSTELLATION_CELEBI
    # when :SLAKING;    return  VAR_CONSTELLATION_SLAKING
    # when :JIRACHI;    return  VAR_CONSTELLATION_JIRACHI
    # when :TYRANTRUM;  return  VAR_CONSTELLATION_TYRANTRUM
    # when :SHARPEDO;   return  VAR_CONSTELLATION_SHARPEDO
    # when :ARCEUS;     return  VAR_CONSTELLATION_ARCEUS
  end
end

#@formatter:on

def promptCaughtPokemonAction(pokemon)
  pickedOption = false
  return pbStorePokemon(pokemon) if !$Trainer.party_full?
  return promptKeepOrRelease(pokemon) if isOnPinkanIsland() && !$game_switches[SWITCH_PINKAN_FINISHED]
  while !pickedOption
    command = pbMessage(_INTL("\\ts[]Your team is full!"),
                        [_INTL("Add to your party"), _INTL("Store to PC"),], 2)
    echoln ("command " + command.to_s)
    case command
    when 0 # SWAP
      if swapCaughtPokemon(pokemon)
        echoln pickedOption
        pickedOption = true
      end
    else
      # STORE
      pbStorePokemon(pokemon)
      echoln pickedOption
      pickedOption = true
    end
  end

end

def promptKeepOrRelease(pokemon)
  pickedOption = false
  while !pickedOption
    command = pbMessage(_INTL("\\ts[]Your team is full!"),
                        [_INTL("Release a party member"), _INTL("Release this #{pokemon.name}"),], 2)
    echoln ("command " + command.to_s)
    case command
    when 0 # SWAP
      if swapReleaseCaughtPokemon(pokemon)
        pickedOption = true
      end
    else
      pickedOption = true
    end
  end
end

# def pbChoosePokemon(variableNumber, nameVarNumber, ableProc = nil, allowIneligible = false)
def swapCaughtPokemon(caughtPokemon)
  pbChoosePokemon(1, 2,
                  proc { |poke|
                    !poke.egg? &&
                      !(poke.isShadow? rescue false)
                  })
  index = pbGet(1)
  return false if index == -1
  $PokemonStorage.pbStoreCaught($Trainer.party[index])
  pbRemovePokemonAt(index)
  pbStorePokemon(caughtPokemon)

  tmp = $Trainer.party[index]
  $Trainer.party[index] = $Trainer.party[-1]
  $Trainer.party[-1] = tmp
  return true
end

def swapReleaseCaughtPokemon(caughtPokemon)
  pbChoosePokemon(1, 2,
                  proc { |poke|
                    !poke.egg? &&
                      !(poke.isShadow? rescue false)
                  })
  index = pbGet(1)
  return false if index == -1
  releasedPokemon = $Trainer.party[index]
  pbMessage("#{releasedPokemon.name} was released.")
  pbRemovePokemonAt(index)
  pbStorePokemon(caughtPokemon)

  tmp = $Trainer.party[index]
  $Trainer.party[index] = $Trainer.party[-1]
  $Trainer.party[-1] = tmp
  return true
end

def constellation_add_star(pokemon)
  star_variables = get_constellation_variable(pokemon)

  pbSEPlay("GUI trainer card open", 80)
  nb_stars = pbGet(star_variables)
  pbSet(star_variables, nb_stars + 1)
end

def clear_all_images()
  for i in 1..99
    # echoln i.to_s + " : " + $game_screen.pictures[i].name
    $game_screen.pictures[i].erase
  end
end

def exportTeamForShowdown()
  message = ""
  for pokemon in $Trainer.party
    message << exportFusedPokemonForShowdown(pokemon)
    message << "\n"
  end
  Input.clipboard = message
end

# Clefnair (Clefable) @ Life Orb
# Ability: Magic Guard
# Level: 33
# Fusion: Dragonair
# EVs: 252 HP / 252 SpD / 4 Spe
# Modest Nature
# - Dazzling Gleam
# - Dragon Breath
# - Wish
# - Water Pulse
def exportFusedPokemonForShowdown(pokemon)

  if pokemon.species_data.is_a?(GameData::FusedSpecies)
    head_pokemon_species = pokemon.species_data.head_pokemon
    species_name = head_pokemon_species.name
  else
    species_name = pokemon.species_data.real_name
  end

  if pokemon.item
    nameLine = _INTL("{1} ({2}) @ {3}", pokemon.name, species_name, pokemon.item.name)
  else
    nameLine = _INTL("{1} ({2})", pokemon.name, species_name)
  end

  abilityLine = _INTL("Ability: {1}", pokemon.ability.name)
  levelLine = _INTL("Level: {1}", pokemon.level)

  fusionLine = ""
  if pokemon.species_data.is_a?(GameData::FusedSpecies)
    body_pokemon_species = pokemon.species_data.body_pokemon
    fusionLine = _INTL("Fusion: {1}\n", body_pokemon_species.name)
  end
  evsLine = calculateEvLineForShowdown(pokemon)
  ivsLine = calculateIvLineForShowdown(pokemon)

  move1 = "", move2 = "", move3 = "", move4 = ""
  move1 = _INTL("- {1}", GameData::Move.get(pokemon.moves[0].id).real_name) if pokemon.moves[0]
  move2 = _INTL("- {1}", GameData::Move.get(pokemon.moves[1].id).real_name) if pokemon.moves[1]
  move3 = _INTL("- {1}", GameData::Move.get(pokemon.moves[2].id).real_name) if pokemon.moves[2]
  move4 = _INTL("- {1}", GameData::Move.get(pokemon.moves[3].id).real_name) if pokemon.moves[3]

  ret = nameLine + "\n" +
    abilityLine + "\n" +
    levelLine + "\n" +
    fusionLine +
    evsLine + "\n" +
    ivsLine + "\n" +
    move1 + "\n" +
    move2 + "\n" +
    move3 + "\n" +
    move4 + "\n"

  return ret
end

def calculateEvLineForShowdown(pokemon)
  evsLine = "EVs: "
  evsLine << _INTL("{1} HP /", pokemon.ev[:HP])
  evsLine << _INTL("{1} Atk / ", pokemon.ev[:ATTACK])
  evsLine << _INTL("{1} Def / ", pokemon.ev[:DEFENSE])
  evsLine << _INTL("{1} SpA / ", pokemon.ev[:SPECIAL_ATTACK])
  evsLine << _INTL("{1} SpD / ", pokemon.ev[:SPECIAL_DEFENSE])
  evsLine << _INTL("{1} Spe / ", pokemon.ev[:SPEED])
  return evsLine
end

def calculateIvLineForShowdown(pokemon)
  ivLine = "IVs: "
  ivLine << _INTL("{1} HP / ", pokemon.iv[:HP])
  ivLine << _INTL("{1} Atk / ", pokemon.iv[:ATTACK])
  ivLine << _INTL("{1} Def / ", pokemon.iv[:DEFENSE])
  ivLine << _INTL("{1} SpA / ", pokemon.iv[:SPECIAL_ATTACK])
  ivLine << _INTL("{1} SpD / ", pokemon.iv[:SPECIAL_DEFENSE])
  ivLine << _INTL("{1} Spe", pokemon.iv[:SPEED])
  return ivLine
end

def addWaterCausticsEffect(fog_name = "caustic1", opacity = 16)
  $game_map.fog_name = fog_name
  $game_map.fog_hue = 0
  $game_map.fog_opacity = opacity
  #$game_map.fog_blend_type = @parameters[4]
  $game_map.fog_zoom = 200
  $game_map.fog_sx = 2
  $game_map.fog_sy = 2

  $game_map.setFog2(fog_name, -3, 0, opacity,)
end

def stopWaterCausticsEffect()
  $game_map.fog_opacity = 0
  $game_map.eraseFog2()
end

def openUrlInBrowser(url = "")
  begin
    # Open the URL in the default web browser
    system("xdg-open", url) || system("open", url) || system("start", url)
  rescue
    Input.clipboard = url
    pbMessage("The game could not open the link in the browser")
    pbMessage("The link has been copied to your clipboard instead")
  end
end

def isPostgame?()
  return $game_switches[SWITCH_BEAT_THE_LEAGUE]
end

def obtainStarter(starterIndex = 0)
  if ($game_switches[SWITCH_RANDOM_STARTERS])
    starter = obtainRandomizedStarter(starterIndex)
  else
    startersList = Settings::KANTO_STARTERS
    if $game_switches[SWITCH_JOHTO_STARTERS]
      startersList = Settings::JOHTO_STARTERS
    elsif $game_switches[SWITCH_HOENN_STARTERS]
      startersList = Settings::HOENN_STARTERS
    elsif $game_switches[SWITCH_SINNOH_STARTERS]
      startersList = Settings::SINNOH_STARTERS
    elsif $game_switches[SWITCH_KALOS_STARTERS]
      startersList = Settings::KALOS_STARTERS
    end
    starter = startersList[starterIndex]
  end
  return GameData::Species.get(starter)
end

# body0
# head 1
def setRivalStarter(starterIndex1, starterIndex2)
  starter1 = obtainStarter(starterIndex1)
  starter2 = obtainStarter(starterIndex2)

  ensureRandomHashInitialized()
  if $game_switches[SWITCH_RANDOM_WILD_TO_FUSION] # if fused starters, only take index 1
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

def ensureRandomHashInitialized()
  if $PokemonGlobal.psuedoBSTHash == nil
    psuedoHash = Hash.new
    for i in 0..NB_POKEMON
      psuedoHash[i] = i
    end
    $PokemonGlobal.psuedoBSTHash = psuedoHash
  end
end

# Get difficulty for displaying in-game
def getDisplayDifficulty
  if $game_switches[SWITCH_GAME_DIFFICULTY_EASY] || $Trainer.lowest_difficulty <= 0
    return getDisplayDifficultyFromIndex(0)
  elsif $Trainer.lowest_difficulty <= 1
    return getDisplayDifficultyFromIndex(1)
  elsif $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
    return getDisplayDifficultyFromIndex(2)
  else
    return getDisplayDifficultyFromIndex(1)
  end
end

def getDisplayDifficultyFromIndex(difficultyIndex)
  return "Easy" if difficultyIndex == 0
  return "Normal" if difficultyIndex == 1
  return "Hard" if difficultyIndex == 2
  return "???"
end

def getGameModeFromIndex(index)
  return "Classic" if index == 0
  return "Random" if index == 1
  return "Remix" if index == 2
  return "Expert" if index == 3
  return "Species" if index == 4
  return "Debug" if index == 5
  return ""
end

# time in seconds
def idleHatEvent(hatId, time, switchToActivate = nil)
  map = $game_map.map_id
  i = 0
  while i < (time / 5) do
    # /5 because we update 5 times per second
    return if $game_map.map_id != map
    i += 1
    pbWait(4)
    i = 0 if $game_player.moving?
    echoln i
  end
  $game_switches[switchToActivate] = true if switchToActivate
  obtainHat(hatId)
end

# Necessary dor setting the various events within the pokemart map, uses the numbers as wondertrade
def get_city_numerical_id(city_sym)
  current_city_numerical = {
    :PEWTER => 1,
    :CERULEAN => 2,
    :VERMILLION => 3,
    :LAVENDER => 4,
    :CELADON => 5,
    :FUCHSIA => 6,
    :SAFFRON => 7,
    :CINNABAR => 8,
    :LEAGUE => 9,
    :VIOLET => 10,
    :AZALEA => 11,
    :GOLDENROD => 12,
    :ECRUTEAK => 13,
    :MAHOGANY => 14,
    :BLACKTHORN => 15,
    :OLIVINE => 16,
    :CIANWOOD => 17,
    :KNOTISLAND => 18,
    :BOONISLAND => 19,
    :KINISLAND => 20,
    :CHRONOISLAND => 21,
    :CRIMSON => 22,
  }
  return current_city_numerical[city_sym]
end

POKEMART_MAP_ID = 357
POKEMART_DOOR_POS = [12, 12]
# city -> Symbol
def enter_pokemart(city)
  pbSet(VAR_CURRENT_MART, city)
  pbSet(VAR_CURRENT_CITY_NUMERICAL_ID, get_city_numerical_id(city))
  echoln get_city_numerical_id(city)
  pbFadeOutIn {
    $game_temp.player_new_map_id = POKEMART_MAP_ID
    $game_temp.player_new_x = POKEMART_DOOR_POS[0]
    $game_temp.player_new_y = POKEMART_DOOR_POS[1]
    $scene.transfer_player(true)
    $game_map.autoplay
    $game_map.refresh
  }
end

def exit_pokemart()
  pokemart_entrances = {
    :PEWTER => [380, 43, 24],
    :CERULEAN => [1, 19, 22],
    :VERMILLION => [19, 32, 13],
    :LAVENDER => [50, 20, 23],
    :CELADON => [95, 18, 15], # not a real pokemart
    :FUCHSIA => [472, 7, 17],
    :SAFFRON => [108, 53, 24],
    :CINNABAR => [98, 30, 30],
    :CRIMSON => [167, 21, 36],
    :GOLDENROD => [237, 36, 33], # not a real pokemart
    :AZALEA => [278, 34, 17],
    :AZALEA_FLOODED => [338, 34, 17],
    :VIOLET => [230, 20, 31],
    :BLACKTHORN => [329, 16, 36],
    :MAHOGANY => [631, 19, 19], # not a real pokemart
    :ECRUTEAK => [359, 46, 38],
    :OLIVINE => [138, 33, 23],
    :CIANWOOD => [709.8, 46],
  }
  current_city = pbGet(VAR_CURRENT_MART)
  current_city = :PEWTER if !current_city.is_a?(Symbol)

  entrance_map = pokemart_entrances[current_city][0]
  entrance_x = pokemart_entrances[current_city][1]
  entrance_y = pokemart_entrances[current_city][2]

  pbSet(VAR_CURRENT_CITY_NUMERICAL_ID, 0)
  pbSet(VAR_CURRENT_MART, 0)
  pbFadeOutIn {
    $game_temp.player_new_map_id = entrance_map
    $game_temp.player_new_x = entrance_x
    $game_temp.player_new_y = entrance_y
    $scene.transfer_player(true)
    $game_map.autoplay
    $game_map.refresh
  }

end

def pokemart_clothes_shop(current_city = nil, include_defaults = true)
  current_city = pbGet(VAR_CURRENT_MART) if !current_city
  echoln current_city
  current_city = :PEWTER if !current_city.is_a?(Symbol)
  current_city_tag = current_city.to_s.downcase
  selector = OutfitSelector.new
  list = selector.generate_clothes_choice(
    baseOptions = include_defaults,
    additionalIds = [],
    additionalTags = [current_city_tag],
    filterOutTags = [])
  clothesShop(list)
end

def pokemart_hat_shop(include_defaults = true)
  current_city = pbGet(VAR_CURRENT_MART)
  current_city = :PEWTER if !current_city.is_a?(Symbol)
  current_city_tag = current_city.to_s.downcase
  selector = OutfitSelector.new
  list = selector.generate_hats_choice(
    baseOptions = include_defaults,
    additionalIds = [],
    additionalTags = [current_city_tag],
    filterOutTags = [])

  hatShop(list)
end

def get_mart_exclusive_items(city)
  items_list = []
  case city
  when :PEWTER;
    items_list = [:ROCKGEM, :NESTBALL]
  when :VIRIDIAN;
    items_list = []
  when :CERULEAN;
    items_list = [:WATERGEM, :NETBALL, :PRETTYWING]
  when :VERMILLION;
    items_list = [:LOVEBALL, :ELECTRICGEM]
  when :LAVENDER;
    items_list = [:GHOSTGEM, :DARKGEM, :DUSKBALL]
  when :CELADON;
    items_list = [:GRASSGEM, :FLYINGGEM, :QUICKBALL, :TIMERBALL,]
  when :FUCHSIA;
    items_list = [:POISONGEM, :REPEATBALL]
  when :SAFFRON;
    items_list = [:PSYCHICGEM, :FIGHTINGGEM, :FRIENDBALL]
  when :CINNABAR;
    items_list = [:FIREGEM, :ICEGEM, :HEAVYBALL]
  when :CRIMSON;
    items_list = [:DRAGONGEM, :LEVELBALL]
  when :GOLDENROD;
    items_list = [:EVERSTONE, :MOONSTONE, :SUNSTONE, :DUSKSTONE, :DAWNSTONE, :SHINYSTONE]
  when :AZALEA;
    items_list = [:BUGGEM]
  when :VIOLET;
    items_list = [:FLYINGGEM, :STATUSBALL]
  when :BLACKTHORN;
    items_list = [:DRAGONGEM, :CANDYBALL]
  when :CHERRYGROVE;
    items_list = [:BUGGEM, :PUREBALL]
  when :MAHOGANY;
    items_list = []
  when :ECRUTEAK;
    items_list = [:GHOSTGEM, :DARKGEM]
  when :OLIVINE;
    items_list = []
  when :CIANWOOD;
    items_list = []
  when :KNOTISLAND;
    items_list = []
  when :BOONISLAND;
    items_list = []
  when :KINISLAND;
    items_list = []
  when :CHRONOISLAND;
    items_list = []
  end
  return items_list
end

def calculate_pokemon_weight(pokemon, nerf = 0)

  base_weight = pokemon.weight
  ivs = []
  pokemon.iv.each { |iv|
    ivs << iv[1]
  }
  level = pokemon.level
  # Ensure IVs is an array of 6 values and level is between 1 and 100
  raise "IVs array must have 6 values" if ivs.length != 6
  raise "Level must be between 1 and 100" unless (1..100).include?(level)

  # Calculate the IV Factor
  iv_sum = ivs.sum
  iv_factor = (iv_sum.to_f / 186) * 30 * 10

  # Calculate the Level Factor
  level_factor = (level.to_f / 100) * 5 * 10

  # Calculate the weight
  weight = base_weight * (1 + (iv_factor / 100) + (level_factor / 100))
  weight -= base_weight
  # Enforce the weight variation limits
  max_weight = base_weight * 4.00 # 400% increase
  min_weight = base_weight * 0.5 # 50% decrease

  # Cap the weight between min and max values
  weight = [[weight, min_weight].max, max_weight].min
  weight -= nerf if weight - nerf > min_weight
  return weight.round(2) # Round to 2 decimal places
end

# nerf: remove x kg from each generated pokemon
def generate_weight_contest_entries(species, level, resultsVariable, nerf = 0)
  # echoln "Generating Pokemon"
  pokemon1 = pbGenerateWildPokemon(species, level) # Pokemon.new(species,level)
  pokemon2 = pbGenerateWildPokemon(species, level) # Pokemon.new(species,level)
  new_weights = []
  new_weights << calculate_pokemon_weight(pokemon1, nerf)
  new_weights << calculate_pokemon_weight(pokemon2, nerf)
  echoln new_weights
  echoln "(nerfed by -#{nerf})"
  pbSet(resultsVariable, new_weights.max)

end

# todo: implement
def getMappedKeyFor(internalKey)

  keybinding_fileName = "keybindings.mkxp1"
  path = System.data_directory + keybinding_fileName

  parse_keybindings(path)

  # echoln Keybindings.new(path).bindings
end

# if need to play animation from event route
def playAnimation(animationId, x, y)
  return if !$scene.is_a?(Scene_Map)
  $scene.spriteset.addUserAnimation(animationId, x, y, true)
end

def formatNumberToString(number)
  return number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

def playCry(pokemonSpeciesSymbol)
  species = GameData::Species.get(pokemonSpeciesSymbol).species
  GameData::Species.play_cry_from_species(species)
end

# chance: out of 100
def lilypadEncounter(pokemon, minLevel, maxLevel, chance = 10)
  minLevel, maxLevel = [minLevel, maxLevel].minmax
  level = rand(minLevel..maxLevel)

  event = $game_map.events[@event_id]
  return if !event
  if rand(0..100) <= chance
    pbWildBattle(pokemon, level)
  else
    playAnimation(Settings::GRASS_ANIMATION_ID, event.x, event.y)
  end
  event.erase
end

def isPlayerMale()
  return pbGet(VAR_TRAINER_GENDER) == GENDER_MALE
end

def isPlayerFemale()
  return pbGet(VAR_TRAINER_GENDER) == GENDER_FEMALE
end

def optionsMenu(options = [], cmdIfCancel = -1, startingOption = 0)
  cmdIfCancel = -1 if !cmdIfCancel
  result = pbShowCommands(nil, options, cmdIfCancel, startingOption)
  echoln "menuResult :#{result}"
  return result
end

def getHiddenPowerName(pokemon)
  hiddenpower = pbHiddenPower(pokemon)
  hiddenPowerType = hiddenpower[0]

  echoln hiddenPowerType
  if Settings::TRIPLE_TYPES.include?(hiddenPowerType)
    return "Neutral"
  end
  return PBTypes.getName(hiddenPowerType)
end

# Returns if the current map is an outdoor map
def isOutdoor()
  current_map = $game_map.map_id
  map_metadata = GameData::MapMetadata.try_get(current_map)
  return map_metadata && map_metadata.outdoor_map
end

#
# Rewards given by hotel questman after a certain nb. of completed quests
#
QUEST_REWARDS = [
  QuestReward.new(1, :HM08, 1, "This HM will allow you to illuminate dark caves and should help you to progress in your journey!"),
  QuestReward.new(5, :AMULETCOIN, 1, "This item will allows you to get twice the money in a battle if the Pokémon holding it took part in it!"),
  QuestReward.new(10, :LANTERN, 1, "This will allow you to illuminate caves without having to use a HM! Practical, isn't it?"),
  QuestReward.new(15, :LINKINGCORD, 3, "This strange cable triggers the evolution of Pokémon that typically evolve via trade. I know you'll put it to good use!"),
  QuestReward.new(20, :SLEEPINGBAG, 1, "This handy item will allow you to sleep anywhere you want. You won't even need hotels anymore!"),
  QuestReward.new(30, :MISTSTONE, 1, "This rare stone can evolve any Pokémon, regardless of their level or evolution method. Use it wisely!", true),
  QuestReward.new(50, :GSBALL, 1, "This mysterious ball is rumored to be the key to call upon the protector of Ilex Forest.  It's a precious relic."),
  QuestReward.new(60, :MASTERBALL, 1, "This rare ball can catch any Pokémon. Don't waste it!", true),
]

def turnEventTowardsEvent(turning, turnedTowards)
  event_x = turnedTowards.x
  event_y = turnedTowards.y
  if turning.x < event_x
    turning.turn_right # Event is to the right of the player
  elsif turning.x > event_x
    turning.turn_left # Event is to the left of the player
  elsif turning.y < event_y
    turning.turn_down # Event is below the player
  elsif turning.y > event_y
    turning.turn_up # Event is above the player
  end
end

def turnPlayerTowardsEvent(event)
  event_x = event.x
  event_y = event.y
  if $game_player.x < event_x
    $game_player.turn_right # Event is to the right of the player
  elsif $game_player.x > event_x
    $game_player.turn_left # Event is to the left of the player
  elsif $game_player.y < event_y
    $game_player.turn_down # Event is below the player
  elsif $game_player.y > event_y
    $game_player.turn_up # Event is above the player
  end
end

def displaySpriteWindowWithMessage(pif_sprite, message = "", x = 0, y = 0, z = 0)
  spriteLoader = BattleSpriteLoader.new
  sprite_bitmap = spriteLoader.load_pif_sprite_directly(pif_sprite)
  pictureWindow = PictureWindow.new(sprite_bitmap.bitmap)

  pictureWindow.opacity = 0
  pictureWindow.z = z
  pictureWindow.x = x
  pictureWindow.y = y
  pbMessage(message)
  pictureWindow.dispose
end

def select_any_pokemon()
  commands = []
  for dex_num in 1..NB_POKEMON
    species = getPokemon(dex_num)
    commands.push([dex_num - 1, species.real_name, species.id])
  end
  return pbChooseList(commands, 0, nil, 1)
end

SWITCH_SS_ANNE_DEPARTED = 88
SWITCH_SNORLAX_GONE_ROUTE_12 = 110
SWITCH_TELEPORT_NPC = 122
SWITCH_GOT_DIVE = 317
SWITCH_GOT_ROCK_CLIMB = 661
SWITCH_GOT_WATERFALL = 388

def fixMissedHMs()
  # Flash
  if $PokemonBag.pbQuantity(:HM08) < 1 && $PokemonGlobal.questRewardsObtained.include?(:HM08)
    pbReceiveItem(:HM08)
  end

  # Cut
  if $PokemonBag.pbQuantity(:HM01) < 1 && $game_switches[SWITCH_SS_ANNE_DEPARTED]
    pbReceiveItem(:HM01)
  end

  # Strength
  if $PokemonBag.pbQuantity(:HM04) < 1 && $game_switches[SWITCH_SNORLAX_GONE_ROUTE_12]
    pbReceiveItem(:HM04)
  end

  # Surf
  if $PokemonBag.pbQuantity(:HM03) < 1 && $game_self_switches[[107, 1, "A"]]
    pbReceiveItem(:HM03)
  end

  # Teleport
  if $PokemonBag.pbQuantity(:HM07) < 1 && $game_switches[SWITCH_TELEPORT_NPC]
    pbReceiveItem(:HM07)
  end

  # Fly
  if $PokemonBag.pbQuantity(:HM02) < 1 && $game_self_switches[[439, 1, "B"]]
    pbReceiveItem(:HM02)
  end

  # Waterfall
  if $PokemonBag.pbQuantity(:HM05) < 1 && $game_switches[SWITCH_GOT_WATERFALL]
    pbReceiveItem(:HM05)
  end

  # Dive
  if $PokemonBag.pbQuantity(:HM06) < 1 && $game_switches[SWITCH_GOT_DIVE]
    pbReceiveItem(:HM06)
  end

  # Rock Climb
  if $PokemonBag.pbQuantity(:HM10) < 1 && $game_switches[SWITCH_GOT_ROCK_CLIMB]
    pbReceiveItem(:HM10)
  end
end

def fixFinishedRocketQuests()
  fix_broken_TR_quests()

  var_tr_missions_cerulean = 288

  switch_tr_mission_cerulean_4 = 1116
  switch_tr_mission_celadon_1 = 1084
  switch_tr_mission_celadon_2 = 1086
  switch_tr_mission_celadon_3 = 1088
  switch_tr_mission_celadon_4 = 1110
  switch_pinkan_done = 1119

  nb_cerulean_missions = pbGet(var_tr_missions_cerulean)

  finishTRQuest("tr_cerulean_1", :SUCCESS, true) if nb_cerulean_missions >= 1 && !pbCompletedQuest?("tr_cerulean_1")
  echoln pbCompletedQuest?("tr_cerulean_1")
  finishTRQuest("tr_cerulean_2", :SUCCESS, true) if nb_cerulean_missions >= 2 && !pbCompletedQuest?("tr_cerulean_2")
  finishTRQuest("tr_cerulean_3", :SUCCESS, true) if nb_cerulean_missions >= 3 && !pbCompletedQuest?("tr_cerulean_3")
  finishTRQuest("tr_cerulean_4", :SUCCESS, true) if $game_switches[switch_tr_mission_cerulean_4] && !pbCompletedQuest?("tr_cerulean_4")

  finishTRQuest("tr_celadon_1", :SUCCESS, true) if $game_switches[switch_tr_mission_celadon_1] && !pbCompletedQuest?("tr_celadon_1")
  finishTRQuest("tr_celadon_2", :SUCCESS, true) if $game_switches[switch_tr_mission_celadon_2] && !pbCompletedQuest?("tr_celadon_2")
  finishTRQuest("tr_celadon_3", :SUCCESS, true) if $game_switches[switch_tr_mission_celadon_3] && !pbCompletedQuest?("tr_celadon_3")
  finishTRQuest("tr_celadon_4", :SUCCESS, true) if $game_switches[switch_tr_mission_celadon_4] && !pbCompletedQuest?("tr_celadon_4")

  finishTRQuest("tr_pinkan", :SUCCESS, true) if $game_switches[switch_pinkan_done] && !pbCompletedQuest?("tr_pinkan")
end

def fix_broken_TR_quests()
  for trainer_quest in $Trainer.quests
    if trainer_quest.id == 0 # tr quests were all set to ID 0 instead of their real ID in v 6.4.0
      for rocket_quest_id in TR_QUESTS.keys
        rocket_quest = TR_QUESTS[rocket_quest_id]
        next if !rocket_quest
        if trainer_quest.name == rocket_quest.name
          trainer_quest.id = rocket_quest_id
        end
      end
    end
  end
end

def failAllIncompleteRocketQuests()
  for trainer_quest in $Trainer.quests
    finishTRQuest("tr_cerulean_1", :FAILURE) if trainer_quest.id == "tr_cerulean_1" && !pbCompletedQuest?("tr_cerulean_1")
    finishTRQuest("tr_cerulean_2", :FAILURE) if trainer_quest.id == "tr_cerulean_2" && !pbCompletedQuest?("tr_cerulean_2")
    finishTRQuest("tr_cerulean_3", :FAILURE) if trainer_quest.id == "tr_cerulean_3" && !pbCompletedQuest?("tr_cerulean_3")
    finishTRQuest("tr_cerulean_4", :FAILURE) if trainer_quest.id == "tr_cerulean_4" && !pbCompletedQuest?("tr_cerulean_4")

    finishTRQuest("tr_celadon_1", :FAILURE) if trainer_quest.id == "tr_celadon_1" && !pbCompletedQuest?("tr_celadon_1")
    finishTRQuest("tr_celadon_2", :FAILURE) if trainer_quest.id == "tr_celadon_2" && !pbCompletedQuest?("tr_celadon_2")
    finishTRQuest("tr_celadon_3", :FAILURE) if trainer_quest.id == "tr_celadon_3" && !pbCompletedQuest?("tr_celadon_3")
    finishTRQuest("tr_celadon_4", :FAILURE) if trainer_quest.id == "tr_celadon_4" && !pbCompletedQuest?("tr_celadon_4")
  end
end

def qmarkMaskCheck()
  if $Trainer.seen_qmarks_sprite
    unless hasHat?(HAT_QMARKS)
      obtainHat(HAT_QMARKS)
      obtainClothes(CLOTHES_GLITCH)
    end
  end
end


def purchaseDyeKitMenu(hats_kit_price=0,clothes_kit_price=0)

  commands = []
  command_hats = "Hats Dye Kit ($#{hats_kit_price})"
  command_clothes = "Clothes Dye Kit ($#{clothes_kit_price})"
  command_cancel = "Cancel"

  commands << command_hats if !$PokemonBag.pbHasItem?(:HATSDYEKIT)
  commands << command_clothes if !$PokemonBag.pbHasItem?(:CLOTHESDYEKIT)
  commands << command_cancel

  if commands.length <= 1
    pbCallBub(2,@event_id)
    pbMessage("\\C[1]Dye Kits\\C[0] can be used to dye clothes all sorts of colours!")

    pbCallBub(2,@event_id)
    pbMessage("You can use them at any time when you change clothes.")
    return
  end
  pbCallBub(2,@event_id)
  pbMessage("\\GWelcome! Are you interested in dyeing your outfits different colours?")

  pbCallBub(2,@event_id)
  pbMessage("I make handy \\C[1]Dye Kits\\C[0] from my Smeargle's paint that can be used to dye your outfits any color you want!")

  pbCallBub(2,@event_id)
  pbMessage("\\GWhat's more is that it's reusable so you can go completely wild with it if you want! Are you interested?")

  choice = optionsMenu(commands,commands.length)
  case commands[choice]
  when command_hats
    if $Trainer.money < hats_kit_price
      pbCallBub(2,@event_id)
      pbMessage("Oh, you don't have enough money...")
      return
    end
    pbMessage("\\G\\PN purchased the dye kit.")
    $Trainer.money -= hats_kit_price
    pbSEPlay("SlotsCoin")
    Kernel.pbReceiveItem(:HATSDYEKIT)
    pbCallBub(2,@event_id)
    pbMessage("\\GHere you go! Have fun dyeing your hats!")
  when command_clothes
    if $Trainer.money < clothes_kit_price
      pbCallBub(2,@event_id)
      pbMessage("Oh, you don't have enough money...")
      return
    end
    pbMessage("\\G\\PN purchased the dye kit.")
    $Trainer.money -= clothes_kit_price
    pbSEPlay("SlotsCoin")
    Kernel.pbReceiveItem(:CLOTHESDYEKIT)
    pbCallBub(2,@event_id)
    pbMessage("\\GHere you go! Have fun dyeing your clothes!")
  end
  pbCallBub(2,@event_id)
  pbMessage("You can use \\C[1]Dye Kits\\C[0] at any time when you change clothes.")
end