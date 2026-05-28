#===============================================================================
# Nuzlocke Mode - Battle rule enforcement
#-------------------------------------------------------------------------------
# All behaviour is implemented by aliasing / reopening existing classes so that
# no core battle file is edited in place. Everything is gated on
# SWITCH_NUZLOCKE_MODE so non-Nuzlocke games are completely unaffected.
#
# Features:
#   1. Perma-death (unfused) - fainted, non-fusion party members are removed
#      permanently after a battle.
#   2. Perma-death (fused)   - fainted fusions are handled per
#      VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE (0 Off / 1 Head dies / 2 Body dies /
#      3 Both die). The surviving half is unfused and kept.
#
# Perma-death stays inert until the player owns at least one Poke Ball
# (balls-first parity with the one-catch rule), and an empty post-battle party
# triggers the engine's standard blackout so the player is never soft-locked.
#
# Battle-items enforcement is NOT here anymore - it lives per-item in
# NuzlockeCaptureRules.rb (ItemHandlers.triggerCanUseInBattle) so Poke Balls
# stay usable while other items are blocked.
#===============================================================================

module NuzlockeBattleRules
  module_function

  # True only when Nuzlocke mode is active and globals are safely available.
  def active?
    return false if !$game_switches
    return false if !$game_switches[SWITCH_NUZLOCKE_MODE]
    return true
  end

  # Build a fresh, unfused Pokemon for the surviving half of a fainted fusion,
  # faithfully copying the preservation logic used by pbUnfuse (level/EXP/IVs/
  # EVs/nickname). +keep_body+ true => keep the body species, false => head.
  # Returns a new Pokemon, or nil if the survivor species can't be resolved.
  def build_survivor(fused, keep_body)
    survivor_species = getBasePokemonID(fused.species_data.id_number, keep_body)
    return nil if !survivor_species || survivor_species <= 0

    # Same individual, re-based onto the half's species. Pokemon#clone deep-copies
    # the individual (IVs/EVs/nature/gender/ability slot/shininess/happiness/held
    # item/nickname/owner); species= recalcs stats and re-derives the ability from
    # the preserved ability_index. This is the user ruling -- "literally the same
    # mon" -- so we copy everything by construction rather than a hand-listed set.
    survivor = fused.clone
    survivor.species = survivor_species

    # EXP: restore the kept half's stored exp the way pbUnfuse does; else the level.
    if !fused.exp_when_fused_head.nil? && !fused.exp_when_fused_body.nil?
      preserved = keep_body ? fused.exp_when_fused_body : fused.exp_when_fused_head
      survivor.exp = preserved + (fused.exp_gained_since_fused || 0)
    else
      survivor.level = fused.level
    end

    # Keep the half's ORIGINAL ability slot if the fusion recorded it (as pbUnfuse
    # does); otherwise the clone already carried the fusion's ability index.
    if keep_body && fused.respond_to?(:body_original_ability_index) && fused.body_original_ability_index
      survivor.ability_index = fused.body_original_ability_index
    elsif !keep_body && fused.respond_to?(:head_original_ability_index) && fused.head_original_ability_index
      survivor.ability_index = fused.head_original_ability_index
    end

    # Shininess kept deterministically (a shiny's surviving half stays shiny).
    survivor.shiny = fused.shiny?

    # Clear vestigial fusion bookkeeping now that this is a standalone Pokemon.
    survivor.exp_when_fused_head = nil    if survivor.respond_to?(:exp_when_fused_head=)
    survivor.exp_when_fused_body = nil    if survivor.respond_to?(:exp_when_fused_body=)
    survivor.exp_gained_since_fused = nil if survivor.respond_to?(:exp_gained_since_fused=)

    survivor.reset_moves   # moves reset to the half's natural set (lost, as in unfuse)
    survivor.heal          # the survivor returns ready to battle
    survivor.obtain_method = 0
    return survivor
  rescue => e
    PBDebug.log("[Nuzlocke] build_survivor failed: #{e.message}") if defined?(PBDebug)
    return nil
  end

  # Add a surviving half to the rebuilt-party list and register it in the Pokedex.
  #
  # We push into +survivors+ (the list process_party_after_battle commits at the
  # end) rather than appending to $Trainer.party directly. The old version
  # appended to $Trainer.party mid-iteration and only "worked" because Ruby's
  # Array#each re-visited the appended element; it also evaluated party_full?
  # against the not-yet-cleaned party, so a full party wrongly boxed the survivor
  # even though the dead fusion had just freed a slot. survivors can never exceed
  # 6 (each survivor replaces exactly one dead party slot), so no PC overflow is
  # possible and none is needed.
  def register_survivor(survivor, survivors)
    return if !survivor
    survivors.push(survivor)
    if $Trainer && $Trainer.pokedex
      $Trainer.pokedex.set_seen(survivor.species)
      $Trainer.pokedex.set_owned(survivor.species)
    end
  end

  # Return a removed Pokemon's held item to the Bag so perma-death only costs the
  # Pokemon, never the item (user ruling). Used when a mon is fully removed:
  # unfused perma-death, or a fused "Both die" faint. (For Head/Body modes the
  # surviving half carries the item instead, via build_survivor.) No-op if the
  # mon holds nothing.
  def reclaim_held_item(mon)
    return if !mon
    item = (mon.item_id rescue nil)
    return if !item
    ($PokemonBag.pbStoreItem(item) rescue nil) if $PokemonBag
    (mon.item = nil) rescue nil
  end

  # Process the whole party after a battle, applying perma-death rules.
  # Rebuilds the party from survivors rather than deleting while iterating.
  def process_party_after_battle
    return if !active?
    return if !$Trainer || !$Trainer.party

    # Balls-first RATCHET (resolves user reports #8/#9/#10): perma-death stays
    # inert until the player has OWNED a Poke Ball at any point in the run, then
    # stays armed forever -- even if the bag later empties. Original purpose was
    # to protect the pre-catch starter rival fight; the previous live-only check
    # leaked, silently disabling perma-death on a wipe whenever the bag happened
    # to be empty. ever_had_balls? latches one-way on $PokemonGlobal and includes
    # a migration heuristic for pre-ratchet saves (multi-mon party / non-empty
    # storage implies catches have happened).
    return if !NuzlockeCaptureRules.ever_had_balls?

    perma_unfused = $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED]
    fused_mode    = (pbGet(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE) rescue 0) || 0

    survivors = []
    messages  = []

    $Trainer.party.each do |mon|
      next if !mon
      # Eggs and non-fainted mons always survive untouched.
      if mon.egg? || !mon.fainted?
        survivors.push(mon)
        next
      end

      # No inline rescue: the method-level rescue below is the safety net. If
      # isFusion ever raised, swallowing it here would misclassify a fusion as
      # unfused and wrongly perma-kill it; letting it bubble safely aborts the
      # whole post-battle processing instead (no one dies on an unexpected error).
      is_fusion = isFusion(mon.species_data.id_number)

      if !is_fusion
        # --- Feature 1: unfused perma-death ---
        if perma_unfused
          reclaim_held_item(mon)   # item back to the Bag; only the mon is lost
          messages.push(_INTL("{1} can never battle again...", mon.name))
          # Dropped from survivors => permanently removed.
        else
          survivors.push(mon)
        end
        next
      end

      # --- Feature 2: fused perma-death ---
      case fused_mode
      when 1   # Head dies, keep body
        survivor = build_survivor(mon, true)
        if survivor
          register_survivor(survivor, survivors)
          messages.push(_INTL("{1} can never battle again, but {2} survived...", mon.name, survivor.name))
        else
          survivors.push(mon)   # fail-safe: don't destroy on error
        end
      when 2   # Body dies, keep head
        survivor = build_survivor(mon, false)
        if survivor
          register_survivor(survivor, survivors)
          messages.push(_INTL("{1} can never battle again, but {2} survived...", mon.name, survivor.name))
        else
          survivors.push(mon)
        end
      when 3   # Both die
        reclaim_held_item(mon)   # both halves gone; item back to the Bag
        messages.push(_INTL("{1} can never battle again...", mon.name))
        # Dropped => removed entirely.
      else     # 0 = Off: normal revive-at-center behaviour
        survivors.push(mon)
      end
    end

    # Commit the rebuilt party in place (keep the same array object).
    $Trainer.party.clear
    survivors.each { |m| $Trainer.party.push(m) }

    messages.each { |msg| pbMessage(msg) }
  rescue => e
    PBDebug.log("[Nuzlocke] process_party_after_battle failed: #{e.message}") if defined?(PBDebug)
  end

  # No-soft-lock guard (Fix #22): some battles (notably the first rival fight)
  # are scripted "you're allowed to lose" (canLose) battles that NEVER trigger a
  # whiteout - the engine's Events.onEndBattle handler does `when 2,5: pbStartOver
  # unless canLose`. If perma-death just emptied the party in such a battle, the
  # player is stranded with zero Pokemon and no recovery (soft-lock). We only
  # fire here for canLose battles; for a normal loss the engine already warps the
  # player, so firing too would double-blackout. pbStartOver itself handles a
  # missing Pokemon Center (warps to the fallback start point), so it's safe even
  # early game. Fix #20 already keeps the pre-catch starter fight from emptying
  # the party at all; this is defense-in-depth for any later canLose battle.
  # NOTE: auto-reset-on-wipe under true perma-death is a separate future feature
  # (task #21). For now we only prevent the soft-lock via the standard blackout.
  def blackout_after_empty_party
    return if !active?
    return if !$Trainer || !$Trainer.party || !$Trainer.party.empty?
    Kernel.pbStartOver(false)
  rescue => e
    PBDebug.log("[Nuzlocke] blackout_after_empty_party failed: #{e.message}") if defined?(PBDebug)
  end
end

#===============================================================================
# Feature 1 & 2: perma-death processing, hooked after pbEndOfBattle.
#===============================================================================
class PokeBattle_Battle
  unless method_defined?(:nuzlocke_orig_pbEndOfBattle)
    alias_method :nuzlocke_orig_pbEndOfBattle, :pbEndOfBattle

    def pbEndOfBattle
      decision = nuzlocke_orig_pbEndOfBattle
      NuzlockeBattleRules.process_party_after_battle
      # Only self-blackout in canLose battles - a normal loss already triggers
      # the engine's own pbStartOver (Events.onEndBattle), so firing here too
      # would double-blackout. @canLose is the PokeBattle_Battle attr_accessor.
      NuzlockeBattleRules.blackout_after_empty_party if @canLose
      return decision
    end
  end
end

#===============================================================================
# Battle-items enforcement (Fix #23) lives elsewhere now.
#
# The old whole-bag block here intercepted the Bag command in
# PokeBattle_Scene#pbCommandMenu and blocked the ENTIRE bag - including Poke
# Balls - which made catching impossible and broke the core Nuzlocke loop.
# It has been removed so the bag opens normally.
#
# Battle-items enforcement now happens per-item in NuzlockeCaptureRules.rb via
# ItemHandlers.triggerCanUseInBattle, which allows Poke Balls while blocking
# other items when battle items are forbidden. Keeping balls usable is what
# preserves the catch loop, so do NOT reintroduce a bag-wide block here.
#===============================================================================
