# Reset Run settings-preservation suites (team 'nuzlocke-tests' / reset-author).
# Wrapped in a defined? guard so load order can never crash boot.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("ALL preserved switches survive the Game.load clobber") do |t|
  defined_syms = NUZLOCKE_RESET_PRESERVED_SWITCH_SYMS.select { |sym| Object.const_defined?(sym) }
  defined_syms.each { |sym| $game_switches[Object.const_get(sym)] = true }
  preserved_switches, preserved_vars = nuzlocke_reset_capture_settings
  $game_switches = Game_Switches.new
  $game_variables = Game_Variables.new
  nuzlocke_reset_restore_settings(preserved_switches, preserved_vars)
  failed = defined_syms.reject { |sym| $game_switches[Object.const_get(sym)] == true }
  t.log("preserved switches checked: #{defined_syms.length} (skipped #{NUZLOCKE_RESET_PRESERVED_SWITCH_SYMS.length - defined_syms.length} undefined)")
  t.log("switches NOT restored: #{failed.inspect}") unless failed.empty?
  t.assert("every defined preserved switch restored to true", failed.empty?)
end

NuzlockeTestHarness.suite("ALL preserved vars survive the Game.load clobber") do |t|
  defined_syms = NUZLOCKE_RESET_PRESERVED_VAR_SYMS.select { |sym| Object.const_defined?(sym) }
  defined_syms.each { |sym| $game_variables[Object.const_get(sym)] = 7 }
  preserved_switches, preserved_vars = nuzlocke_reset_capture_settings
  $game_switches = Game_Switches.new
  $game_variables = Game_Variables.new
  nuzlocke_reset_restore_settings(preserved_switches, preserved_vars)
  failed = defined_syms.reject { |sym| $game_variables[Object.const_get(sym)] == 7 }
  t.log("preserved vars checked: #{defined_syms.length} (skipped #{NUZLOCKE_RESET_PRESERVED_VAR_SYMS.length - defined_syms.length} undefined)")
  t.log("vars NOT restored: #{failed.inspect}") unless failed.empty?
  t.assert("every defined preserved var restored to 7", failed.empty?)
end

NuzlockeTestHarness.suite("Progress switches are NOT preserved (reset wipes them)") do |t|
  t.assert("SWITCH_GOT_BADGE_1 is defined", Object.const_defined?(:SWITCH_GOT_BADGE_1))
  t.refute("SWITCH_GOT_BADGE_1 is not in the preserved switch list",
           NUZLOCKE_RESET_PRESERVED_SWITCH_SYMS.include?(:SWITCH_GOT_BADGE_1))
  t.set_switch(SWITCH_GOT_BADGE_1, true)
  preserved_switches, preserved_vars = nuzlocke_reset_capture_settings
  $game_switches = Game_Switches.new
  $game_variables = Game_Variables.new
  nuzlocke_reset_restore_settings(preserved_switches, preserved_vars)
  t.assert("badge progress STAYS wiped after a reset", $game_switches[SWITCH_GOT_BADGE_1] == false)
end

NuzlockeTestHarness.suite("Restore is idempotent (restoring twice is stable)") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 2)
  preserved_switches, preserved_vars = nuzlocke_reset_capture_settings
  $game_switches = Game_Switches.new
  $game_variables = Game_Variables.new
  nuzlocke_reset_restore_settings(preserved_switches, preserved_vars)
  nuzlocke_reset_restore_settings(preserved_switches, preserved_vars)   # second apply must not change anything
  t.assert("nuzlocke MODE still ON after double restore", $game_switches[SWITCH_NUZLOCKE_MODE] == true)
  t.assert("perma-death still ON after double restore", $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] == true)
  t.assert_eq("fused perma-death var stable after double restore", 2, $game_variables[VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE])
end

NuzlockeTestHarness.suite("Randomization config survives the clobber") do |t|
  t.set_switch(SWITCH_RANDOM_WILD, true)
  t.set_switch(SWITCH_RANDOM_TRAINERS, true)
  t.set_switch(SWITCH_RANDOM_ITEMS, true)
  t.set_switch(SWITCH_RANDOM_TMS, true)
  t.set_var(VAR_RANDOMIZER_WILD_POKE_BST, 25)
  preserved_switches, preserved_vars = nuzlocke_reset_capture_settings
  $game_switches = Game_Switches.new
  $game_variables = Game_Variables.new
  nuzlocke_reset_restore_settings(preserved_switches, preserved_vars)
  t.assert("RANDOM_WILD restored ON", $game_switches[SWITCH_RANDOM_WILD] == true)
  t.assert("RANDOM_TRAINERS restored ON", $game_switches[SWITCH_RANDOM_TRAINERS] == true)
  t.assert("RANDOM_ITEMS restored ON", $game_switches[SWITCH_RANDOM_ITEMS] == true)
  t.assert("RANDOM_TMS restored ON", $game_switches[SWITCH_RANDOM_TMS] == true)
  t.assert_eq("wild BST range restored", 25, $game_variables[VAR_RANDOMIZER_WILD_POKE_BST])
end

# STORY: "Randomized starter regret" -- a player begins a Randomized Nuzlocke,
# hates their randomized starter, and hits Reset Run before committing. The
# fresh run must still be a randomized nuzlocke (both rule + randomizer config
# survive the new-game rebuild).
NuzlockeTestHarness.suite("STORY: Randomized starter regret") do |t|
  t.log("Player starts a Randomized Nuzlocke: perma-death on, wild randomization on.")
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_switch(SWITCH_RANDOM_WILD, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 3)
  t.log("They open the starter box, hate the randomized starter, and hit Reset Run.")
  preserved_switches, preserved_vars = nuzlocke_reset_capture_settings
  t.log("Reset Run rebuilds the game from new-game values, clobbering all switches/vars...")
  $game_switches = Game_Switches.new
  $game_variables = Game_Variables.new
  t.assert("right after clobber the run looks like a plain non-nuzlocke (bug if not restored)",
           $game_switches[SWITCH_NUZLOCKE_MODE] == false && $game_switches[SWITCH_RANDOM_WILD] == false)
  nuzlocke_reset_restore_settings(preserved_switches, preserved_vars)
  t.log("Settings restored on top of the fresh game.")
  t.assert("fresh run is still a Nuzlocke (MODE on)", $game_switches[SWITCH_NUZLOCKE_MODE] == true)
  t.assert("perma-death rule survived", $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] == true)
  t.assert_eq("fused perma-death mode survived", 3, $game_variables[VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE])
  t.assert("fresh run is still Randomized (wild randomization on)", $game_switches[SWITCH_RANDOM_WILD] == true)
end

#===============================================================================
# Fresh-game rebuild (replaces the old save-copy approach).
#===============================================================================
NuzlockeTestHarness.suite("Reset identity: name, character, outfit, slot captured and restored") do |t|
  $Trainer.instance_variable_set(:@name, "Matt")
  $Trainer.instance_variable_set(:@character_ID, 1)
  $Trainer.instance_variable_set(:@clothes, "COOL_SHIRT")
  $Trainer.instance_variable_set(:@hat, "CAP")
  $Trainer.instance_variable_set(:@unlocked_hats, ["CAP", "BEANIE"])
  $Trainer.instance_variable_set(:@save_slot, "File B")
  $game_variables[52] = 0
  $game_variables[84] = "Matt"
  identity = nuzlocke_reset_capture_identity
  t.assert_eq("name captured", "Matt", identity[:ivars][:@name])
  t.assert_eq("character captured", 1, identity[:ivars][:@character_ID])
  t.assert_eq("outfit captured", "COOL_SHIRT", identity[:ivars][:@clothes])
  t.assert_eq("unlocks captured", ["CAP", "BEANIE"], identity[:ivars][:@unlocked_hats])
  t.assert_eq("slot captured", "File B", identity[:ivars][:@save_slot])
  t.assert_eq("gender var captured", 0, identity[:vars][52])
  # Simulate the new game: fresh trainer + fresh variables.
  $Trainer = NuzlockeTestTrainer.new
  $game_variables = Game_Variables.new
  changed = []
  orig_cp = Object.instance_method(:pbChangePlayer)
  Object.send(:define_method, :pbChangePlayer) { |id| changed << id; true }
  nuzlocke_reset_restore_identity(identity)
  nuzlocke_test_restore(:pbChangePlayer, orig_cp)
  t.assert_eq("pbChangePlayer called with the character", [1], changed)
  t.assert_eq("name restored", "Matt", $Trainer.instance_variable_get(:@name))
  t.assert_eq("outfit restored", "COOL_SHIRT", $Trainer.instance_variable_get(:@clothes))
  t.assert_eq("unlocks restored", ["CAP", "BEANIE"], $Trainer.instance_variable_get(:@unlocked_hats))
  t.assert_eq("gender var restored", 0, $game_variables[52])
  t.assert_eq("name var restored", "Matt", $game_variables[84])
end

NuzlockeTestHarness.suite("Reset intro replay: intro switches on, intro flag off, intro events silenced") do |t|
  $game_self_switches = {} if !$game_self_switches
  t.set_switch(SWITCH_DURING_INTRO, true)
  t.set_switch(SWITCH_RANDOMIZED_MODE_INTRO, true)
  nuzlocke_reset_apply_intro_state
  t.refute("DURING_INTRO cleared", $game_switches[SWITCH_DURING_INTRO])
  NUZLOCKE_INTRO_SWITCHES.each { |id| t.assert("intro switch #{id} on", $game_switches[id] == true) }
  t.assert_eq("intro var 199 zeroed", 0, $game_variables[199])
  t.assert("intro map events flipped to their skipped pages", (1..4).all? { |ev| $game_self_switches[[295, ev, "A"]] == true })
  t.assert("splicer demo event flipped", $game_self_switches[[157, 1, "A"]] == true)
  t.assert("item + TM tables seeded", t.shuffles.include?(:items) && t.shuffles.include?(:tms))
  t.assert_eq("gym type reset for a randomized run", -1, $game_variables[VAR_CURRENT_GYM_TYPE])
end

NuzlockeTestHarness.suite("SEAM nuzlocke_reset_run: new game, settings, identity, skip, save -- in order") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_DURING_INTRO, false)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_switch(SWITCH_RANDOM_WILD, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 2)
  $Trainer.instance_variable_set(:@name, "Matt")
  $Trainer.instance_variable_set(:@save_slot, "File A")
  $Trainer.instance_variable_set(:@character_ID, 0)
  $game_self_switches = {} if !$game_self_switches
  $game_temp = Struct.new(:common_event_id, :transition_processing).new(0, false) if !$game_temp.respond_to?(:transition_processing)
  log = []
  stubs = {}
  { nuzlocke_reset_fresh_game!: proc { log << :fresh
                                      $Trainer = NuzlockeTestTrainer.new
                                      $game_switches = Game_Switches.new
                                      $game_variables = Game_Variables.new },
    nuzlocke_reset_apply_randomizer!: proc { log << :randomizer },
    nuzlocke_reset_skip_to_starter!:  proc { log << :skip; true },
    pbChangePlayer:                    proc { |_id| log << :player; true },
    pbMapInterpreter:                  proc { nil } }.each do |name, body|
    stubs[name] = Object.instance_method(name)
    Object.send(:define_method, name, &body)
  end
  saved = []
  game_save = Game.method(:save)
  Game.define_singleton_method(:save) { |*a| saved << a[0]; true }
  Object.send(:define_method, :pbConfirmMessageSerious) { |*_a| true }

  result = nuzlocke_reset_run(true)

  Game.define_singleton_method(:save, game_save)
  stubs.each { |name, orig| nuzlocke_test_restore(name, orig) }

  t.assert("reset ran", result == true)
  t.assert_eq("order: fresh game -> randomizer -> skip", [:fresh, :player, :randomizer, :skip], log)
  t.assert("MODE re-applied on the fresh game", $game_switches[SWITCH_NUZLOCKE_MODE] == true)
  t.assert("perma-death setting survived", $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] == true)
  t.assert("randomizer setting survived", $game_switches[SWITCH_RANDOM_WILD] == true)
  t.assert_eq("fused perma-death var survived", 2, $game_variables[VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE])
  t.assert_eq("name survived onto the NEW trainer", "Matt", $Trainer.instance_variable_get(:@name))
  t.assert_eq("saved back into the same slot", ["File A"], saved)
  t.refute("intro flag off afterwards", $game_switches[SWITCH_DURING_INTRO])
  t.assert("a 'resetting' message was shown", t.captured_msgs.any? { |m| m =~ /resetting your run/i })
end

NuzlockeTestHarness.suite("Reset: declined confirmation does nothing") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_DURING_INTRO, false)
  Object.send(:define_method, :pbConfirmMessageSerious) { |*_a| false }
  ran = false
  orig = Object.instance_method(:nuzlocke_reset_fresh_game!)
  Object.send(:define_method, :nuzlocke_reset_fresh_game!) { ran = true }
  r = nuzlocke_reset_run(true)
  nuzlocke_test_restore(:nuzlocke_reset_fresh_game!, orig)
  t.assert("returns false", r == false)
  t.refute("nothing rebuilt", ran)
end

NuzlockeTestHarness.suite("find_common_event_id_by_name: UTF-8 name match + id fallback") do |t|
  ev = Struct.new(:name)
  $data_common_events = [nil, ev.new("intro"), ev.new("les trucs du d\xC3\xA9but du jeu".b), ev.new("skip intro")]
  t.assert_eq("accented name (binary-encoded in rxdata) matches", 2, find_common_event_id_by_name("les trucs du début du jeu"))
  t.assert_eq("unknown name uses the fallback id", 99, find_common_event_id_by_name("nope", 99))
  $data_common_events = nil
  t.assert_eq("nil table uses the fallback id", 29, find_common_event_id_by_name("x", 29))
end

end # defined?(NuzlockeTestHarness)
