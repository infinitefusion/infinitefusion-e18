#===============================================================================
#
#===============================================================================
def pbBattleChallenge
  $PokemonGlobal.challenge = BattleChallenge.new if !$PokemonGlobal.challenge
  return $PokemonGlobal.challenge
end

def pbBattleChallengeBattle
  return pbBattleChallenge.pbBattle
end

# Used in events
def pbHasEligible?(*arg)
  return pbBattleChallenge.rules.ruleset.hasValidTeam?($Trainer.party)
end

#===============================================================================
#
#===============================================================================
def pbGetBTTrainers(challengeID)
  trlists = (load_data("Data/trainer_lists.dat") rescue [])
  trlists.each { |tr| return tr[0] if !tr[5] && tr[2].include?(challengeID) }
  trlists.each { |tr| return tr[0] if tr[5] }   # is default list
  return []
end

def listAllPokemon
  list=[]
  for i in 0..PBSpecies.maxValue
    list << i
  end
  return list
end

def pbGetBTPokemon(challenge_id)
  customsOnly = !$game_switches[SWITCH_BATTLE_FACTORY_INCLUDE_ALL]
  if customsOnly
    customsList = getCustomSpeciesList()
    return customsList if customsList
  end
  return listAllPokemon




  # list=[]
  # while list.length <= target_size
  #   list << generate_random_species(max_bst)
  # end
  # return list
end

def generate_random_species(max_bst)
  additional_bst = $game_variables[120]
  species=0
  bonus = 0
  while (species==0) # Loop Start
    bonus+= 5 #+ de chance de pogner un bon poke a chaque loop (permet d'eviter infinite loop)
    species=rand(PBSpecies.maxValue)+1
    bst = calcBaseStatsSum(species)
    species=0 if bst > max_bst+additional_bst
  end
  return species
end

#===============================================================================
#
#===============================================================================
def pbEntryScreen(ableproc=nil,indexesVar=nil)
  retval = false
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene, $Trainer.party)
    ret = screen.pbPokemonMultipleEntryScreenEx(pbBattleChallenge.rules.ruleset,ableproc,indexesVar)
    # Set party
    pbBattleChallenge.setParty(ret) if ret
    # Continue (return true) if Pokémon were chosen
    retval = (ret != nil && ret.length > 0)
  }
  return retval
end

def pbEntryScreenArgs(*arg)
  retval = false
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene, $Trainer.party)
    ret = screen.pbPokemonMultipleEntryScreenEx(pbBattleChallenge.rules.ruleset)
    # Set party
    pbBattleChallenge.setParty(ret) if ret
    # Continue (return true) if Pokémon were chosen
    retval = (ret != nil && ret.length > 0)
  }
  return retval
end

#===============================================================================
#
#===============================================================================
class Game_Player < Game_Character
  def moveto2(x, y)
    @x = x
    @y = y
    @real_x = @x * Game_Map::REAL_RES_X
    @real_y = @y * Game_Map::REAL_RES_Y
    @prelock_direction = 0
  end
end

#===============================================================================
#
#===============================================================================
class Game_Event
  def pbInChallenge?
    return pbBattleChallenge.pbInChallenge?
  end
end

def getTrainerTypeGraphic(trainerType)
  case trainerType
  when :YOUNGSTER       then return "BW (19)"
  when :LASS            then return "BW (23)"
  when :POKEMANIAC      then return "BW (30)"
  when :PSYCHIC_F       then return "BW (30)"
  when :GENTLEMAN       then return "BW (55)"
  when :LADY            then return "BW (28)"
  when :CAMPER          then return "BW (59)"
  when :PICNICKER       then return "BW (60)"
  when :TUBER_M         then return "BWTuber_male"
  when :TUBER_F         then return "BWTuber_female"
  when :SWIMMER_M       then return "BWSwimmerLand"
  when :SWIMMER_F       then return "BWSwimmer_female2"
  when :COOLTRAINER_F   then return "BW024"
  when :JUGGLER         then return "BWHarlequin"
  when :POKEMONBREEDER  then return "BW028"
  when :BUGCATCHER      then return "BWBugCatcher_male"
  when :BLACKBELT       then return "BWBlackbelt"
  when :FISHERMAN       then return "BW (71)"
  when :RUINMANIAC      then return "BW (72)"
  when :TAMER           then return "BW (69)"
  when :BEAUTY          then return "BW015"
  when :AROMALADY       then return "BWAomalady"
  when :ROCKER          then return "BWPunkGuy"
  when :BIRDKEEPER      then return "BW (29)"
  when :SAILOR          then return "BWSailor"
  when :HIKER           then return "BWHiker"
  when :ENGINEER        then return "BW (75)"
  when :COOLTRAINER_M   then return "BW023"
  when :BIKER           then return "BW055"
  when :CRUSHGIRL       then return "BWBattleGirl"
  when :POKEMONRANGER_M then return "BW (47)"
  when :POKEMONRANGER_F then return "BW (48)"
  when :PSYCHIC_M       then return "BW (30)"
  when :CHANNELER       then return "BW (40)"
  when :GAMBLER         then return "BW (111)"
  when :SCIENTIST       then return "BW (81)"
  when :SUPERNERD       then return "BW (81)"
  when :CUEBALL         then return "BWRoughneck"
  end
end



#===============================================================================
#
#===============================================================================
def pbBattleChallengeGraphic(event)
  nextTrainer = pbBattleChallenge.nextTrainer
  bttrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)

  trainerType = (bttrainers[nextTrainer][0] rescue nil)
  filename = getTrainerTypeGraphic(trainerType)
  begin
    filename = "" if nil_or_empty?(filename)
    bitmap = AnimatedBitmap.new("Graphics/Characters/" + filename)
    bitmap.dispose
    event.character_name = filename
  rescue
    event.character_name = "BWClerk"
  end
end

def pbBattleChallengeBeginSpeech
  return "..." if !pbBattleChallenge.pbInProgress?
  bttrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
  tr = bttrainers[pbBattleChallenge.nextTrainer]
  return (tr) ? pbGetMessageFromHash(MessageTypes::BeginSpeech, tr[2]) : "..."
end

#===============================================================================
#
#===============================================================================
class PBPokemon
  attr_accessor :species
  attr_accessor :item
  attr_accessor :nature
  attr_accessor :move1
  attr_accessor :move2
  attr_accessor :move3
  attr_accessor :move4
  attr_accessor :ev

  # This method is how each Pokémon is compiled from the PBS files listing
  # Battle Tower/Cup Pokémon.
  def self.fromInspected(str)
    insp = str.gsub(/^\s+/, "").gsub(/\s+$/, "")
    pieces = insp.split(/\s*;\s*/)
    species = (GameData::Species.exists?(pieces[0])) ? GameData::Species.get(pieces[0]).id : nil
    item = (GameData::Item.exists?(pieces[1])) ? GameData::Item.get(pieces[1]).id : nil
    nature = (GameData::Nature.exists?(pieces[2])) ? GameData::Nature.get(pieces[2]).id : nil
    ev = pieces[3].split(/\s*,\s*/)
    ev_array = []
    ev.each do |stat|
      case stat.upcase
      when "HP"          then ev_array.push(:HP)
      when "ATK"         then ev_array.push(:ATTACK)
      when "DEF"         then ev_array.push(:DEFENSE)
      when "SA", "SPATK" then ev_array.push(:SPECIAL_ATTACK)
      when "SD", "SPDEF" then ev_array.push(:SPECIAL_DEFENSE)
      when "SPD"         then ev_array.push(:SPEED)
      end
    end
    moves = pieces[4].split(/\s*,\s*/)
    moveid = []
    for i in 0...Pokemon::MAX_MOVES
      move_data = GameData::Move.try_get(moves[i])
      moveid.push(move_data.id) if move_data
    end
    if moveid.length == 0
      GameData::Move.each { |mov| moveid.push(mov.id); break }   # Get any one move
    end
    return self.new(species, item, nature, moveid[0], moveid[1], moveid[2], moveid[3], ev_array)
  end

  def self.fromPokemon(pkmn)
    mov1 = (pkmn.moves[0]) ? pkmn.moves[0].id : nil
    mov2 = (pkmn.moves[1]) ? pkmn.moves[1].id : nil
    mov3 = (pkmn.moves[2]) ? pkmn.moves[2].id : nil
    mov4 = (pkmn.moves[3]) ? pkmn.moves[3].id : nil
    ev_array = []
    GameData::Stat.each_main do |s|
      ev_array.push(s.id) if pkmn.ev[s.id] > 60
    end
    return self.new(pkmn.species, pkmn.item_id, pkmn.nature,
       mov1, mov2, mov3, mov4, ev_array)
  end

  def initialize(species, item, nature, move1, move2, move3, move4, ev)
    @species = species
    itm = GameData::Item.try_get(item)
    @item    = itm ? itm.id : nil
    @nature  = nature
    @move1   = move1
    @move2   = move2
    @move3   = move3
    @move4   = move4
    @ev      = ev
  end

  def inspect
    c1 = GameData::Species.get(@species).id
    c2 = (@item) ? GameData::Item.get(@item).id : ""
    c3 = (@nature) ? GameData::Nature.get(@nature).id : ""
    evlist = ""
    @ev.each do |stat|
      evlist += "," if evlist != ""
      evlist += stat.real_name_brief
    end
    c4 = (@move1) ? GameData::Move.get(@move1).id : ""
    c5 = (@move2) ? GameData::Move.get(@move2).id : ""
    c6 = (@move3) ? GameData::Move.get(@move3).id : ""
    c7 = (@move4) ? GameData::Move.get(@move4).id : ""
    return "#{c1};#{c2};#{c3};#{evlist};#{c4},#{c5},#{c6},#{c7}"
  end

  # Unused.
  def tocompact
    return "#{species},#{item},#{nature},#{move1},#{move2},#{move3},#{move4},#{ev}"
  end

=begin
  def _dump(depth)
    return [@species, @item, @nature, @move1, @move2, @move3, @move4, @ev].pack("vvCvvvvC")
  end

  def self._load(str)
    data = str.unpack("vvCvvvvC")
    return self.new(data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7])
  end
=end

  def convertMove(move)
    move = :FRUSTRATION if move == :RETURN && GameData::Move.exists?(:FRUSTRATION)
    return move
  end

  def createPokemon(level, iv, trainer)
    pkmn = Pokemon.new(@species, level, trainer, false)
    pkmn.item = @item
    pkmn.personalID = rand(2**16) | rand(2**16) << 16
    pkmn.nature = nature
    pkmn.happiness = 0
    pkmn.moves.push(Pokemon::Move.new(self.convertMove(@move1)))
    pkmn.moves.push(Pokemon::Move.new(self.convertMove(@move2))) if @move2
    pkmn.moves.push(Pokemon::Move.new(self.convertMove(@move3))) if @move3
    pkmn.moves.push(Pokemon::Move.new(self.convertMove(@move4))) if @move4
    pkmn.moves.compact!
    if ev.length > 0
      ev.each { |stat| pkmn.ev[stat] = Pokemon::EV_LIMIT / ev.length }
    end
    GameData::Stat.each_main { |s| pkmn.iv[s.id] = iv }
    pkmn.calc_stats
    return pkmn
  end
end
