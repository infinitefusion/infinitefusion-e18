# Wave 5: encounter slots per method / per rod, and the Field Medkit key item.
if defined?(NuzlockeTestHarness)

NuzlockeTestEncTemp = Struct.new(:encounterType) unless defined?(NuzlockeTestEncTemp)

def nuzlocke_w5_setup(t, mode)
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_var(VAR_NUZLOCKE_ENCOUNTER_SLOTS, mode)
  t.give_ball
  $PokemonTemp = NuzlockeTestEncTemp.new(nil)
end

NuzlockeTestHarness.suite("Encounter slots: method classification") do |t|
  m = NuzlockeCaptureRules
  nuzlocke_w5_setup(t, 1)
  { :Land => :land, :LandNight => :land, :Cave => :land, :BugContest => :land,
    :Water => :water, :OldRod => :fishing, :GoodRod => :fishing, :SuperRod => :fishing,
    :RockSmash => :special, :HeadbuttLow => :special, nil => :special, :NOPE => :special }.each do |et, slot|
    $PokemonTemp.encounterType = et
    t.assert_eq("#{et.inspect} -> #{slot}", slot, m.current_encounter_slot)
  end
  t.set_var(VAR_NUZLOCKE_ENCOUNTER_SLOTS, 2)
  $PokemonTemp.encounterType = :GoodRod
  t.assert_eq("per-rod mode splits rods", :goodrod, m.current_encounter_slot)
  t.set_area("Route 6", 6)
  t.assert_eq("key in rod mode", "Route 6|goodrod", m.slot_key("Route 6"))
  t.set_var(VAR_NUZLOCKE_ENCOUNTER_SLOTS, 0)
  t.assert_eq("key in per-area mode is the plain area", "Route 6", m.slot_key("Route 6"))
  t.assert_eq("plain_area strips the slot", "Route 6", m.plain_area("Route 6|goodrod"))
end

NuzlockeTestHarness.suite("Encounter slots: land encounter does not spend the fishing slot (per method)") do |t|
  m = NuzlockeCaptureRules
  nuzlocke_w5_setup(t, 1)
  t.set_area("Route 6", 6)
  $PokemonTemp.encounterType = :Land
  m.note_wild_encounter_start([:PIDGEY, 5])
  t.assert("land slot recorded", m.first_encounter_areas.include?("Route 6|land"))
  m.mark_current_area_used                       # caught it
  t.assert("land catch recorded", m.caught_areas.include?("Route 6|land"))
  m.clear_wild_encounter_flag
  $PokemonTemp.encounterType = :OldRod
  m.note_wild_encounter_start([:MAGIKARP, 5])
  t.assert("fishing is its own first encounter", m.current_is_first_encounter?)
  t.assert("fishing throw allowed", m.catch_block_reason.nil?)
  m.clear_wild_encounter_flag
  $PokemonTemp.encounterType = :LandDay
  m.note_wild_encounter_start([:RATTATA, 5])
  t.assert_eq("a second land wild is blocked (already caught on land here)", :area_caught, m.catch_block_reason)
end

NuzlockeTestHarness.suite("Encounter slots: per rod splits Old/Good/Super; webs are 'special'") do |t|
  m = NuzlockeCaptureRules
  nuzlocke_w5_setup(t, 2)
  t.set_area("Route 12", 12)
  $PokemonTemp.encounterType = :OldRod
  m.note_wild_encounter_start([:MAGIKARP, 5]); m.mark_current_area_used; m.clear_wild_encounter_flag
  $PokemonTemp.encounterType = :SuperRod
  m.note_wild_encounter_start([:GYARADOS, 15])
  t.assert("Super Rod is a fresh slot after an Old Rod catch", m.current_is_first_encounter? && m.catch_block_reason.nil?)
  m.clear_wild_encounter_flag
  $PokemonTemp.encounterType = nil                   # scripted web: pbWildBattle(:SPINARAK, 4)
  m.note_wild_battle_args([:SPINARAK, 4])
  t.assert("web (scripted) is the 'special' slot", m.first_encounter_areas.include?("Route 12|special"))
  t.assert("web catchable", m.catch_block_reason.nil?)
end

NuzlockeTestHarness.suite("Encounter slots: per area (strict) treats every method as one slot") do |t|
  m = NuzlockeCaptureRules
  nuzlocke_w5_setup(t, 0)
  t.set_area("Route 6", 6)
  $PokemonTemp.encounterType = :Land
  m.note_wild_encounter_start([:PIDGEY, 5]); m.clear_wild_encounter_flag
  $PokemonTemp.encounterType = :OldRod
  m.note_wild_encounter_start([:MAGIKARP, 5])
  t.refute("fishing is NOT a new first encounter in strict mode", m.current_is_first_encounter?)
  t.assert_eq("blocked as encounter used", :encounter_used, m.catch_block_reason)
end

NuzlockeTestHarness.suite("Encounter slots: records survive switching modes (no free catches)") do |t|
  m = NuzlockeCaptureRules
  nuzlocke_w5_setup(t, 1)
  t.set_area("Route 6", 6)
  $PokemonTemp.encounterType = :Land
  m.note_wild_encounter_start([:PIDGEY, 5]); m.mark_current_area_used; m.clear_wild_encounter_flag
  t.set_var(VAR_NUZLOCKE_ENCOUNTER_SLOTS, 0)          # switch to strict
  t.assert("a slot record counts as the area in strict mode", m.current_area_used?)
  # legacy plain record blocks every slot in split mode
  t.set_var(VAR_NUZLOCKE_ENCOUNTER_SLOTS, 2)
  m.caught_areas.push("Route 7")
  t.set_area("Route 7", 7)
  $PokemonTemp.encounterType = :SuperRod
  t.assert("legacy plain-area record blocks the rod slot too", m.current_area_used?)
end

NuzlockeTestHarness.suite("Encounter slots: Shiny Clause gives back the SLOT it recorded") do |t|
  m = NuzlockeCaptureRules
  nuzlocke_w5_setup(t, 1)
  t.set_switch(SWITCH_NUZLOCKE_SHINY_CLAUSE, true)
  t.set_area("Route 6", 6)
  $PokemonTemp.encounterType = :Water
  m.note_wild_encounter_start([:TENTACOOL, 10])
  t.assert_eq("recorded key is the water slot", "Route 6|water", m.area_recorded_this_battle)
  shiny = t.make_pokemon(:TENTACOOL, 10); shiny.shiny = true
  m.note_wild_pokemon(shiny)
  t.refute("water slot given back", m.first_encounter_areas.include?("Route 6|water"))
end

NuzlockeTestHarness.suite("Encounter slots: Soul Link records a forfeited slot as the plain area") do |t|
  m = NuzlockeCaptureRules
  nuzlocke_w5_setup(t, 1)
  t.set_switch(SWITCH_NUZLOCKE_SOUL_LINK, true)
  $PokemonGlobal.nuzlocke_soul_link = nil
  t.set_area("Route 6", 6)
  $PokemonTemp.encounterType = :OldRod
  m.note_wild_encounter_start([:MAGIKARP, 5])
  NuzlockeSoulLink.note_wild_battle_end
  t.assert("failed area is 'Route 6' (no slot suffix)", NuzlockeSoulLink.state[:failed_areas] == ["Route 6"])
end

#-- Field Medkit ----------------------------------------------------------------
NuzlockeTestHarness.suite("Field Medkit: registered as a reusable from-Bag key item") do |t|
  item = GameData::Item.try_get(:NUZLOCKEMEDKIT)
  t.assert("item exists", !item.nil?)
  if item
    t.assert_eq("name", "Field Medkit", item.name)
    t.assert_eq("Key Items pocket", 8, item.pocket)
    t.assert("key item", item.is_key_item?)
    t.assert_eq("from-Bag use (no target)", 2, item.field_use)
    t.assert_eq("not usable in battle", 0, item.battle_use)
    t.assert_eq("id_number", 9647, item.id_number)
  end
  t.assert("UseFromBag handler registered", ItemHandlers::UseFromBag[:NUZLOCKEMEDKIT] ? true : false)
  t.assert("icon exists", pbResolveBitmap("Graphics/Items/NUZLOCKEMEDKIT") ? true : false)
end

NuzlockeTestHarness.suite("Field Medkit: heals HP, status and PP; handler gating") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_MEDKIT_ENABLED, true)
  hurt = t.make_pokemon(:PIKACHU, 20, fainted: true)
  t.set_party([hurt])
  t.assert("precondition: fainted", hurt.fainted?)
  r = ItemHandlers::UseFromBag[:NUZLOCKEMEDKIT].call(:NUZLOCKEMEDKIT)
  t.assert_eq("handler reports used (kept)", 1, r)
  t.refute("healed", hurt.fainted?)
  t.assert("healed message", t.captured_msgs.any? { |m| m.include?("fully healed") })
  r2 = ItemHandlers::UseFromBag[:NUZLOCKEMEDKIT].call(:NUZLOCKEMEDKIT)
  t.assert_eq("already healthy still returns 1 (not consumed)", 1, r2)
  t.set_switch(SWITCH_NUZLOCKE_MEDKIT_ENABLED, false)
  t.assert_eq("disabled -> 0", 0, ItemHandlers::UseFromBag[:NUZLOCKEMEDKIT].call(:NUZLOCKEMEDKIT))
end

NuzlockeTestHarness.suite("Key items: sync_all! adds/removes both items by their toggles") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_CAP_CANDY_ENABLED, true)
  t.set_switch(SWITCH_NUZLOCKE_MEDKIT_ENABLED, false)
  t.empty_bag
  NuzlockeKeyItems.sync_all!
  t.assert("Cap Candy present", $PokemonBag.pbHasItem?(:CAPCANDYNUZLOCKE))
  t.refute("Medkit absent", $PokemonBag.pbHasItem?(:NUZLOCKEMEDKIT))
  t.set_switch(SWITCH_NUZLOCKE_MEDKIT_ENABLED, true)
  t.set_switch(SWITCH_NUZLOCKE_CAP_CANDY_ENABLED, false)
  NuzlockeKeyItems.sync_all!
  t.refute("Cap Candy removed", $PokemonBag.pbHasItem?(:CAPCANDYNUZLOCKE))
  t.assert("Medkit added", $PokemonBag.pbHasItem?(:NUZLOCKEMEDKIT))
end

NuzlockeTestHarness.suite("Wave 5 mode defaults") do |t|
  initializeNuzlockeMode
  t.assert_eq("encounter slots default = per method", 1, $game_variables[VAR_NUZLOCKE_ENCOUNTER_SLOTS])
  t.assert("Medkit OFF by default", $game_switches[SWITCH_NUZLOCKE_MEDKIT_ENABLED] == false)
  t.assert("slots var preserved by Reset Run", NUZLOCKE_RESET_PRESERVED_VAR_SYMS.include?(:VAR_NUZLOCKE_ENCOUNTER_SLOTS))
  t.assert("Medkit switch preserved by Reset Run", NUZLOCKE_RESET_PRESERVED_SWITCH_SYMS.include?(:SWITCH_NUZLOCKE_MEDKIT_ENABLED))
end

NuzlockeTestHarness.suite("Nuzlocke settings can be opened mid-run (Help Man) without the Randomization entry") do |t|
  begin
    scene = NuzlockeSettingsScene.new(true)
    names = scene.pbGetOptions.map { |o| o.name }
    t.refute("Randomization hidden mid-run", names.include?("Randomization"))
    t.assert("Field Medkit present", names.include?("Field Medkit"))
    t.assert("Cap Candy present", names.include?("Cap Candy"))
    t.assert("Encounter slots present", names.include?("Encounter slots"))
    fresh = NuzlockeSettingsScene.new(false).pbGetOptions.map { |o| o.name }
    t.assert("Randomization shown at New Game", fresh.include?("Randomization"))
  rescue => e
    t.assert("settings scene builds its options: #{e.class}: #{e.message}", false)
  end
  t.assert("mid-run opener defined", defined?(pbOpenNuzlockeSettingsMidRun) ? true : false)
end

NuzlockeTestHarness.suite("Help Man (common event 37) offers Nuzlocke settings in Nuzlocke runs") do |t|
  ces = (load_data("Data/CommonEvents.rxdata") rescue nil)
  ce = ces && ces[37]
  t.assert("common event 37 exists and is the Help Man", ce && ce.name.to_s =~ /Update man/i ? true : false)
  if ce
    list = ce.list
    i = list.index { |c| c.code == 111 && c.parameters[0] == 0 && c.parameters[1] == SWITCH_NUZLOCKE_MODE }
    t.assert("dialog starts with 'if Nuzlocke mode'", i == 0)
    t.assert("offers the Nuzlocke settings choice", list.any? { |c| c.code == 102 && c.parameters[0].map(&:to_s).include?("Nuzlocke settings") })
    t.assert("calls the mid-run opener", list.any? { |c| c.code == 355 && c.parameters[0].to_s.include?("pbOpenNuzlockeSettingsMidRun") })
    t.assert("still greets normally afterwards", list.any? { |c| c.code == 101 && c.parameters[0].to_s.include?("Is there anything I can help you") })
  end
end

NuzlockeTestHarness.suite("Key items are registerable to the ready menu") do |t|
  t.assert("Cap Candy has a UseInField handler", ItemHandlers.hasUseInFieldHandler(:CAPCANDYNUZLOCKE) == true)
  t.assert("Medkit has a UseInField handler", ItemHandlers.hasUseInFieldHandler(:NUZLOCKEMEDKIT) == true)
  t.assert("Bag offers Register for Cap Candy", pbCanRegisterItem?(:CAPCANDYNUZLOCKE) == true)
  t.assert("Bag offers Register for Medkit", pbCanRegisterItem?(:NUZLOCKEMEDKIT) == true)
  # Medkit from the ready menu heals without opening any screen.
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_MEDKIT_ENABLED, true)
  hurt = t.make_pokemon(:PIKACHU, 20, fainted: true)
  t.set_party([hurt])
  r = ItemHandlers.triggerUseInField(:NUZLOCKEMEDKIT)
  t.assert_eq("field use returns 1 (used, kept)", 1, r)
  t.refute("party healed from the ready menu", hurt.fainted?)
  t.set_switch(SWITCH_NUZLOCKE_MEDKIT_ENABLED, false)
  t.assert_eq("disabled -> 0", 0, ItemHandlers.triggerUseInField(:NUZLOCKEMEDKIT))
end

end # defined?(NuzlockeTestHarness)
