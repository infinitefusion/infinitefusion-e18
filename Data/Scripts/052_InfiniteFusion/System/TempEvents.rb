class PokemonTemp
  attr_accessor :tempEvents
  attr_accessor :silhouetteDirection

  def tempEvents
    @tempEvents = {} if !@tempEvents
    return @tempEvents
  end

  def pbClearTempEvents()
    return if !@tempEvents || @tempEvents.empty?
    @tempEvents.keys.each { |map_id|
      map = $MapFactory.getMapNoAdd(map_id)
      @tempEvents[map_id].each { |event|
        $game_self_switches[[map_id, event.id, "A"]] = false
        $game_self_switches[[map_id, event.id, "B"]] = false
        $game_self_switches[[map_id, event.id, "C"]] = false
        $game_self_switches[[map_id, event.id, "D"]] = false

        map.events[event.id].erase if map.events[event.id]
      }
    }
    @tempEvents = {}
    @silhouetteDirection = nil
  end

  def createTempEvent(eventTemplateID, map_id, position = [0, 0],direction=nil, event_class = Game_Event)
    return unless $scene.is_a?(Scene_Map)
    template_event = $MapFactory.getMap(MAP_TEMPLATE_EVENTS,false).events[eventTemplateID]
    key_id = ($game_map.events.keys.max || -1) + 1

    rpgEvent= template_event.event.dup
    rpgEvent.id = key_id
    gameEvent = event_class.new($game_map.map_id, rpgEvent, $game_map)

    gameEvent.moveto(position[0], position[1])
    gameEvent.direction = direction if direction

    yield gameEvent if block_given?

    registerTempEvent(map_id, gameEvent)

    $game_map.events[key_id] = gameEvent
    sprite = Sprite_Character.new(Spriteset_Map.viewport, $game_map.events[key_id])
    $scene.spritesets[$game_map.map_id] = Spriteset_Map.new($game_map) if $scene.spritesets[$game_map.map_id] == nil
    $scene.spritesets[$game_map.map_id].character_sprites.push(sprite)
    return gameEvent
  end

  def registerTempEvent(map, event)
    @tempEvents = {} if !@tempEvents
    mapEvents = @tempEvents.has_key?(map) ? @tempEvents[map] : []
    mapEvents.push(event)
    @tempEvents[map] = mapEvents
  end

end

