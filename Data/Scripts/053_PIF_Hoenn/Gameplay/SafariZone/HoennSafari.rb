#PIF2 Safari Zone takes place entirely in the overworld, no battles. You throw Pokemon like you do in Legends Arceus.
# - Safari Balls only work if a Pokemon doesn't see you and the catch rate improves the closer you are to a Pokemon.
# - Catching bonus if the Pokemon hasn't seen you before (caught off guard)
# - You can place berries to attract Pokemon and distract them.

#
# Can hold the throw button to throw further (?)
#

TEMPLATE_EVENT_SAFARI_BALL = 15
TEMPLATE_EVENT_POKEBLOCK = 16

HOENN_SAFARI_MAPS = [MAP_SAFARI_1,MAP_SAFARI_2,MAP_SAFARI_3,MAP_SAFARI_4,MAP_SAFARI_5,MAP_SAFARI_6]

class PokemonTemp
  attr_accessor :overworld_safari
end

class SafariState
  attr_accessor :caught_pokemon
  attr_accessor :area_types
  attr_accessor :area_unlock_methods

end

def initialize_safari
  nb_balls = pbGet(VAR_HOENN_SAFARI_NB_BALLS)
  nb_balls = 18 if nb_balls <= 0

  pbSafariState.pbStart(nb_balls)
  $PokemonTemp.overworld_safari = true
  updateSafariBallDisplay()
  pbSafariState.area_types= initialize_area_types
  pbSafariState.area_unlock_methods= initialize_unlock_methods
  respawn_safari_ball_piles
end

def initialize_area_types
  return {
    :wetland => [
      [:same_species,nil,3],
    ],
    :lakeland => [[:different_species,:WATER,5]],
    :badland => [[:different_species,:NORMAL,6]],
    :grassland => [[:different_species,:GROUND,5]],
    :woodland => [[:different_species,nil,20]],
    :mountains => [[:different_species,:ELECTRIC,5]],
  }
end

def initialize_unlock_methods
  unlock_methods = {}
  pbSafariState.area_types.each do |type, methods|
    chosen_method = rand(methods.size)
    unlock_methods[type] = chosen_method
  end
  echoln unlock_methods
  return unlock_methods
end

def get_area_name(area_id)
  case area_id
  when :lakeland
    return _INTL("Lake Zone")
  when :wetland
    return _INTL("Wetland Zone")
  when :badland
    return _INTL("Badland Zone")
  when :grassland
    return _INTL("Grassland Zone")
  when :woodland
    return _INTL("Woodland Zone")
  when :mountains
    return _INTL("Mountains Zone")
  end

end

# Returns how many catches count toward the requirement.
#   :different_species => number of distinct species (optionally only of the given type)
#   :same_species      => highest number of catches of any single species (optionally only of the given type)
def count_safari_caught(method_type, type = nil)
  caught = pbSafariState.caught_pokemon || []
  caught = caught.select { |s| GameData::Species.get(s).hasType?(type) } if type

  case method_type
  when :same_species
    return caught.group_by { |species| species }.values.map(&:size).max || 0
  else # :different_species
    return caught.uniq.size
  end
end

def count_safari_species(compared_species)
  nb = 0
  caught = pbSafariState.caught_pokemon || []
  caught.each do |caught_species|
    if caught_species == compared_species
      nb += 1
    end
  end
  return nb
end

def safari_requirement_text(method_type, type_id, nb_to_catch)
  type_name = type_id ? GameData::Type.get(type_id).name : nil

  case method_type
  when :different_species
    if type_name
      return _INTL("I can only let you through if you've caught at least \\C[1]{1}\\C[0] different \\C[1]{2}-type\\C[0] Pokémon on this Safari.", nb_to_catch, type_name)
    else
      return _INTL("I can only let you through if you've caught at least \\C[1]{1}\\C[0] different species of Pokémon on this Safari.", nb_to_catch)
    end
  when :same_species
    if type_name
      return _INTL("I can only let you through if you've caught at least \\C[1]{1}\\C[0] \\C[1]{2}-type\\C[0] Pokémon of the same species on this Safari.", nb_to_catch, type_name)
    else
      return _INTL("I can only let you through if you've caught at least \\C[1]{1}\\C[0] Pokémon of the same species on this Safari.", nb_to_catch)
    end
  end
end

def safariNewAreaCheck(area_id)
  area_name = get_area_name(area_id)

  unlock_methods = pbSafariState.area_types[area_id]
  unlock_method  = unlock_methods[pbSafariState.area_unlock_methods[area_id]]
  method_type, type_id, nb_to_catch = unlock_method

  pbCallBub(2, @event_id)
  pbMessage(_INTL("Halt! This way is the \\C[1]{1}\\C[0].", area_name))
  pbCallBub(2, @event_id)
  pbMessage(safari_requirement_text(method_type, type_id, nb_to_catch))

  icons = displayCaughtPokemonIcons
  pbWait(40)
  icons.dispose

  nb_caught = count_safari_caught(method_type, type_id)
  if nb_caught >= nb_to_catch
    pbSEPlay("GUI naming confirm")
    pbCallBub(2, @event_id)
    pbMessage(_INTL("Yes! You've met the requirement. Go right ahead!"))
    return true
  else
    pbSEPlay("GUI sel buzzer")
    pbCallBub(2, @event_id)
    pbMessage(_INTL("Oh, no! You've only got {1} so far... That's not enough!", nb_caught))
    pbCallBub(2, @event_id)
    pbMessage(_INTL("You need to catch more Pokémon before I can let you through!"))
    return false
  end
end

def updateSafariBallDisplay
  return unless $PokemonTemp.overworld_safari
  pbSafariState.updateBallDisplay
end

def throw_ow_safari_ball
  template_event = TEMPLATE_EVENT_SAFARI_BALL
  position = [$game_player.x, $game_player.y]
  event = $PokemonTemp.createTempEvent(template_event, $game_map.map_id, position, $game_player.direction)
  return event
end

def use_safari_feeder(price, floating=false)
  discount = pbGet(VAR_HOENN_SAFARI_FEEDER_DISCOUNT)
  price-=discount
  if price > 0
    message = _INTL("\\GWould you like to use the Pokéblock Feeder for ${1}?",price)
  else
    message = _INTL("\\GWould you like to use the Pokéblock Feeder?",price)
  end
  if pbConfirmMessage(message)
    colors = [:red, :red, :red,
              :blue, :blue, :blue,
              :pink, :pink, :pink,
              :green, :green, :green,
              :yellow, :yellow, :yellow].sample(4)
    pbSpendMoney(price) if price > 0
    feeder_event = this_event()
    positions = [[-1,0], [1,0], [0,1], [0,-1]]
    i=0
    template_event = TEMPLATE_EVENT_POKEBLOCK

    colors.each do |color|

      block_event=$PokemonTemp.createTempEvent(template_event,
                                               $game_map.map_id,
                                               [feeder_event.x,feeder_event.y],
                                               $game_player.direction,
                                               PokeblockEvent, [color,12])
      if floating
        block_event.floating = true
        block_event.forced_bush_depth = 8
        block_event.calculate_bush_depth
      end
      block_event.jump(*positions[i])
      i+=1
    end
  end
end

def create_overworld_pokemon_event(pokemon, position, terrain, behavior_roaming = nil, behavior_noticed = nil)
  template_event = TEMPLATE_EVENT_OW_POKEMON_NORMAL

  species = pokemon[0]
  level = pokemon[1]
  event = $PokemonTemp.createTempEvent(template_event, $game_map.map_id, position, nil, DynamicOverworldPokemonEvent) do |event|
    event.setup_pokemon(species, level, terrain, behavior_roaming, behavior_noticed)
  end
  return unless event
  event.direction = [DIRECTION_LEFT, DIRECTION_RIGHT, DIRECTION_DOWN, DIRECTION_UP].sample
  playOverworldPokemonSpawnAnimation(event, terrain)
  return event
end

def safari_ball_check_collision(ball_event)
  colliding_event = $game_map.get_event_at_position(ball_event.x, ball_event.y, [ball_event.id])
  if colliding_event
    if colliding_event.is_a?(OverworldPokemonEvent)
      echoln "touched a Pokemon! #{colliding_event.name}"
      ball_event.despawn
      try_catch_safari_pokemon(colliding_event)
      renew_overworld_pokemon(colliding_event.id)
    else
      pbSEPlay("MiningPick")
      echoln "touched something that's not a Pokemon! #{colliding_event.name}"
      ball_event.despawn
    end
  end
end


def release_caught_pokemon
  allowed_pokemon = ($game_temp.last_safari_stats[0] || []).map(&:personalID)
  filter = proc {|pokemon|
      allowed_pokemon.include?(pokemon.personalID)
  }
  released = []
  pbFadeOutIn {
    scene = SafariReleaseStorageScene.new
    scene.cursormode == "multiselect"
    screen = SafariReleaseStorageScreen.new(scene, $PokemonStorage)
    screen.setFilter(filter)
    released = screen.pbStartScreen(0) # Boot PC in release only mode
  }
  nb_points = calculate_release_points(released)
  return nb_points
  echoln "Obtained #{nb_points} points for releasing Pokemon"
end

def calculate_catch_rate_points(rate)
  case rate
  when 0..45    then 4
  when 45..55   then 3
  when 55..90  then 2
  when 90..200 then 1
  else              0
  end
end

#Base points: 2
# duplicate: -1
# Shiny: +10 points
#
def calculate_release_points(released_pokemon)
  total_points = 0
  species_counts = Hash.new(0)
  released_pokemon.each { |p| species_counts[p.species] += 1 }

  total_points = 0
  released_pokemon.each do |pokemon|
    species = GameData::Species.get(pokemon.species)
    points = 2
    catch_rate_points =  calculate_catch_rate_points(species.catch_rate)
    points += catch_rate_points
    points += 10 if pokemon.shiny?
    is_duplicate = species_counts[pokemon.species] > 1
    points -= 1 if is_duplicate
    total_points += points
    echoln "calculating points for #{pokemon.species}: #{points}"
  end
  return total_points
end


class Trainer
  attr_accessor :safari_caught
end
def record_safari_catch(pokemon)
  pbSafariState.caught_pokemon = [] unless pbSafariState.caught_pokemon
  pbSafariState.caught_pokemon << pokemon# unless pbSafariState.caught_pokemon.include?(pokemon.species)
end

ANIMATION_POKEBALL = 8

MAX_THROW_DISTANCE = 4
CATCH_RATE_FLOOR   = 60
SNEAK_FLAT_BONUS   = 50
def try_catch_safari_pokemon(pokemon_event)
  pokemon_state = pokemon_event.current_state
  playAnimation(ANIMATION_POKEBALL, pokemon_event.x, pokemon_event.y)
  initial_name = pokemon_event.character_name
  pokemon_event.character_name="safari_ball_throw"
  pokemon_event.hide_notice_icon
  pokemon = pokemon_event.pokemon
  pokemon_event.lock
  pbWait(14)

  distance_from_player = pokemon_event.distance_from_player
  unnoticed = !pokemon_event.noticed_player_once

  distance = distance_from_player.clamp(1, MAX_THROW_DISTANCE)
  closeness = (MAX_THROW_DISTANCE + 1 - distance) / MAX_THROW_DISTANCE.to_f

  capture_rate = [pokemon.species_data.catch_rate, CATCH_RATE_FLOOR].max

  multiplier = unnoticed ? 1 + (2 * closeness) : 1 + closeness
  capture_rate = (capture_rate * multiplier) + (SNEAK_FLAT_BONUS * closeness)

  capture_rate = 0 if pokemon_state == :NOTICED_PLAYER

  echoln "base capture rate: #{pokemon.species_data.catch_rate}"
  echoln "safari capture rate: #{capture_rate}"
  echoln "-----"
  num_shakes = pbCaptureCalc(pokemon, capture_rate, :SAFARIBALL)

  shake = 0
  num_shakes.times do
    shake+=1
    if shake < 4
      pbSEPlay("ballshake")
    else
      pbSEPlay("Battle catch click")
    end

    pokemon_event.pattern=1
    pbWait(2)
    if shake >= 4
      spritesLoader = BattleSpriteLoader.new
      pokemon.pif_sprite = spritesLoader.obtain_pif_sprite(pokemon.species)
      showPokemonInPokeballWithMessage(pokemon.pif_sprite, _INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1",$Trainer.name,pokemon.name))
      record_safari_catch(pokemon)
      pbAddPokemonSilent(pokemon)
      pokemon_event.despawn
      return
    end
    pokemon_event.pattern=0
    pbWait(24)
  end
  playAnimation(ANIMATION_POKEBALL, pokemon_event.x, pokemon_event.y)
  pokemon_event.character_name = initial_name
  pokemon_event.show_notice_icon
  pokemon_event.unlock
end


class Event
  def prepend(callback)
    @callbacks.unshift(callback)
    return self
  end
end


Events.onAction.prepend(proc { |_sender, _e|
  next unless Settings::HOENN && $PokemonTemp.overworld_safari
  next if $game_player.jumping? || $game_player.moving?
  next if $game_player.pbFacingEvent
  next if $game_player.pbFacingTerrainTag.can_surf_freely && !$PokemonGlobal.surfing

  next if pbSafariState.ballcount <= 0
  pbSafariState.ballcount -= 1
  updateSafariBallDisplay
  ball_event = throw_ow_safari_ball
  check_nb_safari_balls_left
})

def check_nb_safari_balls_left
  echoln "#{pbSafariState.ballcount} balls left"
  if pbSafariState.ballcount < 0  #when directly zero, the player can still run around and find another pile
    pbMessage(_INTL("PA:  Ding-dong!\1"))
    pbMessage(_INTL("PA:  Your safari game is over!"))
    pbSafariState.decision = 1
    pbSafariState.pbGoToStart
  end
end


#Simplified copy of the method in PokeBattle to be used outside of a battle (safari zone)
def pbCaptureCalc(pkmn, catch_rate, ball)
  battler = PokeBattle_FakeBattler.new(nil,0, pkmn)
  return 4 if $DEBUG && Input.press?(Input::CTRL)
  # Get a catch rate if one wasn't provided
  catch_rate = pkmn.species_data.catch_rate if !catch_rate

  # First half of the shakes calculation
  a = battler.totalhp
  b = battler.hp
  x = ((3 * a - 2 * b) * catch_rate.to_f) / (3 * a)
  # Calculation modifiers
  if battler.status == :SLEEP || battler.status == :FROZEN
    x *= 2.5
  elsif battler.status != :NONE
    x *= 1.5
  end
  x = x.floor
  x = 1 if x < 1
  # Definite capture, no need to perform randomness checks
  return 4 if x >= 255 || BallHandlers.isUnconditional?(ball, self, battler)
  # Second half of the shakes calculation
  y = (65536 / ((255.0 / x) ** 0.1875)).floor

  # Calculate the number of shakes
  numShakes = 0
  for i in 0...4
    break if numShakes < i
    numShakes += 1 if rand(65536) < y
  end
  return numShakes
end


def placePokeblock()
  block = pbPokeblockCase(false)
  pbRemovePokeblock(block)
  return block
end

def safari_ball_pile(min_nb, max_nb)
  if min_nb == max_nb
    nb = min_nb
  else
    nb = rand(min_nb...max_nb)
  end
  pbSafariState.ballcount+=nb
  pbMEPlay("Item get")
  pbMessage(_INTL("{1} found {2} \\C[1]Safari Balls\\C[0]!", $Trainer.name, nb))
  updateSafariBallDisplay()
end

def respawn_safari_ball_piles
  HOENN_SAFARI_MAPS.each do |map_id|
    map = $MapFactory.getMapNoAdd(map_id)
    for event_data in map.events
      event_id = event_data[0]
      event = event_data[1]
      if event.name == "SafariBalls"
        pbSetSelfSwitch(event.id,"A",false,map_id)
      end
    end
  end
end

SWITCH_UNLOCKED_WOODLANDS = 2252
SWITCH_UNLOCKED_WETLANDS = 2253
SWITCH_UNLOCKED_BADLANDS = 2254
SWITCH_UNLOCKED_GRASSLANDS = 2255
SWITCH_UNLOCKED_LAKE = 2256
SWITCH_UNLOCKED_MOUNTAINS = 2257

def list_unlocked_zones
  unlocked = []
  unlocked << :woodland if $game_switches[SWITCH_UNLOCKED_WOODLANDS]
  unlocked << :wetland if $game_switches[SWITCH_UNLOCKED_WETLANDS]
  unlocked << :badland if $game_switches[SWITCH_UNLOCKED_BADLANDS]
  unlocked << :grassland if $game_switches[SWITCH_UNLOCKED_GRASSLANDS]
  unlocked << :lakeland if $game_switches[SWITCH_UNLOCKED_LAKE]
  unlocked << :mountains if $game_switches[SWITCH_UNLOCKED_MOUNTAINS]
  return unlocked
end