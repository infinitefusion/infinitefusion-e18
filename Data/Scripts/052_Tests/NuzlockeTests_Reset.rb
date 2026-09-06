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
NuzlockeTestHarness.suite("Reset identity: name, character, hair captured and restored; outfits and unlocks are NOT") do |t|
  $Trainer.instance_variable_set(:@name, "Matt")
  $Trainer.instance_variable_set(:@character_ID, 1)
  $Trainer.instance_variable_set(:@skin_tone, 2)
  $Trainer.instance_variable_set(:@hair, "3_red")
  $Trainer.instance_variable_set(:@hair_color, 40)
  $Trainer.instance_variable_set(:@clothes, "COOL_SHIRT")
  $Trainer.instance_variable_set(:@hat, "CAP")
  $Trainer.instance_variable_set(:@unlocked_hats, ["CAP", "BEANIE"])
  $Trainer.instance_variable_set(:@unlocked_clothes, ["COOL_SHIRT"])
  $Trainer.instance_variable_set(:@save_slot, "File B")
  $game_variables[52] = 0
  $game_variables[84] = "Matt"
  identity = nuzlocke_reset_capture_identity
  t.assert_eq("name captured", "Matt", identity[:ivars][:@name])
  t.assert_eq("character captured", 1, identity[:ivars][:@character_ID])
  t.assert_eq("skin tone captured", 2, identity[:ivars][:@skin_tone])
  t.assert_eq("hair captured", "3_red", identity[:ivars][:@hair])
  t.assert_eq("hair colour captured", 40, identity[:ivars][:@hair_color])
  t.refute("outfit NOT captured", identity[:ivars].key?(:@clothes))
  t.refute("hat NOT captured", identity[:ivars].key?(:@hat))
  t.refute("unlocked hats NOT captured", identity[:ivars].key?(:@unlocked_hats))
  t.refute("unlocked clothes NOT captured", identity[:ivars].key?(:@unlocked_clothes))
  t.assert_eq("slot captured", "File B", identity[:ivars][:@save_slot])
  t.assert_eq("gender var captured", 0, identity[:vars][52])
  # Simulate the new game: fresh trainer + fresh variables.
  $Trainer = NuzlockeTestTrainer.new
  $game_variables = Game_Variables.new
  changed = []
  orig_cp = Object.instance_method(:pbChangePlayer)
  orig_so = Object.instance_method(:nuzlocke_reset_starting_outfit)
  outfit_calls = 0
  Object.send(:define_method, :pbChangePlayer) { |id| changed << id; true }
  Object.send(:define_method, :nuzlocke_reset_starting_outfit) { outfit_calls += 1 }
  nuzlocke_reset_restore_identity(identity)
  nuzlocke_test_restore(:pbChangePlayer, orig_cp)
  nuzlocke_test_restore(:nuzlocke_reset_starting_outfit, orig_so)
  t.assert_eq("pbChangePlayer called with the character", [1], changed)
  t.assert_eq("name restored", "Matt", $Trainer.instance_variable_get(:@name))
  t.assert_eq("hair restored", "3_red", $Trainer.instance_variable_get(:@hair))
  t.refute("old outfit NOT restored", $Trainer.instance_variable_get(:@clothes) == "COOL_SHIRT")
  t.refute("old unlocks NOT restored", $Trainer.instance_variable_get(:@unlocked_hats) == ["CAP", "BEANIE"])
  t.assert_eq("starting outfit applied once", 1, outfit_calls)
  t.assert_eq("gender var restored", 0, $game_variables[52])
  t.assert_eq("name var restored", "Matt", $game_variables[84])
end

NuzlockeTestHarness.suite("Reset starting outfit: default clothes for the gender, no hat, defaults unlocked") do |t|
  begin
    $Trainer = Player.new("Matt", GameData::TrainerType.each { |tt| break tt.id })
    $Trainer.instance_variable_set(:@clothes, "COOL_SHIRT")
    $Trainer.instance_variable_set(:@hat, "CAP")
    $game_variables[VAR_TRAINER_GENDER] = GENDER_MALE
    nuzlocke_reset_starting_outfit
    t.assert_eq("male default clothes", getDefaultClothes(GENDER_MALE), $Trainer.clothes)
    t.assert("no hat", $Trainer.hat.nil?)
    t.assert("default clothes unlocked", $Trainer.unlocked_clothes.include?(getDefaultClothes(GENDER_MALE)))
    t.assert("starting outfit unlocked", $Trainer.unlocked_clothes.include?(STARTING_OUTFIT))
    t.refute("run's outfit gone from the unlock list", $Trainer.unlocked_clothes.include?("COOL_SHIRT"))
    $game_variables[VAR_TRAINER_GENDER] = GENDER_FEMALE
    nuzlocke_reset_starting_outfit
    t.assert_eq("female default clothes", getDefaultClothes(GENDER_FEMALE), $Trainer.clothes)
  rescue => e
    t.assert("starting outfit runs on a real Player: #{e.class}: #{e.message}", false)
  end
end

NuzlockeTestHarness.suite("Reset fresh-value check: a save value that survives Game.start_new is forced fresh") do |t|
  before = nuzlocke_reset_snapshot_values
  t.assert("snapshot covers the switches", before.key?(:switches))
  t.assert("snapshot covers the self switches", before.key?(:self_switches))
  t.assert("snapshot covers the player", before.key?(:player))
  t.refute("bootup values are not part of it", before.key?(:pokemon_system))
  # Nothing changed yet: a dry run reports every value as stale.
  stale = nuzlocke_reset_verify_fresh_values(before, false)
  t.assert("dry run flags the untouched switches", stale.include?(:switches))
  # Replace only the switches by hand; the dry run must clear them and keep flagging the rest.
  $game_switches = Game_Switches.new
  stale = nuzlocke_reset_verify_fresh_values(before, false)
  t.refute("fresh switches no longer flagged", stale.include?(:switches))
  t.assert("untouched self switches still flagged", stale.include?(:self_switches))
  # Forcing rebuilds the stragglers as new objects.
  old_self = $game_self_switches
  forced = nuzlocke_reset_verify_fresh_values(before, true)
  t.assert("self switches were forced", forced.include?(:self_switches))
  t.refute("self switches are a new object now", $game_self_switches.equal?(old_self))
  t.assert("second pass finds nothing stale", nuzlocke_reset_verify_fresh_values(before, false).empty?)
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
    nuzlocke_reset_starting_outfit:    proc { log << :outfit },
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
  t.assert_eq("order: fresh game -> randomizer -> skip", [:fresh, :player, :randomizer, :skip], log.reject { |x| x == :outfit })
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
