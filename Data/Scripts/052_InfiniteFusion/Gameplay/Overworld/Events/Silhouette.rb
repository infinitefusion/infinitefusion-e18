class PokemonTemp
  # def pbClearAllTempEvents()
  #   echoln @tempEvents
  #   @tempEvents.keys.each {|map_id|
  #     map = $MapFactory.getMap(map_id,false)
  #     @tempEvents[map_id].each { |event|
  #        map.events[event.id] = nil
  #     }
  #   }
  #   @tempEvents={}
  #   @silhouetteDirection=nil
  # end

  def pbClearSilhouetteTempEvents()
    echoln @tempEvents
    @tempEvents.keys.each {|map_id|
      map = $MapFactory.getMap(map_id,false)
      @tempEvents[map_id].each { |event|
        #this deletes the event after a small fadeout
        $game_self_switches[[map_id, event.id, "B"]] = true if map.events[event.id]
      }
    }
    @tempEvents={}
    @silhouetteDirection=nil
  end
end


def isNightmareEffect()
  return $game_switches[SWITCH_NIGHTMARE_EFFECT] && PBDayNight.isNight?
end


# def playNightmareEffect()
#   frame=1
#   while true
#     frame +=1
#     frame = 1 if frame >4
#     filename = "nightmare"+frame.to_s
#     picture = Game_Picture.new(40)
#     picture.show(filename, 0, 0, 0, 200, 200, 255, 0)
#     pbWait(3)
#     picture.erase
#   end
#
# end

Events.onStepTaken += proc { |sender, e|
  next if !$PokemonTemp.silhouetteDirection
  if $PokemonTemp.silhouetteDirection && $PokemonTemp.silhouetteDirection == $game_player.direction
    $PokemonTemp.pbClearSilhouetteTempEvents
    $PokemonTemp.silhouetteDirection = nil
  end
}

Events.onStepTaken += proc { |sender, e|
  next if !$scene.is_a?(Scene_Map)
  next if !isNightmareEffect()
  steps_constant_offset = 40
  steps_chance=100
  minimum_steps=10

  steps_nb = rand(steps_chance)+pbGet(VAR_KARMA)+steps_constant_offset
  steps_nb = minimum_steps if steps_nb<minimum_steps
  next if $PokemonGlobal.stepcount % steps_nb != 0
  next if !isOutdoor()
  $PokemonTemp.pbClearSilhouetteTempEvents
  spawnSilhouette()
}
Events.onMapChange += proc { |sender, e|
  next unless Settings::KANTO
  next if $PokemonTemp.tempEvents.empty?
  $PokemonTemp.pbClearTempEvents()
}






# def launchSilhouetteCommonEvent(event)
#   $scene.spriteset.addUserAnimation(VIRUS_ANIMATION_ID, event.x, event.y, true)
#   $PokemonTemp.pbClearTempEvents
#   $PokemonTemp.silhouetteDirection = nil
#   pbCommonEvent(COMMON_EVENT_SILHOUETTE)
# end



#
# Faces the same way as player
# Disappears as soon as player takes a step in same direction as event
# -> when talk to it:
# ghost animation
# Message:
# A voice echoed from somewhere...
# [NEXT HINT] (ex: The house in Vermillion City...)
#

def generate_silhouette_event(id)
  $game_self_switches[[MAP_TEMPLATE_EVENTS, TEMPLATE_EVENT_SILHOUETTE, "A"]] = false
  $game_self_switches[[MAP_TEMPLATE_EVENTS, TEMPLATE_EVENT_SILHOUETTE, "B"]] = false
  template_event = $MapFactory.getMap(MAP_TEMPLATE_EVENTS,false).events[TEMPLATE_EVENT_SILHOUETTE]
  new_event= template_event.event.dup
  new_event.name = "temp_silhouette"
  new_event.id = id
  return new_event
end

def spawnSilhouette()
  found_available_position = false
  max_tries = 10
  current_try = 0
  while !found_available_position
    x, y = getRandomPositionOnPerimeter(15, 11, $game_player.x, $game_player.y, 2)
    found_available_position = true if $game_map.passable?(x, y, $game_player.direction)
    current_try += 1
    return if current_try > max_tries
  end
  key_id = ($game_map.events.keys.max || -1) + 1
  rpgEvent = generate_silhouette_event(key_id)
  #rpgEvent = RPG::Event.new(x,y)

  gameEvent = Game_Event.new($game_map.map_id, rpgEvent, $game_map)
  direction = $game_player.direction #[2,4,6,8].sample
  gameEvent.direction = direction
  $PokemonTemp.silhouetteDirection = direction
  $game_map.events[key_id] = gameEvent


  gameEvent.moveto(x, y)
  #-------------------------------------------------------------------------
  #updating the sprites

  sprite = Sprite_Character.new(Spriteset_Map.viewport, $game_map.events[key_id])
   $scene.spritesets[$game_map.map_id] = Spriteset_Map.new($game_map) if $scene.spritesets[$game_map.map_id] == nil
   $scene.spritesets[$game_map.map_id].character_sprites.push(sprite)
  #$PokemonTemp.addTempEvent($game_map.map_id, gameEvent)
end