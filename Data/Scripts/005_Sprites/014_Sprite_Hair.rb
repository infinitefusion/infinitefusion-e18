class Sprite_Hair < Sprite_Wearable
  def initialize(player_sprite, filename, action, viewport)
    super
    @relative_z = 1

    #@sprite.z = @player_sprite.z + 1
  end
end