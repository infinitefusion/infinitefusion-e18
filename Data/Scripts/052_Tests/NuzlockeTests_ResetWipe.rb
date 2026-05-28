# Reset Run wipe (#16): party, bag, storage, money cleared regardless of what
# the snapshot file happened to contain. Snapshot-independent fresh-start.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("Reset wipe clears party, bag, and storage") do |t|
  # Set up a "progressed" state.
  t.set_party([t.make_pokemon(:PIKACHU, 12), t.make_pokemon(:RATTATA, 8)])
  t.give_ball
  $PokemonStorage = NuzlockeTestStorage.new
  $PokemonStorage.stored << t.make_pokemon(:PIDGEY, 5)

  t.assert("precondition: party non-empty", $Trainer.party.compact.length > 0)
  t.assert("precondition: bag has a ball", NuzlockeCaptureRules.player_has_balls?)
  t.refute("precondition: storage non-empty", $PokemonStorage.stored.empty?)

  nuzlocke_reset_wipe_progress

  t.assert("party cleared", $Trainer.party.compact.empty?)
  t.refute("bag empty after wipe", NuzlockeCaptureRules.player_has_balls?)
  # $PokemonStorage was replaced with a real PokemonStorage.new (a fresh,
  # empty storage). Verify it's empty by scanning whatever boxes it exposes.
  if $PokemonStorage.respond_to?(:boxes)
    has_any = ($PokemonStorage.boxes || []).any? { |b| (b.pokemon || []).compact.any? }
    t.refute("storage now empty (the real PokemonStorage replaced the mock)", has_any)
  else
    t.log("real PokemonStorage doesn't expose .boxes; box-scan skipped")
  end
end

NuzlockeTestHarness.suite("Reset wipe is safe on an already-empty state (idempotent)") do |t|
  t.set_party([])
  t.empty_bag
  begin
    nuzlocke_reset_wipe_progress
    t.assert("wipe completed without raising on an empty state", true)
  rescue => e
    t.assert("wipe raised unexpectedly: #{e.class}: #{e.message}", false)
  end
  t.assert("party still empty", $Trainer.party.compact.empty?)
end

end # defined?(NuzlockeTestHarness)
