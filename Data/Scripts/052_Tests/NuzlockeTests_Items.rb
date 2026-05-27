# Held-item-on-perma-death suites (lead-owned; implements the user ruling:
# "always return the item to the bag" -- survivor keeps the fusion's item, a
# fully-removed mon's item goes back to the Bag). Moves are intentionally lost.
# Guarded so load order can never crash boot.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("Held item: unfused perma-death returns item to the bag") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  dead = t.make_pokemon(:RATTATA, 10, fainted: true, held: :LEFTOVERS)
  t.assert("precondition: mon holds LEFTOVERS", dead.item_id == :LEFTOVERS)
  t.set_party([dead])
  NuzlockeBattleRules.process_party_after_battle
  t.assert("mon perma-died (party empty)", $Trainer.party.compact.empty?)
  t.assert("LEFTOVERS returned to the bag", t.bag_stored_items.include?(:LEFTOVERS))
end

NuzlockeTestHarness.suite("Held item: 'Both die' fusion returns item to the bag") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 3)   # Both die
  dead = t.make_pokemon(:B16H19, 20, fainted: true, held: :LEFTOVERS)
  t.set_party([dead])
  NuzlockeBattleRules.process_party_after_battle
  t.assert("fusion gone (party empty)", $Trainer.party.compact.empty?)
  t.assert("LEFTOVERS returned to the bag", t.bag_stored_items.include?(:LEFTOVERS))
end

NuzlockeTestHarness.suite("Held item: surviving half KEEPS the item (not duplicated to bag)") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 1)   # Head dies -> keep BODY
  dead = t.make_pokemon(:B16H19, 20, fainted: true, held: :LEFTOVERS)
  t.set_party([dead])
  NuzlockeBattleRules.process_party_after_battle
  survivor = $Trainer.party.compact.find { |m| m.species_data.id_number == 16 }
  t.assert("surviving body half exists", !survivor.nil?)
  t.assert("survivor holds the fusion's LEFTOVERS", survivor && survivor.item_id == :LEFTOVERS)
  t.refute("item NOT also dumped to the bag (no duplication)", t.bag_stored_items.include?(:LEFTOVERS))
end

NuzlockeTestHarness.suite("Held item: itemless death stores nothing and never crashes") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_party([t.make_pokemon(:RATTATA, 10, fainted: true)])
  NuzlockeBattleRules.process_party_after_battle
  t.assert("nothing stored to the bag", t.bag_stored_items.empty?)
end

NuzlockeTestHarness.suite("Held item: build_survivor copies the fusion's item to the half") do |t|
  f = t.make_pokemon(:B16H19, 20, held: :LEFTOVERS)
  s = NuzlockeBattleRules.build_survivor(f, true)   # keep BODY
  t.assert("survivor built", !s.nil?)
  t.assert_eq("survivor holds the fusion's item", :LEFTOVERS, (s && s.item_id))
end

end # defined?(NuzlockeTestHarness)
