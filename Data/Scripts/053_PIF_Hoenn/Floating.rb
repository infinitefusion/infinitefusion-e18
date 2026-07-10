class Game_Character
  attr_accessor :floating
  attr_reader :float_offset

  alias game_character_init initialize
  def initialize(*args)
    game_character_init(*args)
    @floating = false
    @float_phase = 0.0
    @float_offset = 0
  end

  alias game_character_update update
  def update
    game_character_update

    if @floating
      update_floating
    else
      @float_offset = 0
      @float_phase = 0.0
    end
  end

  private

  def update_floating
    @float_phase += 0.1
    amplitude = 2.5
    @float_offset = Math.sin(@float_phase) * amplitude
  end
end

class Sprite_Character < RPG::Sprite
  alias floating_update update
  def update
    floating_update

    return if @character.nil?
    return unless @character.floating

    # Shift the sprite visually only
    self.oy = self.oy + @character.float_offset
  end
end

