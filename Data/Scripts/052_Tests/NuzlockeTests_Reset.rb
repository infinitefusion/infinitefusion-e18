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
# survive Game.load(snapshot)).
NuzlockeTestHarness.suite("STORY: Randomized starter regret") do |t|
  t.log("Player starts a Randomized Nuzlocke: perma-death on, wild randomization on.")
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_switch(SWITCH_RANDOM_WILD, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 3)
  t.log("They open the starter box, hate the randomized starter, and hit Reset Run.")
  preserved_switches, preserved_vars = nuzlocke_reset_capture_settings
  t.log("Reset Run calls Game.load(snapshot), clobbering all switches/vars...")
  $game_switches = Game_Switches.new
  $game_variables = Game_Variables.new
  t.assert("right after clobber the run looks like a plain non-nuzlocke (bug if not restored)",
           $game_switches[SWITCH_NUZLOCKE_MODE] == false && $game_switches[SWITCH_RANDOM_WILD] == false)
  nuzlocke_reset_restore_settings(preserved_switches, preserved_vars)
  t.log("Settings restored on top of the fresh snapshot.")
  t.assert("fresh run is still a Nuzlocke (MODE on)", $game_switches[SWITCH_NUZLOCKE_MODE] == true)
  t.assert("perma-death rule survived", $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] == true)
  t.assert_eq("fused perma-death mode survived", 3, $game_variables[VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE])
  t.assert("fresh run is still Randomized (wild randomization on)", $game_switches[SWITCH_RANDOM_WILD] == true)
end

end # defined?(NuzlockeTestHarness)
