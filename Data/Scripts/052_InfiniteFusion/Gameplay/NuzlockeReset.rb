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

  # Mirror Game.start_new (MultiSaves.rb) so the scene gets cleanly torn down
  # and rebuilt. Without this, the live Scene_Map keeps stale references
  # (notably @spritesets) and the next render trips a NoMethodError on nil.
  if $game_map && $game_map.events
    $game_map.events.each_value { |event| event.clear_starting }
  end
  $game_temp.common_event_id = 0 if $game_temp
  pbMapInterpreter&.clear
  pbMapInterpreter&.setup(nil, 0, 0)

  # Restore the snapshot into the live globals.
  Game.load(snapshot)

  # Fresh scene avoids the @spritesets-is-nil crash that the previous reset
  # implementation hit; createSpritesets runs when the new scene starts up.
  $scene = Scene_Map.new

  # Re-roll any randomization that's currently enabled so the post-reset run
  # is fresh. The shuffle functions surface their own progress UI via
  # Kernel.pbMessageNoSound.
  nuzlocke_reset_reshuffle_randomizers

  # Warp the player to the new-game start position (same pattern as Game.start_new).
  $MapFactory = PokemonMapFactory.new($data_system.start_map_id)
  $game_player.moveto($data_system.start_x, $data_system.start_y)
  $game_player.refresh
  $PokemonEncounters = PokemonEncounters.new
  $PokemonEncounters.setup($game_map.map_id)
  $game_map.autoplay
  $game_map.update

  # Persist the freshly reset state back into the original slot.
  Game.save(active_slot) if active_slot

  pbMessage(_INTL("Your run has been reset. Good luck."))

  $game_temp.transition_processing = true if $game_temp
end
