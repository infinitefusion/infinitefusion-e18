MULTIPLE_WILD_OW_FUSE_CHANCE = 35

class Game_Event
  def player_near_event?(radius = 1)
    dx = $game_player.x - @x
    dy = $game_player.y - @y
    distance = Math.sqrt(dx * dx + dy * dy)
    return distance <= radius
  end

  def playerPositionRelativeToEvent
    dx = $game_player.x - @x
    dy = $game_player.y - @y

    # Quick map for front/back detection
    front = case @direction
            when DIRECTION_UP then dy < 0
            when DIRECTION_DOWN then dy > 0
            when DIRECTION_LEFT then dx < 0
            when DIRECTION_RIGHT then dx > 0
            end

    back = case @direction
           when DIRECTION_UP then dy > 0
           when DIRECTION_DOWN then dy < 0
           when DIRECTION_LEFT then dx > 0
           when DIRECTION_RIGHT then dx < 0
           end

    # Side: adjacent but not in front or back
    side = !front && !back && (dx.abs + dy.abs == 1)

    return { front: front, back: back, side: side, dx: dx, dy: dy }
  end

end

def fuse_wild_pokemon_animation(battler1, battler2)
  if battler1.ow_coordinates && battler2.ow_coordinates
    playAnimation(Settings::FUSE_ANIMATION_ID, battler1.ow_coordinates[0], battler1.ow_coordinates[1])
    playAnimation(Settings::FUSE_ANIMATION_ID, battler2.ow_coordinates[0], battler2.ow_coordinates[1])
    pbWait(16)
  end
end

def trigger_overworld_wild_battle
  return if $PokemonTemp.overworld_wild_battle_triggered
  $PokemonTemp.overworld_wild_battle_triggered = true
  case $PokemonTemp.overworld_wild_battle_participants.length
  when 0
    $PokemonTemp.overworld_wild_battle_triggered = false
    return
  when 2
    battler1 = $PokemonTemp.overworld_wild_battle_participants[0].pokemon
    battler2 = $PokemonTemp.overworld_wild_battle_participants[1].pokemon
    should_fuse = rand(100) <= MULTIPLE_WILD_OW_FUSE_CHANCE
    should_fuse = false if battler1.isFusion? || battler2.isFusion? #&& rand(100) <= MULTIPLE_WILD_OW_FUSE_CHANCE
    should_fuse = false if battler1.shiny? || battler2.shiny?
    if should_fuse
      fusion_species = fusionOf(battler1.species, battler2.species)
      fusion_level = (battler1.level + battler2.level) / 2.ceil
      fuse_wild_pokemon_animation(battler1, battler2)
      checkWildFusePokemonChallenge(battler1, battler2)
      pbWildBattleSpecific(Pokemon.new(fusion_species, fusion_level))
    else
      pb1v2WildBattleSpecific(battler1, battler2)
    end
  when 3
    battler1 = $PokemonTemp.overworld_wild_battle_participants[0].pokemon
    battler2 = $PokemonTemp.overworld_wild_battle_participants[1].pokemon
    battler3 = $PokemonTemp.overworld_wild_battle_participants[2].pokemon
    pb1v3WildBattleSpecific(battler1, battler2, battler3)
  when 1
    battler = $PokemonTemp.overworld_wild_battle_participants[0].pokemon
    if isWeatherWind?()
      event_x = $PokemonTemp.overworld_wild_battle_participants[0].x
      if event_x && event_x > $game_player.x
        $PokemonTemp.recordBattleRule("windside", 1)  #event to the right of player. Tailwind for event
      elsif event_x && event_x < $game_player.x
        $PokemonTemp.recordBattleRule("windside", 0) #player to the right of event. Tailwind for player
      end
    end
    pbWildBattleSpecific(battler)
  else
    # shouldn"t happen
    battler = $PokemonTemp.overworld_wild_battle_participants[0].pokemon
    pbWildBattleSpecific(battler)
    $PokemonTemp.overworld_wild_battle_participants.shift
  end

  $PokemonTemp.overworld_wild_battle_participants.each do |ow_pokemon|
    ow_pokemon.despawn
  end
  $PokemonTemp.overworld_wild_battle_participants = []

  $PokemonTemp.overworld_wild_battle_triggered = false

end

def overworldPokemonCatchOffGuard()
  event = $MapFactory.getMap(@map_id).events[@event_id]
  return unless event && event.is_a?(OverworldPokemonEvent)
  unless event.current_state == :NOTICED_PLAYER || event.noticed_player_once
    if event.last_facing_direction == $game_player.direction
      setBattleRule("surprise")
      event.set_noticed_sprite
      playAnimation(Settings::EXCLAMATION_ANIMATION_ID, event.x, event.y)
      pbSEPlay("jump")
      event.turn_away_from_player
      event.jump(0,0)
      pbWait(8)
      event.set_roaming_sprite
      $Trainer.stats&.incr_nb_pokemon_surprised
      check_offguard_challenge(event)
    end
  end
  event.overworldPokemonBattle
end

def check_offguard_challenge(pokemon_event)
  return unless pokemon_event.is_a?(OverworldPokemonEvent)
  $Trainer.complete_challenge(:encounter_offguard_any)
  case pokemon_event.behavior_noticed
  when :aggressive
    $Trainer.complete_challenge(:encounter_offguard_aggressive)
  when :curious
    $Trainer.complete_challenge(:encounter_offguard_curious)
  when :skittish, :flee
    $Trainer.complete_challenge(:encounter_offguard_skittish)
  end
end

# Used to be called from spawned overworld Pokemon events, now handled directly in OverworldPokemonEvent
# Kept here, empty in case I forgot to change some for the manual overworld Pokemon
def overworldPokemonBehavior()
  # event = $MapFactory.getMap(@map_id).events[@event_id]
  # return unless event && event.is_a?(OverworldPokemonEvent)
  #
  # # Todo: There's a glitch where static overowrld pokemon also appear on connecting maps.
  # # They don't have any graphics. This just deactivetes their behavior too which makes them
  # # harmless - player won't know they're there... But they are, technically.
  # # This doesn't actually fix the glitch - just makes it invisible.
  # # -
  # # It would be good to make it so that the events only appear in their own map in the first place.
  # return unless @map_id == $game_map.map_id
  # #
  # #
  #
  # begin
  #   if $game_temp.message_window_showing
  #     event.pause_movement
  #   else
  #     event.update_behavior
  #   end
  # rescue
  #   return
  # end
end

def overworldPokemonDetect(radius = 1)
  event = $MapFactory.getMap(@map_id).events[@event_id]
  return pbPlayerInEventCone?(event, $game_player, radius)
end



