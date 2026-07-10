# class Game_Temp
#   attr_accessor :temp_waterfall
#   attr_accessor :waterfall_sprites
#   attr_accessor :splash_sprites
#   attr_accessor :splash_coords
#
#
# end
#
# def generate_dynamic_waterfall(starting_x_position, waterfall_top_y, thickness=1)
#   map_height = $game_map.height - 8
#   echoln map_height
#
#   boulder_positions = []
#   CIANWOOD_BOULDER_IDS.each do |event_id|
#     event = $game_map.events[event_id]
#     boulder_positions << [event.x, event.y]
#   end
#
#   # Add columns from starting_x_position to the right
#   active_columns = []
#   (starting_x_position...(starting_x_position + thickness)).each do |x|
#     break if x >= $game_map.width  # Don't go past map edge
#     active_columns << { x: x, y: waterfall_top_y }
#   end
#
#   visited = []
#   final_coords = []
#   splash_coords = []
#
#   while !active_columns.empty?
#     new_columns = []
#
#     active_columns.each do |segment|
#       x = segment[:x]
#       y = segment[:y]
#       next if visited.include?([x, y])
#
#       visited << [x, y]
#
#       while y < map_height
#         pos = [x, y]
#         final_coords << pos
#
#         if boulder_positions.include?(pos)
#           splash_coords << [x - 1, y] if x > 0
#           splash_coords << [x + 1, y] if x < $game_map.width - 1
#           splash_coords << [x, y]
#
#           new_y = y
#           new_columns << { x: x - 1, y: new_y } if x > 0 && !visited.include?([x - 1, new_y])
#           new_columns << { x: x + 1, y: new_y } if x < $game_map.width - 1 && !visited.include?([x + 1, new_y])
#           break
#         end
#
#         #currents section
#         if y > CIANWOOD_WATERFALL_EDGE+10
#           if !$game_map.passable?(x, y + 1, DIRECTION_DOWN)
#             splash_coords << [x, y + 1] if y + 1 < $game_map.height
#             break
#           end
#         end
#
#         if y == CIANWOOD_WATERFALL_EDGE
#           splash_coords << [x, y]
#         end
#
#         if y == map_height
#           splash_coords << [x, y]
#         end
#
#         y += 1
#       end
#     end
#
#     active_columns = new_columns
#   end
#
#   $game_temp.temp_waterfall = final_coords.uniq
#   $game_temp.splash_coords = splash_coords.uniq
#   echoln $game_temp.temp_waterfall
#   draw_waterfall_layer
# end
#
# def draw_waterfall_layer
#   return if !$game_temp.temp_waterfall || $game_temp.temp_waterfall.empty?
#
#   # Clear previous sprites
#   if $game_temp.waterfall_sprites
#     $game_temp.waterfall_sprites.each(&:dispose)
#   end
#   if $game_temp.splash_sprites
#     $game_temp.splash_sprites.each(&:dispose)
#   end
#
#   $game_temp.waterfall_sprites = []
#   $game_temp.splash_sprites = []
#
#   tile_size = 32
#   waterfall_tile_id = 0  # Waterfall
#
#   splash_tile_id = 4  # Splash impact tile, assuming we have this in the tileset
#   tileset = RPG::Cache.tileset($game_map.tileset_name)
#
#   # Draw waterfall tiles
#   $game_temp.temp_waterfall.each do |x, y|
#     sprite = Sprite.new(Spriteset_Map.viewport)
#
#     sprite.z = 10
#     sprite.x = x * tile_size
#     sprite.y = y * tile_size
#
#     sprite.bitmap = Bitmap.new(tile_size, tile_size)
#     source_rect = Rect.new(waterfall_tile_id * tile_size,0, tile_size, tile_size)  # Frame 0
#     sprite.bitmap.blt(0, 0, tileset, source_rect)
#
#     # Store metadata for animation
#     sprite.instance_variable_set(:@frame_offset, rand(3))  # Optional: make them start at different frames
#     sprite.instance_variable_set(:@tile_x, x)
#     sprite.instance_variable_set(:@tile_y, y)
#
#     $game_temp.waterfall_sprites << sprite
#   end
#
#   # Draw splash impact tiles
#   $game_temp.splash_coords.each do |x, y|
#     sprite = Sprite.new(Spriteset_Map.viewport)
#     sprite.z = 300  # Draw splash above the waterfall
#     sprite.x = x * tile_size
#     sprite.y = y * tile_size
#
#     sprite.bitmap = Bitmap.new(tile_size, tile_size)
#     source_rect = Rect.new(splash_tile_id * tile_size,1, tile_size, tile_size)  # Splash frame 0
#     sprite.bitmap.blt(0, 0, tileset, source_rect)
#
#     # Store metadata for splash animation
#     sprite.instance_variable_set(:@frame_offset, rand(3))  # Optional: make them start at different frames
#     sprite.instance_variable_set(:@tile_x, x)
#     sprite.instance_variable_set(:@tile_y, y)
#
#     $game_temp.splash_sprites << sprite
#   end
# end
#
#
#
#
# CIANWOOD_BOULDER_IDS = [2,3,5,6,
#                         4 ]#chuck head
# CIANWOOD_WATERFALL_EDGE =19
#
#
# def player_on_temp_waterfall?
#   return false if !$game_temp.temp_waterfall
#
#   boulder_positions = []
#   CIANWOOD_BOULDER_IDS.each do |event_id|
#     event = $game_map.events[event_id]
#     boulder_positions << [event.x, event.y]
#   end
#
#   # Return false if a boulder is directly below the player
#   return false if boulder_positions.include?([$game_player.x, $game_player.y + 1])
#
#   return $game_temp.temp_waterfall.any? { |x, y, _| x == $game_player.x && y == $game_player.y }
# end
#
#
#
#
#
#
#
# class Spriteset_Map
#   alias_method :cianwood_waterfall_update, :update
#   def update
#     cianwood_waterfall_update
#
#     waterfall_edge = CIANWOOD_WATERFALL_EDGE
#     if $game_temp.waterfall_sprites
#       frame_count = Graphics.frame_count
#       tile_size = 32
#       autotile_id = 0
#       tileset = RPG::Cache.tileset($game_map.tileset_name)
#
#       # Animate waterfall sprites
#       $game_temp.waterfall_sprites.each do |sprite|
#         tile_y = sprite.instance_variable_get(:@tile_y)
#         frame_offset = sprite.instance_variable_get(:@frame_offset)
#
#         # Animate every 15 frames (change for speed control)
#         animation_frame = (frame_count / 15 + tile_y - frame_offset) % 4
#
#         tileset_x = (autotile_id * 4 + animation_frame) * tile_size
#         tileset_y = tile_y >= waterfall_edge ? tile_size : 0
#         source_rect = Rect.new(tileset_x,tileset_y, tile_size, tile_size)
#
#         sprite.bitmap.clear
#         sprite.bitmap.blt(0, 0, tileset, source_rect)
#
#         # Scroll with map
#         sprite.ox = $game_map.display_x / 4
#         sprite.oy = $game_map.display_y / 4
#       end
#
#       # Animate splash sprites
#       $game_temp.splash_sprites.each do |sprite|
#         tile_y = sprite.instance_variable_get(:@tile_y)
#         frame_offset = sprite.instance_variable_get(:@frame_offset)
#
#         # Animate every 10 frames for splash (you can adjust this speed)
#         offset = (autotile_id * 4 + 4) * tile_size
#         animation_frame = (frame_count / 10 + tile_y + frame_offset) % 4
#         source_rect = Rect.new((autotile_id * 4 + animation_frame) * tile_size + offset, 0, tile_size, tile_size)
#
#         sprite.bitmap.clear
#         sprite.bitmap.blt(0, 0, tileset, source_rect)
#
#         # Scroll with map
#         sprite.ox = $game_map.display_x / 4
#         sprite.oy = $game_map.display_y / 4
#       end
#     end
#   end
# end
