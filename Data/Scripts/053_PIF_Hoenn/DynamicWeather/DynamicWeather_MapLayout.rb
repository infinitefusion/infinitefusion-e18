def update_neighbor_map
  @neighbors_maps = generate_neighbor_map_from_town_map
  @neighbors_maps = normalize_neighbors(@neighbors_maps)
end

def normalize_neighbors(map)
  fixed_map = {}

  map.each do |map_id, neighbors|
    neighbors.each do |neighbor_id|
      fixed_map[map_id] ||= []
      fixed_map[neighbor_id] ||= []
      fixed_map[map_id] |= [neighbor_id]
      fixed_map[neighbor_id] |= [map_id]
    end
  end

  fixed_map
end
def generate_neighbor_map_from_town_map
  mapdata = pbLoadTownMapData
  neighbor_map = {}
  name_to_map_id = {}
  name_grid = {}

  # First, build:
  # - a grid: [x, y] => location_name
  # - a lookup: location_name => map_id (if one exists)
  mapdata.each do |region|
    maps_array = region[2]
    maps_array.each do |entry|
      x, y, name, _showname, map_id = entry
      next unless name.is_a?(String) && !name.empty?

      name_grid[[x, y]] = name
      if map_id.is_a?(Integer) #&& !is_indoor_map?(map_id)
        name_to_map_id[name] ||= map_id  # Only keep the first valid one
      end
    end
  end

  # Now, check each tile against its neighbors (up/down/left/right)
  name_grid.each do |(x, y), name|
    [[0, -1], [0, 1], [-1, 0], [1, 0]].each do |dx, dy|
      neighbor_coords = [x + dx, y + dy]
      neighbor_name = name_grid[neighbor_coords]

      map1 = name_to_map_id[name]
      map2 = name_to_map_id[neighbor_name]
      next unless map1 && map2
      next if map1 == map2  # Prevent self-linking

      neighbor_map[map1] ||= []
      neighbor_map[map2] ||= []

      neighbor_map[map1] << map2 unless neighbor_map[map1].include?(map2)
      neighbor_map[map2] << map1 unless neighbor_map[map2].include?(map1)
    end
  end
  return neighbor_map
end




def generate_neighbor_map_from_connections
  raw_connections = MapFactoryHelper.getMapConnections
  neighbor_map = {}

  raw_connections.each_with_index do |conns, map_id|
    next if conns.nil? || conns.empty?

    conns.each do |conn|
      next unless conn.is_a?(Array) && conn.length >= 4
      map1 = conn[0]
      map2 = conn[3]

      next unless map1.is_a?(Integer) && map2.is_a?(Integer)
      #next if is_indoor_map?(map1) || is_indoor_map?(map2)

      neighbor_map[map1] ||= []
      neighbor_map[map2] ||= []
      neighbor_map[map1] << map2 unless neighbor_map[map1].include?(map2)
      neighbor_map[map2] << map1 unless neighbor_map[map2].include?(map1)
    end
  end

  return neighbor_map
end

def is_outdoor_map?(map_id = $game_map.map_id)
  return !is_indoor_map?(map_id)
end
def is_indoor_map?(map_id = $game_map.map_id)
  mapMetadata = GameData::MapMetadata.try_get(map_id)
  return true if !mapMetadata
  return !mapMetadata.outdoor_map
end