def pbAddPokemonID(pokemon_id, level = 1, see_form = true, skip_randomize = false)
  return false if !pokemon_id
  skip_randomize = true if $game_switches[SWITCH_CHOOSING_STARTER] # when choosing starters
  skip_randomize = true if $game_switches[SWITCH_DONT_RANDOMIZE]
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  if pokemon_id.is_a?(Integer) && level.is_a?(Integer)
    pokemon = Pokemon.new(pokemon_id, level)
    species_name = pokemon.speciesName
  end

  # random species if randomized gift pokemon &  wild poke
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

def getID(pbspecies_unused, species)
  if species.is_a?(String)
    return nil
  elsif species.is_a?(Symbol)
    return GameData::Species.get(species).id_number
  elsif species.is_a?(Pokemon)
    id = species.dexNum
  end
end

# Check if the Pokemon can learn a TM
def CanLearnMove(pokemon, move)
  species = getID(PBSpecies, pokemon)
  return false if species <= 0
  data = load_data("Data/tm.dat")
  return false if !data[move]
  return data[move].any? { |item| item == species }
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

def getPokemonEggGroups(species)
  return GameData::Species.get(species).egg_groups
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
     489, 490, 491, 492, 500, 571, 572,

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
      422, 423, 424, 434, 435,
      466, 467, 494, 493,
      566, 567, 568, 569,570,
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
     403, 429, 468, 573, 574, 575, 576]

  return list.include?(dexNum) || list.include?(head_dex) || list.include?(body_dex)
end

def isHoennPokemon(species)
  dexNum = getDexNumberForSpecies(species)
  poke = getPokemon(species)
  head_dex = getDexNumberForSpecies(poke.get_head_species())
  body_dex = getDexNumberForSpecies(poke.get_body_species())
  list = [252, 253, 276, 277, 278, 279, 280, 281, 282, 283, 284,
          285, 286, 287, 289, 290, 291, 292, 293, 300, 301, 302, 303,
          304, 309, 310, 311, 312, 313, 314, 325, 333, 334, 335, 336, 340,
          341, 342, 355, 356, 357, 378, 379, 380, 381, 382, 385, 386,
          387, 390, 391, 392, 393, 394, 395, 396, 401, 404, 405, 421,
          427, 428, 436, 437, 442, 443, 447, 448, 449, 457, 458, 488,
          495, 496, 497, 501, 502, 503, 504, 505, 506, 507, 508, 509,
          510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521,
          522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533,
          534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545,
          546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557,
          558, 559, 560, 561, 562, 563, 564, 565
  ]
  return list.include?(dexNum) || list.include?(head_dex) || list.include?(body_dex)
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

def listPokemonIDs()
  for id in 0..NB_POKEMON
    pokemon = GameData::Species.get(id).species
    echoln id.to_s + ": " + "\"" + pokemon.to_s + "\"" + ", "
  end
end

#IMPORTANT
#La méthode   def pbCheckEvolution(pokemon,item=0)
#dans PokemonFusion (class PokemonFusionScene)
#a été modifiée et pour une raison ou une autre ca marche
#pas quand on la copie ici.
#Donc NE PAS OUBLIER DE LE COPIER AVEC


def isPartPokemon(src, target)
  return Kernel.isPartPokemon(src, target)
end
#in: pokemon number
def Kernel.isPartPokemon(src, target)

  src = getDexNumberForSpecies(src)
  target = getDexNumberForSpecies(target)
  return true if src == target
  return false if src <= NB_POKEMON
  bod = getBasePokemonID(src, true)
  head = getBasePokemonID(src, false)
  return bod == target || head == target
end

##EDITED HERE
#Retourne le pokemon de base
#param1 = int
#param2 = true pour body, false pour head
#return int du pokemon de base
def getBasePokemonID(pokemon, body = true)
  if pokemon.is_a?(Symbol)
    dex_number = GameData::Species.get(pokemon).id_number
    pokemon = dex_number
  end
  return nil if pokemon <= 0
  return nil if pokemon >= Settings::ZAPMOLCUNO_NB

  # cname = getConstantName(PBSpecies, pokemon) rescue nil
  cname = GameData::Species.get(pokemon).id.to_s
  return pokemon if pokemon <= NB_POKEMON
  return pokemon if cname == nil

  arr = cname.split(/[B,H]/)

  bod = arr[1]
  head = arr[2]

  return bod.to_i if body
  return head.to_i
end

def getGenericPokemonCryText(dex_number)
  return unless dex_number.is_a?(Integer)
  case dex_number
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

def setPokemonMoves(pokemon, move_ids = [])
  moves = []
  move_ids.each { |move_id|
    moves << Pokemon::Move.new(move_id)
  }
  pokemon.moves = moves
end

def changeSpeciesSpecific(pokemon, newSpecies)
  pokemon.species = newSpecies
  $Trainer.pokedex.set_seen(newSpecies)
  $Trainer.pokedex.set_owned(newSpecies)
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


def playCry(pokemonSpeciesSymbol)
  species = GameData::Species.get(pokemonSpeciesSymbol).species
  GameData::Species.play_cry_from_species(species)
end

def getHiddenPowerName(pokemon)
  hiddenpower = pbHiddenPower(pokemon)
  hiddenPowerType = hiddenpower[0]

  echoln hiddenPowerType
  if Settings::TRIPLE_TYPES.include?(hiddenPowerType)
    return _INTL("Neutral")
  end
  return PBTypes.getName(hiddenPowerType)
end

def has_species_or_fusion?(species, form = -1)
  return $Trainer.pokemon_party.any? { |p| p && p.isSpecies?(species) || p.isFusionOf(species) }
end


def delete_party_pokemon_multi(indexes=[],safe=true)
  indexes.sort.reverse_each do |i|
    echoln "Deleting #{$Trainer.party[i].name} (index #{i})"
    if safe
      $Trainer.remove_pokemon_at_index(i)
    else
      #Doesn't check if the player has at least 1 pokemon left
      $Trainer.party.delete_at(i)
    end
  end
end

def format_pokemon_names(species_list=[])
  names_list = []
  species_list.each do |species|
    species_data = GameData::Species.get(species)
    names_list << species_data.name
  end
  return names_list.join(", ")
end