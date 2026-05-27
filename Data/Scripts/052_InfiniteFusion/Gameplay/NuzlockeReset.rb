# Nuzlocke Reset Run
# ------------------
# Captures a "starting line" snapshot of the player's save right after the new-game
# intro completes. The pause-menu "Reset Run" entry (added in 016_UI_PauseMenu.rb)
# uses that snapshot to wipe progress while preserving the player's name and
# Nuzlocke settings, warping them back to the start map. Wild/trainer/item/TM
# randomization is re-shuffled for whichever shuffle switches are currently on.

#===============================================================================
# Snapshot file path helpers
#===============================================================================

# Returns the absolute path to the per-slot nuzlocke snapshot file.
# Returns nil if no slot is provided and the player has no active save slot.
def nuzlocke_snapshot_path(slot = nil)
  slot ||= ($Trainer && $Trainer.save_slot)
  return nil if slot.nil?
  return File.join(SaveData::SAVE_DIR, "#{slot}_nuzlocke_reset.rxdata")
end

# Returns true if a nuzlocke snapshot exists for the currently active save slot.
def nuzlocke_snapshot_exists?
  path = nuzlocke_snapshot_path
  return false if path.nil?
  return File.file?(path)
end

#===============================================================================
# Snapshot capture - hooks onStepTaken
#===============================================================================
# We snapshot on the first overworld step where:
#   * Nuzlocke mode is active
#   * The new-game intro is no longer running (SWITCH_DURING_INTRO is false)
#   * The player has actually saved at least once ($Trainer.save_slot is set)
#   * No snapshot already exists for this slot
#
# Capturing pre-starter is intentional: the player should be able to hit
# "Reset Run" at any point, including after checking the starters but before
# committing to one. SWITCH_DURING_INTRO is cleared by binary map events at
# the end of the intro sequence; once that goes false and they've saved, the
# first overworld step grabs the snapshot.
Events.onStepTaken += proc {
  next if !$game_switches || !$game_switches[SWITCH_NUZLOCKE_MODE]
  next if $game_switches[SWITCH_DURING_INTRO]
  next if !$Trainer || $Trainer.save_slot.nil?
  path = nuzlocke_snapshot_path
  next if path.nil?
  next if File.file?(path)
  begin
    SaveData.save_to_file(path)
    echoln("[NuzlockeReset] Captured reset snapshot for slot '#{$Trainer.save_slot}' at #{path}")
  rescue => e
    echoln("[NuzlockeReset] Failed to capture snapshot: #{e.message}")
  end
}

#===============================================================================
# Common event lookup by name (so reset doesn't break when upstream
# renumbers common events on update).
#===============================================================================
def find_common_event_id_by_name(name)
  return nil if !$data_common_events
  $data_common_events.each_with_index do |ev, i|
    next if ev.nil?
    return i if ev.name == name
  end
  return nil
end

#===============================================================================
# Settings preservation across the snapshot reload.
#
# Game.load(snapshot) overwrites the ENTIRE $game_switches / $game_variables with
# the snapshot's values. The snapshot is captured once per slot at the starting
# line and is NOT refreshed on a new game, so its switch state can be stale and
# silently turn OFF the player's perma-death rules and randomizer config after a
# reset. These two lists name the switches/vars that represent the player's chosen
# SETTINGS (not run progress) and must therefore survive the wipe. Constants are
# resolved with const_defined? guards so unreleased (e.g. stashed Phase 2) options
# are simply skipped until they exist.
#===============================================================================
NUZLOCKE_RESET_PRESERVED_SWITCH_SYMS = [
  # --- Nuzlocke rule switches ---
  :SWITCH_NUZLOCKE_MODE, :SWITCH_NUZLOCKE_MODE_INTRO, :SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA,
  :SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, :SWITCH_NUZLOCKE_FORCE_NICKNAMES,
  :SWITCH_NUZLOCKE_RESET_ENABLED, :SWITCH_NUZLOCKE_AT_LEAST_ONCE,
  :SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, :SWITCH_NUZLOCKE_CAP_CANDY_ENABLED,
  :SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS,
  # --- Nuzlocke Phase 2 switches (skipped until released) ---
  :SWITCH_NUZLOCKE_HERITAGE_MOVEPOOL, :SWITCH_NUZLOCKE_ENCOUNTER_DEX_LOCK,
  :SWITCH_NUZLOCKE_MONOTYPE_FUSION_MANDATE, :SWITCH_NUZLOCKE_FUSION_PERMANENCE_LOCK,
  :SWITCH_NUZLOCKE_SEEDED_RUN, :SWITCH_NUZLOCKE_EVOLUTION_ROULETTE,
  :SWITCH_NUZLOCKE_STARTER_FUSION_LOCK, :SWITCH_NUZLOCKE_DUPES_CLAUSE_ADDITIVE,
  :SWITCH_NUZLOCKE_SHINY_CLAUSE,
  # --- Randomizer configuration switches (define how the run randomizes) ---
  :SWITCH_RANDOMIZED_AT_LEAST_ONCE, :SWITCH_RANDOMIZED_MODE_INTRO,
  :SWITCH_RANDOM_WILD, :SWITCH_RANDOM_WILD_AREA, :SWITCH_RANDOM_WILD_TO_FUSION,
  :SWITCH_RANDOM_TRAINERS, :SWITCH_RANDOM_STARTERS, :SWITCH_RANDOM_STARTER_FIRST_STAGE,
  :SWITCH_RANDOM_ITEMS, :SWITCH_RANDOM_ITEMS_GENERAL, :SWITCH_RANDOM_FOUND_ITEMS,
  :SWITCH_RANDOM_ITEMS_DYNAMIC, :SWITCH_RANDOM_ITEMS_MAPPED, :SWITCH_RANDOM_TMS,
  :SWITCH_RANDOM_GIVEN_ITEMS, :SWITCH_RANDOM_GIVEN_TMS, :SWITCH_RANDOM_SHOP_ITEMS,
  :SWITCH_RANDOM_FOUND_TMS, :SWITCH_WILD_RANDOM_GLOBAL, :SWITCH_RANDOM_STATIC_ENCOUNTERS,
  :SWITCH_RANDOM_WILD_ONLY_CUSTOMS, :SWITCH_RANDOM_GYM_PERSIST_TEAMS,
  :SWITCH_GYM_RANDOM_EACH_BATTLE, :SWITCH_RANDOM_GYM_CUSTOMS, :SWITCH_RANDOMIZE_GYMS_SEPARATELY,
  :SWITCH_RANDOMIZED_GYM_TYPES, :SWITCH_RANDOM_GIFT_POKEMON, :SWITCH_RANDOM_HELD_ITEMS,
  :SWITCH_DEFINED_RIVAL_STARTER, :SWITCH_RANDOMIZED_WILD_POKEMON_TO_FUSIONS,
  :SWITCH_RANDOM_WILD_LEGENDARIES, :SWITCH_RANDOM_TRAINER_LEGENDARIES,
  :SWITCH_RANDOM_GYM_LEGENDARIES, :SWITCH_DONT_RANDOMIZE
].freeze

NUZLOCKE_RESET_PRESERVED_VAR_SYMS = [
  :VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE,
  :VAR_NUZLOCKE_CATCH_RULE_MODE,
  :VAR_RANDOMIZER_WILD_POKE_BST,
  # Phase 2 vars (skipped until released)
  :VAR_NUZLOCKE_HERITAGE_MOVEPOOL_MODE, :VAR_NUZLOCKE_SPLICE_ECONOMY_MODE,
  :VAR_NUZLOCKE_SPLICE_ECONOMY_COST, :VAR_NUZLOCKE_SEEDED_RUN_SEED,
  :VAR_NUZLOCKE_EVOLUTION_ROULETTE_BUDGET, :VAR_NUZLOCKE_DUPES_CLAUSE_REROLL_ATTEMPTS
].freeze

# Capture {switch_id => value} for every preserved switch that is currently defined.
def nuzlocke_reset_capture_settings
  switches = {}
  NUZLOCKE_RESET_PRESERVED_SWITCH_SYMS.each do |sym|
    next if !Object.const_defined?(sym)
    id = Object.const_get(sym)
    switches[id] = $game_switches[id]
  end
  vars = {}
  NUZLOCKE_RESET_PRESERVED_VAR_SYMS.each do |sym|
    next if !Object.const_defined?(sym)
    id = Object.const_get(sym)
    vars[id] = $game_variables[id]
  end
  return [switches, vars]
end

# Re-apply preserved settings on top of the freshly-loaded snapshot.
def nuzlocke_reset_restore_settings(switches, vars)
  switches.each { |id, val| $game_switches[id] = val } if switches
  vars.each { |id, val| $game_variables[id] = val } if vars
end

#===============================================================================
# Re-run randomization shuffles based on currently-active switches
# Shape copied from RepairUtils.rb lines 66-72.
#===============================================================================
def nuzlocke_reset_reshuffle_randomizers
  if $game_switches[SWITCH_RANDOM_TRAINERS]
    Kernel.pbShuffleTrainers()
  end
  if $game_switches[SWITCH_RANDOM_WILD]
    range = pbGet(VAR_RANDOMIZER_WILD_POKE_BST)
    range = 25 if range.nil? || range == 0
    Kernel.pbShuffleDex(range, 1)
  end
  if $game_switches[SWITCH_RANDOM_ITEMS] && defined?(pbShuffleItems)
    pbShuffleItems()
  end
  if $game_switches[SWITCH_RANDOM_TMS] && defined?(pbShuffleTMs)
    pbShuffleTMs()
  end
end

#===============================================================================
# Public entry-point called from the pause menu
#===============================================================================
def nuzlocke_reset_run
  path = nuzlocke_snapshot_path
  if path.nil? || !File.file?(path)
    pbMessage(_INTL("No reset snapshot is available for this save."))
    return
  end

  if !pbConfirmMessageSerious(_INTL("This will wipe ALL progress and reset you to the start. Your name and Nuzlocke settings stay. Continue?"))
    return
  end

  begin
    snapshot = SaveData.read_from_file(path)
  rescue => e
    echoln("[NuzlockeReset] Failed to read snapshot: #{e.message}")
    pbMessage(_INTL("The reset snapshot could not be read."))
    return
  end

  active_slot = $Trainer.save_slot

  # Surface progress before we kick off the heavy work — Game.load and the
  # reshuffles can take a moment on bigger randomized runs.
  pbMessage(_INTL("Resetting your run. This may take a minute...\\^"))

  # Hang onto the live Scene_Map. Game.load (003_Game processing/001_StartGame.rb)
  # internally does `$scene = Scene_Map.new`; we restore the live scene below
  # because a fresh Scene_Map has @spritesets = nil until its main loop runs
  # createSpritesets, and any rendering in between (shuffle progress, save
  # chrome, pbMessage) would crash on Scene_Map#spriteset.
  original_scene = $scene

  # Best-effort cleanup of the current map's event state before the swap.
  if $game_map && $game_map.events
    $game_map.events.each_value { |event| event.clear_starting }
  end
  $game_temp.common_event_id = 0 if $game_temp
  pbMapInterpreter&.clear
  pbMapInterpreter&.setup(nil, 0, 0)

  # Capture the player's chosen SETTINGS (Nuzlocke rules + randomizer config)
  # BEFORE the wipe. Game.load below overwrites ALL switches/variables with the
  # snapshot's (possibly stale) values, which would otherwise silently disable
  # perma-death and randomization for the post-reset run. We re-apply these
  # immediately after the load so the reset keeps your settings exactly.
  preserved_switches, preserved_vars = nuzlocke_reset_capture_settings

  # Restore the snapshot into the live globals. This wipes party / bag /
  # badges / progress flags back to the captured "post-intro, pre-starter"
  # state. We DON'T trust the snapshot's saved position to put the player
  # in a starter-ready spot — the bedroom autorun re-fires the whole intro
  # chain when party_count is 0. Instead we run the canonical
  # "skip intro" common event below, which is the exact same code path the
  # game uses when the player picks Skip during the splicer demo cutscene.
  Game.load(snapshot)

  # Re-apply the preserved settings on top of the restored snapshot, so perma-death
  # and the randomizer switches reflect the player's CURRENT choices (not whatever
  # the snapshot happened to hold). This must happen before the reshuffle below,
  # which keys off these switches.
  nuzlocke_reset_restore_settings(preserved_switches, preserved_vars)

  # Rebuild PokemonEncounters for whatever map the snapshot put us on.
  $PokemonEncounters = PokemonEncounters.new
  $PokemonEncounters.setup($game_map.map_id)
  $game_map.autoplay
  $game_map.update

  # Reclaim the live scene and rebuild its spritesets in-place for the new
  # map. Pattern lifted from Scene_Map#transfer_player (002_Scene_Map.rb).
  if original_scene.is_a?(Scene_Map)
    $scene = original_scene
    original_scene.disposeSpritesets
    RPG::Cache.clear if defined?(RPG::Cache) && RPG::Cache.respond_to?(:need_clearing) && RPG::Cache.need_clearing
    original_scene.createSpritesets
  end

  # Re-roll any randomization that's currently enabled so the post-reset run
  # is fresh. Silent re-roll using the player's already-chosen switches —
  # no randomizer-settings menu pops up. Shuffle functions surface their own
  # progress UI via Kernel.pbMessageNoSound.
  nuzlocke_reset_reshuffle_randomizers

  # Persist the wiped state to the slot before the warp.
  Game.save(active_slot) if active_slot

  # Run the existing in-game "skip intro" common event — the same one the
  # splicer demo cutscene's Skip option triggers. It pops the "Skip to
  # starter selection?" prompt, sets self-switch A on Oak's lab event 1
  # (map 157), and transfers the player to the starter selection point.
  # Looked up by name so upstream renumbering on update won't silently
  # break us.
  skip_id = find_common_event_id_by_name("skip intro")
  if skip_id
    pbCommonEvent(skip_id)
  else
    echoln("[NuzlockeReset] 'skip intro' common event not found; leaving the player at the snapshot position.")
    pbMessage(_INTL("Your run has been reset. Good luck."))
  end

  $game_temp.transition_processing = true if $game_temp
end
