class Hat < Outfit
  attr_accessor :type
  def initialize(id,name,description='',price=0,tags=[], store_locations = [], contest_condition=[])
    super
    @type = :HAT
  end

  def trainer_sprite_path()
    return getTrainerSpriteHatFilename(self.id)
  end
end