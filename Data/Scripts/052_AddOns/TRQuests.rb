
def isWearingTeamRocketOutfit()
  return false if !$game_switches[SWITCH_JOINED_TEAM_ROCKET]
  return (isWearingClothes(CLOTHES_TEAM_ROCKET_MALE) || isWearingClothes(CLOTHES_TEAM_ROCKET_FEMALE)) && isWearingHat(HAT_TEAM_ROCKET)
end

def isWearingFavoriteOutfit()
  favorites = {
    hat: $Trainer.favorite_hat,
    hat2: $Trainer.favorite_hat2,
    clothes: $Trainer.favorite_clothes
  }
  favorites.select! { |item, favorite| !favorite.nil? }
  return false if favorites.empty?
  return favorites.all? do |item, favorite|
    case item
    when :hat
      $Trainer.hat == favorite
    when :hat2
      $Trainer.hat2 == favorite
    when :clothes
      $Trainer.clothes == favorite
    end
  end
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
  Kernel.pbMessage("\\C[#{titleColor}]NOUVELLE MISSION: " + title)
  if show_description
    pbCallBub(3)
    Kernel.pbMessage("\\C[#{textColor}]" + description)
  end
end

#status = :SUCCESS, :FAILURE
def finishTRQuest(id, status, silent = false)
  return if pbCompletedQuest?(id)
  pbMEPlay("Enregistrer le téléphone") if status == :SUCCESS && !silent
  pbMEPlay("Fin du jeu Voltorb") if status == :FAILURE && !silent
  Kernel.pbMessage("\\C[2]Mission accomplie!") if status == :SUCCESS && !silent
  Kernel.pbMessage("\\C[2]Mission échouée...") if status == :FAILURE && !silent

  $game_variables[VAR_KARMA] -= 5 # karma
  $game_variables[VAR_NB_ROCKET_MISSIONS] += 1 #nb. quests completed

  pbSetQuest(id, true)
end

TR_QUESTS = {
  "tr_cerulean_1" => Quest.new("tr_cerulean_1", "Bestioles Effrayantes", "Le Capitaine de la Team Rocket vous a chargé d'éliminer l'infestation d'Insectes dans le QG temporaire de la Team Rocket à Azuria.", QuestBranchRocket, "rocket_petrel", "Cerulean City", TRQuestColor),
  "tr_cerulean_2" => Quest.new("tr_cerulean_2", "Zone Interdite à la Pêche", "Intimidez les pêcheurs du Pont Pépite jusqu'à ce qu'ils quittent la zone.", QuestBranchRocket, "rocket_petrel", "Cerulean City", TRQuestColor),
  "tr_cerulean_3" => Quest.new("tr_cerulean_3", "Pokémon Désobéissant", "Ramenez le Pokémon donné par le Capitaine de la Team Rocket en le mettant K.O. pour lui donner une leçon.", QuestBranchRocket, "rocket_petrel", "Cerulean City", TRQuestColor),
  "tr_cerulean_4" => Quest.new("tr_cerulean_4", "Braquage de Pokémon!", "Suivez Lambda et allez voler un Pokémon rare à une jeune fille.", QuestBranchRocket, "rocket_petrel", "Cerulean City", TRQuestColor),

  "tr_celadon_1" => Quest.new("tr_celadon_1", "Fournir les Nouveaux Venus", "Catch 4 Pokémon with Rocket Balls in the outskirts of Celadon City.", QuestBranchRocket, "rocket_archer", "Celadon City", TRQuestColor),
  "tr_celadon_2" => Quest.new("tr_celadon_2", "Interpellation!", "Interceptez la cargaison de CT destinée au Magasin de Céladopole et faites-vous passer pour le livreur afin de livrer de fausses CT.", QuestBranchRocket, "rocket_archer", "Celadon City", TRQuestColor),
  "tr_celadon_3" => Quest.new("tr_celadon_3", "Collectionneur de Pokémon", "Allez rencontrer un collectionneur de Pokémon sur la Route 22, près de Jadielle, et récupérez son Pokémon rare.", QuestBranchRocket, "rocket_archer", "Celadon City", TRQuestColor),
  "tr_celadon_4" => Quest.new("tr_celadon_4", "Arrêt de l'Opération", "Le QG de la Team Rocket est en train d'être attaqué! Regroupez-vous avec le reste des sbires dans le Tunnel de Doublonville!", QuestBranchRocket, "rocket_archer", "Goldenrod City", TRQuestColor),

  "tr_pinkan" => Quest.new("tr_pinkan", "l'Ile Guimauve!", "Aidez la Team Rocket dans un braquage d'une réserve naturelle de Pokémon!", QuestBranchRocket, "rocket_archer", "Goldenrod City", TRQuestColor),

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
  pbMessage("Tout d’abord, à quoi ressemble le Pokémon légendaire ?")
  bodyTypes = { :BIRD => "Une créature volante", :BEAST => "Une grosse bête", :FISH => "Une créature aquatique", :UNKNOWN => "Je ne sais pas..." }
  chosen_bodyType = optionsMenu(bodyTypes.values)
  answers_so_far << bodyTypes.keys[chosen_bodyType]
  if chosen_bodyType == bodyTypes.length - 1
    pbCallBub(2, @event_id)
    pbMessage("Tu ne le sais pas? Tu as déjà vu ce Pokémon?")
    pbCallBub(2, @event_id)
    pbMessage("Hmm... Tu ferais mieux d'avoir plus d'informations.")
    uncertain_answers += 1
  else
    pbCallBub(2, @event_id)
    pbMessage("#{bodyTypes.values[chosen_bodyType]} C'est aussi un Pokémon légendaire ? Ça a l'air incroyable ! Tu as mon attention.")
  end

  #question 2
  pbCallBub(2, @event_id)
  pbMessage("Ok... Qu'en est-il de son type ?")
  types = { :ELECTRIC => "Type Electrique", :FIRE => "Type Feu", :WATER => "Type Eau", :ICE => "Type Glace", :UNKNOWN => "Je ne sais pas..." }
  chosen_type = optionsMenu(types.values)
  answers_so_far << types.keys[chosen_type]

  if chosen_type == types.length - 1
    pbCallBub(2, @event_id)
    pbMessage("Donc vous ne connaissez pas son type... Hmm...")
    uncertain_answers += 1
  else
    if chosen_bodyType == bodyTypes.length - 1
      pbCallBub(2, @event_id)
      pbMessage("Hmm... C'est donc une créature inconnue de #{types.values[chosen_type]}...")
    else
      pbCallBub(2, @event_id)
      pbMessage("Hmm... #{bodyTypes.values[chosen_bodyType]} de #{types.values[chosen_type]}.")
    end
    susMeter = calculateSuspicionLevel(answers_so_far, uncertain_answers)
    if susMeter == 0
      pbCallBub(2, @event_id)
      pbMessage("Cela semble plutôt excitant!")
    else
      pbCallBub(2, @event_id)
      pbMessage("Je n'ai jamais entendu parler d'une telle créature, mais continuez.")
    end
  end

  #question 3
  pbCallBub(2, @event_id)
  pbMessage("Alors... Où ce Pokémon légendaire a-t-il été aperçu?")
  locations = { :VIRIDIAN => "Près de Jadielle", :LAVENDER => "Près de Lavanville", :CERULEAN => "Près de Azuria", :CINNABAR => "Près de Cramois'Ile", :UNKNOWN => "Je ne sais pas..." }
  chosen_location = optionsMenu(locations.values)
  if chosen_location == locations.length - 1
    uncertain_answers += 1
    if uncertain_answers == 3
      pbCallBub(2, @event_id)
      pbMessage("Est-ce que tu sais quelque chose? C'était une telle perte de temps!")
      return 100
    else
      pbCallBub(2, @event_id)
      pbMessage("Comment ne sais-tu pas où il a été aperçu ? Sais-tu à quel point cela ne m'aide pas?")
      uncertain_answers += 1
    end
  else
    answers_so_far << locations.keys[chosen_location]
    susMeter = calculateSuspicionLevel(answers_so_far, uncertain_answers)
    if susMeter == 0
      pbCallBub(2, @event_id)
      pbMessage("#{locations.values[chosen_location]}, hein? Ah oui, ça aurait beaucoup de sens... Comment n'ai-je pas pensé à ça avant?")
    else
      pbCallBub(2, @event_id)
      pbMessage("Hmmm... #{locations.values[chosen_location]}, Vraiment ? Cela me paraît assez surprenant.")
    end
  end

  #question 4
  locations_formatted = { :VIRIDIAN => "Jadielle", :LAVENDER => "Lavanville", :CERULEAN => "Azuria", :CINNABAR => "Cramois'Ile", :UNKNOWN => "Cet endroit Inconnu" }
  pbCallBub(2, @event_id)
  pbMessage("Et à quelle heure de la journée ce Pokémon légendaire a-t-il été vu à proximité de #{locations_formatted.values[chosen_location]} ?")
  time_of_day = { :DAWN => "À l'aube", :NOON => "À midi", :AFTERNOON => "L'après-midi", :SUNSET => "Au coucher du soleil", :NIGHT => "La nuit" }
  chosen_time = optionsMenu(time_of_day.values)
  pbCallBub(2, @event_id)
  pbMessage("Donc, il a été vu près de #{locations_formatted.values[chosen_location]} #{time_of_day.values[chosen_time].downcase}...")
  answers_so_far << time_of_day.keys[chosen_time]
  return calculateSuspicionLevel(answers_so_far, uncertain_answers)
end

def sellPokemon(event_id)
  if $Trainer.party.length <= 1
    pbCallBub(2, event_id)
    pbMessage("...Attends, je ne peux pas prendre ton seul Pokémon!")
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
    pbMessage("Oh, c'est le Pokémon que tu as reçu du collectionneur, n'est-ce pas?")
    pbCallBub(2, event_id)
    pbMessage("Ouais, je ne peux pas accepter ça. Le collectionneur l'a dit à la police, donc c'est trop risqué.")
    return false
  end

  speciesName = GameData::Species.get(chosenPokemon.species).real_name
  pbCallBub(2, event_id)
  if pbConfirmMessageSerious("Tu veux me vendre ce #{speciesName}, c'est ça ?")
    pbCallBub(2, event_id)
    pbMessage("Hmm... Voyons voir...")
    pbWait(10)
    value = calculate_pokemon_value(chosenPokemon)
    pbCallBub(2, event_id)
    if pbConfirmMessageSerious("\\GJe peux te donner $#{value.to_s} pour cela. Marché conclu?")
      payout = (value * 0.7).to_i
      pbCallBub(2, event_id)
      pbMessage("\\GExcellent. Et bien sûr, 30% vont à la Team Rocket. Vous obtenez donc #{payout}$.")
      $Trainer.money += payout
      $Trainer.remove_pokemon_at_index(pbGet(1))
      pbSEPlay("Marché D'Objet")
      pbCallBub(2, event_id)
      pbMessage("\\GC'est un plaisir de faire affaire avec vous.")
      return true
    else
      pbCallBub(2, event_id)
      pbMessage("Arrête de me faire perdre mon temps!")
    end
  else
    pbCallBub(2, event_id)
    pbMessage("Arrête de me faire perdre mon temps!")
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