LEGENDARIES_LIST = [:ARTICUNO, :ZAPDOS, :MOLTRES, :MEWTWO, :MEW,
                    :ENTEI, :RAIKOU, :SUICUNE, :HOOH, :LUGIA, :CELEBI,
                    :GROUDON, :KYOGRE, :RAYQUAZA, :DEOXYS, :JIRACHI, :LATIAS, :LATIOS,
                    :REGIGIGAS, :DIALGA, :PALKIA, :GIRATINA, :DARKRAI, :CRESSELIA, :ARCEUS,
                    :GENESECT, :RESHIRAM, :ZEKROM, :KYUREM, :MELOETTA,
                    :NECROZMA]

class PokemonGlobalMetadata
  attr_accessor :psuedoHash
  attr_accessor :psuedoBSTHash
  attr_accessor :randomTrainersHash
  attr_accessor :randomGymTrainersHash
  attr_accessor :randomItemsHash
  attr_accessor :randomTMsHash

  alias random_init initialize

  def initialize
    random_init
    @randomGymTrainersHash = nil
    @psuedoHash = nil
    @psuedoBSTHash = nil
    @randomItemsHash = nil
    @randomTMsHash = nil

  end
end

#pense pas que c'est utilisé mais bon...
def get_pokemon_list(include_fusions = false)
  #Create array of all pokemon dex numbers
  pokeArray = []

  monLimit = include_fusions ? PBSpecies.maxValue : NB_POKEMON - 1
  for i in 1..monLimit
    pokeArray.push(i)
  end
  #randomize hash
  return pokeArray
end

def get_randomized_bst_hash(poke_list, bst_range, show_progress = true)
  bst_hash = Hash.new
  for i in 1..NB_POKEMON - 1
    show_shuffle_progress(i) if show_progress
    baseStats = getBaseStatsFormattedForRandomizer(i)
    statsTotal = getStatsTotal(baseStats)

    targetStats_max = statsTotal + bst_range
    targetStats_min = statsTotal - bst_range
    max_bst_allowed = targetStats_max
    min_bst_allowed = targetStats_min
    #if a match, add to hash, remove from array, and cycle to next poke in dex

    #only randomize legendaries to legendaries if Allow Legendaries not enabled
    #

    #
    # if !$game_switches[SWITCH_RANDOM_WILD_LEGENDARIES]
    #   current_species = GameData::Species.get(i).id
    #   random_poke_species = GameData::Species.get(random_poke).id
    #   next if !legendaryOk(current_species,random_poke_species,$game_switches[SWITCH_RANDOM_WILD_LEGENDARIES])
    #
    #   if !is_legendary(current_species)
    #     next if is_legendary(random_poke_species,true)
    #   else
    #     next if !is_legendary(random_poke_species,true)
    #   end
    # end
    playShuffleSE(i)
    random_poke = poke_list.sample
    random_poke_bst = getStatsTotal(getBaseStatsFormattedForRandomizer(random_poke))
    j = 0

    includeLegendaries = $game_switches[SWITCH_RANDOM_WILD_LEGENDARIES]
    current_species = GameData::Species.get(i).id
    random_poke_species = GameData::Species.get(random_poke).id
    while (random_poke_bst <= min_bst_allowed || random_poke_bst >= max_bst_allowed) || !legendaryOk(current_species,random_poke_species,includeLegendaries)
      random_poke = poke_list.sample
      random_poke_species = GameData::Species.get(random_poke).id
      #todo: right now, the main function uses dex numbers, but the legendaryOK check needs the ids.
      # This can be a hit on performance to recalculate the ids from the dex numbers.
      # The function should be optimized to just use the ids everywhere

      random_poke_bst = getStatsTotal(getBaseStatsFormattedForRandomizer(random_poke))
      j += 1
      if j % 5 == 0 #to avoid infinite loops if can't find anything
        min_bst_allowed -= 1
        max_bst_allowed += 1
      end
    end
    bst_hash[i] = random_poke
  end
  return bst_hash
end

def is_legendary(dex_num,printInfo=false)
  pokemon_id = getPokemon(dex_num).id
  is_legendary = is_fusion_of_any(pokemon_id,LEGENDARIES_LIST)

  #echoln "#{pokemon_id} is legendary? : #{is_legendary}"
  #echoln _INTL("{1} ({2}) {3}",dex_num,pokemon_id,is_legendary) if printInfo
  return is_legendary
end

def show_shuffle_progress(i)
  if i % 2 == 0
    n = (i.to_f / NB_POKEMON) * 100
    Kernel.pbMessageNoSound(_INTL("\\ts[]Shuffling wild Pokémon...\\n {1}%\\^", sprintf('%.2f', n), NB_POKEMON))
  end
end

##############
# randomizer shuffle
# ##############
def Kernel.pbShuffleDex(range = 50, type = 0)
  $game_switches[SWITCH_RANDOMIZED_AT_LEAST_ONCE] = true

  #type 0: BST
  #type 1: full random
  range = 1 if range == 0
  should_include_fusions = $game_switches[SWITCH_RANDOM_WILD_TO_FUSION]
  only_customs = $game_switches[SWITCH_RANDOM_WILD_ONLY_CUSTOMS] && should_include_fusions
  # create hash
  pokemon_list = only_customs ? getCustomSpeciesList(true) : get_pokemon_list(should_include_fusions)
  if !pokemon_list #when not enough custom sprites
    pokemon_list = get_pokemon_list(should_include_fusions)
  end
  $PokemonGlobal.psuedoBSTHash = get_randomized_bst_hash(pokemon_list, range, should_include_fusions)
end

def itemCanBeRandomized(item)
  return false if item.is_machine?
  return false if item.is_key_item?
  return false if INVALID_ITEMS.include?(item.id)
  return false if RANDOM_ITEM_EXCEPTIONS.include?(item.id)
  return true
end

def pbShuffleItems()
  randomItemsHash = Hash.new
  available_items = []
  for itemElement in GameData::Item.list_all
    item = itemElement[1]
    if itemCanBeRandomized(item)
      if !available_items.include?(item.id)
        available_items << item.id
      end
    end
  end
  remaining_items = available_items.clone
  for itemId in available_items
    if itemCanBeRandomized(GameData::Item.get(itemId))
      chosenItem = remaining_items.sample
      randomItemsHash[itemId] = chosenItem
      remaining_items.delete(chosenItem)
    end
  end
  $PokemonGlobal.randomItemsHash = randomItemsHash
end

def pbShuffleTMs()
  randomItemsHash = Hash.new
  available_items = []
  for itemElement in GameData::Item.list_all
    item = itemElement[1]
    if item.is_TM?
      if !available_items.include?(item.id)
        available_items << item.id
      end
    end
  end
  remaining_items = available_items.clone
  for itemId in available_items
    if GameData::Item.get(itemId).is_TM?
      chosenItem = remaining_items.sample
      randomItemsHash[itemId] = chosenItem
      remaining_items.delete(chosenItem)
    end
  end
  $PokemonGlobal.randomTMsHash = randomItemsHash
end

#
#   # ######
#   # #on remet arceus a la fin
#   # pokeArray.push(NB_POKEMON)
#
#   # fill random hash
#   #random hash will have to be accessed by number, not internal name
#
#   #use pokeArrayRand to fill in the BST hash also
#   #loop through the actual dex, and use the first mon in pokeArrayRand with
#   #BST in the same 100 range
#
#
#
#
#   for i in 1..NB_POKEMON-1
#     baseStats=getBaseStatsFormattedForRandomizer(i)
#     baseStat_target = 0
#     for k in 0...baseStats.length
#       baseStat_target+=baseStats[k]
#     end
#     baseStat_target = (baseStat_target+range).floor
#     for j in 1...pokeArrayRand.length
#       if $game_switches[SWITCH_RANDOM_WILD_ONLY_CUSTOMS] && $game_switches[SWITCH_RANDOM_WILD_TO_FUSION] && !customSpriteExists(pokeArrayRand[j])
#         next
#       end
#       baseStats=getBaseStatsFormattedForRandomizer(pokeArrayRand[j])
#       baseStat_temp = 0
#       for l in 0...baseStats.length
#         baseStat_temp+=baseStats[l]
#       end
#       baseStat_temp = (baseStat_temp+range).floor
#
#
#       playShuffleSE(i)
#
#       #if a match, add to hash, remove from array, and cycle to next poke in dex
#       if (baseStat_temp == baseStat_target)
#         psuedoBSTHash[i]=pokeArrayRand[j]
#         pokeArrayRand.delete(pokeArrayRand[j])
#             if i % 2 == 0 && type == 1
#               n = (i.to_f/NB_POKEMON)*100
#               Kernel.pbMessageNoSound(_INTL("\\ts[]Shuffling wild Pokémon...\\n {1}%\\^",sprintf('%.2f', n),NB_POKEMON))
#             end
#         break
#       end
#     end
#   end
#   psuedoBSTHash[NB_POKEMON] = NB_POKEMON
#   #add hashes to global data
#   $PokemonGlobal.psuedoHash = psuedoHash
#   $PokemonGlobal.psuedoBSTHash = psuedoBSTHash
# end

def getStatsTotal(baseStats)
  bst = 0
  for k in 0...baseStats.length
    bst += baseStats[k]
  end
  return bst
end

def isPartArceus(poke, type = 0)
  return true if poke == NB_POKEMON
  if type == 1
    return true if getBasePokemonID(poke, true) == NB_POKEMON
    return true if getBasePokemonID(poke, false) == NB_POKEMON
  end
  return false
end

#ajoute x happiness a tous les party member
def Kernel.raisePartyHappiness(increment)
  return
  #  for poke in $Trainer.party
  #    next if poke.isEgg?
  #    poke.happiness += increment
  #  end

end

#Randomizer code is shit. Too lazy to redo it.
# Here is a cheap workaround lol
def getBaseStatsFormattedForRandomizer(dex_num)
  statsArray = []
  stats =  GameData::Species.get(dex_num).base_stats
  statsArray << stats[:HP]
  statsArray << stats[:ATTACK]
  statsArray << stats[:DEFENSE]
  statsArray << stats[:SPECIAL_ATTACK]
  statsArray << stats[:SPECIAL_DEFENSE]
  statsArray << stats[:SPEED]
  return statsArray
end

# def Kernel.pbShuffleDexTrainers()
#   # create hash
#   psuedoHash = Hash.new
#   psuedoBSTHash = Hash.new
#
#   #Create array of all pokemon dex numbers
#   pokeArray = []
#   for i in 1..PBSpecies.maxValue
#     pokeArray.push(i)
#   end
#   #randomize hash
#   pokeArrayRand = pokeArray.dup
#   pokeArrayRand.shuffle!
#   pokeArray.insert(0,nil)
#   # fill random hash
#   #random hash will have to be accessed by number, not internal name
#   for i in 1...pokeArrayRand.length
#     psuedoHash[i]=pokeArrayRand[i]
#   end
#
#   #use pokeArrayRand to fill in the BST hash also
#   #loop through the actual dex, and use the first mon in pokeArrayRand with
#   #BST in the same 100 range
#   for i in 1..PBSpecies.maxValue
#     if i % 20 == 0
#       n = (i.to_f/PBSpecies.maxValue)*100
#       #Kernel.pbMessage(_INTL("\\ts[]Shuffling...\\n {1}%\\^",sprintf('%.2f', n),PBSpecies.maxValue))
#     end
#
#     baseStats=calcBaseStats(i)
#     baseStat_target = 0
#     for k in 0...baseStats.length
#       baseStat_target+=baseStats[k]
#     end
#     baseStat_target = (baseStat_target/50).floor
#     for j in 1...pokeArrayRand.length
#       baseStats=calcBaseStats([pokeArrayRand[j]])
#       baseStat_temp = 0
#       for l in 0...baseStats.length
#         baseStat_temp+=baseStats[l]
#       end
#       baseStat_temp = (baseStat_temp/50).floor
#       #if a match, add to hash, remove from array, and cycle to next poke in dex
#       if baseStat_temp == baseStat_target
#         psuedoBSTHash[i]=pokeArrayRand[j]
#         pokeArrayRand.delete(pokeArrayRand[j])
#         break
#       end
#     end
#   end
#
#   #add hashes to global data0
#   #$PokemonGlobal.psuedoHash = psuedoHash
#   $PokemonGlobal.pseudoBSTHashTrainers = psuedoBSTHash
# end

def getRandomizedTo(species)
  return species if !$PokemonGlobal.psuedoBSTHash
  return $PokemonGlobal.psuedoBSTHash[dexNum(species)]
  # code here
end

def tryRandomizeGiftPokemon(pokemon, dontRandomize = false)
  if $game_switches[SWITCH_RANDOM_GIFT_POKEMON] && $game_switches[SWITCH_RANDOM_WILD] && !dontRandomize
    oldSpecies = pokemon.is_a?(Pokemon) ? dexNum(pokemon) : dexNum(pokemon.species)
    if $PokemonGlobal.psuedoBSTHash[oldSpecies]
      pokemon.species = getSpecies($PokemonGlobal.psuedoBSTHash[oldSpecies])
    end
  end
end

def obtainRandomizedStarter(starterIndex)
  case starterIndex
  when 0
    dexNumber =1
  when 1
    dexNumber = 4
  else
    dexNumber = 7
  end
  random_starter = $PokemonGlobal.psuedoBSTHash[dexNumber]
  if $game_switches[SWITCH_RANDOM_STARTER_FIRST_STAGE]
    species = GameData::Species.get(random_starter)
    random_starter = GameData::Species.get(species.get_baby_species(false)).id_number
  end

  return random_starter
end