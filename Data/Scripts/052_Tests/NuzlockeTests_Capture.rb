# Capture / area / item suites (team 'nuzlocke-tests' / capture-author).
# Wrapped in a defined? guard so load order can never crash boot.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("First catch allowed, second blocked (same area)") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, true)
  t.set_area("Viridian Forest", 20)
  t.assert("first catch allowed (area unused)", NuzlockeCaptureRules.should_block_catch? == false)
  NuzlockeCaptureRules.mark_current_area_used        # simulate a successful catch
  t.assert("second catch blocked (area used)", NuzlockeCaptureRules.should_block_catch? == true)
  t.assert("area now reported used", NuzlockeCaptureRules.current_area_used? == true)
end

NuzlockeTestHarness.suite("Same area NAME across different map_ids = one area") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, true)
  t.set_area("Viridian Forest", 20)                  # first sub-map
  NuzlockeCaptureRules.mark_current_area_used
  t.assert("blocked on map_id 20", NuzlockeCaptureRules.should_block_catch? == true)
  t.set_area("Viridian Forest", 21)                  # second sub-map, SAME displayed name
  t.assert_eq("both sub-maps share one area key", "Viridian Forest", NuzlockeCaptureRules.current_area_key)
  t.assert("still blocked on map_id 21 (keyed by name, not id)", NuzlockeCaptureRules.should_block_catch? == true)
end

NuzlockeTestHarness.suite("Different area NAMES are independent") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, true)
  t.set_area("Route 1", 10)
  NuzlockeCaptureRules.mark_current_area_used
  t.assert("Route 1 blocked after its catch", NuzlockeCaptureRules.should_block_catch? == true)
  t.set_area("Route 2", 11)
  t.assert("Route 2 untouched (independent area)", NuzlockeCaptureRules.should_block_catch? == false)
  t.assert("Route 2 not reported used", NuzlockeCaptureRules.current_area_used? == false)
end

NuzlockeTestHarness.suite("Balls-first toggle flips block on/off") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, true)
  t.set_area("Route 3", 12)
  NuzlockeCaptureRules.mark_current_area_used
  t.assert("blocked with a ball in bag", NuzlockeCaptureRules.should_block_catch? == true)
  t.empty_bag
  t.assert("not blocked once balls are gone (balls-first)", NuzlockeCaptureRules.should_block_catch? == false)
  t.give_ball
  t.assert("blocked again once a ball returns", NuzlockeCaptureRules.should_block_catch? == true)
end

NuzlockeTestHarness.suite("used? vs block? distinction (balls-first only gates block)") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, true)
  t.set_area("Route 4", 13)
  NuzlockeCaptureRules.mark_current_area_used
  t.empty_bag
  # The area is permanently marked once the catch happened; the block, however,
  # is suppressed while there are no balls (no impossible throw to block).
  t.assert("current_area_used? stays TRUE without balls", NuzlockeCaptureRules.current_area_used? == true)
  t.assert("should_block_catch? FALSE without balls", NuzlockeCaptureRules.should_block_catch? == false)
end

NuzlockeTestHarness.suite("battle_items_forbidden? MODE/allowed matrix") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.set_switch(SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, false)
  t.assert("MODE off -> not forbidden", NuzlockeCaptureRules.battle_items_forbidden? == false)
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, true)
  t.assert("MODE on + items allowed -> not forbidden", NuzlockeCaptureRules.battle_items_forbidden? == false)
  t.set_switch(SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, false)
  t.assert("MODE on + items not allowed -> forbidden", NuzlockeCaptureRules.battle_items_forbidden? == true)
end

NuzlockeTestHarness.suite("force_nicknames_active? / one_catch_per_area_active? gating") do |t|
  # Both sub-switches ON but MODE OFF: master gate keeps everything inert.
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, true)
  t.assert("force_nicknames_active? false when MODE off", NuzlockeCaptureRules.force_nicknames_active? == false)
  t.assert("one_catch_per_area_active? false when MODE off", NuzlockeCaptureRules.one_catch_per_area_active? == false)
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.assert("force_nicknames_active? true (MODE on + switch on)", NuzlockeCaptureRules.force_nicknames_active? == true)
  t.assert("one_catch_per_area_active? true (MODE on + switch on)", NuzlockeCaptureRules.one_catch_per_area_active? == true)
  # Master on but sub-switches off => still inert.
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, false)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, false)
  t.assert("force_nicknames_active? false (sub-switch off)", NuzlockeCaptureRules.force_nicknames_active? == false)
  t.assert("one_catch_per_area_active? false (sub-switch off)", NuzlockeCaptureRules.one_catch_per_area_active? == false)
end

# STORY: a trainer walking Route 1 -> 2 -> 3 catches exactly one per route,
# is rebuffed on every re-throw, and finds each fresh route open again.
NuzlockeTestHarness.suite("Routes retain single spawns (story)") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, true)

  t.log("Trainer steps onto Route 1, grass rustling.")
  t.set_area("Route 1", 30)
  t.assert("Route 1 open for the first encounter", NuzlockeCaptureRules.should_block_catch? == false)
  NuzlockeCaptureRules.mark_current_area_used        # caught one here
  t.log("Caught the Route 1 spawn; ball pocketed.")
  t.assert("Route 1 sealed after the catch", NuzlockeCaptureRules.should_block_catch? == true)

  t.log("Pushing north into Route 2.")
  t.set_area("Route 2", 31)
  t.assert("Route 2 is fresh ground", NuzlockeCaptureRules.should_block_catch? == false)
  NuzlockeCaptureRules.mark_current_area_used
  t.log("Bagged the Route 2 spawn.")
  t.assert("Route 2 sealed after the catch", NuzlockeCaptureRules.should_block_catch? == true)

  t.log("Onward to Route 3.")
  t.set_area("Route 3", 32)
  t.assert("Route 3 is fresh ground", NuzlockeCaptureRules.should_block_catch? == false)
  NuzlockeCaptureRules.mark_current_area_used
  t.log("Bagged the Route 3 spawn too.")
  t.assert("Route 3 sealed after the catch", NuzlockeCaptureRules.should_block_catch? == true)

  t.log("Backtracking through every route to test re-throws.")
  t.set_area("Route 1", 30)
  t.assert("Route 1 still sealed on return", NuzlockeCaptureRules.should_block_catch? == true)
  t.set_area("Route 2", 31)
  t.assert("Route 2 still sealed on return", NuzlockeCaptureRules.should_block_catch? == true)
  t.set_area("Route 3", 32)
  t.assert("Route 3 still sealed on return", NuzlockeCaptureRules.should_block_catch? == true)
  t.log("All three routes held their single spawn.")
end

end # defined?(NuzlockeTestHarness)
