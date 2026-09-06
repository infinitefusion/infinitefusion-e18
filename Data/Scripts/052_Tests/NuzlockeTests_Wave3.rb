# Wave 3 suites: Shiny Clause, static-encounter registration + per-battle flag
# clearing (pbWildBattleCore wrapper), Set battle style, forced level cap,
# auto Reset Run on wipe, and the runtime-registered Cap Candy item.
# Guarded so load order can never crash boot.
if defined?(NuzlockeTestHarness)

# Battle double exposing the eachOtherSideBattler API used by the shiny exemption.
NuzlockeTestShinyBattle = Struct.new(:foes) do
  def eachOtherSideBattler(_idx = 0); foes.each { |b| yield b }; end
end unless defined?(NuzlockeTestShinyBattle)
NuzlockeTestBattler = Struct.new(:pokemon) do
  def shiny?; pokemon.shiny?; end
  def fainted?; false; end
end unless defined?(NuzlockeTestBattler)

# Temporarily replace a top-level (Object) function for one suite, restoring the
# original afterwards so later suites (and the real-save check) see real code.
def nuzlocke_test_restore(name, original)
  Object.send(:define_method, name, original)
end

#-- Shiny Clause --------------------------------------------------------------
NuzlockeTestHarness.suite("Shiny Clause: helper gating") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.set_switch(SWITCH_NUZLOCKE_SHINY_CLAUSE, true)
  t.refute("inactive when MODE off", m.shiny_clause_active?)
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.assert("active when MODE + switch on", m.shiny_clause_active? == true)
  t.set_switch(SWITCH_NUZLOCKE_SHINY_CLAUSE, false)
  t.refute("inactive when switch off", m.shiny_clause_active?)
end

NuzlockeTestHarness.suite("Shiny Clause: a shiny first encounter gives the area back") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_SHINY_CLAUSE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 3", 3)
  m.note_wild_encounter_start([:PIDGEY, 5])
  t.assert("precondition: area recorded", m.first_encounter_areas.include?("Route 3"))
  t.assert_eq("precondition: recorded-this-battle = area", "Route 3", m.area_recorded_this_battle)
  shiny = t.make_pokemon(:PIDGEY, 5)
  shiny.shiny = true
  m.note_wild_pokemon(shiny)
  t.refute("area un-recorded after the shiny appears", m.first_encounter_areas.include?("Route 3"))
  t.assert("recorded-this-battle cleared", m.area_recorded_this_battle.nil?)
  m.clear_wild_encounter_flag
  m.note_wild_encounter_start([:RATTATA, 4])   # next wild in Route 3
  t.assert("the NEXT wild becomes the real first encounter", m.current_is_first_encounter?)
end

NuzlockeTestHarness.suite("Shiny Clause OFF: a shiny first encounter still burns the area") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_SHINY_CLAUSE, false)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 3", 3)
  m.note_wild_encounter_start([:PIDGEY, 5])
  shiny = t.make_pokemon(:PIDGEY, 5)
  shiny.shiny = true
  m.note_wild_pokemon(shiny)
  t.assert("area stays recorded with the clause off", m.first_encounter_areas.include?("Route 3"))
end

NuzlockeTestHarness.suite("Shiny Clause: non-shiny never un-records") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_SHINY_CLAUSE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 4", 4)
  m.note_wild_encounter_start([:PIDGEY, 5])
  plain = t.make_pokemon(:PIDGEY, 5)
  plain.shiny = false
  m.note_wild_pokemon(plain)
  t.assert("area still recorded", m.first_encounter_areas.include?("Route 4"))
end

NuzlockeTestHarness.suite("Shiny Clause: opposing_wild_shiny? battle inspection") do |t|
  m = NuzlockeCaptureRules
  shiny = t.make_pokemon(:PIDGEY, 5); shiny.shiny = true
  plain = t.make_pokemon(:RATTATA, 5); plain.shiny = false
  t.assert("single shiny foe -> true", m.opposing_wild_shiny?(NuzlockeTestShinyBattle.new([NuzlockeTestBattler.new(shiny)])) == true)
  t.refute("single plain foe -> false", m.opposing_wild_shiny?(NuzlockeTestShinyBattle.new([NuzlockeTestBattler.new(plain)])))
  t.refute("shiny + plain (double) -> false", m.opposing_wild_shiny?(NuzlockeTestShinyBattle.new([NuzlockeTestBattler.new(shiny), NuzlockeTestBattler.new(plain)])))
  t.refute("no foes -> false", m.opposing_wild_shiny?(NuzlockeTestShinyBattle.new([])))
  t.refute("nil battle -> false", m.opposing_wild_shiny?(nil))
  t.refute("battle without the API (plain double) -> false", m.opposing_wild_shiny?(t.fake_battle))
end

NuzlockeTestHarness.suite("SEAM triggerCanUseInBattle: shiny wild is catchable in a spent area") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_SHINY_CLAUSE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 2)
  t.give_ball
  t.set_area("Route 5", 5)
  m.mark_current_area_used
  t.assert("precondition: area spent -> block", m.should_block_catch? == true)
  shiny = t.make_pokemon(:PIDGEY, 5); shiny.shiny = true
  plain = t.make_pokemon(:PIDGEY, 5); plain.shiny = false
  sc = t.fake_scene
  r_shiny = ItemHandlers.triggerCanUseInBattle(:POKEBALL, nil, nil, nil, true,
              NuzlockeTestShinyBattle.new([NuzlockeTestBattler.new(shiny)]), sc, true)
  r_plain = ItemHandlers.triggerCanUseInBattle(:POKEBALL, nil, nil, nil, true,
              NuzlockeTestShinyBattle.new([NuzlockeTestBattler.new(plain)]), sc, true)
  t.assert("ball allowed against the shiny (passes through)", r_shiny == :ORIG)
  t.assert("ball blocked against the plain wild", r_plain == false)
  t.set_switch(SWITCH_NUZLOCKE_SHINY_CLAUSE, false)
  r_off = ItemHandlers.triggerCanUseInBattle(:POKEBALL, nil, nil, nil, true,
              NuzlockeTestShinyBattle.new([NuzlockeTestBattler.new(shiny)]), sc, true)
  t.assert("clause off -> shiny blocked like any other", r_off == false)
end

NuzlockeTestHarness.suite("SEAM pbThrowPokeBall: catching a shiny does NOT spend the area") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_SHINY_CLAUSE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 2)
  t.give_ball
  t.set_area("Route 6", 6)
  shiny = t.make_pokemon(:PIDGEY, 5); shiny.shiny = true
  plain = t.make_pokemon(:PIDGEY, 5); plain.shiny = false
  thrower = Class.new { include PokeBattle_BattleCommon }.new
  thrower.instance_variable_set(:@caughtPokemon, [])
  thrower.instance_variable_set(:@battlers, [nil, NuzlockeTestBattler.new(shiny)])
  def thrower.nuzlocke_orig_pbThrowPokeBall(*_a); @caughtPokemon << :mon; :caught; end
  thrower.pbThrowPokeBall(1, :POKEBALL)
  t.refute("area NOT spent by the shiny catch", m.current_area_used?)
  thrower.instance_variable_set(:@battlers, [nil, NuzlockeTestBattler.new(plain)])
  thrower.pbThrowPokeBall(1, :POKEBALL)
  t.assert("area spent by a normal catch", m.current_area_used? == true)
end

#-- Static encounters + per-battle flag clearing (pbWildBattleCore wrapper) ---
NuzlockeTestHarness.suite("SEAM pbWildBattleCore: a static encounter is the area's first encounter") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 12", 12)
  seen = nil
  orig = Object.instance_method(:nuzlocke_orig_pbWildBattleCore)
  Object.send(:define_method, :nuzlocke_orig_pbWildBattleCore) { |*_a|
    seen = [m.current_is_first_encounter?, m.should_block_catch?, $nuzlocke_wild_battle_pending]
    1
  }
  result = pbWildBattleCore(:SNORLAX, 30)   # scripted static fight: never went through EncounterModifier
  nuzlocke_test_restore(:nuzlocke_orig_pbWildBattleCore, orig)
  t.assert_eq("original result passed through", 1, result)
  t.assert("inside the battle: flagged as the first encounter", seen && seen[0] == true)
  t.assert("inside the battle: catch NOT blocked", seen && seen[1] == false)
  t.assert("inside the battle: wild-battle pending flag set", seen && seen[2] == true)
  t.assert("area recorded on the save", m.first_encounter_areas.include?("Route 12"))
  t.refute("after the battle: first-encounter flag cleared", m.current_is_first_encounter?)
  t.refute("after the battle: pending flag cleared", $nuzlocke_wild_battle_pending)
  t.assert("a later wild in Route 12 is blocked (forfeit works without onWildBattleEnd)", m.should_block_catch? == true)
end

NuzlockeTestHarness.suite("SEAM pbWildBattleCore: walking encounter already registered is a no-op") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 13", 13)
  m::ENCOUNTER_START_PROC.call([:PIDGEY, 5])   # EncounterModifier registered it
  t.assert("precondition: flagged by EncounterModifier", m.current_is_first_encounter?)
  inside = nil
  orig = Object.instance_method(:nuzlocke_orig_pbWildBattleCore)
  Object.send(:define_method, :nuzlocke_orig_pbWildBattleCore) { |*_a| inside = m.current_is_first_encounter?; 1 }
  pbWildBattleCore([:PIDGEY, 5])
  nuzlocke_test_restore(:nuzlocke_orig_pbWildBattleCore, orig)
  t.assert("still flagged inside the battle", inside == true)
  t.assert_eq("area recorded exactly once", 1, m.first_encounter_areas.count("Route 13"))
  t.refute("flag cleared after the battle", m.current_is_first_encounter?)
end

NuzlockeTestHarness.suite("SEAM pbWildBattleCore: flag cleared even if the battle raises") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 14", 14)
  orig = Object.instance_method(:nuzlocke_orig_pbWildBattleCore)
  Object.send(:define_method, :nuzlocke_orig_pbWildBattleCore) { |*_a| raise "boom" }
  begin
    pbWildBattleCore(:PIDGEY, 5)
  rescue => e
    t.assert("original error propagates", e.message == "boom")
  end
  nuzlocke_test_restore(:nuzlocke_orig_pbWildBattleCore, orig)
  t.refute("flag cleared by ensure", m.current_is_first_encounter?)
  t.refute("pending cleared by ensure", $nuzlocke_wild_battle_pending)
end

NuzlockeTestHarness.suite("onWildPokemonCreate hook only acts while a wild battle is pending") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_SHINY_CLAUSE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 15", 15)
  m.note_wild_encounter_start([:PIDGEY, 5])
  shiny = t.make_pokemon(:PIDGEY, 5); shiny.shiny = true
  $nuzlocke_wild_battle_pending = false
  m::WILD_POKEMON_CREATE_PROC.call(nil, [shiny])   # e.g. roamer generation, not a battle
  t.assert("outside a battle: area untouched", m.first_encounter_areas.include?("Route 15"))
  $nuzlocke_wild_battle_pending = true
  m::WILD_POKEMON_CREATE_PROC.call(nil, [shiny])
  t.refute("inside a battle: shiny gives the area back", m.first_encounter_areas.include?("Route 15"))
  $nuzlocke_wild_battle_pending = false
end

NuzlockeTestHarness.suite("note_wild_battle_args walks every engine argument shape") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Cave A", 20); m.clear_wild_encounter_flag
  m.note_wild_battle_args([:ZUBAT, 8])
  t.assert("species, level pair recorded", m.first_encounter_areas.include?("Cave A"))
  t.set_area("Cave B", 21); m.clear_wild_encounter_flag
  m.note_wild_battle_args([[:ZUBAT, 8]])
  t.assert("[species, level] array recorded", m.first_encounter_areas.include?("Cave B"))
  t.set_area("Cave C", 22); m.clear_wild_encounter_flag
  m.note_wild_battle_args([t.make_pokemon(:ZUBAT, 8)])
  t.assert("Pokemon object recorded", m.first_encounter_areas.include?("Cave C"))
  t.set_area("Cave D", 23); m.clear_wild_encounter_flag
  m.note_wild_battle_args(nil)
  t.refute("nil args: nothing recorded, no crash", m.first_encounter_areas.include?("Cave D"))
end

#-- Set battle style ----------------------------------------------------------
NuzlockeTestHarness.suite("SEAM pbPrepareBattle: Set style forced only when the toggle is on") do |t|
  battle = Struct.new(:switchStyle).new(true)
  orig = Object.instance_method(:nuzlocke_orig_pbPrepareBattle)
  Object.send(:define_method, :nuzlocke_orig_pbPrepareBattle) { |b| b.switchStyle = true }
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_SET_BATTLE_STYLE, false)
  pbPrepareBattle(battle)
  t.assert("toggle off: player's style (switch) kept", battle.switchStyle == true)
  t.set_switch(SWITCH_NUZLOCKE_SET_BATTLE_STYLE, true)
  pbPrepareBattle(battle)
  t.assert("toggle on: Set style forced (switchStyle=false)", battle.switchStyle == false)
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  pbPrepareBattle(battle)
  t.assert("MODE off: never forced", battle.switchStyle == true)
  nuzlocke_test_restore(:nuzlocke_orig_pbPrepareBattle, orig)
end

#-- Level cap ------------------------------------------------------------------
NuzlockeTestHarness.suite("Level cap: PokemonSystem#level_caps reports ON while forced") do |t|
  sys = PokemonSystem.new
  sys.level_caps = 0
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_LEVEL_CAP, false)
  t.assert_eq("toggle off: player's own setting (0)", 0, sys.level_caps)
  t.set_switch(SWITCH_NUZLOCKE_LEVEL_CAP, true)
  t.assert_eq("toggle on: reports 1 (caps enforced)", 1, sys.level_caps)
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.assert_eq("MODE off: player's own setting again", 0, sys.level_caps)
  sys.level_caps = nil
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_LEVEL_CAP, false)
  t.assert("old save with nil level_caps still returns nil when not forced", sys.level_caps.nil?)
end

#-- Auto Reset Run on wipe ----------------------------------------------------
NuzlockeTestHarness.suite("Auto reset on wipe: arming is gated on MODE + toggle + availability") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE, true)
  t.assert("helper active", nuzlocke_auto_reset_active? == true)
  # Still in the intro -> never arms.
  t.set_switch(SWITCH_DURING_INTRO, true)
  $PokemonGlobal.nuzlocke_auto_reset_pending = false
  nuzlocke_flag_auto_reset_after_wipe
  t.refute("during intro -> not armed", $PokemonGlobal.nuzlocke_auto_reset_pending)
  t.set_switch(SWITCH_DURING_INTRO, false)
  orig_exists = Object.instance_method(:nuzlocke_reset_available?)
  nuzlocke_flag_auto_reset_after_wipe
  t.assert("intro over -> armed", $PokemonGlobal.nuzlocke_auto_reset_pending == true)
  $PokemonGlobal.nuzlocke_auto_reset_pending = false
  t.set_switch(SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE, false)
  nuzlocke_flag_auto_reset_after_wipe
  t.refute("toggle off -> not armed", $PokemonGlobal.nuzlocke_auto_reset_pending)
  t.set_switch(SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE, true)
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  nuzlocke_flag_auto_reset_after_wipe
  t.refute("MODE off -> not armed", $PokemonGlobal.nuzlocke_auto_reset_pending)
  nuzlocke_test_restore(:nuzlocke_reset_available?, orig_exists)
end

NuzlockeTestHarness.suite("Auto reset on wipe: pending flag runs the reset once, then clears") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE, true)
  orig_exists = Object.instance_method(:nuzlocke_reset_available?)
  orig_reset  = Object.instance_method(:nuzlocke_reset_run)
  Object.send(:define_method, :nuzlocke_reset_available?) { true }
  ran = 0
  confirm_arg = :unset
  Object.send(:define_method, :nuzlocke_reset_run) { |*a| ran += 1; confirm_arg = a[0] }
  $PokemonGlobal.nuzlocke_auto_reset_pending = true
  handled = [false]
  Events.onStepTakenTransferPossible.trigger(nil, handled)
  t.assert("reset ran once on the step", ran == 1)
  t.assert("step marked handled", handled[0] == true)
  t.refute("pending cleared", $PokemonGlobal.nuzlocke_auto_reset_pending)
  t.assert("'run is over' message shown", t.captured_msgs.any? { |m| m.downcase.include?("run is over") })
  t.assert("reset ran WITHOUT the confirm prompt (confirm=false)", confirm_arg == false)
  handled = [false]
  Events.onStepTakenTransferPossible.trigger(nil, handled)
  t.assert("second step: nothing happens", ran == 1 && handled[0] == false)
  nuzlocke_test_restore(:nuzlocke_reset_available?, orig_exists)
  nuzlocke_test_restore(:nuzlocke_reset_run, orig_reset)
end

#-- Cap Candy -----------------------------------------------------------------
NuzlockeTestHarness.suite("Cap Candy: item is registered after GameData load") do |t|
  item = GameData::Item.try_get(:CAPCANDYNUZLOCKE)
  t.assert("item exists in GameData::Item", !item.nil?)
  if item
    t.assert_eq("name resolves without the message table", "Cap Candy", item.name)
    t.assert_eq("plural resolves", "Cap Candies", item.name_plural)
    t.assert("description resolves", item.description.to_s.include?("level cap"))
    t.assert_eq("Key Items pocket", 8, item.pocket)
    t.assert("never sold (price 0)", item.price == 0)
    t.assert("key item", item.is_key_item? == true)
    t.assert_eq("reusable: usable on a Pokemon, not consumed", 2, item.field_use)
    t.assert_eq("id_number far outside the compiled range", 9646, item.id_number)
    t.assert("numeric lookup works", GameData::Item.try_get(9646).equal?(item))
    t.assert("no collision with TM109", GameData::Item.try_get(:TM109).id_number != item.id_number)
    t.assert("important (can't be tossed or sold)", item.is_important? == true)
  end
  t.assert("icon file exists", pbResolveBitmap("Graphics/Items/CAPCANDYNUZLOCKE") ? true : false)
  t.assert("UseOnPokemon handler registered", ItemHandlers::UseOnPokemon[:CAPCANDYNUZLOCKE] ? true : false)
end

NuzlockeTestHarness.suite("Cap Candy: inventory follows the toggle (added when on, removed when off)") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_CAP_CANDY_ENABLED, true)
  t.empty_bag
  t.assert_eq("toggle on, missing -> added", :added, NuzlockeCapCandy.sync_inventory!)
  t.assert("Cap Candy now in the bag", $PokemonBag.pbHasItem?(:CAPCANDYNUZLOCKE))
  t.assert_eq("second sync is a no-op", :unchanged, NuzlockeCapCandy.sync_inventory!)
  t.set_switch(SWITCH_NUZLOCKE_CAP_CANDY_ENABLED, false)
  t.assert_eq("toggle off, present -> removed", :removed, NuzlockeCapCandy.sync_inventory!)
  t.refute("Cap Candy gone", $PokemonBag.pbHasItem?(:CAPCANDYNUZLOCKE))
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.set_switch(SWITCH_NUZLOCKE_CAP_CANDY_ENABLED, true)
  t.assert_eq("MODE off -> never added", :unchanged, NuzlockeCapCandy.sync_inventory!)
end

NuzlockeTestHarness.suite("Cap Candy: excluded from item randomization (key item)") do |t|
  item = GameData::Item.try_get(:CAPCANDYNUZLOCKE)
  t.assert("itemCanBeRandomized is false", item && itemCanBeRandomized(item) == false)
end

NuzlockeTestHarness.suite("Cap Candy: current_cap follows badges and is safe past the last badge") do |t|
  $Trainer.badge_count = 0
  t.set_switch(SWITCH_GAME_DIFFICULTY_HARD, false)
  t.assert_eq("0 badges -> first cap", Settings::LEVEL_CAPS[0], NuzlockeCapCandy.current_cap)
  $Trainer.badge_count = 3
  t.assert_eq("3 badges -> fourth cap", Settings::LEVEL_CAPS[3], NuzlockeCapCandy.current_cap)
  $Trainer.badge_count = Settings::NB_BADGES
  t.assert_eq("all badges -> max level (no nil crash)", GameData::GrowthRate.max_level, NuzlockeCapCandy.current_cap)
end

NuzlockeTestHarness.suite("Cap Candy: enabled? requires MODE and the toggle") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.set_switch(SWITCH_NUZLOCKE_CAP_CANDY_ENABLED, true)
  t.refute("MODE off -> disabled", NuzlockeCapCandy.enabled?)
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.assert("MODE + toggle -> enabled", NuzlockeCapCandy.enabled? == true)
end

#-- Mode defaults for the new toggles -----------------------------------------
NuzlockeTestHarness.suite("initializeNuzlockeMode: wave 3 defaults") do |t|
  initializeNuzlockeMode
  t.assert("Shiny Clause ON by default", $game_switches[SWITCH_NUZLOCKE_SHINY_CLAUSE] == true)
  t.assert("Set style OFF by default", $game_switches[SWITCH_NUZLOCKE_SET_BATTLE_STYLE] == false)
  t.assert("Level cap OFF by default", $game_switches[SWITCH_NUZLOCKE_LEVEL_CAP] == false)
  t.assert("Auto reset on wipe OFF by default (Blackout)", $game_switches[SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE] == false)
end

NuzlockeTestHarness.suite("Reset Run preserves the wave 3 switches") do |t|
  [SWITCH_NUZLOCKE_SHINY_CLAUSE, SWITCH_NUZLOCKE_SET_BATTLE_STYLE,
   SWITCH_NUZLOCKE_LEVEL_CAP, SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE].each { |id| $game_switches[id] = true }
  sw, vars = nuzlocke_reset_capture_settings
  $game_switches = Game_Switches.new
  nuzlocke_reset_restore_settings(sw, vars)
  t.assert("Shiny Clause restored", $game_switches[SWITCH_NUZLOCKE_SHINY_CLAUSE] == true)
  t.assert("Set style restored", $game_switches[SWITCH_NUZLOCKE_SET_BATTLE_STYLE] == true)
  t.assert("Level cap restored", $game_switches[SWITCH_NUZLOCKE_LEVEL_CAP] == true)
  t.assert("Auto reset restored", $game_switches[SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE] == true)
  undefined = (NUZLOCKE_RESET_PRESERVED_SWITCH_SYMS + NUZLOCKE_RESET_PRESERVED_VAR_SYMS).reject { |s| Object.const_defined?(s) }
  t.assert("every preserved symbol is a real constant (no dead entries) #{undefined.inspect}", undefined.empty?)
end

end # defined?(NuzlockeTestHarness)
