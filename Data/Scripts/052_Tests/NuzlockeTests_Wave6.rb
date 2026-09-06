# Wave 6: the Repel Toggle key item.
if defined?(NuzlockeTestHarness)

NuzlockeTestHarness.suite("Repel Toggle: registered as a from-Bag key item") do |t|
  item = GameData::Item.try_get(:NUZLOCKEREPELTOGGLE)
  t.assert("item exists", !item.nil?)
  if item
    t.assert_eq("name", "Repel Toggle", item.name)
    t.assert_eq("Key Items pocket", 8, item.pocket)
    t.assert("key item", item.is_key_item?)
    t.assert_eq("from-Bag use (no target)", 2, item.field_use)
    t.assert_eq("not usable in battle", 0, item.battle_use)
    t.assert_eq("id_number", 9648, item.id_number)
  end
  t.assert("UseFromBag handler registered", ItemHandlers::UseFromBag[:NUZLOCKEREPELTOGGLE] ? true : false)
  t.assert("UseInField handler registered", ItemHandlers.hasUseInFieldHandler(:NUZLOCKEREPELTOGGLE) == true)
  t.assert("Bag offers Register", pbCanRegisterItem?(:NUZLOCKEREPELTOGGLE) == true)
  t.assert("icon exists", pbResolveBitmap("Graphics/Items/NUZLOCKEREPELTOGGLE") ? true : false)
end

NuzlockeTestHarness.suite("Repel Toggle: flips on/off and drives isRepelActive") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_REPEL_TOGGLE_ENABLED, true)
  t.set_switch(SWITCH_USED_AN_INCENSE, false)
  NuzlockeRepelToggle.set(false)
  $PokemonGlobal.repel = 0 if $PokemonGlobal.respond_to?(:repel=)
  t.refute("starts off", NuzlockeRepelToggle.on?)
  t.refute("no repel while off", isRepelActive)
  r = ItemHandlers.triggerUseInField(:NUZLOCKEREPELTOGGLE)
  t.assert_eq("field use returns 1 (used, kept)", 1, r)
  t.assert("now on", NuzlockeRepelToggle.on?)
  t.assert("ON message", t.captured_msgs.any? { |m| m.include?("now ON") })
  t.assert("repel active while on", isRepelActive == true)
  t.assert("repel step counter untouched", !$PokemonGlobal.respond_to?(:repel) || $PokemonGlobal.repel.to_i == 0)
  r2 = ItemHandlers::UseFromBag[:NUZLOCKEREPELTOGGLE].call(:NUZLOCKEREPELTOGGLE)
  t.assert_eq("bag use also returns 1", 1, r2)
  t.refute("now off again", NuzlockeRepelToggle.on?)
  t.assert("OFF message", t.captured_msgs.any? { |m| m.include?("now OFF") })
  t.refute("no repel after switching off", isRepelActive)
end

NuzlockeTestHarness.suite("Repel Toggle: incense still wins; setting off disables and removes it") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_REPEL_TOGGLE_ENABLED, true)
  NuzlockeRepelToggle.set(true)
  t.set_switch(SWITCH_USED_AN_INCENSE, true)
  t.refute("incense (fusion repel) overrides the toggle", isRepelActive)
  t.set_switch(SWITCH_USED_AN_INCENSE, false)
  t.assert("active again without incense", isRepelActive == true)
  t.empty_bag
  NuzlockeKeyItems.sync_all!
  t.assert("item handed out while enabled", $PokemonBag.pbHasItem?(:NUZLOCKEREPELTOGGLE))
  t.set_switch(SWITCH_NUZLOCKE_REPEL_TOGGLE_ENABLED, false)
  t.assert_eq("disabled -> handler returns 0", 0, ItemHandlers.triggerUseInField(:NUZLOCKEREPELTOGGLE))
  NuzlockeKeyItems.sync_all!
  t.refute("item taken away", $PokemonBag.pbHasItem?(:NUZLOCKEREPELTOGGLE))
  t.refute("toggle forced off with the setting", NuzlockeRepelToggle.on?)
  t.refute("no repel once disabled", isRepelActive)
end

NuzlockeTestHarness.suite("Repel Toggle: defaults, reset preservation, settings entry") do |t|
  initializeNuzlockeMode
  t.assert("OFF by default", $game_switches[SWITCH_NUZLOCKE_REPEL_TOGGLE_ENABLED] == false)
  t.assert("switch preserved by Reset Run", NUZLOCKE_RESET_PRESERVED_SWITCH_SYMS.include?(:SWITCH_NUZLOCKE_REPEL_TOGGLE_ENABLED))
  begin
    names = NuzlockeSettingsScene.new(true).pbGetOptions.map { |o| o.name }
    t.assert("Repel Toggle option present mid-run", names.include?("Repel Toggle"))
  rescue => e
    t.assert("settings scene builds its options: #{e.class}: #{e.message}", false)
  end
end

end # defined?(NuzlockeTestHarness)
