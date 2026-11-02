#Tiles that change to a different tile when the player or an event steps on it.
# Used for suspended bridges. Maybe some other cool uses.
#
# shifting_tile_vertical -> shifts all tiles aligned vertically with the current one to the tile to the right of it in the tileset.
# shifting_tile_horizontal -> shifts all tiles aligned horizontally with the current one to the tile under it in the tileset.

class Game_Temp
  attr_accessor :shifting_tiles
end

def pbGetShiftingTile(map, x, y)
  return nil unless map.valid?(x, y)
  for layer in [2, 1, 0]
    tile_id = map.data[x, y, layer]
    next if tile_id.nil?
    terrain_tag = GameData::TerrainTag.try_get(map.terrain_tags[tile_id])
    next unless terrain_tag
    next if terrain_tag.bridge && $PokemonGlobal.bridge == 0
    return [layer, tile_id, :vertical]   if terrain_tag.shifting_tile_vertical
    return [layer, tile_id, :horizontal] if terrain_tag.shifting_tile_horizontal
  end
  return nil
end

def pbShiftedTileId(tile_id, mode)
  return (mode == :horizontal) ? tile_id + 8 : tile_id + 1
end

def pbCollectShiftingTiles(map, mx, my, layer, tile_id, mode)
  tiles = [[mx, my, layer, tile_id]]
  dirs = (mode == :vertical) ? [[0, -1], [0, 1]] : [[-1, 0], [1, 0]]

  dirs.each do |dx, dy|
    x, y = mx + dx, my + dy
    loop do
      result = pbGetShiftingTile(map, x, y)
      break unless result && result[2] == mode
      tiles << [x, y, result[0], result[1]]
      x += dx
      y += dy
    end
  end
  return tiles
end

Events.onStepTakenFieldMovement += proc { |_sender, e|
  event = e[0]
  thistile = $MapFactory.getRealTilePos(event.map.map_id, event.x, event.y)
  map = $MapFactory.getMap(thistile[0])
  mx, my = thistile[1], thistile[2]

  $game_temp.shifting_tiles ||= {}
  key = event.object_id
  prev = $game_temp.shifting_tiles[key]
  current = pbGetShiftingTile(map, mx, my)

  if current
    layer, tile_id, mode = current
    tiles = pbCollectShiftingTiles(map, mx, my, layer, tile_id, mode)

    new_coords = tiles.map { |t| t[0, 3] }.sort
    prev_coords = prev&.map { |t| [t[:x], t[:y], t[:layer]] }&.sort

    unless new_coords == prev_coords
      if prev
        prev_map = $MapFactory.getMap(prev.first[:map_id])
        prev.each { |t| prev_map.set_tile(t[:x], t[:y], t[:layer], t[:original]) }
      end
      tiles.each { |x, y, layer, tid| map.set_tile(x, y, layer, pbShiftedTileId(tid, mode)) }
      $game_temp.shifting_tiles[key] = tiles.map { |x, y, layer, tid|
        { map_id: thistile[0], x: x, y: y, layer: layer, original: tid }
      }
    end
  elsif prev
    prev_map = $MapFactory.getMap(prev.first[:map_id])
    prev.each { |t| prev_map.set_tile(t[:x], t[:y], t[:layer], t[:original]) }
    $game_temp.shifting_tiles.delete(key)
  end
}