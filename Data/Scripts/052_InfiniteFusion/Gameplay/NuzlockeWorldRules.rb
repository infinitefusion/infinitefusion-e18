# Nuzlocke World Rules
# --------------------
# Hooks affecting overworld/shop systems. Gated on SWITCH_NUZLOCKE_MODE +
# the per-feature switch. Implemented purely by aliasing so it stays
# update-resilient against upstream IF changes.

module NuzlockeWorldRules
  module_function

  # HP-restore items only. Revives and status heals are intentionally NOT here
  # -- the setting's intent is "you can always heal HP," not "you can always
  # revive / cure status." If no item from this list is in the mart's stock,
  # we inject a Potion.
  HEALING_ITEMS = [
    :POTION, :SUPERPOTION, :HYPERPOTION, :MAXPOTION, :FULLRESTORE,
    :FRESHWATER, :SODAPOP, :LEMONADE, :MOOMOOMILK, :BERRYJUICE
  ].freeze

  def guarantee_mart_heals_active?
    return false if !$game_switches
    return false if !$game_switches[SWITCH_NUZLOCKE_MODE]
    return $game_switches[SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS]
  end

  # True when nuzlocke is on AND the player chose "Disallowed" for trainer
  # fleeing. When true, we set the cannotRun battle rule on trainer battles,
  # so the player can't escape -- a loss is a loss.
  def trainer_flee_blocked?
    return false if !$game_switches
    return false if !$game_switches[SWITCH_NUZLOCKE_MODE]
    return !$game_switches[SWITCH_NUZLOCKE_TRAINER_FLEE_ALLOWED]
  end

  # Ensure the mart stock contains at least one basic HP-healing item. No-op if
  # the setting is off, the input isn't an Array, or the stock already has any
  # HEALING_ITEMS entry. Otherwise prepend a Potion.
  def ensure_heal_in_stock(stock)
    return stock if !guarantee_mart_heals_active?
    return stock if !stock.is_a?(Array)
    has_heal = stock.any? do |id|
      sym = (GameData::Item.get(id).id rescue id)
      HEALING_ITEMS.include?(sym)
    end
    return stock if has_heal
    return [:POTION] + stock
  end
end

#===============================================================================
# Wrap the engine's mart randomizer so the resulting stock is heal-guaranteed
# when the Nuzlocke setting is on. This covers the user's case directly --
# randomized marts that could have rolled zero healing items -- without touching
# the non-randomized path (vanilla marts already stock heals).
#===============================================================================
class Object
  unless private_method_defined?(:nuzlocke_orig_replaceShopStockWithRandomized) ||
         method_defined?(:nuzlocke_orig_replaceShopStockWithRandomized)
    alias_method :nuzlocke_orig_replaceShopStockWithRandomized, :replaceShopStockWithRandomized
    def replaceShopStockWithRandomized(stock)
      randomized = nuzlocke_orig_replaceShopStockWithRandomized(stock)
      return NuzlockeWorldRules.ensure_heal_in_stock(randomized)
    end
  end
end

#===============================================================================
# Trainer-fleeing (#13). Hooked at pbTrainerBattleCore -- the common path every
# trainer-battle entry point (pbTrainerBattle, pbDoubleTrainerBattle,
# pbTripleTrainerBattle) funnels through. When the setting blocks fleeing, we
# apply the cannotRun battle rule before the original runs, so the engine sees
# canRun=false at battle setup. When the setting allows fleeing, we touch
# nothing -- the IF default stands, and the emergent "fled-but-fainted-mons-
# still-perma-die" partial-forfeit mechanic continues to work.
#===============================================================================
class Object
  unless private_method_defined?(:nuzlocke_orig_pbTrainerBattleCore) ||
         method_defined?(:nuzlocke_orig_pbTrainerBattleCore)
    alias_method :nuzlocke_orig_pbTrainerBattleCore, :pbTrainerBattleCore
    def pbTrainerBattleCore(*args, **kwargs)
      if NuzlockeWorldRules.trainer_flee_blocked? && defined?(setBattleRule)
        setBattleRule("cannotRun")
      end
      return nuzlocke_orig_pbTrainerBattleCore(*args, **kwargs)
    end
  end
end
