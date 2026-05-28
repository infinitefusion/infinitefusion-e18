# Balls-first RATCHET (resolves #10 / user reports #8/#9): perma-death is gated
# by "have you EVER had a ball this run", not "do you have one right now."
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("Ratchet: starts OFF on a fresh empty state") do |t|
  m = NuzlockeCaptureRules
  t.empty_bag
  $Trainer.party = []   # no party, no storage, no balls
  t.refute("ever_had_balls? false on a blank state", m.ever_had_balls?)
end

NuzlockeTestHarness.suite("Ratchet: latches true the FIRST time the bag holds a ball, and survives emptying") do |t|
  m = NuzlockeCaptureRules
  t.empty_bag
  $Trainer.party = []
  t.refute("not yet latched", m.ever_had_balls?)
  t.give_ball                                  # bag now has a ball
  t.assert("latches true on first read with balls", m.ever_had_balls?)
  t.empty_bag                                  # use all balls; bag empty again
  t.refute("live player_has_balls? is now false", m.player_has_balls?)
  t.assert("ratchet STAYS true after the bag empties (the fix)", m.ever_had_balls?)
end

NuzlockeTestHarness.suite("Migration: multi-mon party implies they've caught -> ratchet latches") do |t|
  m = NuzlockeCaptureRules
  t.empty_bag                                   # no balls in bag right now
  # Starter + a caught mon: pre-ratchet save has no flag set, but the party state
  # tells us this run has clearly crossed the pre-catch threshold.
  t.set_party([t.make_pokemon(:BULBASAUR, 8), t.make_pokemon(:PIDGEY, 6)])
  t.assert("ratchet latches via migration heuristic", m.ever_had_balls?)
end

NuzlockeTestHarness.suite("Perma-death respects the RATCHET (not just the live bag)") do |t|
  # Exact reproduction of the user-reported scenario: bag empty NOW but the run
  # is past the early game (multi-mon party). Previously a wipe retained all
  # mons because the live check was false; with the ratchet it fires.
  m = NuzlockeCaptureRules
  t.empty_bag                                   # zero balls -- the user's situation
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  starter = t.make_pokemon(:BULBASAUR, 8)
  caught  = t.make_pokemon(:PIDGEY, 6, fainted: true)
  t.set_party([starter, caught])                # multi-mon party => migration latches
  t.assert("ratchet is on via migration", m.ever_had_balls?)
  NuzlockeBattleRules.process_party_after_battle
  t.refute("fainted Pidgey was REMOVED (perma-death active despite empty bag)",
           $Trainer.party.compact.any? { |p| p.species == :PIDGEY })
  t.assert_eq("starter retained", 1, $Trainer.party.compact.length)
end

NuzlockeTestHarness.suite("Pre-ratchet protection: solo starter, no balls, no party history -> still inert") do |t|
  # The original balls-first intent: the starter rival fight, where the player
  # has exactly one mon (starter) and no way to catch yet. Must stay inert.
  m = NuzlockeCaptureRules
  t.empty_bag
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_party([t.make_pokemon(:BULBASAUR, 5, fainted: true)])   # lone fainted starter
  t.refute("ratchet still OFF (no balls, single-mon party)", m.ever_had_balls?)
  NuzlockeBattleRules.process_party_after_battle
  t.assert("starter SURVIVES (pre-catch protection preserved)",
           $Trainer.party.compact.any? { |p| p.species == :BULBASAUR })
end

end # defined?(NuzlockeTestHarness)
