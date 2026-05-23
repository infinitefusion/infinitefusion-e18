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
#   3. Battle items lock     - the Bag command is unavailable in battle when
#      battle items are not allowed.
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
    id_number = fused.species_data.id_number
    survivor_species = getBasePokemonID(id_number, keep_body)
    return nil if !survivor_species || survivor_species <= 0

    # Mirror pbUnfuse: prefer preserved fused-EXP if present, else use level.
    survivor = Pokemon.new(survivor_species, fused.level)
    if fused.exp_when_fused_head != nil && fused.exp_when_fused_body != nil
      preserved = (keep_body ? fused.exp_when_fused_body : fused.exp_when_fused_head)
      gained    = fused.exp_gained_since_fused || 0
      survivor.exp = preserved + gained
    end

    # Copy over IVs / EVs (hashes - dup so we don't share references).
    survivor.iv = fused.iv.dup       if fused.iv
    survivor.ev = fused.ev.dup       if fused.ev
    survivor.ivMaxed = fused.ivMaxed.dup if fused.ivMaxed

    # Preserve the nickname only if the trainer actually nicknamed the fusion.
    survivor.name = fused.name if fused.nicknamed?

    survivor.obtain_method = 0
    return survivor
  rescue => e
    PBDebug.log("[Nuzlocke] build_survivor failed: #{e.message}") if defined?(PBDebug)
    return nil
  end

  # Give a Pokemon to the player: into the party if there's room, else the PC.
  def give_survivor(survivor)
    return if !survivor
    if $Trainer && !$Trainer.party_full?
      $Trainer.party[$Trainer.party.length] = survivor
    else
      $PokemonStorage.pbStoreCaught(survivor) if $PokemonStorage
    end
    if $Trainer && $Trainer.pokedex
      $Trainer.pokedex.set_seen(survivor.species)
      $Trainer.pokedex.set_owned(survivor.species)
    end
  end

  # Process the whole party after a battle, applying perma-death rules.
  # Rebuilds the party from survivors rather than deleting while iterating.
  def process_party_after_battle
    return if !active?
    return if !$Trainer || !$Trainer.party

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

      is_fusion = (isFusion(mon.species_data.id_number) rescue false)

      if !is_fusion
        # --- Feature 1: unfused perma-death ---
        if perma_unfused
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
          give_survivor(survivor)
          messages.push(_INTL("{1} can never battle again, but {2} survived...", mon.name, survivor.name))
        else
          survivors.push(mon)   # fail-safe: don't destroy on error
        end
      when 2   # Body dies, keep head
        survivor = build_survivor(mon, false)
        if survivor
          give_survivor(survivor)
          messages.push(_INTL("{1} can never battle again, but {2} survived...", mon.name, survivor.name))
        else
          survivors.push(mon)
        end
      when 3   # Both die
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
      return decision
    end
  end
end

#===============================================================================
# Feature 3: battle items lock, hooked into the command menu.
# When Nuzlocke mode is on and battle items are NOT allowed, intercept a Bag
# selection (return value 1), warn the player, and re-open the menu so they
# pick another action. Trainer/other battles are unaffected when the switch is
# off.
#===============================================================================
class PokeBattle_Scene
  unless method_defined?(:nuzlocke_orig_pbCommandMenu)
    alias_method :nuzlocke_orig_pbCommandMenu, :pbCommandMenu

    def pbCommandMenu(idxBattler, firstAction)
      loop do
        ret = nuzlocke_orig_pbCommandMenu(idxBattler, firstAction)
        if ret == 1 && nuzlocke_items_blocked?
          pbDisplayMessage(_INTL("No items allowed in this challenge!"))
          next   # bounce back to the command menu
        end
        return ret
      end
    end

    def nuzlocke_items_blocked?
      return false if !$game_switches
      return false if !$game_switches[SWITCH_NUZLOCKE_MODE]
      return false if $game_switches[SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED]
      return true
    end
  end
end
