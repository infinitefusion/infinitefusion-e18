class Outfit
  attr_accessor :id
  attr_accessor :name
  attr_accessor :description
  attr_accessor :tags
  attr_accessor :price
  attr_accessor :store_location

  attr_accessor :is_in_regional_set
  attr_accessor :is_in_city_exclusive_set

  attr_accessor :contest_condition



  REGION_TAGS = ["kanto", "johto", "hoenn", "sinnoh", "unova", "kalos", "alola", "galar", "paldea"]
  def check_if_regional_set(tags)
    REGION_TAGS.any? { |region| tags.include?(region) }
  end

  CITY_OUTFIT_TAGS= [
    "pewter","cerulean","vermillion","lavender","celadon","fuchsia","cinnabar",
    "crimson","goldenrod","azalea", "violet", "blackthorn", "mahogany", "ecruteak",
    "olivine","cianwood", "kin"
  ]
  def check_if_city_set(tags)
    CITY_OUTFIT_TAGS.any? { |city| tags.include?(city) }
  end

  def initialize(id, name, description = '',price=0, tags = [], store_locations = [], contest_conditions = [])
    @id = id
    @name = _INTL(name)
    @description = _INTL(description)
    @tags = tags
    @price = price

    @is_in_regional_set = check_if_regional_set(tags)
    @is_in_city_exclusive_set = check_if_city_set(tags)
    @store_location = store_locations
    @contest_condition = contest_conditions
  end

  def trainer_sprite_path()
    return nil
  end
end
