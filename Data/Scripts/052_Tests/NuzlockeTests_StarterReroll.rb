# Starter slot machine suites: override served through obtainStarter, classic
# and randomized pools, gating messages, and the Oak's lab map event itself.
if defined?(NuzlockeTestHarness)

def nuzlocke_sr_setup(t)
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_STARTER_REROLL, true)
  t.set_switch(NuzlockeStarterSlots::STARTER_SELECTION_SWITCH, true)
  $PokemonGlobal.nuzlocke_starter_override = nil
  $PokemonGlobal.nuzlocke_starter_spins = nil
end

NuzlockeTestHarness.suite("Starter slots: gating") do |t|
  nuzlocke_sr_setup(t)
  t.assert("enabled with MODE + toggle", NuzlockeStarterSlots.enabled? == true)
  t.set_switch(SWITCH_NUZLOCKE_STARTER_REROLL, false)
  t.refute("toggle off -> disabled", NuzlockeStarterSlots.enabled?)
  t.set_switch(SWITCH_NUZLOCKE_STARTER_REROLL, true)
  t.set_switch(SWITCH_LEGENDARY_MODE, true)
  t.refute("legendary mode -> disabled", NuzlockeStarterSlots.enabled?)
  t.set_switch(SWITCH_LEGENDARY_MODE, false)
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.refute("MODE off -> disabled", NuzlockeStarterSlots.enabled?)
end

NuzlockeTestHarness.suite("Starter slots: classic reroll is one grass, one fire, one water, never the current trio") do |t|
  nuzlocke_sr_setup(t)
  t.set_switch(SWITCH_RANDOM_STARTERS, false)
  before = NuzlockeStarterSlots.current_trio.map(&:id)
  t.assert_eq("default trio is the Kanto starters", [:BULBASAUR, :CHARMANDER, :SQUIRTLE], before)
  trio = NuzlockeStarterSlots.reroll!
  t.assert("grass slot from the grass list", Settings::GRASS_STARTERS.include?(trio[0]))
  t.assert("fire slot from the fire list", Settings::FIRE_STARTERS.include?(trio[1]))
  t.assert("water slot from the water list", Settings::WATER_STARTERS.include?(trio[2]))
  t.assert("none of the previous trio", (trio & before).empty?)
  t.assert_eq("obtainStarter serves the override", trio, NuzlockeStarterSlots.current_trio.map(&:id))
  t.assert_eq("spin counted", 1, NuzlockeStarterSlots.spins)
  t.assert_eq("override persisted on the save", trio, $PokemonGlobal.nuzlocke_starter_override)
end

NuzlockeTestHarness.suite("Starter slots: override off -> engine starters again") do |t|
  nuzlocke_sr_setup(t)
  t.set_switch(SWITCH_RANDOM_STARTERS, false)
  NuzlockeStarterSlots.reroll!
  $PokemonGlobal.nuzlocke_starter_override = nil
  t.assert_eq("back to Kanto starters", [:BULBASAUR, :CHARMANDER, :SQUIRTLE], NuzlockeStarterSlots.current_trio.map(&:id))
  $PokemonGlobal.nuzlocke_starter_override = [:PIKACHU]   # malformed -> ignored
  t.assert_eq("malformed override ignored", :BULBASAUR, obtainStarter(0).id)
end

NuzlockeTestHarness.suite("Starter slots: randomized reroll stays within the BST window of each starter") do |t|
  nuzlocke_sr_setup(t)
  t.set_switch(SWITCH_RANDOM_STARTERS, true)
  t.set_switch(SWITCH_RANDOM_WILD_TO_FUSION, false)
  t.set_switch(SWITCH_RANDOM_WILD_LEGENDARIES, false)
  t.set_switch(SWITCH_RANDOM_STARTER_FIRST_STAGE, false)
  t.set_var(VAR_RANDOMIZER_WILD_POKE_BST, 25)
  trio = NuzlockeStarterSlots.reroll!
  t.assert_eq("three species", 3, trio.length)
  t.assert("three different species", trio.uniq.length == 3)
  [1, 4, 7].each_with_index do |dex, i|
    target = getStatsTotal(getBaseStatsFormattedForRandomizer(dex))
    got = getStatsTotal(getBaseStatsFormattedForRandomizer(GameData::Species.get(trio[i]).id_number))
    t.assert("slot #{i} (#{trio[i]}, BST #{got}) within ±25 of #{target} (or widened)", (got - target).abs <= 25 + NuzlockeStarterSlots::MAX_DRAWS / 5)
    t.refute("slot #{i} is not a legendary", is_legendary(GameData::Species.get(trio[i]).id_number))
    t.assert("slot #{i} is a base species (no fusions when fusions are off)", GameData::Species.get(trio[i]).id_number <= NB_POKEMON)
  end
  t.assert_eq("served through obtainStarter", trio, NuzlockeStarterSlots.current_trio.map(&:id))
end

NuzlockeTestHarness.suite("Starter slots: randomized reroll honours first-stage") do |t|
  nuzlocke_sr_setup(t)
  t.set_switch(SWITCH_RANDOM_STARTERS, true)
  t.set_switch(SWITCH_RANDOM_STARTER_FIRST_STAGE, true)
  t.set_var(VAR_RANDOMIZER_WILD_POKE_BST, 25)
  trio = NuzlockeStarterSlots.reroll!
  trio.each do |sp|
    data = GameData::Species.get(sp)
    baby = GameData::Species.get(data.get_baby_species(false)).id
    t.assert_eq("#{sp} is its own base form", sp, baby)
  end
end

NuzlockeTestHarness.suite("SEAM pbNuzlockeStarterSlotMachine: messages and spin") do |t|
  nuzlocke_sr_setup(t)
  t.set_switch(SWITCH_RANDOM_STARTERS, false)
  t.set_switch(SWITCH_NUZLOCKE_STARTER_REROLL, false)
  pbNuzlockeStarterSlotMachine
  t.assert("unplugged when the toggle is off", t.captured_msgs.any? { |m| m.include?("unplugged") })
  t.set_switch(SWITCH_NUZLOCKE_STARTER_REROLL, true)
  t.set_switch(NuzlockeStarterSlots::STARTER_SELECTION_SWITCH, false)
  pbNuzlockeStarterSlotMachine
  t.assert("inert when selection is not open", t.captured_msgs.any? { |m| m.include?("Nothing happens") })
  t.set_switch(NuzlockeStarterSlots::STARTER_SELECTION_SWITCH, true)
  # pbMessage stub returns nil for the choice -> "Leave it"; force "Spin!" by
  # answering 0 for messages that carry commands.
  Object.send(:define_method, :pbMessage) { |*a| ($nuzlocke_test_msgs ||= []) << a[0].to_s; a[1].is_a?(Array) ? 0 : nil }
  Object.send(:define_method, :pbSEPlay) { |*_a| nil }
  r = pbNuzlockeStarterSlotMachine
  t.assert("spin ran", r == true)
  t.assert("override set", !NuzlockeStarterSlots.override.nil?)
  t.assert("result announced", t.captured_msgs.any? { |m| m.include?("now hold") })
end

NuzlockeTestHarness.suite("Map 77: the slot machine event exists next to the starter table") do |t|
  map = (load_data("Data/Map077.rxdata") rescue nil)
  t.assert("Map077 loads", !map.nil?)
  if map
    ev = map.events.values.find { |e| e.name == "Nuzlocke slot machine" }
    t.assert("event present", !ev.nil?)
    if ev
      t.assert_eq("position on the cleared shelf row (15,17)", [15, 17], [ev.x, ev.y])
      t.assert_eq("two pages", 2, ev.pages.length)
      on = ev.pages[1]
      t.assert("page 2 conditioned on SWITCH_NUZLOCKE_MODE", on.condition.switch1_valid && on.condition.switch1_id == SWITCH_NUZLOCKE_MODE)
      t.assert_eq("page 2 shows the Game Corner machine tile (left-column, faces the stool)", 9280, on.graphic.tile_id)
      t.assert_eq("red Game Corner stool to its left", 8923, map.data[14, 17, 1])
      t.assert("upper shelf row cleared", (13..16).all? { |x| map.data[x, 17, 1] == 0 || x == 14 })
      t.assert("plant access tiles are floor", map.data[16, 15, 1] == 0 && map.data[16, 16, 1] == 0)
      t.assert("page 2 calls the slot machine script", on.list.any? { |c| c.code == 355 && c.parameters[0].to_s.include?("pbNuzlockeStarterSlotMachine") })
      t.assert("page 1 is invisible and walk-through", ev.pages[0].through && ev.pages[0].graphic.tile_id == 0)
      balls = [54, 55, 56].map { |id| map.events[id] }
      t.assert("the three Poke Ball events are still there", balls.all? { |b| b && b.name == "Ball" })
    end
  end
end

end # defined?(NuzlockeTestHarness)
