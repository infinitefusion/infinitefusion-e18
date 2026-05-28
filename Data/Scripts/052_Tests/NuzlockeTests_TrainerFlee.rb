# Trainer-fleeing setting (#13). Tests the gating helper directly. The alias
# on pbTrainerBattleCore is wired by the unless-guard in NuzlockeWorldRules.rb
# and verified at file-load time; the helper drives whether the cannotRun
# battle rule is applied at trainer-battle setup.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("Trainer-flee: setting Allowed (default) -> not blocked") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_TRAINER_FLEE_ALLOWED, true)
  t.refute("trainer fleeing is NOT blocked when Allowed", NuzlockeWorldRules.trainer_flee_blocked?)
end

NuzlockeTestHarness.suite("Trainer-flee: setting Disallowed -> blocked") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_TRAINER_FLEE_ALLOWED, false)
  t.assert("trainer fleeing IS blocked when Disallowed", NuzlockeWorldRules.trainer_flee_blocked?)
end

NuzlockeTestHarness.suite("Trainer-flee: MODE off -> never blocked (master gate)") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.set_switch(SWITCH_NUZLOCKE_TRAINER_FLEE_ALLOWED, false)   # would block, but...
  t.refute("master MODE off overrides the sub-setting", NuzlockeWorldRules.trainer_flee_blocked?)
end

end # defined?(NuzlockeTestHarness)
