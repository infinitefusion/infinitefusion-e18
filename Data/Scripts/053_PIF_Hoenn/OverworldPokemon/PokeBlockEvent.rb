class PokeblockEvent < Game_Event
  attr_accessor :pokemon
  attr_accessor :color

  DESPAWN_SECONDS = 60

  #Level is for calculating the HP
  def initialize(map_id, event, map=nil, color=:RED, level=16)
    super(map_id, event, map)
    @pokemon = Pokemon.new(:DITTO, level) #fake pokemon for calcualting damage when pokemon eat it
    @color = color
    @drain_per_frame = @pokemon.totalhp.to_f / (DESPAWN_SECONDS * Graphics.frame_rate)
    @hp_float = @pokemon.hp.to_f
  end

  def update_opacity
    @opacity = (255 * (@pokemon.hp.to_f / @pokemon.totalhp)).round
  end

  def update
    super
    return if @erased
    @hp_float -= @drain_per_frame
    @pokemon.hp = [@hp_float.round, 0].max
    update_opacity
    despawn if @pokemon.hp <= 0
  end
end