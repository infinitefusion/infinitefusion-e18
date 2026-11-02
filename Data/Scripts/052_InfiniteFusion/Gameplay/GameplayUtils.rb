# chosen pokemon is returned with this format:
#[[boxID, boxPosition],pokemon]

def pbChoosePokemonPC(positionVariableNumber, pokemonVarNumber, ableProc = nil)
  chosen = nil
  pokemon = nil

  pbFadeOutIn {
    scene = PokemonStorageScene.new
    screen = PokemonStorageScreen.new(scene, $PokemonStorage)
    screen.setFilter(ableProc) if ableProc
    chosen = screen.choosePokemon
    pokemon = $PokemonStorage[chosen[0]][chosen[1]] if chosen
    scene.pbCloseBox
  }
  pbSet(positionVariableNumber, chosen)
  pbSet(pokemonVarNumber, pokemon)
end

def npcTrade(npcPokemon_species, nickname, trainerName, playerPokemonProc)
  chosen_pokemon = pbChoosePokemon(1, 2, playerPokemonProc)
  chosen_position = pbGet(1)
  return nil if chosen_position <= -1
  pbStartTrade(chosen_position, npcPokemon_species, nickname, trainerName, 0)
end

def floorHole(mapBelow, frames_for_fall = 8, bikeOnly = true)
  return unless mapBelow
  return if $game_player.moving?

  event = this_event()
  event.instance_variable_set(:@idle_frames, 0) unless event.instance_variable_defined?(:@idle_frames)
  event.instance_variable_set(:@idle_frames, event.instance_variable_get(:@idle_frames) + 1)

  frames_for_fall = 0 if bikeOnly && !$PokemonGlobal.bicycle
  pbSEPlay("bw_fall")
  if event.instance_variable_get(:@idle_frames) >= frames_for_fall
    event.instance_variable_set(:@idle_frames, 0)

    # Find a passable landing tile on the target map
    target_x, target_y = findPassableLanding(mapBelow, $game_player.x, $game_player.y)
    return unless target_x

    pbSEPlay("Slash")
    playAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y)
    event.direction_fix = false
    event.turn_left

    pbWait(4)
    playerFall(mapBelow, target_x, target_y)
    pbWait(8)
  end
end

def floorHoleSameMap(x_offset,y_offset, frames_for_fall = 8, bikeOnly = true, relative_to_player=true,landing_animation = Settings::EXCLAMATION_ANIMATION_ID)
  return unless x_offset && y_offset
  if relative_to_player
    x = $game_player.x+x_offset
    y = $game_player.y+y_offset
  else
    x = x_offset
    y = y_offset
  end
  return if $game_player.moving?

  event = this_event()
  event.instance_variable_set(:@idle_frames, 0) unless event.instance_variable_defined?(:@idle_frames)
  event.instance_variable_set(:@idle_frames, event.instance_variable_get(:@idle_frames) + 1)

  frames_for_fall = 0 if bikeOnly && !$PokemonGlobal.bicycle
  if event.instance_variable_get(:@idle_frames) >= frames_for_fall
    event.instance_variable_set(:@idle_frames, 0)

    # Find a passable landing tile on the target map
    target_x, target_y = findPassableLanding($game_map.map_id, x, y)
    return unless target_x

    pbSEPlay("Slash")
    playAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y)
    event.direction_fix = false
    event.turn_left

    pbWait(4)
    playerFall($game_map.map_id, target_x, target_y, landing_animation)
    event.turn_down
    event.direction_fix = true
    pbWait(8)
  end
end




# Loads the target map and spirals outward from (start_x, start_y)
# until a passable tile is found. Returns [x, y] or [nil, nil].
def findPassableLanding(map_id, start_x, start_y, max_radius = 10)
  # Load the target map data without switching to it
  map_data = load_data(sprintf("Data/Map%03d.rxdata", map_id))
  target_map = Game_Map.new
  target_map.setup(map_id)

  # Check exact position first
  if target_map.passableStrict?(start_x, start_y, 2)
    return [start_x, start_y]
  end

  # Spiral outward: check ring by ring
  1.upto(max_radius) do |radius|
    (-radius..radius).each do |dx|
      (-radius..radius).each do |dy|
        next unless dx.abs == radius || dy.abs == radius # Only check the outer ring
        x = start_x + dx
        y = start_y + dy
        next unless target_map.valid?(x, y)
        return [x, y] if target_map.passableStrict?(x, y, 2)
      end
    end
  end

  return [nil, nil]
end

BASIC_SHIRTS = {
  :GRASS => "basicgrass",
  :FIRE => "basicfire",
  :WATER => "basicwater",
  :BUG => "basicbug",
  :NORMAL => "basicnormal",
  :ROCK => "basicrock",
  :GROUND => "basicground",
  :STEEL => "basicsteel",
  :PSYCHIC => "basicpsychic",
  :POISON => "basicpoison",
  :ICE => "basicice",
  :GHOST => "basicghost",
  :FLYING => "basicflying",
  :FIGHTING => "basicfight",
  :FAIRY => "basicfairy",
  :ELECTRIC => "basicelectric",
  :DRAGON => "basicdragon",
  :DARK => "basicdark",
}

def basicTypeShirts(event_id, nb_owned_for_reward = 5)
  GameData::Type.each do |type|
    nb_owned = 0
    GameData::Species.each do |species|
      if $Trainer.pokedex.owned?(species.species) && species.hasType?(type)
        nb_owned += 1
      end
    end
    if nb_owned >= nb_owned_for_reward
      clothes_reward = BASIC_SHIRTS[type.id]
      unless hasClothes?(clothes_reward)
        pbCallBub(2, event_id)
        pbMessage(_INTL("Let's see your Pokédex..."))
        pbCallBub(2, event_id)
        pbMessage(_INTL("Oh! You've caught {1} \\C[1]{2}-type\\C[0] Pokémon! You must be a huge {2} fan!", nb_owned, type.name))
        pbCallBub(2, event_id)
        pbMessage(_INTL("I have just the shirt for you. Here you go!"))
        obtainClothes(clothes_reward)
        return true
      end
    end
  end
  return false
end

def timeTrialStart
  $game_temp.time_trial_bumps = 0
  pbSet(VAR_TIME_TRIAL_START, Time.now)
end

def timeTrialStop
  currentTime = Time.now
  startTime = pbGet(VAR_TIME_TRIAL_START)
  elapsed = (currentTime - startTime).to_f.truncate(3)
  pbSet(VAR_TIME_TRIAL_SECONDS, elapsed)
end

def timeTrialApplyBumpsPenalty
  nb_bumps = $game_temp.time_trial_bumps
  current_time = pbGet(VAR_TIME_TRIAL_SECONDS)
  current_time += (nb_bumps * 0.5)
  pbSet(VAR_TIME_TRIAL_SECONDS, current_time.truncate(3))
end

def get_current_town_map_location
  map_data = pbLoadTownMapData
  all_maps = map_data[0][2]
  map_id_position = find_position_for_map(all_maps, $game_map.map_id)
  if map_id_position
    return $game_map.map_id
  else
    return $Trainer.last_visited_town_map_location
  end
end

def getNaturalPokemonList()
  list = []
  if Settings::KANTO
    for i in 1..501
      pokemon_species = GameData::Species.get(i)
      list << pokemon_species.species
    end
  end

  if Settings::HOENN
    # Todo: Update and double check this!!!
    return [
      :PIDGEY, :PIDGEOTTO, :PIDGEOT, :RATTATA, :RATICATE, :SPEAROW, :FEAROW, :PIKACHU, :RAICHU, :CLEFAIRY, :CLEFABLE, :ZUBAT, :GOLBAT, :ODDISH, :GLOOM, :VILEPLUME, :PARAS, :PARASECT, :MEOWTH, :PERSIAN, :POLIWAG, :POLIWHIRL,
      :POLIWRATH, :ABRA, :KADABRA, :ALAKAZAM, :MACHOP, :MACHOKE, :MACHAMP, :GEODUDE, :GRAVELER, :GOLEM, :PONYTA, :RAPIDASH, :MAGNEMITE, :MAGNETON, :DODUO, :DODRIO, :GRIMER, :MUK, :KRABBY, :KINGLER, :VOLTORB, :ELECTRODE,
      :HITMONLEE, :HITMONCHAN, :HORSEA, :SEADRA, :GOLDEEN, :SEAKING, :STARYU, :STARMIE, :MAGIKARP, :GYARADOS, :DITTO, :EEVEE, :VAPOREON, :JOLTEON, :FLAREON, :PORYGON, :SNORLAX, :HOOTHOOT, :NOCTOWL, :CROBAT, :PICHU, :CLEFFA,
      :IGGLYBUFF, :MAREEP, :FLAAFFY, :AMPHAROS, :BELLOSSOM, :MARILL, :AZUMARILL, :HOPPIP, :SKIPLOOM, :JUMPLUFF, :AIPOM, :SUNKERN, :SUNFLORA, :ESPEON, :UMBREON, :MURKROW, :MISDREAVUS, :PINECO, :FORRETRESS, :SHUCKLE,
      :TEDDIURSA, :URSARING, :SLUGMA, :MAGCARGO, :REMORAID, :OCTILLERY, :MANTINE, :HOUNDOUR, :HOUNDOOM, :SMEARGLE, :TYROGUE, :HITMONTOP, :AZURILL, :WYNAUT, :AMBIPOM, :MISMAGIUS, :HONCHKROW, :MUNCHLAX, :MANTYKE,
      :LEAFEON, :GLACEON, :TREECKO, :GROVYLE, :SCEPTILE, :TORCHIC, :COMBUSKEN, :BLAZIKEN, :MUDKIP, :MARSHTOMP, :SWAMPERT, :RALTS, :KIRLIA, :GARDEVOIR, :GALLADE, :SHEDINJA, :KECLEON, :MAWILE, :SLAKING, :NOSEPASS,
      :LUXRAY, :AGGRON, :KLINKLANG, :ZOROARK, :SYLVEON, :ROSERADE, :DRIFBLIM, :NINJASK, :WHIMSICOTT, :TALONFLAME, :NINCADA, :RIOLU, :SLAKOTH, :VIGOROTH, :WAILMER, :SHINX, :LUXIO, :ARON, :LAIRON, :KLINK, :KLANG, :ZORUA,
      :BUDEW, :ROSELIA, :DRIFLOON, :SHROOMISH, :COTTONEE, :FLETCHLING, :FLETCHINDER, :SABLEYE, :VENIPEDE, :WHIRLIPEDE, :SCOLIPEDE, :ORICORIO_1, :ORICORIO_2, :ORICORIO_3, :ORICORIO_4, :TRUBBISH, :GARBODOR, :CARVANHA, :SHARPEDO,
      :PHANTUMP, :TREVENANT, :SANDYGAST, :PALOSSAND, :FOMANTIS, :LURANTIS, :CARBINK, :SCRAGGY, :SCRAFTY, :LOTAD, :LOMBRE, :LUDICOLO, :LUVDISC, :POOCHYENA, :MIGHTYENA, :ZIGZAGOON, :LINOONE, :WURMPLE, :SILCOON, :BEAUTIFLY,
      :CASCOON, :DUSTOX, :SEEDOT, :NUZLEAF, :SHIFTRY, :TAILLOW, :SWELLOW, :WINGULL, :PELIPPER, :SURSKIT, :MASQUERAIN, :WHISMUR, :LOUDRED, :EXPLOUD, :MAKUHITA, :HARIYAMA, :SKITTY, :DELCATTY, :MEDITITE, :MEDICHAM,
      :ELECTRIKE, :MANECTRIC, :PLUSLE, :MINUN, :VOLBEAT, :ILLUMISE, :GULPIN, :SWALOT, :NUMEL, :CAMERUPT, :SPOINK, :GRUMPIG, :CORPHISH, :CRAWDAUNT, :CHINGLING, :CHIMECHO, :SPHEAL, :SEALEO, :WALREIN, :CLAMPERL, :GOREBYSS, :HUNTAIL,
      :WOOBAT, :SWOOBAT, :TYNAMO, :EELEKTRIK, :EELEKTROSS, :SKRELP, :DRAGALGE
    ]
  end
  return list
end

def pokedex_check
  missing = []
  natural_pokemon_list = getNaturalPokemonList
  natural_pokemon_list.each do |species|
    unless $Trainer.owned?(species)
      missing.push(species)
    end
  end
  return missing
end

def replace_water_autotile(target_base_id = 240)
  map = $MapFactory.getMap($game_map.map_id)
  tiles_per_autotile = TilemapRenderer::TILES_PER_AUTOTILE rescue 48

  for x in 0..map.width - 1
    for y in 0..map.height - 1
      for z in [2, 1, 0]
        tile_id = map.data[x, y, z]
        next unless tile_id && tile_id > 0

        terrain_tag = GameData::TerrainTag.try_get(map.terrain_tags[tile_id]) if map.terrain_tags
        if terrain_tag && terrain_tag.can_surf
          shape_index = tile_id % tiles_per_autotile
          new_tile_id = target_base_id + shape_index
          if map.data[x, y, z] != new_tile_id
            echoln "(#{x},#{y},#{z}): #{tile_id} -> #{new_tile_id}"
            map.set_tile(x, y, z, new_tile_id)
          end
        end
      end
    end
  end
end


#checks each of the events passed as ID to see if a berry of a specific type has been planted
# @return
# -1 : Berry not found
# 0 : Berry found, not grown
# 1 : Berry found, fully grown
def check_event_for_berries(wanted_berry_type, variable_result,variable_quantity, events_list = [])
  quantity_found = 0
  found_berry= false
  found_full_grown = false
  events_list.each do |event_id|
    berry_data = $PokemonGlobal.eventvars[[$game_map.map_id, event_id]]
    if berry_data
      berry_type = berry_data[1]
      growth_stage= berry_data[0]
      if berry_type == wanted_berry_type
        found_berry = true
        quantity_found+=1
        if growth_stage == 5
          found_full_grown = true
        end
      end
    end
  end
  pbSet(variable_quantity, quantity_found)
  if found_full_grown
    pbSet(variable_result, 1) if found_full_grown
  elsif found_berry
    pbSet(variable_result, 0) if found_berry
  else
    pbSet(variable_result, -1)
  end
  return found_berry
end

def berryMasterRandomBerry(rare_berries_only=false)
  rare_berries = [    :GREPABERRY, :HONDEWBERRY, :KELPSYBERRY, :MAGOSTBERRY, :NOMELBERRY, :POMEGBERRY,
                      :QUALOTBERRY, :RABUTABERRY, :TAMATOBERRY,

                      :SPELONBERRY, :PAMTREBERRY, :WATMELBERRY, :DURINBERRY, :BELUEBERRY, # given by the wife in the originals
  ]
  normal_berries = [    :ASPEARBERRY, :CHERIBERRY, :CHESTOBERRY, :LEPPABERRY, :LUMBERRY, :ORANBERRY,
                        :PECHABERRY, :PERSIMBERRY, :RAWSTBERRY, :SITRUSBERRY]

  berries_list = rare_berries_only ? rare_berries : (rare_berries + normal_berries)
  berry = berries_list.sample
  pbReceiveItem(berry)
end

def last_map_position_smell_npc
  last_map = $Trainer.last_visited_town_map_location
  case last_map
  when MAP_MT_CHIMNEY
  when MAP_ROUTE_112
  when MAP_ROUTE_112_NORTH
  when MAP_JAGGED_PASS
    pbCallBub(2,@event_id)
    pbMessage(_INTL("Sniff...\nUm... You, uh... smell singed."))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("Were you at a volcano or something?"))
  when MAP_DESERT
  when MAP_ROUTE_113
  when MAP_FALLARBOR
    pbCallBub(2,@event_id)
    pbMessage(_INTL("Sniff...\nUm... You, uh... smell like dust."))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("Were you in a desert or something?"))
  when MAP_RUSTURF_TUNNEL
  when MAP_SHOAL_CAVE
  when MAP_METEOR_FALLS
  when MAP_DESERT_UNDERPASS
  when MAP_GRANITE_CAVE
    pbCallBub(2,@event_id)
        pbMessage(_INTL("Sniff...\nUm... You, uh... smell damp."))
        pbCallBub(2,@event_id)
        pbMessage(_INTL("Were you in a cave or something?"))
  when MAP_RUSTBORO
      pbCallBub(2,@event_id)
      pbMessage(_INTL("Sniff...\nUm... You, uh... smell like rust."))
      pbCallBub(2,@event_id)
      pbMessage(_INTL("Were you in an old city or something?"))
  when MAP_MAUVILLE
    pbCallBub(2,@event_id)
    pbMessage(_INTL("Sniff...\nUm... You, uh... smell like ozone."))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("Were you near a power plant or something?"))
  when MAP_DEWFORD
  when MAP_SLATEPORT
  when MAP_MOSSDEEP
  when MAP_SOOTOPOLIS
  when MAP_PACIFIDLOG
  when MAP_AQUA_CAMP
  when MAP_ROUTE_104_SOUTH
  when MAP_ROUTE_105
  when MAP_ROUTE_106
  when MAP_ROUTE_107
  when MAP_ROUTE_108
  when MAP_ROUTE_109
    pbCallBub(2,@event_id)
    pbMessage(_INTL("Sniff...\nUm... You, uh... smell like brine."))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("Were you at the beach or something?"))
  else
    pbCallBub(2,@event_id)
    pbMessage(_INTL("Sniff...\nUm... You, uh... smell like the rainforest."))
    pbCallBub(2,@event_id)
    pbMessage(_INTL("Ah, the smell of home!"))
  end
end
#
DIRECTION_ARROWS = {
  left:  "←",
  right: "→",
  down:  "↓",
  up:    "↑"
}
def direction_sign(**directions)
  lines = []
  directions.each do |key, label|
    arrow = DIRECTION_ARROWS[key]
    next if arrow.nil? || label.nil?
    lines << "#{arrow} #{label}"
  end
  pbMessage(lines.join("\n"))
end


# map = $MapFactory.getMap($game_map.map_id)
#
# erased_tiles = []
# for tile in tiles_to_cut
#   for map_layer in [2, 1, 0]
#     tile_id = map.data[tile[1], tile[2], map_layer]
#     cut_tile_id = tile_id -8
#     next if tile_id == nil
#     tile_tag = GameData::TerrainTag.try_get(map.terrain_tags[tile_id])
#     next unless tile_tag.battle_environment == :Grass
#     map.erase_tile(tile[1], tile[2], map_layer)
#     unless tile_tag.id == :CutGrass
#       map.set_tile(tile[1], tile[2], map_layer,cut_tile_id)
#     end
#     erased_tiles << tile
#   end
# end
# unless erased_tiles.empty?
#   pbSEPlay("Cut", 80)
#   $scene.spriteset.addUserAnimation(Settings::CUT_TREE_ANIMATION_ID, $game_player.x, $game_player.y, false, 1)
# end