# Reset Run + world-seam coverage (team round 2 / world-author).
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("find_common_event_id_by_name: name lookup over common events") do |t|
  ev = Struct.new(:name)
  $data_common_events = [nil, ev.new("intro"), ev.new("skip intro"), ev.new("other")]
  t.assert_eq("'skip intro' resolves to its index", 2, find_common_event_id_by_name("skip intro"))
  t.assert_eq("'intro' resolves to its index", 1, find_common_event_id_by_name("intro"))
  t.assert("unknown name returns nil", find_common_event_id_by_name("nope").nil?)
  $data_common_events = nil
  t.assert("nil $data_common_events returns nil", find_common_event_id_by_name("x").nil?)
end

NuzlockeTestHarness.suite("nuzlocke_snapshot_path: per-slot path with $Trainer fallback") do |t|
  path = nuzlocke_snapshot_path("TEST")
  t.assert("explicit slot returns a String", path.is_a?(String))
  t.assert("explicit slot path ends with TEST_nuzlocke_reset.rxdata",
           path.end_with?("TEST_nuzlocke_reset.rxdata"))
  fallback = nuzlocke_snapshot_path(nil)
  t.assert("nil slot falls back to a String", fallback.is_a?(String))
  t.assert("nil slot falls back to $Trainer.save_slot ('TEST')",
           fallback.end_with?("TEST_nuzlocke_reset.rxdata"))
end

NuzlockeTestHarness.suite("nuzlocke_reset_run: no-snapshot is a graceful no-op") do |t|
  begin
    nuzlocke_reset_run
    t.assert("nuzlocke_reset_run returns without raising when no snapshot exists", true)
  rescue => e
    t.assert("nuzlocke_reset_run raised unexpectedly: #{e.class}: #{e.message}", false)
  end
  t.assert("a 'no reset snapshot' message was shown to the player",
           t.captured_msgs.any? { |m| m =~ /no reset snapshot/i })
end

# STORY: with Force Nicknames on, a non-egg acquisition drops straight into name
# entry. (The seam flag is sticky within a suite; per-acquisition forcing is
# covered in NuzlockeTests_Seams.rb -- here we narrate the starter end to end.)
NuzlockeTestHarness.suite("STORY: 'Name them all' -- starter is force-named") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  t.log("Player chooses Bulbasaur as their starter.")
  pbNickname(t.make_pokemon(:BULBASAUR, 5))
  t.assert("starter forced the name-entry screen open", t.nick_prompted?)
  t.log("A later gift and a caught wild mon take the same forced path.")
end

NuzlockeTestHarness.suite("STORY: eggs are exempt from forced naming (named on hatch)") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  t.log("Player receives an egg; eggs are named when they hatch, not now.")
  pbNickname(t.make_egg(:PIKACHU))
  t.refute("egg did NOT force the name-entry screen", t.nick_prompted?)
end

end # defined?(NuzlockeTestHarness)
