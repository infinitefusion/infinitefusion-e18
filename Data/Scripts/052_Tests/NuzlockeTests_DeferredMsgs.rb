# Perma-death messages are queued during pbEndOfBattle and drained AFTER the
# engine's onEndBattle handlers run (evolution check, pick-up, pbStartOver).
# This stops "X can never battle again..." from interrupting evolutions etc. (#15).
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("Perma-death messages QUEUE during processing (not pbMessage'd inline)") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_party([t.make_pokemon(:RATTATA, 8, fainted: true)])

  NuzlockeBattleRules.process_party_after_battle

  queue = ($nuzlocke_pending_perma_death_msgs || [])
  t.assert("a perma-death message was queued (not displayed yet)",
           queue.any? { |m| m.to_s.include?("can never battle again") })
  t.refute("nothing pbMessage'd inline (no interruption of post-battle flow)",
           t.captured_msgs.any? { |m| m.to_s.include?("can never battle again") })
end

NuzlockeTestHarness.suite("Registered drainer flushes the queue (so evolution etc. run first)") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_party([t.make_pokemon(:RATTATA, 8, fainted: true)])
  NuzlockeBattleRules.process_party_after_battle

  # Call the EXACT proc registered with Events.onEndBattle. Skips the engine's
  # default handler (which needs $Trainer methods we don't mock), but proves
  # our drainer -- the proc object engine actually invokes -- does its job.
  NuzlockeBattleRules::PERMA_DEATH_MSG_DRAINER_PROC.call(nil, [1, false])

  t.assert("queue is empty after drain",
           ($nuzlocke_pending_perma_death_msgs || []).empty?)
  t.assert("the perma-death message displayed (queued -> drained -> pbMessage)",
           t.captured_msgs.any? { |m| m.to_s.include?("can never battle again") })
end

NuzlockeTestHarness.suite("Drainer with no perma-death event is a clean no-op") do |t|
  NuzlockeBattleRules::PERMA_DEATH_MSG_DRAINER_PROC.call(nil, [1, false])
  t.refute("no spurious messages when the queue is empty",
           t.captured_msgs.any? { |m| m.to_s.include?("can never battle") })
end

end # defined?(NuzlockeTestHarness)
