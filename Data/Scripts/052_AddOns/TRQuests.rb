
def isWearingTeamRocketOutfit()
  return false if !$game_switches[SWITCH_JOINED_TEAM_ROCKET]
  return (isWearingClothes(CLOTHES_TEAM_ROCKET_MALE) || isWearingClothes(CLOTHES_TEAM_ROCKET_FEMALE)) && isWearingHat(HAT_TEAM_ROCKET)
end

def obtainRocketOutfit()
  Kernel.pbReceiveItem(:ROCKETUNIFORM)
  gender = pbGet(VAR_TRAINER_GENDER)
  if gender == GENDER_MALE
    obtainClothes(CLOTHES_TEAM_ROCKET_MALE)
    obtainHat(HAT_TEAM_ROCKET)
    $Trainer.unlocked_clothes << CLOTHES_TEAM_ROCKET_FEMALE
  else
    obtainClothes(CLOTHES_TEAM_ROCKET_FEMALE)
    obtainHat(HAT_TEAM_ROCKET)
    $Trainer.unlocked_clothes << CLOTHES_TEAM_ROCKET_MALE
  end
  #$PokemonBag.pbStoreItem(:ROCKETUNIFORM,1)
end

def acceptTRQuest(id, show_description = true)
  return if isQuestAlreadyAccepted?(id)

  title = TR_QUESTS[id].name
  description = TR_QUESTS[id].desc
  showNewTRMissionMessage(title, description, show_description)
  addRocketQuest(id)
end
  
def addRocketQuest(id)
  $Trainer.quests = [] if $Trainer.quests.class == NilClass
  quest = TR_QUESTS[id]
  $Trainer.quests << quest if quest
end

def showNewTRMissionMessage(title, description, show_description)
  titleColor = 2
  textColor = 2
  pbMEPlay("rocketQuest", 80, 110)

  pbCallBub(3)
  Kernel.pbMessage("\\C[#{titleColor}]NEW MISSION: " + title)
  if show_description
    pbCallBub(3)
    Kernel.pbMessage("\\C[#{textColor}]" + description)
  end
end

#status = :SUCCESS, :FAILURE
def finishTRQuest(id, status, silent = false)
  return if pbCompletedQuest?(id)
  pbMEPlay("Register phone") if status == :SUCCESS && !silent
  pbMEPlay("Voltorb Flip Game Over") if status == :FAILURE && !silent
  Kernel.pbMessage("\\C[2]Mission completed!") if status == :SUCCESS && !silent
  Kernel.pbMessage("\\C[2]Mission Failed...") if status == :FAILURE && !silent

  $game_variables[VAR_KARMA] -= 5 # karma
  $game_variables[VAR_NB_ROCKET_MISSIONS] += 1 #nb. quests completed

  pbSetQuest(id, true)
end

TR_QUESTS = {
  "tr_cerulean_1" => Quest.new("tr_cerulean_1", "Creepy Crawlies", "The Team Rocket Captain has tasked you with clearing the bug infestation in the temporary Rocket HQ in Cerulean City", QuestBranchRocket, "rocket_petrel", "Cerulean City", TRQuestColor),
  "tr_cerulean_2" => Quest.new("tr_cerulean_2", "No Fishing Zone", "Intimidate the fishermen at Nugget Bridge until they leave the area.", QuestBranchRocket, "rocket_petrel", "Cerulean City", TRQuestColor),
  "tr_cerulean_3" => Quest.new("tr_cerulean_3", "Disobedient Pokémon", "Bring back the Pokémon given by the Team Rocket Captain fainted to teach it a lesson.", QuestBranchRocket, "rocket_petrel", "Cerulean City", TRQuestColor),
  "tr_cerulean_4" => Quest.new("tr_cerulean_4", "Gran Theft Pokémon!", "Follow Petrel and go steal a rare Pokémon from a young girl.", QuestBranchRocket, "rocket_petrel", "Cerulean City", TRQuestColor),

  "tr_celadon_1" => Quest.new("tr_celadon_1", "Supplying the new grunts", "Catch 4 Pokémon with Rocket Balls in the outskirts of Celadon City.", QuestBranchRocket, "rocket_archer", "Celadon City", TRQuestColor),
  "tr_celadon_2" => Quest.new("tr_celadon_2", "Interception!", "Intercept the TMs shipment to the Celadon Store and pose as the delivery person to deliver fake TMs.", QuestBranchRocket, "rocket_archer", "Celadon City", TRQuestColor),
  "tr_celadon_3" => Quest.new( "tr_celadon_3", "Pokémon Collector", "Go meet a Pokémon collector on Route 22, near Viridian City and get his rare Pokémon.", QuestBranchRocket, "rocket_archer", "Celadon City", TRQuestColor),
  "tr_celadon_4" => Quest.new("tr_celadon_4", "Operation Shutdown", "The Team Rocket HQ is being raided! Regroup with the rest of the grunts in Goldenrod Tunnel!", QuestBranchRocket, "rocket_archer", "Goldenrod City", TRQuestColor),

  "tr_pinkan" => Quest.new("tr_pinkan", "Pinkan Island!", "Help Team Rocket with a heist on a Pokémon nature preserve!", QuestBranchRocket, "rocket_archer", "Goldenrod City", TRQuestColor),

}

def calculateSuspicionLevel(answersSoFar, uncertain_answers)
  echoln answersSoFar

  believable_answers = [
    [:BIRD, :ICE, :CINNABAR, :DAWN], #articuno
    [:BIRD, :ELECTRIC, :LAVENDER, :AFTERNOON], #zapdos
    [:BIRD, :FIRE, :CINNABAR, :SUNSET], #moltres
    [:BEAST, :ELECTRIC, :CERULEAN, :NIGHT], #raikou
    [:BEAST, :ELECTRIC, :LAVENDER, :NIGHT], #raikou
    [:BEAST, :FIRE, :VIRIDIAN, :NOON], #entei
    [:BEAST, :FIRE, :VIRIDIAN, :SUNSET], #entei
    [:BEAST, :WATER, :CERULEAN, :DAWN], #suicune
    [:BEAST, :WATER, :CERULEAN, :NIGHT], #suicune
    [:FISH, :WATER, :CERULEAN, :NIGHT], #suicune
    [:FISH, :WATER, :CERULEAN, :DAWN] #suicune
  ]

  min_suspicion_score = Float::INFINITY

  # Iterate over each believable answer
  believable_answers.each do |believable_answer|
    suspicion_score = 0
    length_to_check = [answersSoFar.length, believable_answer.length].min

    # Compare answersSoFar with believable_answer up to the current length
    length_to_check.times do |i|
      suspicion_score += 1 unless answersSoFar[i] == believable_answer[i]
    end

    # Track the minimum suspicion score found
    min_suspicion_score = [min_suspicion_score, suspicion_score].min
  end
  min_suspicion_score += min_suspicion_score if uncertain_answers > 1
  echoln "suspicion score: #{min_suspicion_score}"
  return min_suspicion_score
end

##### Gameplay stuff

def legendaryQuestioning()
  uncertain_answers = 0
  answers_so_far = []

  #question 1
  pbCallBub(2, @event_id)
  pbMessage("First off what does the legendary Pokémon look like?")
  bodyTypes = { :BIRD => "A flying creature", :BEAST => "A large beast", :FISH => "An aquatic creature", :UNKNOWN => "I don't know..." }
  chosen_bodyType = optionsMenu(bodyTypes.values)
  answers_so_far << bodyTypes.keys[chosen_bodyType]
  if chosen_bodyType == bodyTypes.length - 1
    pbCallBub(2, @event_id)
    pbMessage("You don't know? Have you even seen that Pokémon?")
    pbCallBub(2, @event_id)
    pbMessage("Hmm... You better have some more information.")
    uncertain_answers += 1
  else
    pbCallBub(2, @event_id)
    pbMessage("#{bodyTypes.values[chosen_bodyType]} that's also a legendary Pokémon? That sounds incredible! You have my attention.")
  end

  #question 2
  pbCallBub(2, @event_id)
  pbMessage("Okay... What about its type?")
  types = { :ELECTRIC => "Electric-type", :FIRE => "Fire-type", :WATER => "Water-Type", :ICE => "Ice-type", :UNKNOWN => "I don't know..." }
  chosen_type = optionsMenu(types.values)
  answers_so_far << types.keys[chosen_type]

  if chosen_type == types.length - 1
    pbCallBub(2, @event_id)
    pbMessage("So you don't know its type... Hmm...")
    uncertain_answers += 1
  else
    if chosen_bodyType == bodyTypes.length - 1
      pbCallBub(2, @event_id)
      pbMessage("Hmm... So it's an unknown creature that's #{types.values[chosen_type]}...")
    else
      pbCallBub(2, @event_id)
      pbMessage("Hmm... #{bodyTypes.values[chosen_bodyType]} that's #{types.values[chosen_type]}.")
    end
    susMeter = calculateSuspicionLevel(answers_so_far, uncertain_answers)
    if susMeter == 0
      pbCallBub(2, @event_id)
      pbMessage("That sounds pretty exciting!")
    else
      pbCallBub(2, @event_id)
      pbMessage("I've never heard of such a creature, but keep going.")
    end
  end

  #question 3
  pbCallBub(2, @event_id)
  pbMessage("So... Where was this legendary Pokémon sighted?")
  locations = { :VIRIDIAN => "Near Viridian City", :LAVENDER => "Near Lavender Town", :CERULEAN => "Near Cerulean City", :CINNABAR => "Near Cinnabar Island", :UNKNOWN => "I don't know" }
  chosen_location = optionsMenu(locations.values)
  if chosen_location == locations.length - 1
    uncertain_answers += 1
    if uncertain_answers == 3
      pbCallBub(2, @event_id)
      pbMessage("Do you even know anything? This has been such a waste of time!")
      return 100
    else
      pbCallBub(2, @event_id)
      pbMessage("How can you not know where it was sighted? Do you know how unhelpful this is to me?")
      uncertain_answers += 1
    end
  else
    answers_so_far << locations.keys[chosen_location]
    susMeter = calculateSuspicionLevel(answers_so_far, uncertain_answers)
    if susMeter == 0
      pbCallBub(2, @event_id)
      pbMessage("#{locations.values[chosen_location]}, huh? Ah yes, that would make a lot of sense... How did I not think of this before?")
    else
      pbCallBub(2, @event_id)
      pbMessage("Hmmm... #{locations.values[chosen_location]}, really? That sounds pretty surprising to me.")
    end
  end

  #question 4
  locations_formatted = { :VIRIDIAN => "Viridian City", :LAVENDER => "Lavender Town", :CERULEAN => "Cerulean City", :CINNABAR => "Cinnabar Island", :UNKNOWN => "that unknown location" }
  pbCallBub(2, @event_id)
  pbMessage("And at what time of the day was that legendary Pokémon seen near #{locations_formatted.values[chosen_location]} exactly?")
  time_of_day = { :DAWN => "At dawn", :NOON => "At noon", :AFTERNOON => "In the afternoon", :SUNSET => "At sunset", :NIGHT => "At night" }
  chosen_time = optionsMenu(time_of_day.values)
  pbCallBub(2, @event_id)
  pbMessage("So it was seen near #{locations_formatted.values[chosen_location]} #{time_of_day.values[chosen_time].downcase}...")
  answers_so_far << time_of_day.keys[chosen_time]
  return calculateSuspicionLevel(answers_so_far, uncertain_answers)
end

def sellPokemon(event_id)
  if $Trainer.party.length <= 1
    pbCallBub(2, event_id)
    pbMessage("... Wait, I can't take your only Pokémon!")
    return false
  end
  pbChoosePokemon(1, 2,
                  proc { |poke|
                    !poke.egg?
                  })
  chosenIndex = pbGet(1)
  chosenPokemon = $Trainer.party[chosenIndex]

  exotic_pokemon_id = pbGet(VAR_EXOTIC_POKEMON_ID)
  if chosenPokemon.personalID == exotic_pokemon_id
    pbCallBub(2, event_id)
    pbMessage("Oh, this is the Pokémon you got from the collector, right?")
    pbCallBub(2, event_id)
    pbMessage("Yeah, I can't take that one. The collector blabbed to the police so it's too risky.")
    return false
  end

  speciesName = GameData::Species.get(chosenPokemon.species).real_name
  pbCallBub(2, event_id)
  if pbConfirmMessageSerious("You wanna sell me this #{speciesName}, is that right?")
    pbCallBub(2, event_id)
    pbMessage("Hmm... Let's see...")
    pbWait(10)
    value = calculate_pokemon_value(chosenPokemon)
    pbCallBub(2, event_id)
    if pbConfirmMessageSerious("\\GI could give you $#{value.to_s} for it. Do we have a deal?")
      payout = (value * 0.7).to_i
      pbCallBub(2, event_id)
      pbMessage("\\GExcellent. And of course, 30% goes to Team Rocket. So you get $#{payout}.")
      $Trainer.money += payout
      $Trainer.remove_pokemon_at_index(pbGet(1))
      pbSEPlay("Mart buy item")
      pbCallBub(2, event_id)
      pbMessage("\\GPleasure doing business with you.")
      return true
    else
      pbCallBub(2, event_id)
      pbMessage("Stop wasting my time!")
    end
  else
    pbCallBub(2, event_id)
    pbMessage("Stop wasting my time!")
  end
  return false
end

def calculate_pokemon_value(pokemon)
  # Attribute weights adjusted further for lower-level Pokémon
  catch_rate_weight = 0.5
  level_weight = 0.2
  stats_weight = 0.3

  # Constants for the price range
  min_price = 100
  max_price = 20000
  foreign_pokemon_bonus = 3000
  fused_bonus = 1000
  # Baseline minimum values for scaling
  min_catch_rate = 3 # Legendary catch rate
  min_level = 1 # Minimum level for a Pokémon
  min_base_stats = 180 # Approximate minimum total stats (e.g., Sunkern)

  # Attribute maximums
  max_catch_rate = 255 # Easy catch rate Pokémon like Magikarp
  max_level = 100
  max_base_stats = 720 # Maximum base stat total (e.g., Arceus)

  # Normalize values based on actual ranges
  normalized_catch_rate = (max_catch_rate - pokemon.species_data.catch_rate).to_f / (max_catch_rate - min_catch_rate)
  normalized_level = (pokemon.level - min_level).to_f / (max_level - min_level)
  normalized_stats = (calcBaseStatsSum(pokemon.species) - min_base_stats).to_f / (max_base_stats - min_base_stats)

  # Apply weights to each component
  weighted_catch_rate = normalized_catch_rate * catch_rate_weight
  weighted_level = normalized_level * level_weight
  weighted_stats = normalized_stats * stats_weight

  # Calculate the total score and scale to price range with a reduced scaling factor
  total_score = weighted_catch_rate + weighted_level + weighted_stats
  price = min_price + (total_score * (max_price - min_price) * 0.4) # Lower scaling factor

  # Add foreign Pokémon bonus if applicable
  is_foreign = !(isKantoPokemon(pokemon.species) || isJohtoPokemon(pokemon.species))
  price += foreign_pokemon_bonus if is_foreign
  price += fused_bonus if isSpeciesFusion(pokemon.species)

  price.to_i # Convert to an integer value
end

def updatePinkanBerryDisplay()
  return if !isOnPinkanIsland()
  berry_image_width=25

  clear_all_images()
  pbSEPlay("GUI storage pick up", 80, 100)
  nbPinkanBerries = $PokemonBag.pbQuantity(:PINKANBERRY)
  for i in 1..nbPinkanBerries
    x_pos=i*berry_image_width
    y_pos=0
    $game_screen.pictures[i].show("pinkanberryui",0,x_pos,y_pos)
  end
end

PINKAN_ISLAND_MAP = 51
PINKAN_ISLAND_START_ROCKET = [11,25]
PINKAN_ISLAND_START_POLICE = [20,55]
def pinkanIslandWarpToStart()
  $game_temp.player_new_map_id    = PINKAN_ISLAND_MAP
  if $game_switches[SWITCH_PINKAN_SIDE_ROCKET]
    $game_temp.player_new_x         = PINKAN_ISLAND_START_ROCKET[0]
    $game_temp.player_new_y         = PINKAN_ISLAND_START_ROCKET[1]
  else
    $game_temp.player_new_x         = PINKAN_ISLAND_START_POLICE[0]
    $game_temp.player_new_y         = PINKAN_ISLAND_START_POLICE[1]
  end
  $scene.transfer_player if $scene.is_a?(Scene_Map)
  $game_map.refresh
  $game_switches[Settings::STARTING_OVER_SWITCH] = true
  $scene.reset_map(true)
end

def isOnPinkanIsland()
  return Settings::PINKAN_ISLAND_MAPS.include?($game_map.map_id)
end

def pinkanAddAllCaughtPinkanPokemon()
  for pokemon in $Trainer.party
    pbStorePokemon(pokemon)
  end
end

def resetPinkanIsland()
  $game_switches[SWITCH_BLOCK_PINKAN_WHISTLE]=false
  $game_switches[SWITCH_LEAVING_PINKAN_ISLAND]=false
  $game_switches[SWITCH_PINKAN_SIDE_POLICE]=false
  $game_switches[SWITCH_PINKAN_SIDE_ROCKET]=false
  $game_switches[SWITCH_PINKAN_FINISHED]=false

  for map_id in Settings::PINKAN_ISLAND_MAPS
    map = $MapFactory.getMap(map_id,false)
    for event in map.events.values
      $game_self_switches[[map_id, event.id, "A"]] = false
      $game_self_switches[[map_id, event.id, "B"]] = false
      $game_self_switches[[map_id, event.id, "C"]] = false
      $game_self_switches[[map_id, event.id, "D"]] = false
    end
  end
end