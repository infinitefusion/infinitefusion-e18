# Dupes Clause (Wave 2). A wild is a skippable dupe only if you already own it:
# a non-fusion you own (any stage of its evolution line by default, or the exact
# species when VAR_NUZLOCKE_DUPES_SCOPE = 1), or a FUSION whose head AND body
# lines are both owned. A fusion with at least one new half is catchable. Dupes don't count as the area's first
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
  t.set_var(VAR_NUZLOCKE_DUPES_SCOPE, 1)   # exact species for this suite
  t.set_party([t.make_pokemon(:PIDGEY, 10)])
  t.assert("owned species is a dupe", m.wild_is_dupe?(:PIDGEY) == true)
  t.refute("unowned species is not a dupe", m.wild_is_dupe?(:RATTATA))
end

NuzlockeTestHarness.suite("Dupes: family_root keys every stage of a line to its lowest stage") do |t|
  m = NuzlockeCaptureRules
  $nuzlocke_family_root_cache = nil
  pidgey  = GameData::Species.get(:PIDGEY).id_number
  pidgeot = GameData::Species.get(:PIDGEOT).id_number
  pichu   = GameData::Species.get(:PICHU).id_number
  raichu  = GameData::Species.get(:RAICHU).id_number
  eevee   = GameData::Species.get(:EEVEE).id_number
  t.assert_eq("Pidgeot -> Pidgey", pidgey, m.family_root(pidgeot))
  t.assert_eq("Pidgey -> itself", pidgey, m.family_root(pidgey))
  t.assert_eq("Raichu -> Pichu (babies included)", pichu, m.family_root(raichu))
  t.assert_eq("Vaporeon -> Eevee (branched line)", eevee, m.family_root(GameData::Species.get(:VAPOREON).id_number))
  t.assert_eq("Flareon -> Eevee", eevee, m.family_root(GameData::Species.get(:FLAREON).id_number))
  t.assert_eq("Silcoon and Cascoon share Wurmple", m.family_root(GameData::Species.get(:SILCOON).id_number), m.family_root(GameData::Species.get(:CASCOON).id_number)) if GameData::Species.exists?(:SILCOON) && GameData::Species.exists?(:CASCOON)
  t.assert_eq("Ditto is its own root", GameData::Species.get(:DITTO).id_number, m.family_root(GameData::Species.get(:DITTO).id_number))
end

NuzlockeTestHarness.suite("Dupes: evolution-line scope (default) makes every stage a dupe") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_DUPES_SCOPE, 0)
  t.set_party([t.make_pokemon(:PIDGEOTTO, 20)])
  t.assert("owned Pidgeotto -> wild Pidgey is a dupe", m.wild_is_dupe?(:PIDGEY) == true)
  t.assert("owned Pidgeotto -> wild Pidgeot is a dupe", m.wild_is_dupe?(:PIDGEOT) == true)
  t.refute("Rattata still catchable", m.wild_is_dupe?(:RATTATA))
  t.set_party([t.make_pokemon(:PIKACHU, 20)])
  t.assert("owned Pikachu -> wild Pichu is a dupe", m.wild_is_dupe?(:PICHU) == true)
  t.assert("owned Pikachu -> wild Raichu is a dupe", m.wild_is_dupe?(:RAICHU) == true)
  t.set_party([t.make_pokemon(:JOLTEON, 20)])
  t.assert("owned Jolteon -> wild Eevee is a dupe", m.wild_is_dupe?(:EEVEE) == true)
  t.assert("owned Jolteon -> wild Vaporeon is a dupe (same line)", m.wild_is_dupe?(:VAPOREON) == true)
  # Exact-species scope: only Pidgeotto itself is a dupe.
  t.set_var(VAR_NUZLOCKE_DUPES_SCOPE, 1)
  t.set_party([t.make_pokemon(:PIDGEOTTO, 20)])
  t.refute("exact scope: Pidgey is NOT a dupe", m.wild_is_dupe?(:PIDGEY))
  t.assert("exact scope: Pidgeotto IS a dupe", m.wild_is_dupe?(:PIDGEOTTO) == true)
end

NuzlockeTestHarness.suite("Dupes: fusion halves are matched by evolution line too") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_DUPES_SCOPE, 0)
  # Own Pidgeotto and Raticate: the Pidgey/Rattata fusion B16H19 is a full dupe.
  t.set_party([t.make_pokemon(:PIDGEOTTO, 20), t.make_pokemon(:RATICATE, 20)])
  t.assert("both halves' lines owned -> fusion is a dupe", m.wild_is_dupe?(:B16H19) == true)
  t.set_party([t.make_pokemon(:PIDGEOTTO, 20)])
  t.refute("only one half's line owned -> catchable", m.wild_is_dupe?(:B16H19))
  # An owned fusion's halves count for their lines: own B16H19, wild Pidgeot is a dupe.
  t.set_party([t.make_pokemon(:B16H19, 20)])
  t.assert("owned fusion half (Pidgey) -> wild Pidgeot is a dupe", m.wild_is_dupe?(:PIDGEOT) == true)
end

NuzlockeTestHarness.suite("Dupes: mode default, reset preservation, settings values") do |t|
  m = NuzlockeCaptureRules
  initializeNuzlockeMode
  t.assert_eq("default scope = evolution line", 0, $game_variables[VAR_NUZLOCKE_DUPES_SCOPE])
  t.assert("scope var preserved by Reset Run", NUZLOCKE_RESET_PRESERVED_VAR_SYMS.include?(:VAR_NUZLOCKE_DUPES_SCOPE))
  begin
    opt = NuzlockeSettingsScene.new(true).pbGetOptions.find { |o| o.name == "Dupes Clause" }
    t.assert("Dupes Clause option present", !opt.nil?)
    t.assert_eq("three values", 3, opt.values.length) if opt && opt.respond_to?(:values)
  rescue => e
    t.assert("settings scene builds its options: #{e.class}: #{e.message}", false)
  end
end

NuzlockeTestHarness.suite("Dupes: a fusion is a dupe only if BOTH halves are owned") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_DUPES_SCOPE, 1)   # exact species for this suite
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
