PUDDLE_ANIMATION_ID = 31
Events.onStepTakenFieldMovement += proc { |_sender, e|
  event = e[0]
  if $scene.is_a?(Scene_Map)
    event.each_occupied_tile do |x, y|
      mapTerrainTag = $MapFactory.getTerrainTag(event.map.map_id, x, y, false)
      if $PokemonGlobal.surfing
        if isWaterTerrain?(mapTerrainTag) && !event.always_on_top
          $scene.spriteset.addUserAnimation(PUDDLE_ANIMATION_ID, event.x, event.y, true, 0)
          break
        end
      elsif $PokemonGlobal.boat
        $scene.spriteset.addUserAnimation(PUDDLE_ANIMATION_ID, event.x, event.y-2, true, 0)
        break
      else
        if mapTerrainTag == 16
          pbSEPlay("puddle", 100) if event == $game_player && !$PokemonGlobal.surfing
          $scene.spriteset.addUserAnimation(PUDDLE_ANIMATION_ID, event.x, event.y, true, 0)
          break
        end
      end
    end
  end
}

def isWaterTerrain?(tag)
  return [5, 6, 7, 9, 16, 27].include?(tag)
end
