#===============================================================================
# Cap Candy (Nuzlocke mode) -- item registration
#
# A Nuzlocke-only KEY ITEM that raises one Pokemon straight to the current
# level cap (see the UseOnPokemon handler in "New Items effects.rb"). It is
# reusable (field_use 5: usable on a Pokemon, not consumed) and lives in the
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
      field_use:   5,        # usable on a party member, NOT consumed (IF: 1=consumed, 5=reusable, 2=from-Bag handler)
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
          NuzlockeKeyItems.register_all
        end
      end
    end
  end
end

#===============================================================================
# Field Medkit (Nuzlocke mode) -- reusable key item, full party heal from the
# Bag anywhere outside battle (battle_use 0 keeps it out of the battle bag).
#===============================================================================
module NuzlockeMedkit
  ITEM_ID     = :NUZLOCKEMEDKIT
  ITEM_NUMBER = 9647

  module_function

  def enabled?
    return false if !$game_switches
    return false if !$game_switches[SWITCH_NUZLOCKE_MODE]
    return $game_switches[SWITCH_NUZLOCKE_MEDKIT_ENABLED] ? true : false
  end

  def sync_inventory!
    return NuzlockeKeyItems.sync_item(ITEM_ID, enabled?)
  end

  # Heal everyone. Returns true if anything was actually healed.
  def heal_party!
    return false if !$Trainer || !$Trainer.party
    needed = $Trainer.party.compact.any? { |p| !p.egg? && (p.hp < p.totalhp || p.status != :NONE || p.moves.any? { |m| m && m.pp < m.total_pp }) }
    $Trainer.heal_party if $Trainer.respond_to?(:heal_party)
    return needed
  end

  def register_item
    return if GameData::Item.try_get(ITEM_ID)
    desc = "A Nuzlocke-only medkit that fully heals your whole party anywhere outside battle. Never runs out."
    item = GameData::Item.new({
      id: ITEM_ID, id_number: ITEM_NUMBER, name: "Field Medkit", name_plural: "Field Medkits",
      pocket: 8, price: 0, description: desc,
      field_use: 2,      # usable from the Bag (UseFromBag handler), no target
      battle_use: 0, type: 6, move: nil
    })
    item.define_singleton_method(:name)        { "Field Medkit" }
    item.define_singleton_method(:name_plural) { "Field Medkits" }
    item.define_singleton_method(:description) { desc }
    GameData::Item::DATA[ITEM_ID]     = item
    GameData::Item::DATA[ITEM_NUMBER] = item
  end
end

ItemHandlers::UseFromBag.add(:NUZLOCKEMEDKIT, proc { |_item|
  if !NuzlockeMedkit.enabled?
    pbMessage(_INTL("It won't have any effect."))
    next 0
  end
  if !$Trainer || $Trainer.party.compact.empty?
    pbMessage(_INTL("There is no Pokémon."))
    next 0
  end
  healed = NuzlockeMedkit.heal_party!
  if healed
    (pbSEPlay("Pkmn heal") rescue nil)
    pbMessage(_INTL("Your Pokémon were fully healed!"))
  else
    pbMessage(_INTL("Your Pokémon are already in perfect health."))
  end
  next 1
})

#===============================================================================
# Ready-menu ("Register") support. The Bag offers Register for any item with a
# UseInField handler; the registered item is then used straight from the ready
# menu key. Return 1 = used (kept), 0 = not used.
#===============================================================================
ItemHandlers::UseInField.add(:NUZLOCKEMEDKIT, proc { |_item|
  if !NuzlockeMedkit.enabled?
    pbMessage(_INTL("It won't have any effect."))
    next 0
  end
  if !$Trainer || $Trainer.party.compact.empty?
    pbMessage(_INTL("There is no Pokémon."))
    next 0
  end
  if NuzlockeMedkit.heal_party!
    (pbSEPlay("Pkmn heal") rescue nil)
    pbMessage(_INTL("Your Pokémon were fully healed!"))
  else
    pbMessage(_INTL("Your Pokémon are already in perfect health."))
  end
  next 1
})

ItemHandlers::UseInField.add(:CAPCANDYNUZLOCKE, proc { |item|
  if !NuzlockeCapCandy.enabled?
    pbMessage(_INTL("It won't have any effect."))
    next 0
  end
  if !$Trainer || $Trainer.party.compact.empty?
    pbMessage(_INTL("There is no Pokémon."))
    next 0
  end
  used = false
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene, $Trainer.party)
    screen.pbStartScene(_INTL("Use on which Pokémon?"), false)
    loop do
      scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
      chosen = screen.pbChoosePokemon
      break if chosen < 0
      pkmn = $Trainer.party[chosen]
      next if !pkmn
      used = ItemHandlers.triggerUseOnPokemon(item, pkmn, screen) || used
    end
    screen.pbEndScene
  }
  next used ? 1 : 0
})

#===============================================================================
# Repel Toggle (Nuzlocke mode) -- key item that switches an endless Repel on
# and off. State lives in $PokemonGlobal.nuzlocke_repel_on (saved with the
# game). While on, isRepelActive() reports true, so wild Pokemon below the
# lead's level stay away exactly as with a normal Repel; nothing counts down.
# Turning the setting off takes the item away and switches the repel off.
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :nuzlocke_repel_on          # true while the Repel Toggle is switched on
end

module NuzlockeRepelToggle
  ITEM_ID     = :NUZLOCKEREPELTOGGLE
  ITEM_NUMBER = 9648

  module_function

  def enabled?
    return false if !$game_switches
    return false if !$game_switches[SWITCH_NUZLOCKE_MODE]
    return $game_switches[SWITCH_NUZLOCKE_REPEL_TOGGLE_ENABLED] ? true : false
  end

  def on?
    return false if !$PokemonGlobal || !$PokemonGlobal.respond_to?(:nuzlocke_repel_on)
    return $PokemonGlobal.nuzlocke_repel_on ? true : false
  end

  # The repel effect applies only while both the setting and the toggle are on.
  def active?
    return enabled? && on?
  end

  def set(value)
    return if !$PokemonGlobal || !$PokemonGlobal.respond_to?(:nuzlocke_repel_on=)
    $PokemonGlobal.nuzlocke_repel_on = value ? true : false
  end

  # Flip the toggle and tell the player. Returns 1 (used, kept).
  def toggle!
    set(!on?)
    if on?
      (pbSEPlay("Item use") rescue nil) if defined?(pbSEPlay)
      pbMessage(_INTL("The Repel Toggle is now ON. Weak wild Pokémon will stay away."))
    else
      (pbSEPlay("GUI menu close") rescue nil) if defined?(pbSEPlay)
      pbMessage(_INTL("The Repel Toggle is now OFF."))
    end
    return 1
  end

  def sync_inventory!
    set(false) if !enabled? && on?
    return NuzlockeKeyItems.sync_item(ITEM_ID, enabled?)
  end

  def register_item
    return if GameData::Item.try_get(ITEM_ID)
    desc = "A Nuzlocke-only switch for an endless Repel. Use it to turn the repel effect on or off at any time."
    item = GameData::Item.new({
      id: ITEM_ID, id_number: ITEM_NUMBER, name: "Repel Toggle", name_plural: "Repel Toggles",
      pocket: 8, price: 0, description: desc,
      field_use: 2,      # usable from the Bag (UseFromBag handler), no target
      battle_use: 0, type: 6, move: nil
    })
    item.define_singleton_method(:name)        { "Repel Toggle" }
    item.define_singleton_method(:name_plural) { "Repel Toggles" }
    item.define_singleton_method(:description) { desc }
    GameData::Item::DATA[ITEM_ID]     = item
    GameData::Item::DATA[ITEM_NUMBER] = item
  end
end

NUZLOCKE_REPEL_TOGGLE_USE = proc { |_item|
  if !NuzlockeRepelToggle.enabled?
    pbMessage(_INTL("It won't have any effect."))
    next 0
  end
  next NuzlockeRepelToggle.toggle!
}
ItemHandlers::UseFromBag.add(:NUZLOCKEREPELTOGGLE, NUZLOCKE_REPEL_TOGGLE_USE)
ItemHandlers::UseInField.add(:NUZLOCKEREPELTOGGLE, NUZLOCKE_REPEL_TOGGLE_USE)

# The engine asks isRepelActive() once per step / turn and passes the answer
# into the wild-encounter roll. An incense (FUSIONREPEL) still wins: that check
# comes first in the original and forces fusions instead of blocking.
if defined?(isRepelActive) && !defined?(nuzlocke_orig_isRepelActive)
  alias nuzlocke_orig_isRepelActive isRepelActive
  def isRepelActive
    return true if NuzlockeRepelToggle.active? && !($game_switches && $game_switches[SWITCH_USED_AN_INCENSE])
    return nuzlocke_orig_isRepelActive
  end
end

#===============================================================================
# Shared: registration on data load, Bag sync for every Nuzlocke key item.
#===============================================================================
module NuzlockeKeyItems
  module_function

  def register_all
    NuzlockeCapCandy.register_item
    NuzlockeMedkit.register_item
    NuzlockeRepelToggle.register_item
  end

  # Present while +wanted+, gone otherwise. Returns :added, :removed, :unchanged.
  def sync_item(item_id, wanted)
    return :unchanged if !$PokemonBag || !$PokemonBag.respond_to?(:pbHasItem?)
    return :unchanged if !GameData::Item.exists?(item_id)
    has = $PokemonBag.pbHasItem?(item_id)
    if wanted && !has
      $PokemonBag.pbStoreItem(item_id, 1)
      return :added
    elsif !wanted && has
      5.times do
        break if !$PokemonBag.pbHasItem?(item_id)
        $PokemonBag.pbDeleteItem(item_id, 1)
      end
      return :removed
    end
    return :unchanged
  rescue => e
    PBDebug.log("[Nuzlocke] key item sync failed for #{item_id}: #{e.message}") if defined?(PBDebug)
    return :unchanged
  end

  def sync_all!
    NuzlockeCapCandy.sync_inventory!
    NuzlockeMedkit.sync_inventory!
    NuzlockeRepelToggle.sync_inventory!
  end
end

# Cap Candy's own sync now routes through the shared helper.
module NuzlockeCapCandy
  module_function
  def sync_inventory!
    return NuzlockeKeyItems.sync_item(ITEM_ID, enabled?)
  end
end

# Also register now, in case DATA was already loaded before this file ran.
NuzlockeKeyItems.register_all if GameData::Item::DATA.is_a?(Hash) && !GameData::Item::DATA.empty?

# Keep the Bag in step with the settings whenever the player changes maps
# (cheap: one pbHasItem? check per item), so old saves and toggles converge.
if defined?(Events) && Events.respond_to?(:onMapChange)
  Events.onMapChange += proc { |_sender, _e|
    NuzlockeKeyItems.sync_all! if $game_switches && $game_switches[SWITCH_NUZLOCKE_MODE]
  }
end
