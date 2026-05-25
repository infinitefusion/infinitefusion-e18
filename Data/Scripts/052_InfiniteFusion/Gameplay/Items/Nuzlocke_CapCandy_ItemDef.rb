# Cap Candy Item Definition and Initialization
# For Nuzlocke Mode Phase 2

# Register Cap Candy item data if it doesn't already exist
# This allows the item to be used dynamically without requiring a full recompile

module GameData
  class Item
    # Initialize Cap Candy item if not present
    def self.add_cap_candy_if_missing
      cap_candy_id = :CAPCANDYNUZLOCKE
      return if self.try_get(cap_candy_id)  # Already exists, skip

      # Define the Cap Candy item
      cap_candy_data = {
        id: cap_candy_id,
        id_number: 646,
        name: "Cap Candy",
        name_plural: "Cap Candies",
        pocket: 5,  # Pocket 5 = General items/consumables
        price: 0,   # Not purchasable
        description: "A Nuzlocke-exclusive item that instantly raises a Pokémon to the current level cap.",
        field_use: 1,      # Can be used in field
        battle_use: 0,     # Cannot be used in battle directly
        type: 0,           # Not a special type
        move: nil
      }

      # Create and register the item
      item_obj = self.new(cap_candy_data)
      self::DATA[cap_candy_id] = item_obj
    end
  end
end

# Call initialization when the module loads
GameData::Item.add_cap_candy_if_missing
