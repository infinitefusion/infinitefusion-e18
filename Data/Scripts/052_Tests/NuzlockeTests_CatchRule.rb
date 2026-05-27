# Catch-rule 3-way mode + first-encounter-only logic (Wave 2 feature).
# Modes: 0=Off, 1=First encounter only (canonical), 2=One per area.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("catch_rule_mode resolves VAR with legacy-boolean fallback") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  # Explicit VAR wins.
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.assert_eq("VAR=1 -> First encounter", m::CATCH_RULE_FIRST_ENCOUNTER, m.catch_rule_mode)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 2)
  t.assert_eq("VAR=2 -> One per area", m::CATCH_RULE_ONE_PER_AREA, m.catch_rule_mode)
  # VAR unset (0): fall back to the legacy boolean.
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 0)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, true)
  t.assert_eq("VAR=0 + legacy ON -> One per area", m::CATCH_RULE_ONE_PER_AREA, m.catch_rule_mode)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, false)
  t.assert_eq("VAR=0 + legacy OFF -> Off", m::CATCH_RULE_OFF, m.catch_rule_mode)
  # Master switch off => always Off.
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.assert_eq("MODE off -> Off regardless of VAR", m::CATCH_RULE_OFF, m.catch_rule_mode)
end

NuzlockeTestHarness.suite("one_catch_per_area_active? true for both restricted modes") do |t|
  m = NuzlockeCaptureRules
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.assert("active in First-encounter mode", m.one_catch_per_area_active? == true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 2)
  t.assert("active in One-per-area mode", m.one_catch_per_area_active? == true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 0)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, false)
  t.refute("inactive when Off", m.one_catch_per_area_active?)
end

NuzlockeTestHarness.suite("First-encounter: the first wild is catchable, later ones blocked") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 1", 10)

  m.note_wild_encounter_start                       # the area's FIRST wild appears
  t.assert("this battle is flagged the first encounter", m.current_is_first_encounter?)
  t.refute("first encounter is catchable (not blocked)", m.should_block_catch?)

  m.mark_current_area_used                          # player catches it
  t.assert("after catching, the area is blocked", m.should_block_catch? == true)
  m.clear_wild_encounter_flag                       # battle ends

  m.note_wild_encounter_start                       # a SECOND wild appears in Route 1
  t.refute("second wild is NOT the first encounter", m.current_is_first_encounter?)
  t.assert("second wild is blocked (already caught here)", m.should_block_catch? == true)
end

NuzlockeTestHarness.suite("First-encounter: fleeing the first wild FORFEITS the area") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 2", 11)

  m.note_wild_encounter_start                       # first wild appears...
  t.assert("first encounter flagged", m.current_is_first_encounter?)
  m.clear_wild_encounter_flag                        # ...player flees / KOs it (no catch)

  m.note_wild_encounter_start                       # next wild in the same area
  t.refute("later wild is not the first encounter", m.current_is_first_encounter?)
  t.refute("area was never caught in", m.current_area_used?)
  t.assert("area is FORFEITED -- still blocked despite no catch",
           m.should_block_catch? == true)
  t.log("Route 2's first encounter fled; the area is closed for good.")
end

NuzlockeTestHarness.suite("First-encounter: a DOUBLE battle's first encounter stays catchable") do |t|
  m = NuzlockeCaptureRules
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 1", 10)
  # EncounterModifier fires once per wild; a double battle => two calls, same area,
  # same battle. The flag the first mon sets must NOT be cleared by the second.
  m.note_wild_encounter_start   # mon 1 (records the area, flags catchable)
  m.note_wild_encounter_start   # mon 2 (same area, same battle)
  t.assert("double-battle first encounter remains the catchable one", m.current_is_first_encounter?)
  t.refute("and is not blocked", m.should_block_catch?)
end

NuzlockeTestHarness.suite("First-encounter: balls-first -- pre-ball wilds don't burn the slot") do |t|
  m = NuzlockeCaptureRules
  t.empty_bag                                       # no balls yet
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 1", 10)

  m.note_wild_encounter_start                       # encounter before having balls
  t.refute("no first encounter recorded without balls", m.current_is_first_encounter?)
  t.assert("area NOT yet recorded as encountered", m.first_encounter_areas.empty?)

  t.give_ball                                       # now buy balls and come back
  m.note_wild_encounter_start
  t.assert("first real (post-ball) encounter is the catchable one", m.current_is_first_encounter?)
  t.refute("and it is catchable", m.should_block_catch?)
end

end # defined?(NuzlockeTestHarness)
