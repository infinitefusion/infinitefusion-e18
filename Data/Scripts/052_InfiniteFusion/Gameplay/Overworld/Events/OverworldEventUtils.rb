def turnEventTowardsEvent(turning, turnedTowards)
  if turnedTowards.is_a?(Integer)
    turnedTowards = $game_map.events[turnedTowards]
  end
  if turning.is_a?(Integer)
    turning = $game_map.events[turning]
  end

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

def resetFrames(event)
  if event.is_a?(Integer)
    event = $game_map.events[event]
  end
  event.pattern=0
end

def turnPlayerTowardsEvent(event)
  if event.is_a?(Integer)
    event = $game_map.events[event]
  end

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

def giveJigglypuffScribbles(possible_versions = [1, 2, 3, 4])
  selected_scribbles_version = possible_versions.sample
  case selected_scribbles_version
  when 1
    scribbles_id = HAT_SCRIBBLES1
  when 2
    scribbles_id = HAT_SCRIBBLES2
  when 3
    scribbles_id = HAT_SCRIBBLES3
  when 4
    scribbles_id = HAT_SCRIBBLES4
  end
  return if !scribbles_id

  if !hasHat?(scribbles_id)
    $Trainer.unlocked_hats << scribbles_id
  end
  putOnHat(scribbles_id, true, true)
end

# type:
# 0: default
# 1: wood
def sign(message, type = 0)
  signId = "sign_#{type}"
  translated = MessageTypes.getFromMapHash($game_map.map_id, message)
  formatted_message = "\\sign[#{signId}]#{translated}"
  pbMessage(formatted_message)
end

def setEventGraphicsToPokemon(species, eventId, shiny=false)
  event = $game_map.events[eventId]
  return if !event
  shiny_folder= shiny ? "Shiny/" : ""
  path = "Followers/#{shiny_folder}#{species.to_s}"
  echoln path
  if pbResolveBitmap("Graphics/Characters/" +path)
    event.character_name = path
  else
    path =  "Followers/#{shiny_folder}#{species.to_s}_fly"
    event.character_name = path
  end
  event.refresh
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

DIRECTION_ALL = 0
DIRECTION_LEFT = 4
DIRECTION_RIGHT = 6
DIRECTION_DOWN = 2
DIRECTION_UP = 8

DIRECTION_ALL = 0
DIRECTION_LEFT = 4
DIRECTION_RIGHT = 6
DIRECTION_DOWN = 2
DIRECTION_UP = 8

DIRECTION_ALL = 0
DIRECTION_LEFT = 4
DIRECTION_RIGHT = 6
DIRECTION_DOWN = 2
DIRECTION_UP = 8

DIRECTION_ALL = 0
DIRECTION_LEFT = 4
DIRECTION_RIGHT = 6
DIRECTION_DOWN = 2
DIRECTION_UP = 8

DIRECTION_ALL = 0
DIRECTION_LEFT = 4
DIRECTION_RIGHT = 6
DIRECTION_DOWN = 2
DIRECTION_UP = 8

def kick_ball(eventId, obstacleName = nil, targetDestination = nil, targetSwitch = nil)
  target_radius = 2
  ball = $game_map.events[eventId]
  return if !ball

  dir = $game_player.direction
  dx = (dir == DIRECTION_RIGHT ? 1 : dir == DIRECTION_LEFT ? -1 : 0)
  dy = (dir == DIRECTION_DOWN ? 1 : dir == DIRECTION_UP ? -1 : 0)

  # Shorter kick distance — scales gently with speed
  player_speed = $game_player.move_speed
  remaining_distance = [player_speed * 0.8, 1].max.floor

  pbSEPlay("jump", 80, 100) rescue nil
  pbWait(3)

  current_dir = dir
  total_bounces = 0
  max_bounces = 3
  will_pop = false
  while remaining_distance > 0 && total_bounces < max_bounces
    travel = 0
    while travel < remaining_distance
      test_x = ball.x + dx * (travel + 1)
      test_y = ball.y + dy * (travel + 1)
      event_at_test = $game_map.get_event_at_position(test_x, test_y)
      if event_at_test && event_at_test.name == obstacleName && event_at_test.active?
        ball.through = true
        will_pop = true
      else
        break if !$game_map.passable?(test_x - dx, test_y - dy, current_dir) ||
          !$game_map.passable?(test_x, test_y, current_dir)
      end

      travel += 1
    end

    if travel > 0
      ball.jump(dx * travel, dy * travel)
      pbWait(6)
    end

    if travel < remaining_distance
      pbSEPlay("jump", 80, 80) rescue nil
      total_bounces += 1
      remaining_distance = [remaining_distance / 2.0, 1].max.floor

      pbWait(6)

      dx *= -1
      dy *= -1
      current_dir = case current_dir
                    when DIRECTION_UP then DIRECTION_DOWN
                    when DIRECTION_DOWN then DIRECTION_UP
                    when DIRECTION_LEFT then DIRECTION_RIGHT
                    when DIRECTION_RIGHT then DIRECTION_LEFT
                    end

      bounce_dist = [remaining_distance / 2.0, 1].max.floor
      ball.jump(dx * bounce_dist, dy * bounce_dist)
      pbWait(8)
    else
      remaining_distance = 0
    end

    # After it lands
    if will_pop
      pbWait(24)
      pbSetSelfSwitch(eventId, "A", true)
    elsif targetDestination && targetSwitch
      pbWait(24)
      dist = (ball.x - targetDestination[0]).abs + (ball.y - targetDestination[1]).abs
      if dist <= target_radius
        $game_switches[targetSwitch] = true
        $scene.reset_map(false)
      end
    end

  end
end

def showTimeWindow
  timeText = pbGetTimeNow.strftime(_INTL("%I:%M %p"))
  window = LocationWindow.new(timeText)
  window.set_close_automatically(false)
  $scene.spriteset.addUserSprite(window)
  return window
end

def updateTimeWindow(window)
  return if !window || window.disposed?
  window.text = pbGetTimeNow.strftime(_INTL("%I:%M %p"))
end

def update_weather(last_weather_hour)
  now = pbGetTimeNow
  current_hour = now.hour
  if current_hour != last_weather_hour
    if current_hour % 4 == 0 # Update every 4 hours
      $game_weather.update_weather
    end
    last_weather_hour = current_hour
  end
  return if last_weather_hour
end

def sit_on_chair
  pbSEPlay("jump", 80, 100)
  max_faster_time = 20

  # Enter sitting state
  $game_temp.faster_time = 4
  is_outdoor = isOutdoor()
  time_window = showTimeWindow if is_outdoor

  $game_player.through = true
  $game_player.jump_forward
  $game_player.turn_180
  $game_player.through = false
  last_weather_hour = pbGetTimeNow.hour
  time_on_chair = 0
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    if is_outdoor
      updateTimeWindow(time_window)
      last_weather_hour = update_weather(last_weather_hour) if time_on_chair % 100 == 0
      time_on_chair += 1
      if time_on_chair % 100 == 0
        $game_temp.faster_time += 1 if $game_temp.faster_time < max_faster_time
      end
    end
    direction = checkInputDirection
    next if !direction

    facing_terrain = $game_player.pbFacingTerrainTag(direction)
    if facing_terrain&.chair
      pbSEPlay("jump", 80, 100)
      $game_player.direction_fix = true
      $game_player.jumpTowards(direction)
      $game_player.direction_fix = false
    else
      passable = $game_map.passable?($game_player.x, $game_player.y, direction)
      dest_x = $game_player.x + (direction == 6 ? 1 : direction == 4 ? -1 : 0)
      dest_y = $game_player.y + (direction == 2 ? 1 : direction == 8 ? -1 : 0)
      if passable #&& !$game_map.event_at_position(dest_x, dest_y)  #todo Meant to make it so that you can't get stuck, but also prevents from interacting with
        $game_player.turn_generic(direction)
        $game_player.jump_forward
        break
      else
        $game_player.turn_generic(direction)
        $game_player.turn_180
      end
    end
    pbWait(8)
  end

ensure
  # Always clean up
  $game_temp.faster_time = nil
  time_window.dispose if time_window && !time_window.disposed?
end

def checkInputDirection
  return DIRECTION_UP if Input.trigger?(Input::UP)
  return DIRECTION_DOWN if Input.trigger?(Input::DOWN)
  return DIRECTION_LEFT if Input.trigger?(Input::LEFT)
  return DIRECTION_RIGHT if Input.trigger?(Input::RIGHT)
  return nil
end

def getOnBoat
  set_player_graphics("boat_briney_peeko")
  $PokemonTemp.prevent_ow_battles = true
  $PokemonGlobal.boat = true
end

def getOffBoat
  reset_player_graphics
  $PokemonTemp.prevent_ow_battles = false
  $PokemonGlobal.boat = false
  $game_map.refresh
end

def check_beach_seashell
  pbMessage(_INTL("{1} flipped the seashell over...", $Trainer.name))
  pearl_chance = 2
  heartscale_chance = 20
  pokemon_chance = 40
  roll = rand(1..100)
  if roll <= pearl_chance
    pbReceiveItem(:PEARL)
  elsif roll <= pearl_chance + heartscale_chance
    pbReceiveItem(:HEARTSCALE)
  elsif roll <= pearl_chance + heartscale_chance + pokemon_chance
    possible_pokemon = [:KRABBY] # if added to the game, also dwebble, binacle?
    event = $game_map.events[@event_id]
    # Spawn Pokémon
    level = rand(8..16)
    pbWait(4)
    playAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y)
    spawn_random_overworld_pokemon_group([possible_pokemon.sample, level], 1, 3, [event.x, event.y], :Cave)
  else
    # Nothing
    pbMessage(_INTL("...There's nothing there."))
  end
end

# shortcut for events
def spawn_near(species, level, group_size)
  spawn_random_overworld_pokemon_group([species, level], 1, group_size)
end

def clefairy_minigame(length = 4, clefairy_event_id = nil)
  if clefairy_event_id
    event = $game_map.events[clefairy_event_id]
  end
  possible_elements = [_INTL("Left!"), _INTL("Up!"), _INTL("Right!"), _INTL("Down!")]
  pbMessage(_INTL("Listen up and remember this!"))
  sequence = []
  message = ""
  (0...length).each { |i|
    element = possible_elements.sample
    sequence << element
    message += element
    message += "\\wt[20]"
    message += " "
  }
  message += "\\wtnp[40]"
  pbWait(8)
  pbMessage(message)
  pbMessage(_INTL("Get ready... Press the buttons!\\wtnp[20]"))

  player_input = []
  loop do
    if Input.trigger?(Input::LEFT)
      player_input << possible_elements[0]
      pbSEPlay("GUI save choice", 80, 100)
    end
    if Input.trigger?(Input::UP)
      player_input << possible_elements[1]
      pbSEPlay("GUI save choice", 80, 100)
    end
    if Input.trigger?(Input::RIGHT)
      player_input << possible_elements[2]
      pbSEPlay("GUI save choice", 80, 100)
    end
    if Input.trigger?(Input::DOWN)
      player_input << possible_elements[3]
      pbSEPlay("GUI save choice", 80, 100)
    end
    if Input.trigger?(Input::BACK)
      pbSEPlay("GUI sel buzzer", 80, 100)
      return false
    end
    Graphics.update
    Input.update
    break if player_input.size == sequence.size
  end

  pbWait(10)
  if player_input == sequence
    pbSEPlay("GUI naming confirm", 80, 100)
    pbMEPlay("clefairy_correct",100)
    pbMessage(_INTL("Correct!\\wtnp[40]"))

    12.times do
      event.turn_left_90 if event
      pbWait(20)
    end
    return true
  else
    pbSEPlay("GUI sel buzzer", 80, 100)
    pbMessage(_INTL("Incorrect!\\wtnp[40]"))
    return false
  end
end

# Switch 20
def isDebugMode()
  return $DEBUG
end

def side_stairs_right
  case $game_player.direction
  when DIRECTION_RIGHT # Going up
    destination_x = $game_player.x + 1
    destination_y = $game_player.y - 1
    if $game_player.destination_is_passable(destination_x, destination_y)
      $game_player.move_upper_right
    elsif $game_player.destination_is_passable(destination_x, $game_player.y)
      $game_player.move_right
    end

  when DIRECTION_LEFT # Going down
    destination_x = $game_player.x - 1
    destination_y = $game_player.y + 1
    if $game_player.destination_is_passable(destination_x, destination_y)
      $game_player.move_lower_left
    elsif $game_player.destination_is_passable(destination_x, $game_player.y)
      $game_player.move_left
    end
  end
end

def side_stairs_left
  case $game_player.direction
  when DIRECTION_LEFT # Going up
    destination_x = $game_player.x - 1
    destination_y = $game_player.y - 1
    if $game_player.destination_is_passable(destination_x, destination_y)
      $game_player.move_upper_left
    elsif $game_player.destination_is_passable(destination_x, $game_player.y)
      $game_player.move_left
    end

  when DIRECTION_RIGHT # Going down
    destination_x = $game_player.x + 1
    destination_y = $game_player.y + 1
    if $game_player.destination_is_passable(destination_x, destination_y)
      $game_player.move_lower_right
    elsif $game_player.destination_is_passable(destination_x, $game_player.y)
      $game_player.move_right
    end
  end
end

def get_random_trend
  items = list_all_item_names.reject { |name| name.include?("TM") || name.include?("HM") || name.include?("unknown_item") }
  name1, name2 = items.sample(2)

  word1 = name1.split.first
  word2 = name2.split[1] || name2.split.first

  "#{word1} #{word2}"
end

def trendSet(option1, option2)
  choice = pbMessage(_INTL("What do you think? Do you think any of these have any potential?"), [_INTL("Not really..."), "#{option1} is pretty cool!", "I like #{option2}!"])
  case choice
  when 0
    return false
  when 1
    pbSet(VAR_TRENDY_PHRASE, option1)
    return true
  when 2
    pbSet(VAR_TRENDY_PHRASE, option2)
    return true
  end
  return false
end

def vendingMachine(stock)
  pbPokemonMart(stock, _INTL("It's a vending machine. What do you want to buy?"), true, _INTL(""), _INTL("Purchase anything else?"))
end

# Shiny egg of a random Pokemon (from a list)
def obtainBirthdayGift
  possible_species =
    [
      :PICHU, :CLEFFA, :IGGLYBUFF, :TOGEPI, :EEVEE, :HAPPINY, :BUDEW, :CHINGLING, :MUNCHLAX, :RIOLU,
    ]
  species = possible_species.sample
  pokemon = Pokemon.new(species, Settings::EGG_LEVEL)
  pokemon.shiny = true
  pokemon.natural_shiny = true
  pokemon.moves[0] = Pokemon::Move.new(:HOLDHANDS)
  pbGenerateEgg(pokemon)
end

# Called from an event. The event's name must be the legendary Pokemon's species
# Returns true is it's not in $trainer.caught_legendaries or $trainer.encountered_legendaries
# Returns false if it is
def is_legendary_active?(species)
  $Trainer.caught_legendaries = [] unless $Trainer.caught_legendaries
  $Trainer.encountered_legendaries = [] unless $Trainer.encountered_legendaries
  is_caught = $Trainer.caught_legendaries.include?(species)
  is_encountered = $Trainer.encountered_legendaries.include?(species)

  return !is_caught && !is_encountered
end

def setEventGraphicPokemon(species, event_id)
  species_data = GameData::Species.get(species)
  event = $game_map.events[event_id]
  return unless event
  if event
    echoln event.get_page(1)
    event.get_page(1).graphic.character_name = getOverworldLandPath(species_data)
    # event.character_name= #"Graphics/Characters/#{getOverworldLandPath(species_data)}"
    event.refresh
  end
end

# ZORUA FOREST
#
ZORUA_FOLLOWED_VARIABLE = 1031

def shapeshift_zorua

  zorua_events = [32, 36, 38, 34, 37, 61, 41]
  nb_active = $game_variables[ZORUA_FOLLOWED_VARIABLE]
  for i in 0..nb_active
    event_id = zorua_events[i]
    event = $game_map.events[event_id]
    next unless event
    next if event.erased
    encounter_type = getTimeBasedEncounter(:Land)
    disguise_species = getRandomPokemonFromRoute(:ZORUA, encounter_type)
    species_data = GameData::Species.get(disguise_species)
    event.character_name = getOverworldLandPath(species_data)
    event.refresh
  end
end

def transfer_subtle(new_x, new_y)
  return if isWearingHat(HAT_ZOROARK)
  map = $game_map.map_id
  $game_temp.player_new_map_id = map
  $game_temp.player_new_x = new_x
  $game_temp.player_new_y = new_y

  pbFadeOutIn {
    $scene.transfer_player(false)
    shapeshift_zorua
  }
end

def this_event()
  return $game_map.events[@event_id]
end

def get_event(id)
  return $game_map.events[id]
end

def select_tv_show_quests(episode = 0)
  all_episodes = [
    [],
    [:main_stolen_parts, :route_102_rematch, :petalburg_berry, :route104_rivalWeather, :petalburgwoods_spores],
    [:main_steven_letter, :route104_oricorio, :route104_oricorio_forms, :rustboro_whismur, :rustboro_shiny],
    [:main_devon_parts, :dewford_fishing, :route109_tanning, :route109_seahouse, :route109_beachball],
    [:magma_help_grunts, :aqua_help_grunts],
    [:mauville_quests_1]
  ]

  episode_quests = all_episodes[episode] || []
  completed_ids = get_completed_quests.map { |q| q.id.to_s }
  filtered = episode_quests.select { |q| completed_ids.include?(q.to_s) }
  #filtered = episode_quests # For debugging with all quests

  filtered.sample(2)
end

def get_show_dialog(quest_id)
  echoln quest_id
  case quest_id
    # Episode 1
  when :main_stolen_parts
    return _INTL("Sootopolis Void attacked the city and tried to steal a precious package from the Rangers headquarters. Littleroot Crimson was able to stop him, but now he's coming back with a vengeance...")
  when :route_102_rematch
    return _INTL("There was a part where Littleroot Crimson had a rematch with Fallarbor Bordeaux and he finally evolved his Combusken.")
  when :petalburg_berry
    return _INTL("There was an entire subplot about Rustboro Ivory entering a berry-growing contest that she ended up winning with a super-mutant berry.")
  when :route104_rivalWeather
    return _INTL("There was a part where Lilicove Viridian waited until the wind picked up to catch a Pidgeot that had been terrorizing the town.")
  when :petalburgwoods_spores
    return _INTL("At one point, Mauville Yellow met a scientist in the woods and helped him collect highly toxic spore.")

    # Episode 2
  when :main_steven_letter
    return _INTL("Littleroot Crimson seeked out the help of the grandmaster that was hiding at the end of the dark cave.")
  when :route104_oricorio
    return _INTL("Rustboro Ivory befriended that lonely Oricorio in the flowers field.")
  when :route104_oricorio_forms
    return _INTL("The Oricorio kept switching forms!")
  when :rustboro_whismur
    return _INTL("Mauville Yellow fused a Pellipper with Exploud to create a sonic weapon. And then it ended up being much too loud, it was so funny!")
  when :rustboro_shiny
    return _INTL("Pacifidlog Cobalt found that shiny Azumarill. I never saw it coming!")

    # Episode 3
  when :main_devon_parts
    return _INTL("At least, Littleroot Crimson finally delivered that precious package. I can't wait to see what happens next with that.")
  when :dewford_fishing
    return _INTL("Hey, that part where Fallarbor Bordeaux fished up that Dragalge was pretty neat.")
  when :route109_tanning
    return _INTL("That whole subplot about Pacifidlog Cobalt trying to get a tan definitely dragged on a bit...")
  when :route109_seahouse
    return _INTL("Although that scene with Lilicove Viridian beating up all the bad guys in the beach house was really fun!")
  when :route109_beachball
    return _INTL("The chase sequence with the Kingler when Mauville Yellow was carrying that beach ball was really funny though!")
    # Episode 4
  when :magma_help_grunts
    return _INTL("I never expected Littleroot Crimson to infiltrate the villains's lair like that!")
  when :aqua_help_grunts
    return _INTL("I never expected Littleroot Crimson to infiltrate the villains's lair like that!")

    # Episode 5
  when :mauville_quests_1
    return "" # directly in the event's dialog
  end
end

def setDayCareOverworlds(land_event_ids = [], water_event_ids = [])
  day_care_map = 74
  return unless $game_map.map_id == day_care_map
  land_event_ids.each_with_index do |event_id, i|
    event = $game_map.events[event_id]
    pbSetSelfSwitch(event.id, "A", false, day_care_map)
    event.character_name = ""
  end
  water_event_ids.each_with_index do |event_id, i|
    event = $game_map.events[event_id]
    pbSetSelfSwitch(event.id, "A", false, day_care_map)
    event.character_name = ""
  end

  $PokemonGlobal.daycare.each_with_index do |day_care_slot, i|
    day_care_pokemon = day_care_slot[0]
    next unless day_care_pokemon
    if day_care_pokemon.hasType?(:WATER)
      event_id = water_event_ids[i]
      swimming = true
    else
      event_id = land_event_ids[i]
      swimming = false
    end

    event = $game_map.events[event_id]
    pbSetSelfSwitch(event.id, "A", true, day_care_map)
    $game_map.refresh

    overworldPath = getRoamingSprite(day_care_pokemon.species_data, day_care_pokemon.isShiny?)
    is_flying = overworldPath.include?("_fly")
    event.step_anime = true if is_flying
    echoln overworldPath
    event.character_name = overworldPath if overworldPath
    if swimming
      event.forced_bush_depth = 20
      event.step_anime = true
      event.set_animation_speed(2)
      event.calculate_bush_depth
    end
  end
end

def getRandomWonderTradeNames(number=1)
  names= RandTrainerNames_female + RandTrainerNames_male
  return names.sample(number)
end

def getRandomUnisexName
  return RandTrainerNames_unisex.sample
end

