#===============================================================================
# Nuzlocke Capture Rules (Phase 2 enforcement)
#
# Implemented purely by reopening / aliasing — this file is the ONLY file that
# changes for these features, so it stays update-resilient and avoids stepping on
# parallel teammates editing the core catch/overworld files.
#
# Features:
#   1. One catch per area (SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA)
#      - Area identity = the displayed area NAME ($game_map.name), so a route
#        split across multiple sub-maps counts as ONE area.
#      - "Area used" is recorded ONLY on a SUCCESSFUL catch. Fleeing or defeating
#        the first encounter does NOT burn the area. (Common romhack reading; it
#        is also the only event we can detect cleanly without touching the
#        overworld encounter code that a teammate owns.)
#      - Balls-first caveat: an area never becomes "used" while the player has no
#        Poke Balls, and a catch is only blocked when the player actually has
#        balls (no point blocking a throw that cannot happen). So pre-ball
#        encounters never consume the area's one allowed catch.
#   2. Force nicknames (SWITCH_NUZLOCKE_FORCE_NICKNAMES)
#      - Every caught Pokemon is nicknamed unconditionally (the optional yes/no
#        confirm is skipped). Vanilla optional behavior is preserved when off.
#
# Everything is gated on SWITCH_NUZLOCKE_MODE. When that switch is off, every
# alias falls straight through to the original implementation.
#===============================================================================

#===============================================================================
# Registry of areas where a catch has already been used up, stored on the save.
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :nuzlocke_caught_areas
end

module NuzlockeCaptureRules
  module_function

  # Master gate. Anything Nuzlocke-related is inert unless this is on.
  def nuzlocke_active?
    return false if !$game_switches
    return $game_switches[SWITCH_NUZLOCKE_MODE]
  end

  def one_catch_per_area_active?
    return false if !nuzlocke_active?
    return $game_switches[SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA]
  end

  def force_nicknames_active?
    return false if !nuzlocke_active?
    return $game_switches[SWITCH_NUZLOCKE_FORCE_NICKNAMES]
  end

  # True when nuzlocke is on AND battle items are forbidden. Battle-items
  # enforcement now lives ENTIRELY in ItemHandlers.triggerCanUseInBattle below
  # (the parallel NuzlockeBattleRules.rb no longer blocks the whole bag). When
  # this is true, any item that is NOT a Poke Ball is blocked; Poke Balls stay
  # usable (still subject to the one-catch block).
  def battle_items_forbidden?
    return false if !nuzlocke_active?
    return !$game_switches[SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED]
  end

  # Returns the list of area keys where the player has already used their catch.
  # Keys are the displayed area NAME strings (see current_area_key). nil is
  # treated as [] (lazy init).
  #
  # NOTE: keying switched from numeric map_id to the displayed area name so a
  # route split across several sub-maps counts as ONE area. Older saves that
  # stored integer map_ids will simply start fresh under the new string keying
  # (a previously-burned area becomes catchable again). This is acceptable for a
  # dev-stage feature.
  def caught_areas
    return [] if !$PokemonGlobal
    $PokemonGlobal.nuzlocke_caught_areas ||= []
    return $PokemonGlobal.nuzlocke_caught_areas
  end

  # The area key for the current map: the displayed location/area NAME, matching
  # what the player sees on the location signpost. The signpost is built from
  # $game_map.name (see 012_Overworld/001_Overworld.rb:394), which resolves the
  # map's display name via pbGetMessage(MessageTypes::MapNames, map_id) in
  # 004_Game classes/004_Game_Map.rb:133. We reuse that same name so our "area"
  # matches the on-screen area name. Falls back to the map_id as a string only
  # if no name resolves, so this never returns nil/crashes.
  def current_area_key
    return nil if !$game_map
    name = ($game_map.name rescue nil)
    return name if name.is_a?(String) && !name.strip.empty?
    return $game_map.map_id.to_s
  end

  # Backwards-compatible accessor. Older code referred to current_area_id; it now
  # returns the name-based key.
  def current_area_id
    return current_area_key
  end

  # Balls-first gate: true only if the bag holds at least one Poke Ball.
  def player_has_balls?
    return false if !$PokemonBag
    bag_pockets = ($PokemonBag.pockets rescue nil)
    return false if !bag_pockets
    bag_pockets.each do |pocket|
      next if !pocket
      pocket.each do |entry|
        next if !entry
        item_id = entry[0]
        next if !item_id
        item = (GameData::Item.get(item_id) rescue nil)
        next if !item
        return true if item.is_poke_ball?
      end
    end
    return false
  end

  # True if the current area's one allowed catch has already been used.
  def current_area_used?
    area = current_area_key
    return false if area.nil?
    return caught_areas.include?(area)
  end

  # Mark the current area as having had its catch used (idempotent).
  def mark_current_area_used
    area = current_area_key
    return if area.nil?
    list = caught_areas
    list.push(area) if !list.include?(area)
  end

  # Whether a catch attempt in the current area should be blocked right now.
  # Only blocks when: nuzlocke + one-catch on, the player actually has balls
  # (no reason to block an impossible throw), and the area is already used.
  def should_block_catch?
    return false if !one_catch_per_area_active?
    return false if !player_has_balls?
    return current_area_used?
  end
end

#===============================================================================
# Block a catch attempt at item-selection time, BEFORE the ball is registered or
# consumed. ItemHandlers.triggerCanUseInBattle returning false stops
# pbRegisterItem from ever running, so no ball is spent and the round is not
# consumed. The player can still battle, run, or use other items normally.
#===============================================================================
module ItemHandlers
  class << self
    unless method_defined?(:nuzlocke_orig_triggerCanUseInBattle) ||
           respond_to?(:nuzlocke_orig_triggerCanUseInBattle)
      alias_method :nuzlocke_orig_triggerCanUseInBattle, :triggerCanUseInBattle

      def triggerCanUseInBattle(item, pkmn, battler, move, firstAction, battle, scene, showMessages = true)
        is_ball = (GameData::Item.get(item).is_poke_ball? rescue false)
        # Battle-items lock: when items are forbidden, block everything that is
        # NOT a Poke Ball. Balls are deliberately exempt here (they are only ever
        # gated by the one-catch rule below), so catching stays possible.
        if !is_ball && NuzlockeCaptureRules.battle_items_forbidden?
          if showMessages && scene && scene.respond_to?(:pbDisplay)
            scene.pbDisplay(_INTL("No items allowed in this challenge!"))
          end
          return false
        end
        # One-catch-per-area: block a Poke Ball when this area's catch is spent.
        if is_ball && NuzlockeCaptureRules.one_catch_per_area_active? &&
           NuzlockeCaptureRules.should_block_catch?
          if showMessages && scene && scene.respond_to?(:pbDisplay)
            scene.pbDisplay(_INTL("You already caught a Pokémon in this area!"))
          end
          return false
        end
        return nuzlocke_orig_triggerCanUseInBattle(item, pkmn, battler, move, firstAction, battle, scene, showMessages)
      end
    end
  end
end

#===============================================================================
# Catch / store hooks. Aliased on the shared module so both PokeBattle_Battle and
# PokeBattle_SafariZone (which both `include PokeBattle_BattleCommon`) pick them up.
#===============================================================================
module PokeBattle_BattleCommon
  #-----------------------------------------------------------------------------
  # Record "area used" only on a SUCCESSFUL catch. We detect success by watching
  # @caughtPokemon grow across the original call (it only pushes on a 4-shake
  # capture). Fleeing/defeating never grows it, so the area is not burned.
  #-----------------------------------------------------------------------------
  unless method_defined?(:nuzlocke_orig_pbThrowPokeBall)
    alias_method :nuzlocke_orig_pbThrowPokeBall, :pbThrowPokeBall
    def pbThrowPokeBall(idxBattler, ball, catch_rate = nil, showPlayer = false)
      before = (@caughtPokemon.is_a?(Array) ? @caughtPokemon.length : 0)
      result = nuzlocke_orig_pbThrowPokeBall(idxBattler, ball, catch_rate, showPlayer)
      if NuzlockeCaptureRules.one_catch_per_area_active?
        after = (@caughtPokemon.is_a?(Array) ? @caughtPokemon.length : 0)
        NuzlockeCaptureRules.mark_current_area_used if after > before
      end
      return result
    end
  end

  #-----------------------------------------------------------------------------
  # Force-nickname: make the optional "give a nickname?" prompt unconditional.
  #
  # The original pbStorePokemon body is:
  #     if pbDisplayConfirm(_INTL("Would you like to give a nickname...")) ...
  # We don't want to duplicate the whole store routine, so instead we set a flag
  # and intercept pbDisplayConfirm (below): while the flag is set, that one
  # confirm auto-answers "yes", so the original always opens the name entry. No
  # double prompt, no duplicated store logic. When the switch is off the flag is
  # never set and pbDisplayConfirm behaves exactly as vanilla.
  #-----------------------------------------------------------------------------
  unless method_defined?(:nuzlocke_orig_pbStorePokemon)
    alias_method :nuzlocke_orig_pbStorePokemon, :pbStorePokemon
    def pbStorePokemon(pkmn)
      if NuzlockeCaptureRules.force_nicknames_active? && pkmn && !pkmn.shadowPokemon?
        @nuzlocke_force_nick = true
        begin
          return nuzlocke_orig_pbStorePokemon(pkmn)
        ensure
          @nuzlocke_force_nick = false
        end
      end
      return nuzlocke_orig_pbStorePokemon(pkmn)
    end
  end
end

#===============================================================================
# pbDisplayConfirm lives on the concrete battle classes (not the shared module),
# so the auto-yes interception used by force-nickname is aliased here. While the
# @nuzlocke_force_nick flag (set by pbStorePokemon above) is on, the single
# "give a nickname?" confirm answers yes so the name entry always opens.
#===============================================================================
class PokeBattle_Battle
  unless method_defined?(:nuzlocke_orig_pbDisplayConfirm)
    alias_method :nuzlocke_orig_pbDisplayConfirm, :pbDisplayConfirm
    def pbDisplayConfirm(msg)
      return true if @nuzlocke_force_nick
      return nuzlocke_orig_pbDisplayConfirm(msg)
    end
  end
end

class PokeBattle_SafariZone
  unless method_defined?(:nuzlocke_orig_pbDisplayConfirm)
    alias_method :nuzlocke_orig_pbDisplayConfirm, :pbDisplayConfirm
    def pbDisplayConfirm(msg)
      return true if @nuzlocke_force_nick
      return nuzlocke_orig_pbDisplayConfirm(msg)
    end
  end
end
