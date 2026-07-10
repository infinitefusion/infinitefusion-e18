def hoennSelectStarter
  starters = [obtainStarter(0), obtainStarter(1), obtainStarter(2)]
  selected_starter = StartersSelectionScene.new(starters).startScene
  pbAddPokemonSilent(selected_starter)
  return selected_starter
end

def hoennSelectCustomStarter
  starter = pbGet(VAR_PLAYER_STARTER_CHOICE)
  selected_starter = StartersSelectionSceneSingle.new(starter).startScene
  pbAddPokemonSilent(selected_starter)
  return selected_starter
end

def secretBaseQuest_pickedNearbySpot()
  return false if !$Trainer.secretBase
  expected_map = 65
  expected_positions = [
    [30, 43], [31, 43], [32, 42], [33, 42], [34, 42], [35, 42], [36, 40], [37, 40], # trees
    [41, 40] # cliff
  ]

  picked_base_map = $Trainer.secretBase.outside_map_id
  picked_position = $Trainer.secretBase.outside_entrance_position
  return picked_base_map == expected_map && expected_positions.include?(picked_position)
end

# To scroll a picture on screen in a seamless, continuous loop (used in the truck scene in the intro)
# Provide 2 pictures (so that the loop isn't choppy)
# Speed in pixels per frame
def scroll_picture_loop(pic_a_nb, pic_b_nb, width, speed)
  pic_a = $game_screen.pictures[pic_a_nb]
  pic_b = $game_screen.pictures[pic_b_nb]

  # move both
  pic_a.x -= speed
  pic_b.x -= speed

  # wrap-around: always place offscreen one after the other
  if pic_a.x <= -width
    pic_a.x = pic_b.x + width
  elsif pic_b.x <= -width
    pic_b.x = pic_a.x + width
  end
end

# Setup:
# Vendors placed in the map with a name that starts with "vendor"
# They need to have a self switch B to deactivate them on their last page
#
# Market spots placed in the map with the name "market_spot"

# When assign_market_vendors is called, the game assign a random
# vendor to each of the market spots and reset its switches.
# All of the others will be made invisible
#
def list_market_vendors()
  vendors = []
  $game_map.events.each do |id, event|
    vendors << id if event.name.start_with?("vendor")
  end
  return vendors
end

def list_market_spots()
  spots = []
  $game_map.events.each do |id, event|
    spots << id if event.name == "market_spot"
  end
  return spots
end

def reset_vendor_events(vendors_ids_list)
  vendors_ids_list.each do |id|
    pbSetSelfSwitch(id, "A", false)
    pbSetSelfSwitch(id, "B", true)
    event = $game_map.events[id]
    event.moveto(0, 0)
  end
end

def assign_market_vendors
  vendor_events = list_market_vendors
  reset_vendor_events(vendor_events)

  market_spots = list_market_spots

  chosen_vendors = vendor_events.sample(market_spots.size)
  chosen_vendors.shuffle
  assign_vendors_to_spots(chosen_vendors)

end

def assign_vendors_to_spots(vendors_ids)
  market_spots = list_market_spots
  market_spots.each do |spot_event_id|
    spot_event = $game_map.events[spot_event_id]
    coordinates = [spot_event.x, spot_event.y]
    direction = spot_event.direction

    assigned_vendor_id = vendors_ids[-1]
    vendors_ids.pop
    assigned_vendor_event = $game_map.events[assigned_vendor_id]
    assigned_vendor_event.moveto(coordinates.first, coordinates.last)
    # assigned_vendor_event.direction = direction
    pbSetSelfSwitch(assigned_vendor_id, "B", false)
  end
end

# Moves the assigned vendors to their spots
# Needs to be called evertime the map is reloaded
def reposition_market_vendors
  all_vendors = list_market_vendors
  active_vendors = []
  all_vendors.each do |vendor_id|
    unless pbGetSelfSwitch(vendor_id, "B")
      active_vendors << vendor_id
    end
  end
  active_vendors.shuffle
  assign_vendors_to_spots(active_vendors)
end

def map_is_altering_cave?
  return false unless Settings::HOENN
  return $game_map.map_id == 70
end

def select_altering_cave_encounter
  level_range = 8..16
  encounter_table =
    {
      :MONDAY => [:ZUBAT, :ZUBAT, :ZUBAT, :WOOBAT, :HOUNDOUR],
      :TUESDAY => [:ZUBAT, :ZUBAT, :ZUBAT, :WOOBAT, :SCRAGGY],
      :WEDNESDAY => [:ZUBAT, :ZUBAT, :ZUBAT, :WOOBAT, :PINECO],
      :THURSDAY => [:ZUBAT, :ZUBAT, :ZUBAT, :WOOBAT, :MAREEP],
      :FRIDAY => [:ZUBAT, :ZUBAT, :ZUBAT, :WOOBAT, :TEDDIURSA],
      :SATURDAY => [:ZUBAT, :ZUBAT, :ZUBAT, :WOOBAT, :AIPOM],
      :SUNDAY => [:ZUBAT, :ZUBAT, :ZUBAT, :WOOBAT, :SMEARGLE],
    }
  day_of_week = getDayOfTheWeek
  species = encounter_table[day_of_week].sample
  level = rand(level_range)
  return [species, level]
end

def build_electricity_gym_map(variable = VAR_MAUVILLE_GYM_ELECTRICITY_MAP)
  events = {}
  $game_map.events.each do |id, event|
    if event.name =~ /ELEC\((\d+),(\d+)\)/
      x = $1.to_i
      y = $2.to_i
      coordinates = [x, y]
      events[coordinates] = id
    end
  end
  pbSet(variable, events)
end

# coordinates:
# [1,2]
# status :ver, :hor, :off
# color: :red, :blue, nil
def gym_electricity(coordinates, status, color = nil)
  hue = 0
  hue = 60 if color == :blue
  hue = 180 if color == :red

  events_map = pbGet(VAR_MAUVILLE_GYM_ELECTRICITY_MAP)
  build_electricity_gym_map(VAR_MAUVILLE_GYM_ELECTRICITY_MAP) unless events_map.is_a?(Hash)
  events_map = pbGet(VAR_MAUVILLE_GYM_ELECTRICITY_MAP)
  event_id = events_map[coordinates]

  if event_id
    event = $game_map.events[event_id]
    return unless event
    if status == :ver
      event.width, event.height = 1, 5
      event.character_hue = hue
      pbSetSelfSwitch(event_id, "B", false)
      pbSetSelfSwitch(event_id, "A", true)
    elsif status == :hor
      event.width, event.height = 5, 1
      event.character_hue = hue
      pbSetSelfSwitch(event_id, "B", false)
      pbSetSelfSwitch(event_id, "A", false)
    elsif status == :off
      event.width, event.height = 1, 1
      pbSetSelfSwitch(event_id, "B", true)
    end

    event.refresh_hue = false
  end

end

def mauville_reset_switches
  switch_events = []
  $game_map.events.each do |id, event|
    if event.name.start_with?("switch")
      switch_events << id
    end
  end
  switch_events.each do |id|
    pbSetSelfSwitch(id, "A", false)
  end
end

def set_gym_elec_all_off
  events_map = pbGet(VAR_MAUVILLE_GYM_ELECTRICITY_MAP)
  build_electricity_gym_map(VAR_MAUVILLE_GYM_ELECTRICITY_MAP) unless events_map.is_a?(Hash)
  events_map = pbGet(VAR_MAUVILLE_GYM_ELECTRICITY_MAP)
  events_map.keys.each do |key|
    event_id = events_map[key]
    event = $game_map.events[event_id]
    return unless event
    event.width, event.height = 1, 1
    pbSetSelfSwitch(event_id, "B", true)
  end
end

def convertHeartScalesToCoins
  conversion_rate = 500 # nb coins per heart scale
  params = ChooseNumberParams.new
  params.setRange(0, $PokemonBag.pbQuantity(:HEARTSCALE))
  params.setDefaultValue(0)
  pbCallBubDown(2, @event_id)
  number_heartscales = pbMessageChooseNumber(_INTL("\\hsAwesome! And how many Heart Scales would you like to convert into Heart Coins?"), params)
  if number_heartscales > 0
    nb_coins = conversion_rate * number_heartscales

    pbCallBubDown(2, @event_id)
    pbMessage(_INTL("\\hsPerfect!"))
    $PokemonBag.pbDeleteItem(:HEARTSCALE, number_heartscales)
    pbMessage(_INTL("\\hs{1} handed over the Heart Scales", $Trainer.name))
    pbWait(12)
    pbSEPlay("MiningPick")
    pbWait(8)
    pbSEPlay("MiningPick")
    pbWait(4)
    pbSEPlay("MiningPick")
    pbWait(16)
    pbSEPlay("MiningRevealItem")
    pbWait(4)
    pbCallBubDown(2, @event_id)
    pbMessage(_INTL("Here you go! I converted your Heart Scales into {1} \\C[1]{2}\\C[0]!", nb_coins, COSMETIC_CURRENCY_NAME))
    pbReceiveCosmeticsMoney(nb_coins)
    pbCallBubDown(2, @event_id)
    pbMessage(_INTL("Come back whenever you find more Heart Scales to convert!"))
  else
    pbCallBub(2, @event_id)
    pbMessage(_INTL("If you find some Heart Scales, bring them to me and I'll convert them for you!"))
  end
end

def reset_gym_2_darkness

end

def mauville_info_desk
  pbCallBub(2, @event_id)
  cmd_gym = _INTL("The Gym")
  cmd_tunnels = _INTL("The Tunnels")
  cmd_pokecenter = _INTL("The Pokémon Center")
  cmd_bike = _INTL("The Bicycle Shop")
  cmd_mart = _INTL("The PokéMart")
  cmd_clothes = _INTL("The Clothing Boutique")
  cmd_exp = _INTL("The Exp. Lab")
  cmd_tv = _INTL("TV Mauville")
  cmd_gamecorner = _INTL("The Game Corner")
  cmd_workshop = _INTL("The Pokéball Workshop")
  cmd_cancel = _INTL("Never mind")
  commands = [cmd_cancel,cmd_tunnels, cmd_gym, cmd_pokecenter, cmd_bike, cmd_mart, cmd_clothes, cmd_exp, cmd_tv, cmd_gamecorner, cmd_workshop]
  choice = optionsMenu(commands,0)
  case commands[choice]
  when cmd_gym
    pbCallBubDown(2, @event_id)
    pbMessage(_INTL("The Gym Leader in Mauville City is \\C[1]Wattson\\C[0]. He specializes in Electric-type Pokémon."))
    pbCallBub(2, @event_id)
    pbMessage(_INTL("His Gym is located in the northwest part of the city. You can find it by exiting straight ahead and following the road, then turning left at the Pokémon Center."))
  when cmd_tunnels
    pbCallBub(2, @event_id)
    pbMessage(_INTL("Mauville has an interconnected network of tunnels to make it easy to get around the city. You're in them right now!"))
    pbCallBub(2, @event_id)
    pbMessage(_INTL("There is also a lower level that you can access through the stairs on the left."))
  when cmd_pokecenter
    pbCallBub(2, @event_id)
    pbMessage(_INTL("The Pokémon Center is right in the middle of the city!"))
    pbCallBub(2, @event_id)
    pbMessage(_INTL("You can find it easily by exiting the tunnel straight ahead and following the road."))
  when cmd_bike
    pbCallBub(2, @event_id)
    pbMessage(_INTL("Rydel's bicycle shop is one of the most popular stores in the city! The owner is known to be very generous with Pokémon Trainers."))
    pbCallBub(2, @event_id)
    pbMessage(_INTL("To get to it, just exit the tunnel straight ahead and follow the road, then turn right at the Pokémon Center. You can't miss it!"))
  when cmd_mart
    pbCallBub(2, @event_id)
    pbMessage(_INTL("The Mauville Poké Mart sells a variety of items for Trainers. One of their top-selling items is the Cell Battery!"))
    pbCallBub(2, @event_id)
    pbMessage(_INTL("It's located right outside the tunnel, straight ahead."))
  when cmd_clothes
    pbCallBub(2, @event_id)
    pbMessage(_INTL("The Clothing Boutique is a popular store in Mauville. They sell several exclusive clothes and even offer \\C[1]Dye kits\\C[0] that can be used to dye your clothes and hats. It's a must-see!"))
    pbCallBub(2, @event_id)
    pbMessage(_INTL("It's located right outside the tunnel, straight ahead, then to the right."))
  when cmd_exp
    pbCallBub(2, @event_id)
    pbMessage(_INTL("The Exp. Lab is a high-tech laboratory where they can make \\C[1]Experience Candies\\C[0] for your Pokémon."))
    pbCallBub(2, @event_id)
    pbMessage(_INTL("If you'd like to check it out, it's located on the upper level behind the gym, in the northernmost part of the city."))
  when cmd_tv
    pbCallBub(2, @event_id)
    pbMessage(_INTL("Most of the region's TV broadcasts are filmed right here at the TV Mauville studios. "))
    pbCallBub(2, @event_id)
    pbMessage(_INTL("The studios are free to tour! To find it, just take a left in the tunnel and head to the lower level."))
  when cmd_gamecorner
    pbCallBub(2, @event_id)
    pbMessage(_INTL("Mauville is very well known for its Game Corner. People come from all over the region to gamble!"))
    pbCallBub(2, @event_id)
    pbMessage(_INTL("The fastest way there is to take the stairs to the lower level of tunnel on the left and then head outside!"))
  when cmd_workshop
      pbCallBub(2, @event_id)
      pbMessage(_INTL("The Pokéball Workshop is a family-owned workshop that can swap your Pokémon's Pokéball for a different one."))
      pbCallBub(2, @event_id)
      pbMessage(_INTL("You can find the workshop by taking a left and heading to the lower level of tunnel."))
  end
end

def inputColorCode(codeVariable)
  return ColorCodeDoor.new(codeVariable).inputColorCode
end

