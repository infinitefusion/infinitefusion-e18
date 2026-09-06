# Wave 4: story-gated catching (Oak's handout), block-reason messages, and
# auto-reset only on a real wipe.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("Story gate: a randomized early Poke Ball does not make an encounter count") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.lock_catching
  t.give_ball_only                    # ball from a randomized item, Oak hasn't handed any out
  t.set_area("Route 1", 1)
  m.note_wild_encounter_start([:PIDGEY, 3])
  t.refute("Route 1 NOT recorded as first-encountered", m.first_encounter_areas.include?("Route 1"))
  t.refute("battle not flagged catchable", m.current_is_first_encounter?)
  t.assert_eq("throw is blocked as :locked", :locked, m.catch_block_reason)
  m.clear_wild_encounter_flag
  t.unlock_catching                   # Oak's handout
  m.note_wild_encounter_start([:PIDGEY, 3])
  t.assert("after the handout, Route 1's first encounter is recorded", m.first_encounter_areas.include?("Route 1"))
  t.assert("and it is catchable", m.catch_block_reason.nil?)
end

NuzlockeTestHarness.suite("Block reasons + messages: locked / area caught / encounter used") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 2", 2)
  sc = t.fake_scene; b = t.fake_battle
  # locked
  t.lock_catching; t.give_ball_only
  r = ItemHandlers.triggerCanUseInBattle(:POKEBALL, nil, nil, nil, true, b, sc, true)
  t.assert("locked -> blocked", r == false)
  t.assert("locked message names Oak", t.captured_msgs.last.to_s.include?("Professor Oak"))
  # encounter used (forfeited first encounter)
  t.give_ball
  m.note_wild_encounter_start([:PIDGEY, 3]); m.clear_wild_encounter_flag
  m.note_wild_encounter_start([:RATTATA, 3])
  t.assert_eq("forfeited -> :encounter_used", :encounter_used, m.catch_block_reason)
  ItemHandlers.triggerCanUseInBattle(:POKEBALL, nil, nil, nil, true, b, sc, true)
  t.assert("message says the encounter was used up, NOT 'caught'",
           t.captured_msgs.last.to_s.include?("used up your encounter") && !t.captured_msgs.last.to_s.include?("caught"))
  # area caught
  m.mark_current_area_used
  t.assert_eq("caught -> :area_caught", :area_caught, m.catch_block_reason)
  ItemHandlers.triggerCanUseInBattle(:POKEBALL, nil, nil, nil, true, b, sc, true)
  t.assert("message says already caught", t.captured_msgs.last.to_s.include?("already caught"))
  # no balls -> nothing to block
  t.empty_bag
  t.assert("no balls -> no reason", m.catch_block_reason.nil?)
end

NuzlockeTestHarness.suite("Shiny Clause never overrides the story lock") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_SHINY_CLAUSE, true)
  t.set_switch(SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.lock_catching; t.give_ball_only
  shiny = t.make_pokemon(:PIDGEY, 5); shiny.shiny = true
  r = ItemHandlers.triggerCanUseInBattle(:POKEBALL, nil, nil, nil, true,
        NuzlockeTestShinyBattle.new([NuzlockeTestBattler.new(shiny)]), t.fake_scene, true)
  t.assert("shiny still blocked before Oak's handout", r == false)
end

NuzlockeTestHarness.suite("Perma-death stays inert with an early Poke Ball before Oak's handout") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.lock_catching; t.give_ball_only
  t.set_party([t.make_pokemon(:BULBASAUR, 5, fainted: true)])
  NuzlockeBattleRules.process_party_after_battle
  t.assert("starter survives the rival fight even holding a random ball", $Trainer.party.compact.length == 1)
end

NuzlockeTestHarness.suite("Auto reset arms only on a real wipe, not on fleeing a trainer") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE, true)
  t.set_switch(SWITCH_DURING_INTRO, false)
  # Fled: a living party goes through the blackout routine.
  t.set_party([t.make_pokemon(:PIKACHU, 10), t.make_pokemon(:RATTATA, 8, fainted: true)])
  $PokemonGlobal.nuzlocke_auto_reset_pending = false
  t.refute("living party is not a wipe", nuzlocke_party_wiped?)
  nuzlocke_flag_auto_reset_after_wipe(nuzlocke_party_wiped?)
  t.refute("not armed after a flee", $PokemonGlobal.nuzlocke_auto_reset_pending)
  # Real wipe: everyone fainted.
  t.set_party([t.make_pokemon(:PIKACHU, 10, fainted: true)])
  t.assert("all fainted is a wipe", nuzlocke_party_wiped?)
  nuzlocke_flag_auto_reset_after_wipe(nuzlocke_party_wiped?)
  t.assert("armed after a real wipe", $PokemonGlobal.nuzlocke_auto_reset_pending == true)
  # Perma-death emptied the party.
  $PokemonGlobal.nuzlocke_auto_reset_pending = false
  t.set_party([])
  t.assert("empty party is a wipe", nuzlocke_party_wiped?)
  nuzlocke_flag_auto_reset_after_wipe(nuzlocke_party_wiped?)
  t.assert("armed after perma-death wipe", $PokemonGlobal.nuzlocke_auto_reset_pending == true)
end

NuzlockeTestHarness.suite("Reset rebuild drops the global spriteset so the player sprite rebinds") do |t|
  scene = Object.new
  disposed = false
  sg = Object.new
  sg.define_singleton_method(:dispose) { disposed = true }
  scene.instance_variable_set(:@spritesetGlobal, sg)
  nuzlocke_reset_drop_global_spriteset(scene)
  t.assert("old global spriteset disposed", disposed)
  t.assert("scene will create a fresh one", scene.instance_variable_get(:@spritesetGlobal).nil?)
  nuzlocke_reset_drop_global_spriteset(Object.new)   # no ivar: no crash
  t.assert("safe on a scene without the ivar", true)
end

end # defined?(NuzlockeTestHarness)
