# Battle edge-cases + cross-feature scenarios (team round 2 / edge-author).
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("MODE off => perma-death fully inert") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  healthy = t.make_pokemon(:PIKACHU, 12)
  dead    = t.make_pokemon(:RATTATA, 10, fainted: true)
  t.set_party([healthy, dead])
  NuzlockeBattleRules.process_party_after_battle
  party = $Trainer.party
  t.assert("healthy Pikachu untouched (MODE off)", party.any? { |m| m && m.species == :PIKACHU })
  t.assert("fainted Rattata SURVIVES (perma-death inert when MODE off)",
           party.any? { |m| m && m.species == :RATTATA })
  t.assert_eq("party unchanged: size 2", 2, party.compact.length)
end

NuzlockeTestHarness.suite("Mixed party one pass (mode 2: body dies, keep head)") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 2)    # body dies -> keep HEAD (19)
  healthy      = t.make_pokemon(:PIKACHU, 14)
  egg          = t.make_egg(:CHARMANDER, 5)
  dead_unfused = t.make_pokemon(:RATTATA, 10, fainted: true)
  dead_fusion  = t.make_pokemon(:B16H19, 20, fainted: true)  # body Pidgey(16)/head Rattata(19)
  t.set_party([healthy, egg, dead_unfused, dead_fusion])
  NuzlockeBattleRules.process_party_after_battle
  party = $Trainer.party
  t.assert("healthy Pikachu kept", party.any? { |m| m && m.species == :PIKACHU })
  t.assert("egg kept (eggs never die)", party.any? { |m| m && m.egg? })
  t.assert("fainted UNFUSED Rattata removed",
           party.none? { |m| m && m.species == :RATTATA && !m.egg? &&
                              !isFusion(m.species_data.id_number) && m.fainted? })
  t.assert("dead FUSION no longer in party",
           party.none? { |m| m && isFusion(m.species_data.id_number) })
  surviving_head = party.find { |m| m && m.species_data.id_number == 19 && !m.egg? && !m.fainted? }
  t.assert("HEAD half (dex 19, unfused, healthy) returned", !surviving_head.nil?)
  t.refute("HEAD half is not a fusion",
           isFusion(surviving_head.species_data.id_number)) if surviving_head
  t.assert_eq("final compact party = Pikachu + egg + head-half = 3", 3, party.compact.length)
  t.log("post-battle party: #{party.compact.map { |m| m.egg? ? :EGG : m.species }.inspect}")
end

NuzlockeTestHarness.suite("Balls-first boundary: 0 balls => fainted mon survives") do |t|
  t.empty_bag
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  dead = t.make_pokemon(:RATTATA, 8, fainted: true)
  t.set_party([dead])
  NuzlockeBattleRules.process_party_after_battle
  t.refute("balls-first gate closed at 0 balls", NuzlockeCaptureRules.player_has_balls?)
  t.assert("fainted Rattata SURVIVES at 0 balls (gate inert)",
           $Trainer.party.any? { |m| m && m.species == :RATTATA })
  t.assert_eq("party intact: size 1", 1, $Trainer.party.compact.length)
end

NuzlockeTestHarness.suite("Balls-first boundary: 1 ball => fainted mon removed") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  dead = t.make_pokemon(:RATTATA, 8, fainted: true)
  t.set_party([dead])
  NuzlockeBattleRules.process_party_after_battle
  t.assert("balls-first gate open with 1 ball", NuzlockeCaptureRules.player_has_balls?)
  t.assert("fainted Rattata permanently removed with 1 ball",
           $Trainer.party.none? { |m| m && m.species == :RATTATA })
  t.assert_eq("party now empty", 0, $Trainer.party.compact.length)
end

# CROSS-FEATURE STORY: your one catch from an area dies, and the area stays
# burned forever -- no do-over. Stitches the one-catch registry to perma-death.
NuzlockeTestHarness.suite("STORY: the Route 1 catch dies (one-catch + perma-death)") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 1)
  t.set_area("Route 1", 10)
  t.log("Route 1: a wild RATTATA appears. The trainer's first and ONLY catch here.")
  t.refute("Route 1 is open before the catch", NuzlockeCaptureRules.should_block_catch?)
  NuzlockeCaptureRules.mark_current_area_used
  t.assert("Route 1 is now BURNED -- one catch spent", NuzlockeCaptureRules.should_block_catch?)
  t.log("Later, in a trainer battle, the Route 1 Rattata faints...")
  t.set_party([t.make_pokemon(:RATTATA, 10, fainted: true)])
  NuzlockeBattleRules.process_party_after_battle
  t.assert_eq("party is empty -- the Route 1 catch perma-died", 0, $Trainer.party.compact.length)
  t.set_area("Route 1", 10)
  t.assert("Route 1 STILL blocked -- a dead catch does NOT free the area",
           NuzlockeCaptureRules.should_block_catch? == true)
  t.log("Route 1 stays closed forever. The slot is gone. This is the Nuzlocke.")
end

end # defined?(NuzlockeTestHarness)
