# Dupes Clause (Wave 2). A wild is a skippable dupe only if you already own it:
# a non-fusion you own, or a FUSION whose head AND body are both owned. A fusion
# with at least one new half is catchable. Dupes don't count as the area's first
# encounter, so the next non-dupe wild is the real shot.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("Dupes: owned_species_of decomposes fusions into both halves") do |t|
  m = NuzlockeCaptureRules
  pidgey = t.make_pokemon(:PIDGEY, 10)
  fusion = t.make_pokemon(:B16H19, 10)   # body Pidgey(16) / head Rattata(19)
  t.assert_eq("non-fusion -> [its species id]", [16], m.owned_species_of(pidgey))
  t.assert("fusion -> both halves (16 and 19)",
           m.owned_species_of(fusion).sort == [16, 19])
end

NuzlockeTestHarness.suite("Dupes: non-fusion wild is a dupe iff you own it") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_party([t.make_pokemon(:PIDGEY, 10)])
  t.assert("owned species is a dupe", m.wild_is_dupe?(:PIDGEY) == true)
  t.refute("unowned species is not a dupe", m.wild_is_dupe?(:RATTATA))
end

NuzlockeTestHarness.suite("Dupes: a fusion is a dupe only if BOTH halves are owned") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  # Own both Pidgey(16) and Rattata(19): the B16H19 fusion is a full dupe.
  t.set_party([t.make_pokemon(:PIDGEY, 10), t.make_pokemon(:RATTATA, 10)])
  t.assert("fusion with both halves owned IS a dupe", m.wild_is_dupe?(:B16H19) == true)
  # Own only Pidgey: the fusion's head (Rattata) is new -> catchable, not a dupe.
  t.set_party([t.make_pokemon(:PIDGEY, 10)])
  t.refute("fusion with a NEW half is NOT a dupe (catchable)", m.wild_is_dupe?(:B16H19))
  # Own neither.
  t.set_party([t.make_pokemon(:PIKACHU, 10)])
  t.refute("fusion with both halves new is not a dupe", m.wild_is_dupe?(:B16H19))
end

NuzlockeTestHarness.suite("Dupes: a dupe wild is skipped; the next non-dupe is the first encounter") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_DUPES_CLAUSE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)        # first-encounter
  t.set_party([t.make_pokemon(:PIDGEY, 10)])         # own Pidgey
  t.set_area("Route 1", 10)

  m::ENCOUNTER_START_PROC.call([:PIDGEY, 5])         # a dupe appears
  t.refute("dupe did NOT become the first encounter", m.current_is_first_encounter?)
  t.assert("area still open (not recorded by the dupe)", m.first_encounter_areas.empty?)
  t.assert("dupe is not catchable", m.should_block_catch? == true)

  m::ENCOUNTER_START_PROC.call([:RATTATA, 5])        # next wild: a non-dupe
  t.assert("non-dupe becomes the first encounter", m.current_is_first_encounter?)
  t.refute("and is catchable", m.should_block_catch?)
end

NuzlockeTestHarness.suite("Dupes: a fusion with a new half is catchable as the first encounter") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_DUPES_CLAUSE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_party([t.make_pokemon(:PIDGEY, 10)])         # own only Pidgey(16)
  t.set_area("Route 5", 50)

  m::ENCOUNTER_START_PROC.call([:B16H19, 18])        # fusion: head Rattata is new
  t.assert("fusion-with-new-half IS the first encounter", m.current_is_first_encounter?)
  t.refute("and is catchable (not skipped as a dupe)", m.should_block_catch?)
end

NuzlockeTestHarness.suite("Dupes: clause OFF means even owned species count normally") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_DUPES_CLAUSE, false)  # clause OFF
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_party([t.make_pokemon(:PIDGEY, 10)])
  t.set_area("Route 1", 10)
  m::ENCOUNTER_START_PROC.call([:PIDGEY, 5])         # owned, but clause is off
  t.assert("with clause off, the owned wild still becomes the first encounter",
           m.current_is_first_encounter?)
end

end # defined?(NuzlockeTestHarness)
