# Force-nickname loop (#7): hitting OK on the species name used to bypass the
# force. Now the entry re-prompts until the player enters something that isn't
# the species name (or empty), with a clear message between attempts. Bounded
# at 5 attempts so a stuck UI can't hang.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("Force-nick LOOP: OK-on-species-name re-prompts until real name") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  pk = t.make_pokemon(:PIKACHU, 5)
  # Simulate: first attempt the user just hits OK (species name); second they
  # actually enter a real nickname.
  t.set_name_entry_responses([pk.speciesName, "ACE"])

  pbNickname(pk)

  t.assert_eq("final name is the real entry", "ACE", pk.name)
  t.assert("a 'must be nicknamed' notice was displayed",
           t.captured_msgs.any? { |m| m.to_s.include?("must be nicknamed") })
end

NuzlockeTestHarness.suite("Force-nick LOOP: empty name also re-prompts") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  pk = t.make_pokemon(:PIKACHU, 5)
  t.set_name_entry_responses(["", "REALNAME"])
  pbNickname(pk)
  t.assert_eq("empty -> re-prompt -> real name applied", "REALNAME", pk.name)
end

NuzlockeTestHarness.suite("Force-nick LOOP: first valid entry breaks the loop (no spurious notices)") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  pk = t.make_pokemon(:PIKACHU, 5)
  t.set_name_entry_responses(["VALID"])
  pbNickname(pk)
  t.assert_eq("real name accepted on first try", "VALID", pk.name)
  t.refute("no 'must be nicknamed' notice on a one-shot valid entry",
           t.captured_msgs.any? { |m| m.to_s.include?("must be nicknamed") })
end

NuzlockeTestHarness.suite("Force-nick LOOP: bounded -- 5 species-name attempts then accept (no hang)") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  pk = t.make_pokemon(:PIKACHU, 5)
  # Stub always returns species name -> loop hits its bound and accepts.
  t.set_name_entry_responses([pk.speciesName])
  begin
    pbNickname(pk)
    t.assert("pbNickname returned without hanging on a stuck UI", true)
  rescue => e
    t.assert("pbNickname raised unexpectedly: #{e.class}: #{e.message}", false)
  end
end

end # defined?(NuzlockeTestHarness)
