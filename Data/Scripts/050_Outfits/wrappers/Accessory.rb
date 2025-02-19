class Accessory < Outfit
  attr_accessor :type
  def initialize(id,name,description='',price=0,tags=[])
    super
    @type = :ACCESSORY
  end

  def trainer_sprite_path()
    return getTrainerSpriteHatFilename(self.id)
  end
end