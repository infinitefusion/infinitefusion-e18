#===============================================================================
# Cap Candy (Nuzlocke mode) -- item registration
#
# A Nuzlocke-only KEY ITEM that raises one Pokemon straight to the current
# level cap (see the UseOnPokemon handler in "New Items effects.rb"). It is
# reusable (field_use 2: usable on a Pokemon, not consumed) and lives in the
# Key Items pocket. While the Cap Candy setting is on it is simply in the Bag;
# turning the setting off takes it away again. It is never sold: randomized
# runs shuffle mart stock, and key items are excluded from that shuffle, so
# handing it out directly is the only way it survives a randomizer.
#
# The item is registered at runtime rather than compiled into Data/items.dat:
#   * GameData.load_all (run from Game.initialize, AFTER every script file has
#     been evaluated) replaces GameData::Item::DATA wholesale with items.dat, so
#     we hook GameData::Item.load to re-add it every time the table loads.
#   * name / name_plural / description normally resolve through the compiled
#     message tables by id_number, which know nothing about this item; the item
#     object answers those itself.
# id_number 9646 is far above the compiled range (max 698 as of IF 6.7.2).
#===============================================================================
module NuzlockeCapCandy
  ITEM_ID     = :CAPCANDYNUZLOCKE
  ITEM_NUMBER = 9646

  module_function

  def enabled?
    return false if !$game_switches
    return false if !$game_switches[SWITCH_NUZLOCKE_MODE]
    return $game_switches[SWITCH_NUZLOCKE_CAP_CANDY_ENABLED] ? true : false
  end

  # The level a Cap Candy raises to. Once every badge is earned the game's own
  # LEVEL_CAPS table has no entry (getCurrentLevelCap would crash on nil), so
  # the cap becomes the max level.
  def current_cap
    if !$Trainer || !$Trainer.respond_to?(:badge_count) ||
       $Trainer.badge_count >= Settings::NB_BADGES ||
       Settings::LEVEL_CAPS[$Trainer.badge_count].nil?
      return GameData::GrowthRate.max_level
    end
    cap = getCurrentLevelCap()
    return cap.clamp(1, GameData::GrowthRate.max_level)
  end

  # Keep the Bag in step with the setting: present while on, gone while off.
  # Returns :added, :removed or :unchanged.
  def sync_inventory!
    return :unchanged if !$PokemonBag || !$PokemonBag.respond_to?(:pbHasItem?)
    return :unchanged if !GameData::Item.exists?(ITEM_ID)
    has = $PokemonBag.pbHasItem?(ITEM_ID)
    if enabled? && !has
      $PokemonBag.pbStoreItem(ITEM_ID, 1)
      return :added
    elsif !enabled? && has
      5.times do
        break if !$PokemonBag.pbHasItem?(ITEM_ID)
        $PokemonBag.pbDeleteItem(ITEM_ID, 1)
      end
      return :removed
    end
    return :unchanged
  rescue => e
    PBDebug.log("[Nuzlocke] Cap Candy sync failed: #{e.message}") if defined?(PBDebug)
    return :unchanged
  end

  def register_item
    return if GameData::Item.try_get(ITEM_ID)
    item = GameData::Item.new({
      id:          ITEM_ID,
      id_number:   ITEM_NUMBER,
      name:        "Cap Candy",
      name_plural: "Cap Candies",
      pocket:      8,        # Key Items
      price:       0,        # never sold
      description: "A Nuzlocke-only candy that raises a Pokémon straight to the current level cap. Never runs out.",
      field_use:   2,        # usable on a party member, NOT consumed
      battle_use:  0,
      type:        6,        # key item
      move:        nil
    })
    # Message-table bypass (see header).
    item.define_singleton_method(:name)        { "Cap Candy" }
    item.define_singleton_method(:name_plural) { "Cap Candies" }
    item.define_singleton_method(:description) {
      "A Nuzlocke-only candy that raises a Pokémon straight to the current level cap. Never runs out."
    }
    GameData::Item::DATA[ITEM_ID]     = item
    GameData::Item::DATA[ITEM_NUMBER] = item
  end
end

module GameData
  class Item
    class << self
      unless method_defined?(:nuzlocke_orig_load)
        alias_method :nuzlocke_orig_load, :load
        def load
          nuzlocke_orig_load
          NuzlockeCapCandy.register_item
        end
      end
    end
  end
end

# Also register now, in case DATA was already loaded before this file ran.
NuzlockeCapCandy.register_item if GameData::Item::DATA.is_a?(Hash) && !GameData::Item::DATA.empty?

# Keep the Bag in step with the setting whenever the player changes maps
# (cheap: one pbHasItem? check), so old saves and toggles both converge.
if defined?(Events) && Events.respond_to?(:onMapChange)
  Events.onMapChange += proc { |_sender, _e|
    NuzlockeCapCandy.sync_inventory! if $game_switches && $game_switches[SWITCH_NUZLOCKE_MODE]
  }
end
