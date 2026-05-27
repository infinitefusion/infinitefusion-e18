# Battle perma-death suites (authored by team 'nuzlocke-tests' / battle-author).
# Registers against NuzlockeTestHarness. Wrapped in a defined? guard so load
# order can never crash boot; if the harness somehow isn't loaded first, these
# simply don't register (detectable via the logged suite count).
if defined?(NuzlockeTestHarness)

# 1. Fused mode 0 (Off): a fainted fusion SURVIVES intact in the party.
NuzlockeTestHarness.suite("Fused perma-death mode 0 (Off): fainted fusion survives") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 0)   # Off

  dead_fusion = t.make_pokemon(:B16H19, 20, fainted: true)  # body Pidgey(16)/head Rattata(19)
  t.set_party([dead_fusion])

  NuzlockeBattleRules.process_party_after_battle
  party = $Trainer.party

  t.assert("fainted fusion still in party (mode Off)",
           party.any? { |m| m && isFusion(m.species_data.id_number) })
  t.assert_eq("party size unchanged", 1, party.compact.length)
end

# 2. Fused mode 2 (Body dies, keep HEAD): survivor species id == HEAD dex (19).
NuzlockeTestHarness.suite("Fused perma-death mode 2 (Body dies): keeps HEAD half") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 2)   # Body dies -> keep HEAD

  dead_fusion = t.make_pokemon(:B16H19, 20, fainted: true)  # head Rattata(19)
  t.set_party([dead_fusion])

  NuzlockeBattleRules.process_party_after_battle
  party = $Trainer.party

  t.assert("original fusion removed",
           party.none? { |m| m && isFusion(m.species_data.id_number) })
  surviving_half = party.find { |m| m && !isFusion(m.species_data.id_number) }
  t.assert("a surviving unfused half returned", !surviving_half.nil?)
  t.assert_eq("survivor is the HEAD species (dex 19)", 19, surviving_half.species_data.id_number)
  t.assert_eq("final party size = surviving half only", 1, party.compact.length)
end

# 3. Fused mode 3 (Both die): fusion removed, NO survivor returned, party shrinks.
NuzlockeTestHarness.suite("Fused perma-death mode 3 (Both die): no survivor") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 3)   # Both die

  healthy     = t.make_pokemon(:PIKACHU, 12)
  dead_fusion = t.make_pokemon(:B16H19, 20, fainted: true)
  t.set_party([healthy, dead_fusion])

  NuzlockeBattleRules.process_party_after_battle
  party = $Trainer.party

  t.assert("fusion removed from party",
           party.none? { |m| m && isFusion(m.species_data.id_number) })
  t.assert("NO surviving half returned (no unfused Pidgey/Rattata)",
           party.none? { |m| m && [16, 19].include?(m.species_data.id_number) })
  t.assert("healthy Pikachu kept", party.any? { |m| m && m.species == :PIKACHU })
  t.assert_eq("party shrank to healthy mon only", 1, party.compact.length)
end

# 4. Multi-fusion party, mode 1 (Head dies, keep BODY): two fainted fusions yield
#    two BODY halves; one healthy mon kept untouched.
NuzlockeTestHarness.suite("Multi-fusion party mode 1: two body-halves + healthy kept") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 1)   # Head dies -> keep BODY

  healthy = t.make_pokemon(:PIKACHU, 15)
  fusion_a = t.make_pokemon(:B16H19, 20, fainted: true)  # body 16 (Pidgey)
  fusion_b = t.make_pokemon(:B10H13, 22, fainted: true)  # body 10 (Caterpie)
  t.set_party([fusion_a, healthy, fusion_b])

  NuzlockeBattleRules.process_party_after_battle
  party = $Trainer.party

  t.assert("no fusions remain", party.none? { |m| m && isFusion(m.species_data.id_number) })
  t.assert("healthy Pikachu survived", party.any? { |m| m && m.species == :PIKACHU })
  t.assert("BODY half of fusion A (dex 16) returned",
           party.any? { |m| m && m.species_data.id_number == 16 })
  t.assert("BODY half of fusion B (dex 10) returned",
           party.any? { |m| m && m.species_data.id_number == 10 })
  t.assert_eq("party = healthy + two body halves", 3, party.compact.length)
  t.log("post-battle party: #{party.compact.map { |m| m.species }.inspect}")
end

# 5. Unfused perma-death OFF: a fainted unfused mon SURVIVES (switch off).
NuzlockeTestHarness.suite("Unfused perma-death OFF: fainted unfused survives") do |t|
  t.give_ball                                          # balls-first gate satisfied
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, false)   # OFF

  healthy = t.make_pokemon(:PIKACHU, 12)
  dead    = t.make_pokemon(:RATTATA, 10, fainted: true)
  t.set_party([healthy, dead])

  NuzlockeBattleRules.process_party_after_battle
  party = $Trainer.party

  t.assert("fainted unfused Rattata kept (perma-death unfused OFF)",
           party.any? { |m| m && m.species == :RATTATA })
  t.assert("healthy Pikachu kept", party.any? { |m| m && m.species == :PIKACHU })
  t.assert_eq("party size unchanged", 2, party.compact.length)
end

# 6. build_survivor preserves level and IVs (value-equal dup'd hash).
NuzlockeTestHarness.suite("build_survivor preserves level + IVs") do |t|
  fused = t.make_pokemon(:B16H19, 30)   # not fainted; we call build_survivor directly
  survivor = NuzlockeBattleRules.build_survivor(fused, true)   # keep BODY (dex 16)

  t.assert("survivor built", !survivor.nil?)
  t.assert_eq("survivor is the BODY species (dex 16)", 16, survivor.species_data.id_number)
  t.assert_eq("survivor.level == fused.level (30)", 30, survivor.level)
  t.assert_eq("survivor.iv equals fused.iv (preserved, value-equal)", fused.iv, survivor.iv)
  t.refute("survivor.iv is a distinct object (dup, not shared ref)", survivor.iv.equal?(fused.iv))
end

# 7. Wipeout -> blackout: all-fainted unfused party + balls + unfused perma-death ON;
#    process empties the party; blackout_after_empty_party then fires pbStartOver.
NuzlockeTestHarness.suite("Wipeout empties party then blackout fires") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)

  t.set_party([t.make_pokemon(:RATTATA, 8, fainted: true),
               t.make_pokemon(:PIDGEY, 9, fainted: true)])

  NuzlockeBattleRules.process_party_after_battle
  t.assert("party empty after all unfused mons perma-died", $Trainer.party.compact.empty?)
  t.refute("blackout not yet triggered (only on explicit guard call)", t.startover_triggered?)

  NuzlockeBattleRules.blackout_after_empty_party
  t.assert("blackout (pbStartOver) fired on empty party", t.startover_triggered?)
end

# 8. STORY: the ace fusion falls to a crit under Head-dies mode; the body half
#    limps on unfused and the fusion is gone for good.
NuzlockeTestHarness.suite("The ace fusion falls") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 1)   # Head dies -> keep BODY

  t.log("Our beloved ace 'B16H19' (body Pidgey / head Rattata) led the charge...")
  ace = t.make_pokemon(:B16H19, 35, fainted: true)
  t.log("...and a critical hit took it down. Head-dies mode is in effect.")
  t.set_party([ace])

  NuzlockeBattleRules.process_party_after_battle
  party = $Trainer.party

  t.assert("the fusion is gone for good",
           party.none? { |m| m && isFusion(m.species_data.id_number) })
  body_half = party.find { |m| m && m.species_data.id_number == 16 }
  t.assert("the BODY half (Pidgey, dex 16) limps on, now unfused", !body_half.nil?)
  t.refute("the surviving half is no longer a fusion",
           body_half && isFusion(body_half.species_data.id_number))
  t.assert_eq("only the lone survivor remains", 1, party.compact.length)
  t.log("Epilogue: #{party.compact.map { |m| m.species }.inspect} fights on.") if !party.compact.empty?
end

end # defined?(NuzlockeTestHarness)
