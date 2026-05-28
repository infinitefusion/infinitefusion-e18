# Force-nickname on egg hatch (#11). pbHatch had its own inline name prompt
# that bypassed our pbNickname wrap, so eggs ended up un-named at both ends.
# Now pbHatch is aliased to invoke force_nickname_loop! after the original.
# The loop helper is tested directly here -- a freshly-hatched Pokemon's @name
# is set to nil by the original pbHatch, which is exactly what we simulate.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("Hatch force-nick: just-hatched Pokemon (name=nil) gets forced into entry") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  pk = t.make_pokemon(:PIKACHU, 5)
  pk.name = nil   # post-pbHatch state: original pbHatch nils @name (line 205)
  t.set_name_entry_responses(["HATCHLING"])

  NuzlockeCaptureRules.force_nickname_loop!(pk)

  t.assert_eq("forced entry applied", "HATCHLING", pk.name)
  t.assert("name-entry screen was opened", t.nick_prompted?)
end

NuzlockeTestHarness.suite("Hatch force-nick: OK-on-species-name re-prompts (#7's loop reused)") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  pk = t.make_pokemon(:PIKACHU, 5)
  pk.name = nil
  # User OKs species name first, then enters a real one.
  t.set_name_entry_responses([pk.speciesName, "REALNAME"])

  NuzlockeCaptureRules.force_nickname_loop!(pk)

  t.assert_eq("re-prompt yielded the real name", "REALNAME", pk.name)
  t.assert("'must be nicknamed' notice appeared on the retry",
           t.captured_msgs.any? { |m| m.to_s.include?("must be nicknamed") })
end

NuzlockeTestHarness.suite("Hatch force-nick: already-nicknamed mon is left alone (no re-prompt)") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  pk = t.make_pokemon(:PIKACHU, 5)
  pk.name = "BOLT"   # the user already nicknamed during the original pbHatch prompt
  t.set_name_entry_responses(["WOULD_OVERWRITE_IF_PROMPTED"])

  NuzlockeCaptureRules.force_nickname_loop!(pk)

  t.assert_eq("existing nickname preserved (no spurious re-prompt)", "BOLT", pk.name)
  t.refute("name-entry screen was NOT opened", t.nick_prompted?)
end

end # defined?(NuzlockeTestHarness)
