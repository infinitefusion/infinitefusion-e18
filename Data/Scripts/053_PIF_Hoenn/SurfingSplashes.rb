# frozen_string_literal: true
SURF_SPLASH_ANIMATION_ID = 31

class Game_Temp
  attr_accessor :surf_patches

  def initializeSurfPatches
    @surf_patches = []
  end

  def clearSurfSplashPatches
    return unless @surf_patches
    @surf_patches.clear
  end
end

class Spriteset_Map
  alias surf_patch_update update
  def update
    surf_patch_update
    return unless $scene.is_a?(Scene_Map)
    return unless Settings::GAME_ID == :IF_HOENN
    return unless $PokemonGlobal.surfing
    return if Graphics.frame_count % 60 != 0
    animate_surf_water_splashes
  end
end

class SurfPatch
  MAX_NUMBER_SURF_SPLASHES = 4

  attr_accessor :shape

  def initialize(patch_size)
    x, y = getRandomPositionOnPerimeter(8, 6, $game_player.x, $game_player.y, 2)
    variance = rand(5..8)
    @shape = getRandomSplashPatch(patch_size, x, y, variance)
  end

  def getRandomSplashPatch(tile_count, center_x, center_y, variance = rand(4))
    return [] if tile_count <= 0

    center_pos = getRandomPositionOnPerimeter(tile_count, tile_count, center_x, center_y, variance)
    area = [center_pos]
    visited = {}  # Use hash with key format "x,y" for O(1) lookups
    visited["#{center_pos[0]},#{center_pos[1]}"] = true
    queue = [center_pos]

    # Pre-shuffle directions once
    directions = [[1, 0], [-1, 0], [0, 1], [0, -1],
                  [1, 1], [-1, -1], [1, -1], [-1, 1]].shuffle

    map_id = $game_map.map_id  # Cache map_id

    while area.length < tile_count && !queue.empty?
      current = queue.sample
      queue.delete(current)
      cx, cy = current

      directions.take(rand(1..4)).each do |dx, dy|
        nx, ny = cx + dx, cy + dy
        key = "#{nx},#{ny}"
        next if visited[key]

        # Check terrain validity immediately before adding
        terrain = $MapFactory.getTerrainTag(map_id, nx, ny, false)
        next unless terrain&.can_surf
        next unless $game_map.playerPassable?(nx, ny, 2)

        visited[key] = true
        new_pos = [nx, ny]
        area << new_pos
        queue << new_pos

        break if area.length >= tile_count
      end
    end

    area
  end
end

def animate_surf_water_splashes
  return unless $game_temp.surf_patches

  $game_temp.surf_patches.each do |patch|
    next if patch.nil? || patch.shape.empty?
    patch.shape.each do |x_pos, y_pos|
      $scene.spriteset.addUserAnimation(SURF_SPLASH_ANIMATION_ID, x_pos, y_pos, true, -1)
    end
  end
end

def try_spawn_surf_water_splashes
  return if $PokemonGlobal.stepcount % 5 != 0
  return unless rand < 0.1
  spawnSurfSplashPatch
end

# Events.onStepTaken += proc { |sender, e|
#   next unless $scene.is_a?(Scene_Map)
#   next unless Settings::GAME_ID == :IF_HOENN
#   next unless $PokemonGlobal.surfing
#
#   player_pos = [$game_player.x, $game_player.y]  # Cache player position
#
#   if $game_temp.surf_patches
#     # Use reverse_each to safely delete while iterating
#     $game_temp.surf_patches.reverse_each.with_index do |patch, reverse_idx|
#       next unless patch && patch.shape
#
#       if patch.shape.include?(player_pos)
#         next if rand(100) > 25
#
#         # Calculate actual index for deletion
#         actual_idx = $game_temp.surf_patches.length - 1 - reverse_idx
#         $game_temp.surf_patches.delete_at(actual_idx)
#
#         echoln "surf patch encounter!"
#         wild_pokemon = $PokemonEncounters.choose_wild_pokemon(:Water)
#         if wild_pokemon
#           pbWildBattle(wild_pokemon[0], wild_pokemon[1])
#         else
#           pbItemBall(:OLDBOOT)
#         end
#         break
#       end
#     end
#   end
#
#   try_spawn_surf_water_splashes
# }

def spawnSurfSplashPatch
  $game_temp.initializeSurfPatches unless $game_temp.surf_patches

  patch_size = rand(3..6)  # Faster than .sample for small ranges
  splash_patch = SurfPatch.new(patch_size)
  $game_temp.surf_patches << splash_patch
  $game_temp.surf_patches.shift if $game_temp.surf_patches.length > SurfPatch::MAX_NUMBER_SURF_SPLASHES
  echoln $game_temp.surf_patches
end