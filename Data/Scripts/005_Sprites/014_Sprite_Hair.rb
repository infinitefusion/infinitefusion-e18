class Sprite_Hair < Sprite_Wearable
  def initialize(player_sprite, filename, action, viewport)
    super
    @relative_z = 1

    #@sprite.z = @player_sprite.z + 1
  end

  def animate(action, frame = nil)
    @action = action
    current_frame = @player_sprite.character.pattern if !frame
    direction = @player_sprite.character.direction
    crop_spritesheet(direction, current_frame, action)
    adjust_layer()
    set_sprite_position(@action, direction, current_frame)
  end

  def crop_spritesheet(direction, current_frame, action)
    sprite_x = ((current_frame)) * @frameWidth

    # Don't animate surf
    sprite_x = 0 if action == "surf"

    sprite_y = ((direction - 2) / 2) * @frameHeight
    @sprite.src_rect.set(sprite_x, sprite_y, @frameWidth, @frameHeight)
  end

  def set_sprite_position(action, direction, current_frame)
    @sprite.x = @player_sprite.x - @player_sprite.ox
    @sprite.y = @player_sprite.y - @player_sprite.oy
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
      if direction == DIRECTION_DOWN # Always animate as if on the first frame
        apply_sprite_offset(Outfit_Offsets::SURF_OFFSETS_DOWN, 0)
      elsif direction == DIRECTION_LEFT
        apply_sprite_offset(Outfit_Offsets::SURF_OFFSETS_LEFT, 0)
      elsif direction == DIRECTION_RIGHT
        apply_sprite_offset(Outfit_Offsets::SURF_OFFSETS_RIGHT, 0)
      elsif direction == DIRECTION_UP
        apply_sprite_offset(Outfit_Offsets::SURF_OFFSETS_UP, 0)
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
    end

  end

end