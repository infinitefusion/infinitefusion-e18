# Enforcement-SEAM suites: these exercise the actual hooks that call the helper
# logic -- triggerCanUseInBattle, pbThrowPokeBall's record-on-success, the global
# pbNickname forcing, the reset reshuffle dispatch, mode setup -- not just the
# helpers in isolation. This is where real bugs hide.
# Guarded so load order can never crash boot.
if defined?(NuzlockeTestHarness)

#-- Mode setup ----------------------------------------------------------------
NuzlockeTestHarness.suite("initializeNuzlockeMode sets canonical defaults") do |t|
  initializeNuzlockeMode
  t.assert("MODE on", $game_switches[SWITCH_NUZLOCKE_MODE] == true)
  t.assert("one-catch on", $game_switches[SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA] == true)
  t.assert("perma-death unfused on", $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] == true)
  t.assert("force nicknames on", $game_switches[SWITCH_NUZLOCKE_FORCE_NICKNAMES] == true)
  t.assert("reset enabled on", $game_switches[SWITCH_NUZLOCKE_RESET_ENABLED] == true)
  t.assert("battle items OFF (classic)", $game_switches[SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED] == false)
  t.assert("cap candy OFF (opt-in)", $game_switches[SWITCH_NUZLOCKE_CAP_CANDY_ENABLED] == false)
  t.assert("guarantee heals on", $game_switches[SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS] == true)
  t.assert_eq("fused perma-death default = Both (3)", 3, $game_variables[VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE])
end

NuzlockeTestHarness.suite("Game-mode identity for Nuzlocke") do |t|
  t.assert_eq("getGameModeFromIndex(6) = Nuzlocke", _INTL("Nuzlocke"), getGameModeFromIndex(6))
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.assert_eq("symbol is :NUZLOCKE", :NUZLOCKE, getCurrentGameModeSymbol)
  t.set_switch(SWITCH_RANDOMIZED_AT_LEAST_ONCE, true)
  t.assert_eq("randomized nuzlocke still reports :NUZLOCKE (nuzlocke wins)", :NUZLOCKE, getCurrentGameModeSymbol)
end

#-- triggerCanUseInBattle (battle-items + one-catch enforcement seam) ----------
NuzlockeTestHarness.suite("SEAM triggerCanUseInBattle: items forbidden blocks non-balls, allows balls") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, false)
  t.give_ball
  sc = t.fake_scene; b = t.fake_battle
  potion = ItemHandlers.triggerCanUseInBattle(:POTION, nil, nil, nil, true, b, sc, true)
  ball   = ItemHandlers.triggerCanUseInBattle(:POKEBALL, nil, nil, nil, true, b, sc, true)
  t.assert("Potion is blocked (returns false)", potion == false)
  t.assert("Poke Ball passes through (allowed)", ball == :ORIG)
  t.assert("'no items' message was shown", t.captured_msgs.any? { |m| m.downcase.include?("no items") })
end

NuzlockeTestHarness.suite("SEAM triggerCanUseInBattle: one-catch blocks the second ball") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, true)
  t.set_switch(SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, true)   # isolate the one-catch rule
  t.give_ball
  t.set_area("Route 1", 10)
  sc = t.fake_scene; b = t.fake_battle
  first = ItemHandlers.triggerCanUseInBattle(:POKEBALL, nil, nil, nil, true, b, sc, true)
  t.assert("first ball allowed", first == :ORIG)
  NuzlockeCaptureRules.mark_current_area_used
  second = ItemHandlers.triggerCanUseInBattle(:POKEBALL, nil, nil, nil, true, b, sc, true)
  t.assert("second ball blocked", second == false)
  t.assert("'already caught' message shown", t.captured_msgs.any? { |m| m.downcase.include?("already caught") })
end

#-- pbThrowPokeBall record-on-success seam ------------------------------------
NuzlockeTestHarness.suite("SEAM pbThrowPokeBall marks the area on catch, NOT on a miss") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, true)
  t.give_ball
  t.set_area("Route 1", 10)

  thrower = Class.new { include PokeBattle_BattleCommon }.new
  thrower.instance_variable_set(:@caughtPokemon, [])

  # A miss/flee: the original throw does NOT grow @caughtPokemon.
  def thrower.nuzlocke_orig_pbThrowPokeBall(*_a); :missed; end
  thrower.pbThrowPokeBall(0, :POKEBALL)
  t.assert("area NOT burned by a missed throw", NuzlockeCaptureRules.current_area_used? == false)

  # A successful catch: the original throw grows @caughtPokemon.
  def thrower.nuzlocke_orig_pbThrowPokeBall(*_a); @caughtPokemon << :mon; :caught; end
  thrower.pbThrowPokeBall(0, :POKEBALL)
  t.assert("area burned after a successful catch", NuzlockeCaptureRules.current_area_used? == true)
end

#-- Force-nickname seam (global pbNickname) -----------------------------------
NuzlockeTestHarness.suite("SEAM force-nickname: pbNickname opens name entry directly") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  pk = t.make_pokemon(:PIKACHU, 5)
  pbNickname(pk)
  t.assert("name-entry screen was forced open", t.nick_prompted?)
  t.assert_eq("nickname applied", "TESTNICK", pk.name)
end

NuzlockeTestHarness.suite("SEAM force-nickname OFF: optional confirm, no forced entry") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, false)
  pk = t.make_pokemon(:PIKACHU, 5)
  pbNickname(pk)   # stubbed pbConfirmMessage answers 'no'
  t.refute("name-entry NOT forced when the rule is off", t.nick_prompted?)
end

NuzlockeTestHarness.suite("SEAM force-nickname: eggs are exempt") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  egg = t.make_egg(:PIKACHU)
  pbNickname(egg)
  t.refute("egg is not force-named (named on hatch instead)", t.nick_prompted?)
end

#-- Reset reshuffle dispatch seam ---------------------------------------------
NuzlockeTestHarness.suite("SEAM reshuffle dispatches only the enabled randomizers") do |t|
  t.set_switch(SWITCH_RANDOM_WILD, true)
  t.set_switch(SWITCH_RANDOM_TRAINERS, false)
  t.set_switch(SWITCH_RANDOM_ITEMS, true)
  t.set_switch(SWITCH_RANDOM_TMS, false)
  nuzlocke_reset_reshuffle_randomizers
  t.assert("wild dex shuffled", t.shuffles.include?(:dex))
  t.assert("items shuffled", t.shuffles.include?(:items))
  t.refute("trainers NOT shuffled (switch off)", t.shuffles.include?(:trainers))
  t.refute("TMs NOT shuffled (switch off)", t.shuffles.include?(:tms))
end

NuzlockeTestHarness.suite("SEAM reshuffle dispatches nothing when all randomizers off") do |t|
  nuzlocke_reset_reshuffle_randomizers
  t.assert("no shuffles dispatched", t.shuffles.empty?)
end

#-- Surviving-half retention regression (the weak thread found + fixed) --------
# Old code appended the survivor to $Trainer.party mid-iteration and read
# party_full? against the un-cleaned party; a full party wrongly boxed the
# survivor. These assert the survivor stays IN the party even when full.
NuzlockeTestHarness.suite("Survivor stays in a FULL party (regression)") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 1)   # Head dies -> keep BODY
  party = [t.make_pokemon(:PIKACHU, 10), t.make_pokemon(:BULBASAUR, 10),
           t.make_pokemon(:CHARMANDER, 10), t.make_pokemon(:SQUIRTLE, 10),
           t.make_pokemon(:EEVEE, 10),
           t.make_pokemon(:B16H19, 20, fainted: true)]   # dead fusion, body Pidgey(16)
  t.set_party(party)
  NuzlockeBattleRules.process_party_after_battle
  final = $Trainer.party.compact
  t.assert("surviving BODY half (Pidgey, 16) is IN the party, not boxed",
           final.any? { |m| m.species_data.id_number == 16 })
  t.assert_eq("party stays at 6 (5 healthy + survivor)", 6, final.length)
  t.assert("the dead fusion itself is gone", final.none? { |m| isFusion(m.species_data.id_number) rescue false })
end

NuzlockeTestHarness.suite("Two dead fusions in a 6-mon party: both halves retained") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 1)   # keep BODY
  party = [t.make_pokemon(:PIKACHU, 10), t.make_pokemon(:BULBASAUR, 10),
           t.make_pokemon(:CHARMANDER, 10), t.make_pokemon(:SQUIRTLE, 10),
           t.make_pokemon(:B16H19, 20, fainted: true),   # body Pidgey(16)
           t.make_pokemon(:B10H13, 22, fainted: true)]   # body Caterpie(10)
  t.set_party(party)
  NuzlockeBattleRules.process_party_after_battle
  final = $Trainer.party.compact
  t.assert("body half Pidgey(16) retained", final.any? { |m| m.species_data.id_number == 16 })
  t.assert("body half Caterpie(10) retained", final.any? { |m| m.species_data.id_number == 10 })
  t.assert_eq("party stays at 6 (4 healthy + 2 halves)", 6, final.length)
  t.log("final party: #{final.map { |m| m.species }.inspect}")
end

end # defined?(NuzlockeTestHarness)
