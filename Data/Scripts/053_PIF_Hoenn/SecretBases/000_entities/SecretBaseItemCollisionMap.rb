
# [:i]: Unpassable and Interactable
# [:x]: Unpassable
# [] : Passable

# ex:
# [
# [[:x],[:x],[:x]],
# [[:i],[:i],[:i]
# ]
# -> 2 rows, only interactable from the bottom


class SecretBaseItemCollisionMap
  attr_accessor :collision_map
  def initialize(collisions_array = [])
    @collision_map = collisions_array
  end

  #todo
  def get_interactable_tiles

  end
  #todo
  def get passable_tiles

  end

end
