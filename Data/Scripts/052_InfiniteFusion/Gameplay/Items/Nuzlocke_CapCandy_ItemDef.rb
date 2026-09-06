#===============================================================================
# Cap Candy (Nuzlocke mode) -- item registration
#
# A Nuzlocke-only QoL item that raises one Pokemon straight to the current level
# cap (see the UseOnPokemon handler in "New Items effects.rb"). The item is
# registered at runtime rather than compiled into Data/items.dat, so the mod
# never has to ship a rebuilt items.dat or PBS recompile.
#
# Two things make runtime registration work reliably:
#   * GameData.load_all (run from Game.initialize, AFTER every script file has
#     been evaluated) replaces GameData::Item::DATA wholesale with the contents
#     of items.dat. Registering at script-load time therefore gets wiped. We
#     hook GameData::Item.load so the item is re-added every time the table is
#     (re)loaded.
#   * name / name_plural / description normally resolve through the compiled
#     message tables by id_number, which know nothing about this item and would
#     return "". The item object answers those itself.
#
# id_number 9646 is deliberately far above the compiled range (max 698 as of
# IF 6.7.2) so it can never collide with an upstream item. DATA is keyed by
# both the symbol and the number, matching GameData::Item.register.
#===============================================================================
module NuzlockeCapCandy
  ITEM_ID     = :CAPCANDYNUZLOCKE
  ITEM_NUMBER = 9646
  PRICE       = 3000

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

  # Mart stock hook: every PokeMart sells Cap Candy while the toggle is on.
  def add_to_stock(stock)
    return stock if !enabled?
    return stock if !stock.is_a?(Array)
    return stock if stock.include?(ITEM_ID)
    return stock if !GameData::Item.exists?(ITEM_ID)
    return stock + [ITEM_ID]
  end

  def register_item
    return if GameData::Item.try_get(ITEM_ID)
    item = GameData::Item.new({
      id:          ITEM_ID,
      id_number:   ITEM_NUMBER,
      name:        "Cap Candy",
      name_plural: "Cap Candies",
      pocket:      2,        # Medicine, next to Rare Candy
      price:       PRICE,
      description: "A Nuzlocke-only candy that raises a Pokémon straight to the current level cap.",
      field_use:   1,        # usable from the Bag on a party member
      battle_use:  0,
      type:        0,
      move:        nil
    })
    # Message-table bypass (see header).
    item.define_singleton_method(:name)        { "Cap Candy" }
    item.define_singleton_method(:name_plural) { "Cap Candies" }
    item.define_singleton_method(:description) {
      "A Nuzlocke-only candy that raises a Pokémon straight to the current level cap."
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

# Sell it in every PokeMart while enabled. pbPokemonMart lives in 016_UI, which
# loads before this file.
class Object
  unless private_method_defined?(:nuzlocke_orig_pbPokemonMart) ||
         method_defined?(:nuzlocke_orig_pbPokemonMart)
    alias_method :nuzlocke_orig_pbPokemonMart, :pbPokemonMart
    def pbPokemonMart(stock, speech = nil, cantsell = false)
      stock = NuzlockeCapCandy.add_to_stock(stock)
      return nuzlocke_orig_pbPokemonMart(stock, speech, cantsell)
    end
  end
end
