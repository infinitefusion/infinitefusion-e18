def pbAddPokemonID(pokemon, level = nil, seeform = true, dontRandomize = false)
  return if !pokemon || !$Trainer
  dontRandomize = true if $game_switches[SWITCH_CHOOSING_STARTER] #when choosing starters

  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end

  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = Pokemon.new(pokemon, level, $Trainer)
  end
  #random species if randomized gift pokemon &  wild poke
  if $game_switches[SWITCH_RANDOM_GIFT_POKEMON] && $game_switches[SWITCH_RANDOM_WILD] && !dontRandomize
    tryRandomizeGiftPokemon(pokemon, dontRandomize)
  end

  speciesname = PBSpecies.getName(pokemon.species)
  Kernel.pbMessage(_INTL("{1} obtained {2}!\\se[itemlevel]\1", $Trainer.name, speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  return true
end

def pbAddPokemonID(pokemon_id, level = 1, see_form = true, skip_randomize = false)
  return false if !pokemon_id
  skip_randomize = true if $game_switches[SWITCH_CHOOSING_STARTER] #when choosing starters
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  if pokemon_id.is_a?(Integer) && level.is_a?(Integer)
    pokemon = Pokemon.new(pokemon_id, level)
    species_name = pokemon.speciesName
  end

  #random species if randomized gift pokemon &  wild poke
  if $game_switches[SWITCH_RANDOM_GIFT_POKEMON] && $game_switches[SWITCH_RANDOM_WILD] && !skip_randomize
    tryRandomizeGiftPokemon(pokemon, skip_randomize)
  end

  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $Trainer.name, species_name))
  pbNicknameAndStore(pokemon)
  $Trainer.pokedex.register(pokemon) if see_form
  return true
end

def pbHasSpecies?(species)
  if species.is_a?(String) || species.is_a?(Symbol)
    id = getID(PBSpecies, species)
  elsif species.is_a?(Pokemon)
    id = species.dexNum
  end
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.dexNum == id
  end
  return false
end

#ancienne methode qui est encore callée un peu partout dans les vieux scripts
def getID(pbspecies_unused, species)
  if species.is_a?(String)
    return nil
  elsif species.is_a?(Symbol)
    return GameData::Species.get(species).id_number
  elsif species.is_a?(Pokemon)
    id = species.dexNum
  end
end

#Check if the Pokemon can learn a TM
def CanLearnMove(pokemon, move)
  species = getID(PBSpecies, pokemon)
  return false if species <= 0
  data = load_data("Data/tm.dat")
  return false if !data[move]
  return data[move].any? { |item| item == species }
end

def pbPokemonIconFile(pokemon)
  bitmapFileName = pbCheckPokemonIconFiles(pokemon.species, pokemon.isEgg?)
  return bitmapFileName
end

def pbCheckPokemonIconFiles(speciesID, egg = false, dna = false)
  if egg
    bitmapFileName = sprintf("Graphics/Icons/iconEgg")
    return pbResolveBitmap(bitmapFileName)
  else
    bitmapFileName = _INTL("Graphics/Pokemon/Icons/{1}", speciesID)
    ret = pbResolveBitmap(bitmapFileName)
    return ret if ret
  end
  ret = pbResolveBitmap("Graphics/Icons/iconDNA.png")
  return ret if ret
  return pbResolveBitmap("Graphics/Icons/iconDNA.png")
end


def getPokemon(dexNum)
  if dexNum.is_a?(Integer)
    if dexNum > NB_POKEMON
      body_id = getBodyID(dexNum)
      head_id = getHeadID(dexNum, body_id)
      pokemon_id = getFusedPokemonIdFromDexNum(body_id, head_id)
    else
      pokemon_id = dexNum
    end
  else
    pokemon_id = dexNum
  end

  return GameData::Species.get(pokemon_id)
end

def getSpecies(dexnum)
  return getPokemon(dexnum.species) if dexnum.is_a?(Pokemon)
  return getPokemon(dexnum)
end

def getAbilityIndexFromID(abilityID, fusedPokemon)
  abilityList = fusedPokemon.getAbilityList
  for abilityArray in abilityList #ex: [:CHLOROPHYLL, 0]
    ability = abilityArray[0]
    index = abilityArray[1]
    return index if ability == abilityID
  end
  return 0
end


# dir_path = Settings::CUSTOM_BATTLERS_FOLDER_INDEXED
# indexFolders = Dir.entries(dir_path).select do |entry|
#   entry_number = entry.to_i
#   File.directory?(File.join(dir_path, entry)) && entry_number.between?(1, NB_POKEMON)
# end
# return nil if indexFolders.empty?
# # Loop until a non-empty folder is found
# selectedIndex = nil
# spritesList = []
# until selectedIndex && !spritesList.empty?
#   selectedIndex = indexFolders.sample
#   spritesList = Dir.entries(File.join(dir_path, selectedIndex)).select do |file|
#     File.file?(File.join(dir_path, selectedIndex, file))
#   end
# end
# selectedSprite = spritesList.sample
# return getPokemonSpeciesFromSprite(selectedSprite)
#end



def addShinyStarsToGraphicsArray(imageArray, xPos, yPos, shinyBody, shinyHead, debugShiny, srcx = nil, srcy = nil, width = nil, height = nil, showSecondStarUnder = false, showSecondStarAbove = false, showSecondStarAfter = false, centraliseStar = false)
  color = nil
  if !(shinyBody && shinyHead)
    if debugShiny
      imageArray.push(["Graphics/Pictures/shiny_debug", xPos, yPos, srcx, srcy, width, height, color])
    else
      imageArray.push(["Graphics/Pictures/shiny", xPos, yPos, srcx, srcy, width, height, color])
    end
  else
    # Centralize the first Star
    if centraliseStar
      if showSecondStarUnder
        yPos -= 8
      elsif showSecondStarAbove
        yPos += 8
      elsif showSecondStarAfter
        xPos -= 8
      else
        xPos += 8
      end
    end
    if debugShiny
      imageArray.push(["Graphics/Pictures/shiny_debug", xPos, yPos, srcx, srcy, width, height, color])
    else
      imageArray.push(["Graphics/Pictures/shiny", xPos, yPos, srcx, srcy, width, height, color])
    end
    if showSecondStarUnder
      yPos += 15
    elsif showSecondStarAbove
      yPos -= 15
    elsif showSecondStarAfter
      xPos += 15
    else
      xPos -= 15
    end
    if debugShiny
      imageArray.push(["Graphics/Pictures/shiny_debug", xPos, yPos, srcx, srcy, width, height, color])
    else
      imageArray.push(["Graphics/Pictures/shiny", xPos, yPos, srcx, srcy, width, height, color])
    end
  end
  # if onlyOutline
  #   imageArray.push(["Graphics/Pictures/shiny_black",xPos,yPos,srcx,srcy,width,height,color])
  # end

end

# def getRandomCustomFusion(returnRandomPokemonIfNoneFound = true, customPokeList = [], maxPoke = -1, recursionLimit = 3, maxBST = 300)
#   if customPokeList.length == 0
#     customPokeList = getCustomSpeciesList()
#   end
#   randPoke = []
#   if customPokeList.length >= 5000
#     chosen = false
#     i = 0 #loop pas plus que 3 fois pour pas lag
#     while chosen == false
#       fusedPoke = customPokeList[rand(customPokeList.length)]
#       if (i >= recursionLimit) || maxPoke == -1
#         return fusedPoke
#       end
#     end
#   else
#     if returnRandomPokemonIfNoneFound
#       return rand(maxPoke) + 1
#     end
#   end
#
#   return randPoke
# end

def getAllNonLegendaryPokemon()
  list = []
  for i in 1..143
    list.push(i)
  end
  for i in 147..149
    list.push(i)
  end
  for i in 152..242
    list.push(i)
  end
  list.push(246)
  list.push(247)
  list.push(248)
  for i in 252..314
    list.push(i)
  end
  for i in 316..339
    list.push(i)
  end
  for i in 352..377
    list.push(i)
  end
  for i in 382..420
    list.push(i)
  end
  return list
end

def getPokemonEggGroups(species)
  return GameData::Species.get(species).egg_groups
end

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

def pbGetSelfSwitch(eventId, switch)
  return $game_self_switches[[@map_id, eventId, switch]]
end

def getAllNonLegendaryPokemon()
  list = []
  for i in 1..143
    list.push(i)
  end
  for i in 147..149
    list.push(i)
  end
  for i in 152..242
    list.push(i)
  end
  list.push(246)
  list.push(247)
  list.push(248)
  for i in 252..314
    list.push(i)
  end
  for i in 316..339
    list.push(i)
  end
  for i in 352..377
    list.push(i)
  end
  for i in 382..420
    list.push(i)
  end
  return list
end

def generateSimpleTrainerParty(teamSpecies, level)
  team = []
  for species in teamSpecies
    poke = Pokemon.new(species, level)
    team << poke
  end
  return team
end

def isInKantoGeneration(dexNumber)
  return dexNumber <= 151
end

def isKantoPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  return isInKantoGeneration(dexNum) || isInKantoGeneration(head_dex) || isInKantoGeneration(body_dex)
end

def isInJohtoGeneration(dexNumber)
  return dexNumber > 151 && dexNumber <= 251
end

def isJohtoPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  return isInJohtoGeneration(dexNum) || isInJohtoGeneration(head_dex) || isInJohtoGeneration(body_dex)
end

def isAlolaPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  list = [
    370, 373, 430, 431, 432, 433, 450, 451, 452,
    453, 454, 455, 459, 460, 463, 464, 465, 469, 470,
    471, 472, 473, 474, 475, 476, 477, 498, 499,
  ]
  return list.include?(dexNum) || list.include?(head_dex) || list.include?(body_dex)
end

def isKalosPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  list =
    [327, 328, 329, 339, 371, 372, 417, 418,
     425, 426, 438, 439, 440, 441, 444, 445, 446,
     456, 461, 462, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487,
     489, 490, 491, 492, 500,

    ]
  return list.include?(dexNum) || list.include?(head_dex) || list.include?(body_dex)
end

def isUnovaPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  list =
    [
      330, 331, 337, 338, 348, 349, 350, 351, 359, 360, 361,
      362, 363, 364, 365, 366, 367, 368, 369, 374, 375, 376, 377,
      397, 398, 399, 406, 407, 408, 409, 410, 411, 412, 413, 414,
      415, 416, 419, 420,
      422, 423, 424, 434, 345,
      466, 467, 494, 493,
    ]
  return list.include?(dexNum) || list.include?(head_dex) || list.include?(body_dex)
end

def isSinnohPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  list =
    [254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265,
     266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 288, 294,
     295, 296, 297, 298, 299, 305, 306, 307, 308, 315, 316, 317,
     318, 319, 320, 321, 322, 323, 324, 326, 332, 343, 344, 345,
     346, 347, 352, 353, 354, 358, 383, 384, 388, 389, 400, 402,
     403, 429, 468]

  return list.include?(dexNum) || list.include?(head_dex) || list.include?(body_dex)
end

def isHoennPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  list = [252, 253, 276, 277, 278, 279, 280, 281, 282, 283, 284,
          285, 286, 287, 289, 290, 291, 292, 293, 300, 301, 302, 303,
          304, 309, 310, 311, 312, 313, 314, 333, 334, 335, 336, 340,
          341, 342, 355, 356, 357, 378, 379, 380, 381, 382, 385, 386, 387, 390,
          391, 392, 393, 394, 395, 396, 401, 404, 405, 421, 427, 428, 436,
          437, 442, 443, 447, 448, 449, 457, 458, 488, 495, 496, 497, 501]
  return list.include?(dexNum) || list.include?(head_dex) || list.include?(body_dex)
end

def pbBitmap(path)
  if !pbResolveBitmap(path).nil?
    bmp = RPG::Cache.load_bitmap_path(path)
    bmp.storedPath = path
  else
    p "Image located at '#{path}' was not found!" if $DEBUG
    bmp = Bitmap.new(1, 1)
  end
  return bmp
end



def reverseFusionSpecies(species)
  dexId = getDexNumberForSpecies(species)
  return species if dexId <= NB_POKEMON
  return species if dexId > (NB_POKEMON * NB_POKEMON) + NB_POKEMON
  body = getBasePokemonID(dexId, true)
  head = getBasePokemonID(dexId, false)
  newspecies = (head) * NB_POKEMON + body
  return getPokemon(newspecies)
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


def get_default_moves_at_level(species, level)
  moveset = GameData::Species.get(species).moves
  knowable_moves = []
  moveset.each { |m| knowable_moves.push(m[1]) if m[0] <= level }
  # Remove duplicates (retaining the latest copy of each move)
  knowable_moves = knowable_moves.reverse
  knowable_moves |= []
  knowable_moves = knowable_moves.reverse
  # Add all moves
  moves = []
  first_move_index = knowable_moves.length - MAX_MOVES
  first_move_index = 0 if first_move_index < 0
  for i in first_move_index...knowable_moves.length
    #moves.push(Pokemon::Move.new(knowable_moves[i]))
    moves << knowable_moves[i]
  end
  return moves
end

def find_newer_available_version
  latest_Version = fetch_latest_game_version
  return nil if !latest_Version
  return nil if is_higher_version(Settings::GAME_VERSION_NUMBER, latest_Version)
  return latest_Version
end

def is_higher_version(gameVersion, latestVersion)
  gameVersion_parts = gameVersion.split('.').map(&:to_i)
  latestVersion_parts = latestVersion.split('.').map(&:to_i)

  # Compare each part of the version numbers from left to right
  gameVersion_parts.each_with_index do |part, i|
    return true if (latestVersion_parts[i].nil? || part > latestVersion_parts[i])
    return false if part < latestVersion_parts[i]
  end
  return latestVersion_parts.length <= gameVersion_parts.length
end

def get_current_game_difficulty
  return :EASY if $game_switches[SWITCH_GAME_DIFFICULTY_EASY]
  return :HARD if $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
  return :NORMAL
end

def get_difficulty_text
  if $game_switches[SWITCH_GAME_DIFFICULTY_EASY]
    return "Easy"
  elsif $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
    return "Hard"
  else
    return "Normal"
  end
end

def pokemonExceedsLevelCap(pokemon)
  return false if $Trainer.badge_count >= Settings::NB_BADGES
  current_max_level = Settings::LEVEL_CAPS[$Trainer.badge_count]
  current_max_level *= Settings::HARD_MODE_LEVEL_MODIFIER if $game_switches[SWITCH_GAME_DIFFICULTY_HARD]
  return pokemon.level >= current_max_level
end

def listPokemonIDs()
  for id in 0..NB_POKEMON
    pokemon = GameData::Species.get(id).species
    echoln id.to_s + ": " + "\"" + pokemon.to_s + "\"" + ", "
  end
end

def getLatestSpritepackDate()
  return Time.new(Settings::NEWEST_SPRITEPACK_YEAR, Settings::NEWEST_SPRITEPACK_MONTH)
end

def new_spritepack_was_released()
  current_spritepack_date = $PokemonGlobal.current_spritepack_date
  latest_spritepack_date = getLatestSpritepackDate()
  if !current_spritepack_date || (current_spritepack_date < latest_spritepack_date)
    $PokemonGlobal.current_spritepack_date = latest_spritepack_date
    return true
  end
  return false
end