# Survivor-fidelity suites (team round 2 / fidelity-author): build_survivor
# preserves the kept half's EXP and a real nickname, and eggs never perma-die.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("build_survivor preserves the kept half's EXP") do |t|
  f = t.make_pokemon(:B16H19, 25)
  f.instance_variable_set(:@exp_when_fused_head, 1000)
  f.instance_variable_set(:@exp_when_fused_body, 2000)
  f.instance_variable_set(:@exp_gained_since_fused, 50)
  body = NuzlockeBattleRules.build_survivor(f, true)    # keep BODY half
  t.assert("keep_body survivor built", !body.nil?)
  t.assert_eq("BODY survivor exp = body preserved + gained (2000+50)", 2050, body.exp)

  f2 = t.make_pokemon(:B16H19, 25)
  f2.instance_variable_set(:@exp_when_fused_head, 1000)
  f2.instance_variable_set(:@exp_when_fused_body, 2000)
  f2.instance_variable_set(:@exp_gained_since_fused, 50)
  head = NuzlockeBattleRules.build_survivor(f2, false)  # keep HEAD half
  t.assert("keep_head survivor built", !head.nil?)
  t.assert_eq("HEAD survivor exp = head preserved + gained (1000+50)", 1050, head.exp)
end

NuzlockeTestHarness.suite("build_survivor keeps a real nickname, not a fusion name") do |t|
  named = t.make_pokemon(:B16H19, 20)
  named.name = "ACEY"
  t.assert("input fusion is nicknamed", named.nicknamed? == true)
  s = NuzlockeBattleRules.build_survivor(named, true)
  t.assert("nicknamed survivor built", !s.nil?)
  t.assert_eq("survivor keeps the trainer's nickname", "ACEY", s.name)
  t.assert("survivor still reads as nicknamed", s.nicknamed? == true)

  plain = t.make_pokemon(:B16H19, 20)
  t.refute("control fusion is not nicknamed", plain.nicknamed?)
  s2 = NuzlockeBattleRules.build_survivor(plain, true)   # keep BODY (Pidgey, 16)
  t.assert("control survivor built", !s2.nil?)
  t.refute("control survivor is not nicknamed", s2.nicknamed?)
  t.assert_eq("control survivor name is its species name", s2.species_data.name, s2.name)
end

NuzlockeTestHarness.suite("Egg survives a full party wipe (eggs never perma-die)") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  egg          = t.make_egg(:PIKACHU)
  dead_unfused = t.make_pokemon(:RATTATA, 10, fainted: true)
  t.set_party([egg, dead_unfused])
  NuzlockeBattleRules.process_party_after_battle
  party = $Trainer.party
  t.assert("egg still in party after wipe", party.any? { |m| m && m.egg? })
  t.assert("fainted unfused Rattata permanently removed",
           party.none? { |m| m && !m.egg? && m.species == :RATTATA })
  t.assert_eq("party = egg only", 1, party.compact.length)
  t.log("post-wipe party: #{party.compact.map { |m| m.egg? ? '<egg>' : m.species }.inspect}")
end

end # defined?(NuzlockeTestHarness)
