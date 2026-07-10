class Sprite_Wearable < RPG::Sprite
  attr_accessor :filename
  attr_accessor :action
  attr_accessor :sprite

  def initialize(player_sprite, filename, action, viewport, relative_z = 0)
    @player_sprite = player_sprite
    @viewport = viewport
    @sprite = Sprite.new(@viewport)
    @wearableBitmap = AnimatedBitmap.new(filename) if pbResolveBitmap(filename)
    @filename = filename
    @sprite.bitmap = @wearableBitmap.bitmap if @wearableBitmap
    @action = action
    @color = 0
    @frameWidth = 80 #@sprite.width
    @frameHeight = 80 #@sprite.height / 4
    @sprite.z = 0
    @relative_z = relative_z # relative to player
    echoln(_INTL("init had at z = {1}, player sprite at {2}", @sprite.z, @player_sprite.z))
  end

  def apply_sprite_offset(offsets_array, current_frame)
    @sprite.x += offsets_array[current_frame][0]
    @sprite.y += offsets_array[current_frame][1]
  end

  def adjustPositionForScreenScrolling
    @sprite.x  = @player_sprite.x
    @sprite.y  = @player_sprite.y
    @sprite.ox = @player_sprite.ox
    @sprite.oy = @player_sprite.oy

    if $game_map.scroll_direction == DIRECTION_UP
        @sprite.z += 50 # temporary layering fix
    end
  end


  def set_sprite_position(action, direction, current_frame)
    @sprite.x = @player_sprite.x
    @sprite.y = @player_sprite.y
    @sprite.ox = @player_sprite.ox
    @sprite.oy = @player_sprite.oy
    case action
    when "run"
      if direction == DIRECTION_DOWN
        apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_DOWN, current_frame)
      elsif direction == DIRECTION_LEFT
        apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_LEFT, current_frame)
      elsif direction == DIRECTION_RIGHT
        apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_RIGHT, current_frame)
      elsif direction == DIRECTION_UP
        apply_sprite_offset(Outfit_Offsets::RUN_OFFSETS_UP, current_frame)
      end
    when "surf"
      if direction == DIRECTION_DOWN
        apply_sprite_offset(Outfit_Offsets::SURF_OFFSETS_DOWN, current_frame)
      elsif direction == DIRECTION_LEFT
        apply_sprite_offset(Outfit_Offsets::SURF_OFFSETS_LEFT, current_frame)
      elsif direction == DIRECTION_RIGHT
        apply_sprite_offset(Outfit_Offsets::SURF_OFFSETS_RIGHT, current_frame)
      elsif direction == DIRECTION_UP
        apply_sprite_offset(Outfit_Offsets::SURF_OFFSETS_UP, current_frame)
      end
    when "dive"
      if direction == DIRECTION_DOWN
        apply_sprite_offset(Outfit_Offsets::DIVE_OFFSETS_DOWN, current_frame)
      elsif direction == DIRECTION_LEFT
        apply_sprite_offset(Outfit_Offsets::DIVE_OFFSETS_LEFT, current_frame)
      elsif direction == DIRECTION_RIGHT
        apply_sprite_offset(Outfit_Offsets::DIVE_OFFSETS_RIGHT, current_frame)
      elsif direction == DIRECTION_UP
        apply_sprite_offset(Outfit_Offsets::DIVE_OFFSETS_UP, current_frame)
      end
    when "bike"
      if direction == DIRECTION_DOWN
        apply_sprite_offset(Outfit_Offsets::BIKE_OFFSETS_DOWN, current_frame)
      elsif direction == DIRECTION_LEFT
        apply_sprite_offset(Outfit_Offsets::BIKE_OFFSETS_LEFT, current_frame)
      elsif direction == DIRECTION_RIGHT
        apply_sprite_offset(Outfit_Offsets::BIKE_OFFSETS_RIGHT, current_frame)
      elsif direction == DIRECTION_UP
        apply_sprite_offset(Outfit_Offsets::BIKE_OFFSETS_UP, current_frame)
      end
    when "fish"
      if direction == DIRECTION_DOWN
        apply_sprite_offset(Outfit_Offsets::FISH_OFFSETS_DOWN, current_frame)
      elsif direction == DIRECTION_LEFT
        apply_sprite_offset(Outfit_Offsets::FISH_OFFSETS_LEFT, current_frame)
      elsif direction == DIRECTION_RIGHT
        apply_sprite_offset(Outfit_Offsets::FISH_OFFSETS_RIGHT, current_frame)
      elsif direction == DIRECTION_UP
        apply_sprite_offset(Outfit_Offsets::FISH_OFFSETS_UP, current_frame)
      end
    else
      @sprite.x = @player_sprite.x
      @sprite.y = @player_sprite.y
      @sprite.ox = @player_sprite.ox
      @sprite.oy = @player_sprite.oy
    end
    #adjustPositionForScreenScrolling()

    @sprite.y -= 2 if current_frame % 2 == 1
  end

  def animate(action, frame = nil)
    @action = action
    current_frame = @player_sprite.character.pattern if !frame
    direction = @player_sprite.character.direction
    crop_spritesheet(direction)
    adjust_layer()
    set_sprite_position(@action, direction, current_frame)
  end

  def update(action, filename, color)
    @sprite.opacity = @player_sprite.opacity if @wearableBitmap
    @sprite.opacity = 0 if $game_player.hasGraphicsOverride?
    if filename != @filename || color != @color
      if pbResolveBitmap(filename)
        @wearableBitmap = AnimatedBitmap.new(filename, color)
        @sprite.bitmap = @wearableBitmap.bitmap
      else
        @wearableBitmap = nil
        @sprite.bitmap = nil
      end
      @color = color
      @filename = filename
    end
  end

  def adjust_layer()
    if @sprite.z != @player_sprite.z + @relative_z
      @sprite.z = @player_sprite.z + @relative_z
    end
  end

  def crop_spritesheet(direction)
    sprite_x = 0
    sprite_y = ((direction - 2) / 2) * @frameHeight
    @sprite.src_rect.set(sprite_x, sprite_y, @frameWidth, @frameHeight)
  end

  def dispose
    return if @disposed
    @sprite.dispose if @sprite
    @sprite = nil
    @disposed = true
  end

  def disposed?
    @disposed
  end

end