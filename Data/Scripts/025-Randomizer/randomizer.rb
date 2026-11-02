LEGENDARIES_LIST = [:ARTICUNO, :ZAPDOS, :MOLTRES, :MEWTWO, :MEW,
                    :ENTEI, :RAIKOU, :SUICUNE, :HOOH, :LUGIA, :CELEBI,
                    :GROUDON, :KYOGRE, :RAYQUAZA, :DEOXYS, :JIRACHI, :LATIAS, :LATIOS,
                    :REGIROCK, :REGICE, :REGISTEEL,
                    :REGIGIGAS, :DIALGA, :PALKIA, :GIRATINA, :DARKRAI, :CRESSELIA, :ARCEUS,
                    :GENESECT, :RESHIRAM, :ZEKROM, :KYUREM, :MELOETTA_A,:MELOETTA_P,
                    :NECROZMA, :U_NECROZMA, :DIANCIE]


class PokemonTemp
  attr_accessor :should_reshuffle_trainers
  attr_accessor :should_reshuffle_pokemon
  attr_accessor :should_reshuffle_items
  attr_accessor :should_reshuffle_gyms

end

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

  monLimit = include_fusions ? PBSpecies.maxValue : NB_POKEMON
  for i in 1..monLimit
    pokeArray.push(i)
  end
  #randomize hash
  return pokeArray
end

def get_randomized_bst_hash(poke_list, bst_range, show_progress = true)
  bst_hash = Hash.new
  msg = ""
  progress_bar = ShuffleProgressBar.new(_INTL("Shuffling wild Pokémon...")) if show_progress

  for i in 1..NB_POKEMON
    show_shuffle_progress(progress_bar, i, NB_POKEMON) if progress_bar
    baseStats = getBaseStatsFormattedForRandomizer(i)
    statsTotal = getStatsTotal(baseStats)

    max_bst_allowed = statsTotal + bst_range
    min_bst_allowed = statsTotal - bst_range

    playShuffleSE(i)

    includeLegendaries = $game_switches[SWITCH_RANDOM_WILD_LEGENDARIES]
    same_egg_group = $game_switches[SWITCH_RANDOM_WILD_EGG_GROUP]
    current_species_data = GameData::Species.get(i)
    current_species = current_species_data.id
    current_egg_groups = Array(current_species_data.egg_groups)

    j = 0
    loop do
      random_poke = poke_list.sample
      random_poke_species_data = GameData::Species.get(random_poke)
      random_poke_species = random_poke_species_data.id
      random_poke_bst = getStatsTotal(getBaseStatsFormattedForRandomizer(random_poke))

      if same_egg_group
        random_poke_egg_groups = Array(random_poke_species_data.egg_groups)
        egg_group_ok = random_poke_egg_groups.any? { |g| current_egg_groups.include?(g) }
      else
        egg_group_ok = true
      end
      bst_ok = random_poke_bst > min_bst_allowed && random_poke_bst < max_bst_allowed
      legendary_ok = legendaryOk(current_species, random_poke_species, includeLegendaries)

      j += 1
      if j % 5 == 0
        min_bst_allowed -= 1
        max_bst_allowed += 1
      end

      if egg_group_ok && bst_ok && legendary_ok
        msg += "#{current_species_data.species} (#{current_species_data.egg_groups})-> #{random_poke_species_data.species} (#{random_poke_species_data.egg_groups})\n"
        bst_hash[i] = random_poke
        break
      end
    end
  end
  progress_bar.dispose if progress_bar
  Input.clipboard = msg if $DEBUG
  return bst_hash
end

LEGENDARY_LOOKUP = {}
LEGENDARIES_LIST.each { |sp| LEGENDARY_LOOKUP[sp] = true }
def is_legendary(dex_num)
  if dex_num.is_a?(Integer)
    return is_legendary_num(dex_num)
  end
  id = getPokemon(dex_num).id
  if species_is_fusion(id)
    LEGENDARY_LOOKUP.key?(get_body_species_from_symbol(id)) ||
      LEGENDARY_LOOKUP.key?(get_head_species_from_symbol(id))
  else
    LEGENDARY_LOOKUP.key?(id)
  end
end

def legendary_nums
  $legendary_nums ||= begin
                        h = {}
                        LEGENDARIES_LIST.each { |sym| h[GameData::Species.get(sym).id_number] = true }
                        h
                      end
end

def is_legendary_num(dex)
  if dex <= NB_POKEMON
    legendary_nums.key?(dex)
  else
    legendary_nums.key?(dex / NB_POKEMON) || legendary_nums.key?(dex % NB_POKEMON)
  end
end

def build_species_cache(species_ids)
  bst_cache = {}
  legendary_cache = {}
  egg_group_cache = {}

  species_ids.each do |id|
    next if bst_cache.key?(id)
    bst_cache[id] = calcBaseStatsSum(id)
    legendary_cache[id] = is_legendary(id)
    sp = GameData::Species.get(id)
    egg_group_cache[id] = Array(sp.egg_groups)
  end

  [bst_cache, legendary_cache, egg_group_cache]
end

def show_shuffle_progress(progress_bar, nb_processed, nb_to_process)
  return if !progress_bar || progress_bar.disposed?
  progress_bar.progress = nb_processed.to_f / nb_to_process
  progress_bar.update
  # if i % 2 == 0
  #   n = (i.to_f / NB_POKEMON) * 100
  #   Kernel.pbMessageNoSound(_INTL("\\ts[]Shuffling wild Pokémon...\\n {1}%\\^", sprintf('%.2f', n), NB_POKEMON))
  # end
end

#equivalent of common event 28 (APPLY randomizer options)
def reshuffleWithCurrentSettings()
  if $PokemonTemp.should_reshuffle_pokemon
    bst = pbGet(VAR_RANDOMIZER_WILD_POKE_BST)
    if $game_switches[SWITCH_RANDOM_WILD_TO_FUSION]
      type = 1
    else
      type = nil
    end
    Kernel.initRandomTypeArray
    Kernel.pbShuffleDex(bst,type, true)

  end
  if $PokemonTemp.should_reshuffle_trainers
    if $game_switches[SWITCH_RANDOM_TRAINERS_CUSTOMS_ONLY]
      Kernel.pbShuffleTrainersCustom
    else
      Kernel.pbShuffleTrainers
    end
  end
end

##############
# randomizer shuffle
# ##############
def Kernel.pbShuffleDex(range = nil, type = nil, force_reshuffle=true)
  range = 50 unless range
  type = 0 unless type
  return if $PokemonGlobal.psuedoBSTHash && !force_reshuffle
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
  $PokemonGlobal.psuedoBSTHash = get_randomized_bst_hash(pokemon_list, range, true)
  $PokemonTemp.should_reshuffle_pokemon = false
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
#               Kernel.pbMessageNoSound("\\ts[]Shuffling wild Pokémon...\\n {1}%\\^",sprintf('%.2f', n),NB_POKEMON)
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
#       #Kernel.pbMessage("\\ts[]Shuffling...\\n {1}%\\^",sprintf('%.2f', n),PBSpecies.maxValue)
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
end

def tryRandomizeGiftPokemon(pokemon, dontRandomize = false)
  dontRandomize = true if $game_switches[SWITCH_DONT_RANDOMIZE]
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