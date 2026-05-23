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
# Note on SWITCH_DURING_INTRO (917):
# A codebase grep finds no Ruby line that ever clears switch 917 - the only
# readers are in RandomizerSettings.rb. The switch is therefore set/cleared
# inside the intro's map events (binary .rxdata), so we can trust the Ruby-side
# read but we cannot verify the toggle in source. As a defensive secondary
# guard we also require $Trainer.party_count > 0, which is naturally false
# until the starter has been received and a normal step is taken on a real map.
Events.onStepTaken += proc {
  next if !$game_switches || !$game_switches[SWITCH_NUZLOCKE_MODE]
  next if $game_switches[SWITCH_DURING_INTRO]
  next if !$Trainer || $Trainer.save_slot.nil?
  next if $Trainer.party_count == 0
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

  # Restore the snapshot into the live globals.
  Game.load(snapshot)

  # Re-roll any randomization that's currently enabled so the post-reset run is fresh.
  nuzlocke_reset_reshuffle_randomizers

  # Warp the player to the new-game start position (same pattern as Game.start_new).
  $MapFactory = PokemonMapFactory.new($data_system.start_map_id)
  $game_player.moveto($data_system.start_x, $data_system.start_y)
  $game_player.refresh
  $game_map.autoplay

  # Persist the freshly reset state back into the original slot.
  Game.save(active_slot) if active_slot

  pbMessage(_INTL("Your run has been reset. Good luck."))

  $game_temp.transition_processing = true if $game_temp
end
