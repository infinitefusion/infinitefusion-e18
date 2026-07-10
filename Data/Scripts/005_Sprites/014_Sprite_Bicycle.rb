class Sprite_Bicycle < Sprite_Wearable
  def initialize(player_sprite, filename, action, viewport)
    super
    @relative_z = -1
  end

  def update(action, filename, color)
    if @player_sprite.biking?
      filename = $PokemonGlobal.bike_trick ? getOverworldBicycleTrickFilename : getOverworldBicycleFilename
    end
    super(action, filename, color)
  end


  def animate(action, frame = nil)
    @action = action
    current_frame = @player_sprite.character.pattern if !frame
    direction = @player_sprite.character.direction
    check_bike_trick
    crop_spritesheet(direction, current_frame)
    adjust_layer()
    set_sprite_position(@action, direction, current_frame)
  end

  def check_bike_trick
    if @player_sprite.biking?
      correct_filename = $PokemonGlobal.bike_trick ? getOverworldBicycleTrickFilename : getOverworldBicycleFilename
      if correct_filename != @filename
        bike_color = $Trainer.bike_color || 0
        if pbResolveBitmap(correct_filename)
          @wearableBitmap = AnimatedBitmap.new(correct_filename, bike_color)
          @sprite.bitmap = @wearableBitmap.bitmap
        end
        @filename = correct_filename
      end
    end
  end

  def crop_spritesheet(direction, current_frame)
    sprite_x = ((current_frame)) * @frameWidth
    sprite_y = ((direction - 2) / 2) * @frameHeight
    @sprite.src_rect.set(sprite_x, sprite_y, @frameWidth, @frameHeight)
  end

  def set_sprite_position(action, direction, current_frame)
    @sprite.x = @player_sprite.x
    @sprite.y = @player_sprite.y
    if $PokemonGlobal.bike_trick # to compensate for the offset applied to the player
      @sprite.y += Sprite_Player::ACRO_BIKE_TRICK_POSITION_OFFSET
    end
    @sprite.ox = @player_sprite.ox
    @sprite.oy = @player_sprite.oy
  end
end