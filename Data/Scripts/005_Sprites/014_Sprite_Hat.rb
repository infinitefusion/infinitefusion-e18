class Sprite_Hat < Sprite_Wearable
  def initialize(player_sprite, filename, action, viewport)
    super
    @relative_z = 2
    #@sprite.z = @player_sprite.z + 2

  end

  # def set_sprite_position(action, direction, current_frame)
  #   @sprite.x = @player_sprite.x - @player_sprite.ox
  #   @sprite.y = @player_sprite.y - @player_sprite.oy
  #   case action
  #   when "run"
  #     if direction == DIRECTION_DOWN
  #       apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_DOWN, current_frame)
  #     elsif direction == DIRECTION_LEFT
  #       apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_LEFT, current_frame)
  #     elsif direction == DIRECTION_RIGHT
  #       apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_RIGHT, current_frame)
  #     elsif direction == DIRECTION_UP
  #       apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_UP, current_frame)
  #     end
  #   when "surf"
  #     if direction == DIRECTION_DOWN
  #       apply_sprite_offset(Outfit_Offsets::SURF_OFFSETS_DOWN,current_frame)
  #     elsif direction == DIRECTION_LEFT
  #       apply_sprite_offset( Outfit_Offsets::SURF_OFFSETS_LEFT,current_frame)
  #     elsif direction == DIRECTION_RIGHT
  #       apply_sprite_offset( Outfit_Offsets::SURF_OFFSETS_RIGHT,current_frame)
  #     elsif direction == DIRECTION_UP
  #       apply_sprite_offset( Outfit_Offsets::SURF_OFFSETS_UP,current_frame)
  #     end
  #   when "dive"
  #     if direction == DIRECTION_DOWN
  #       apply_sprite_offset(Outfit_Offsets::DIVE_OFFSETS_DOWN,current_frame)
  #     elsif direction == DIRECTION_LEFT
  #       apply_sprite_offset( Outfit_Offsets::DIVE_OFFSETS_LEFT,current_frame)
  #     elsif direction == DIRECTION_RIGHT
  #       apply_sprite_offset( Outfit_Offsets::DIVE_OFFSETS_RIGHT,current_frame)
  #     elsif direction == DIRECTION_UP
  #       apply_sprite_offset( Outfit_Offsets::DIVE_OFFSETS_UP,current_frame)
  #     end
  #   when "bike"
  #     if direction == DIRECTION_DOWN
  #       apply_sprite_offset(Outfit_Offsets::BIKE_OFFSETS_DOWN,current_frame)
  #     elsif direction == DIRECTION_LEFT
  #       apply_sprite_offset( Outfit_Offsets::BIKE_OFFSETS_LEFT,current_frame)
  #     elsif direction == DIRECTION_RIGHT
  #       apply_sprite_offset( Outfit_Offsets::BIKE_OFFSETS_RIGHT,current_frame)
  #     elsif direction == DIRECTION_UP
  #       apply_sprite_offset( Outfit_Offsets::BIKE_OFFSETS_UP,current_frame)
  #     end
  #   else
  #     @sprite.x = @player_sprite.x - @player_sprite.ox
  #     @sprite.y = @player_sprite.y - @player_sprite.oy
  #   end
  #   @sprite.y -= 2 if current_frame % 2 == 1
  # end

end


# class Sprite_Hat < RPG::Sprite
#   attr_accessor :filename
#   attr_accessor :action
#   attr_accessor :hat_sprite
#
#   def initialize(player_sprite, filename, action, viewport)
#     @player_sprite = player_sprite
#     @viewport = viewport
#     @hat_sprite = Sprite.new(@viewport)
#     @hatBitmap = AnimatedBitmap.new(filename) if pbResolveBitmap(filename)
#     @filename = filename
#     @hat_sprite.bitmap = @hatBitmap.bitmap if @hatBitmap
#     @action = action
#     @color = 0
#     @frameWidth = 80  #@hat_sprite.width
#     @frameHeight = 80 #@hat_sprite.height / 4
#     @hat_sprite.z = @player_sprite.z + 2
#     echoln(_INTL("init had at z = {1}, player sprite at {2}",@hat_sprite.z,@player_sprite.z))
#
#     #Unused position offset
#     # @x_pos_base_offset = 0
#     # @y_pos_base_offset = 0
#   end
#
#   def apply_sprite_offset(offsets_array, current_frame)
#     @hat_sprite.x  += offsets_array[current_frame][0]
#     @hat_sprite.y  += offsets_array[current_frame][1]
#   end
#
#   def set_sprite_position(action, direction, current_frame)
#     @hat_sprite.x = @player_sprite.x - @player_sprite.ox
#     @hat_sprite.y = @player_sprite.y - @player_sprite.oy
#     case action
#     when "run"
#       if direction == DIRECTION_DOWN
#         apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_DOWN, current_frame)
#       elsif direction == DIRECTION_LEFT
#         apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_LEFT, current_frame)
#       elsif direction == DIRECTION_RIGHT
#         apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_RIGHT, current_frame)
#       elsif direction == DIRECTION_UP
#         apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_UP, current_frame)
#       end
#     when "surf"
#       if direction == DIRECTION_DOWN
#         apply_sprite_offset(Outfit_Offsets::SURF_OFFSETS_DOWN,current_frame)
#       elsif direction == DIRECTION_LEFT
#         apply_sprite_offset( Outfit_Offsets::SURF_OFFSETS_LEFT,current_frame)
#       elsif direction == DIRECTION_RIGHT
#         apply_sprite_offset( Outfit_Offsets::SURF_OFFSETS_RIGHT,current_frame)
#       elsif direction == DIRECTION_UP
#         apply_sprite_offset( Outfit_Offsets::SURF_OFFSETS_UP,current_frame)
#       end
#     when "dive"
#       if direction == DIRECTION_DOWN
#         apply_sprite_offset(Outfit_Offsets::DIVE_OFFSETS_DOWN,current_frame)
#       elsif direction == DIRECTION_LEFT
#         apply_sprite_offset( Outfit_Offsets::DIVE_OFFSETS_LEFT,current_frame)
#       elsif direction == DIRECTION_RIGHT
#         apply_sprite_offset( Outfit_Offsets::DIVE_OFFSETS_RIGHT,current_frame)
#       elsif direction == DIRECTION_UP
#         apply_sprite_offset( Outfit_Offsets::DIVE_OFFSETS_UP,current_frame)
#       end
#     when "bike"
#       if direction == DIRECTION_DOWN
#         apply_sprite_offset(Outfit_Offsets::BIKE_OFFSETS_DOWN,current_frame)
#       elsif direction == DIRECTION_LEFT
#         apply_sprite_offset( Outfit_Offsets::BIKE_OFFSETS_LEFT,current_frame)
#       elsif direction == DIRECTION_RIGHT
#         apply_sprite_offset( Outfit_Offsets::BIKE_OFFSETS_RIGHT,current_frame)
#       elsif direction == DIRECTION_UP
#         apply_sprite_offset( Outfit_Offsets::BIKE_OFFSETS_UP,current_frame)
#       end
#     else
#       @hat_sprite.x = @player_sprite.x - @player_sprite.ox
#       @hat_sprite.y = @player_sprite.y - @player_sprite.oy
#     end
#     @hat_sprite.y -= 2 if current_frame % 2 == 1
#   end
#
#   def animate(action)
#     @action = action
#     current_frame = @player_sprite.character.pattern
#     direction = @player_sprite.character.direction
#     crop_spritesheet(direction)
#     set_sprite_position(@action, direction, current_frame)
#     adjust_hat_layer()
#   end
#
#   def update(action, hatFilename,color)
#     @hat_sprite.opacity = @player_sprite.opacity if @hatBitmap
#     if hatFilename != @filename || color != @color
#       if pbResolveBitmap(hatFilename)
#         #echoln pbResolveBitmap(hatFilename)
#         @hatBitmap = AnimatedBitmap.new(hatFilename,color)
#         @hat_sprite.bitmap = @hatBitmap.bitmap
#       else
#         @hatBitmap = nil
#         @hat_sprite.bitmap = nil
#       end
#       @color =color
#       @filename = hatFilename
#     end
#     animate(action)
#   end
#
#   def adjust_hat_layer()
#     if @hat_sprite.z != @player_sprite.z
#       @hat_sprite.z = @player_sprite.z
#     end
#   end
#
#   def crop_spritesheet(direction)
#     sprite_x = 0
#     sprite_y = ((direction - 2) / 2) * @frameHeight
#     @hat_sprite.src_rect.set(sprite_x, sprite_y, @frameWidth, @frameHeight)
#   end
#
#   def dispose
#     return if @disposed
#     @hat_sprite.dispose if @hat_sprite
#     @hat_sprite = nil
#     @disposed = true
#   end
#
#   def disposed?
#     @disposed
#   end
#
# end
