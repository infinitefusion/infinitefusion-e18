# Soul Link suites. The relay is stubbed (no HTTP in the harness); everything
# else -- tagging, ledger build, event diff, release, fusion merge/split,
# config export/import, code validation -- runs against the real code.
if defined?(NuzlockeTestHarness)

# Storage double with the boxes API Soul Link walks.
class NuzlockeTestBoxStorage
  Box = Struct.new(:pokemon)
  attr_reader :boxes
  def initialize(n = 2); @boxes = Array.new(n) { Box.new(Array.new(30)) }; end
  def [](b, i = nil); i.nil? ? @boxes[b] : @boxes[b].pokemon[i]; end
  def []=(b, i, v); @boxes[b].pokemon[i] = v; end
  def pbStoreCaught(p); @boxes[0].pokemon[@boxes[0].pokemon.index(nil)] = p; 0; end
  def full?; false; end
end

def nuzlocke_sl_setup(t)
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_SOUL_LINK, true)
  $PokemonStorage = NuzlockeTestBoxStorage.new
  $PokemonGlobal.nuzlocke_soul_link = nil
  $nuzlocke_test_relay = { pushed: [], pull: nil, create: "ABC234", leave: 0 }
  r = NuzlockeSoulLink::Relay
  r.define_singleton_method(:create_room) { $nuzlocke_test_relay[:create] }
  r.define_singleton_method(:push) { |code, key, ledger| $nuzlocke_test_relay[:pushed] << [code, key, ledger]; true }
  r.define_singleton_method(:pull) { |code| $nuzlocke_test_relay[:pull] }
  r.define_singleton_method(:leave) { |code, key| $nuzlocke_test_relay[:leave] += 1; true }
  r.define_singleton_method(:configured?) { true }
end

def nuzlocke_sl_partner_ledger(name, areas)
  { "v" => 1, "name" => name, "key" => "#{name}_1", "updated" => Time.now.to_i, "areas" => areas }
end

NuzlockeTestHarness.suite("Soul Link: gating and player key") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_SOUL_LINK, false)
  t.refute("inactive when toggle off", NuzlockeSoulLink.active?)
  t.set_switch(SWITCH_NUZLOCKE_SOUL_LINK, true)
  t.assert("active when MODE + toggle", NuzlockeSoulLink.active? == true)
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.refute("inactive when MODE off", NuzlockeSoulLink.active?)
  $PokemonGlobal.nuzlocke_soul_link = nil
  $Trainer.define_singleton_method(:name) { "Matt Mc Combs!" }
  $Trainer.define_singleton_method(:id) { 123456789 }
  key = NuzlockeSoulLink.player_key
  t.assert("player key is URL-safe: #{key}", key =~ NuzlockeSoulLink::PLAYER_PATTERN ? true : false)
  t.assert("player key strips spaces/punctuation", !key.include?(" ") && !key.include?("!"))
  t.assert_eq("player key is stable", key, NuzlockeSoulLink.player_key)
end

NuzlockeTestHarness.suite("Soul Link: tagging on acquisition + obtain-map fallback") do |t|
  nuzlocke_sl_setup(t)
  t.set_area("Route 3", 3)
  pk = t.make_pokemon(:PIDGEY, 5)
  NuzlockeSoulLink.tag_acquired(pk)
  t.assert_eq("tagged with current area", ["Route 3"], pk.nuzlocke_link_areas)
  NuzlockeSoulLink.tag_acquired(pk)
  t.assert_eq("tagging twice does not duplicate", ["Route 3"], pk.nuzlocke_link_areas)
  egg = t.make_egg(:PIDGEY)
  NuzlockeSoulLink.tag_acquired(egg)
  t.assert("eggs are not tagged", egg.nuzlocke_link_areas.nil?)
  t.set_switch(SWITCH_NUZLOCKE_SOUL_LINK, false)
  pk2 = t.make_pokemon(:RATTATA, 5)
  NuzlockeSoulLink.tag_acquired(pk2)
  t.assert("no tagging when Soul Link is off", pk2.nuzlocke_link_areas.nil?)
  # obtain-map fallback for mons caught before Soul Link was enabled
  t.set_switch(SWITCH_NUZLOCKE_SOUL_LINK, true)
  pk3 = t.make_pokemon(:ZUBAT, 5)
  pk3.obtain_map = 7 if pk3.respond_to?(:obtain_map=)
  orig = Object.instance_method(:pbGetMapNameFromId)
  Object.send(:define_method, :pbGetMapNameFromId) { |id| id == 7 ? "Mt. Moon" : "" }
  t.assert_eq("untagged mon falls back to its obtain map name", ["Mt. Moon"], NuzlockeSoulLink.link_areas_for(pk3))
  Object.send(:define_method, :pbGetMapNameFromId, orig)
end

NuzlockeTestHarness.suite("Soul Link: ledger build (alive > dead > failed)") do |t|
  nuzlocke_sl_setup(t)
  a = t.make_pokemon(:PIDGEY, 5); a.nuzlocke_link_areas = ["Route 3"]; a.name = "Bird"
  b = t.make_pokemon(:ZUBAT, 5);  b.nuzlocke_link_areas = ["Mt. Moon"]
  t.set_party([a])
  $PokemonStorage[0, 0] = b
  NuzlockeSoulLink.note_dead_areas(["Route 4"])
  NuzlockeSoulLink.state[:failed_areas].push("Route 5")
  NuzlockeSoulLink.state[:failed_areas].push("Route 3")   # failed but a living mon exists -> alive wins
  led = NuzlockeSoulLink.build_ledger
  t.assert_eq("version", 1, led["v"])
  t.assert_eq("Route 3 alive in party", ["alive", "party", "Bird"], [led["areas"]["Route 3"]["status"], led["areas"]["Route 3"]["location"], led["areas"]["Route 3"]["name"]])
  t.assert_eq("Mt. Moon alive in box", ["alive", "box"], [led["areas"]["Mt. Moon"]["status"], led["areas"]["Mt. Moon"]["location"]])
  t.assert_eq("Route 4 dead", "dead", led["areas"]["Route 4"]["status"])
  t.assert_eq("Route 5 failed", "failed", led["areas"]["Route 5"]["status"])
  t.assert("ledger serializes to JSON", serialize_json(led).include?("\"Route 3\""))
end

NuzlockeTestHarness.suite("Soul Link: partner death -> linked release (party + box, item returned)") do |t|
  nuzlocke_sl_setup(t)
  mine = t.make_pokemon(:PIDGEY, 5, held: :ORANBERRY); mine.nuzlocke_link_areas = ["Route 3"]; mine.name = "Bird"
  boxed = t.make_pokemon(:RATTATA, 5); boxed.nuzlocke_link_areas = ["Route 3"]
  other = t.make_pokemon(:ZUBAT, 5); other.nuzlocke_link_areas = ["Mt. Moon"]
  t.set_party([mine, other])
  $PokemonStorage[1, 3] = boxed
  NuzlockeSoulLink.state[:room] = "ABC234"
  NuzlockeSoulLink.state[:partners] = { "Alesia_1" => nuzlocke_sl_partner_ledger("Alesia",
    "Route 3" => { "species" => "SPEAROW", "name" => "Spike", "status" => "dead", "location" => "" },
    "Mt. Moon" => { "species" => "GEODUDE", "name" => "Rock", "status" => "alive", "location" => "party" }) }
  events = NuzlockeSoulLink.compute_events
  t.assert_eq("one event (Route 3 dead)", 1, events.length)
  t.assert_eq("event area", "Route 3", events[0][:area])
  n = NuzlockeSoulLink.process_pending_events(false)   # no confirm in tests
  t.assert_eq("one event applied", 1, n)
  t.refute("linked party mon released", $Trainer.party.any? { |m| m.equal?(mine) })
  t.assert("unlinked party mon untouched", $Trainer.party.any? { |m| m.equal?(other) })
  t.assert("linked boxed mon released", $PokemonStorage[1, 3].nil?)
  t.assert("held item returned to the bag", t.bag_stored_items.include?(:ORANBERRY))
  t.assert("Route 3 now recorded dead on my side", NuzlockeSoulLink.state[:dead_areas].include?("Route 3"))
  t.assert("event marked applied", NuzlockeSoulLink.state[:applied]["Alesia_1|Route 3|dead"] == true)
  t.assert("re-run produces no new events", NuzlockeSoulLink.compute_events.empty?)
  t.assert("ledger was pushed after applying", $nuzlocke_test_relay[:pushed].length >= 1)
  t.assert("'can never battle again' shown", t.captured_msgs.any? { |m| m.include?("never battle again") })
end

NuzlockeTestHarness.suite("Soul Link: partner failed catch -> broken link releases mine") do |t|
  nuzlocke_sl_setup(t)
  mine = t.make_pokemon(:PIDGEY, 5); mine.nuzlocke_link_areas = ["Route 3"]
  t.set_party([mine])
  NuzlockeSoulLink.state[:room] = "ABC234"
  NuzlockeSoulLink.state[:partners] = { "Alesia_1" => nuzlocke_sl_partner_ledger("Alesia",
    "Route 3" => { "species" => "", "name" => "", "status" => "failed", "location" => "" }) }
  NuzlockeSoulLink.process_pending_events(false)
  t.assert("my Route 3 mon released", $Trainer.party.compact.empty?)
end

NuzlockeTestHarness.suite("Soul Link: deferred confirm keeps the mon and re-asks later") do |t|
  nuzlocke_sl_setup(t)
  mine = t.make_pokemon(:PIDGEY, 5); mine.nuzlocke_link_areas = ["Route 3"]
  t.set_party([mine])
  NuzlockeSoulLink.state[:room] = "ABC234"
  NuzlockeSoulLink.state[:partners] = { "Alesia_1" => nuzlocke_sl_partner_ledger("Alesia",
    "Route 3" => { "species" => "", "name" => "", "status" => "dead", "location" => "" }) }
  n = NuzlockeSoulLink.process_pending_events(true)   # harness pbConfirmMessage answers "no"
  t.assert_eq("nothing applied on 'no'", 0, n)
  t.assert("mon kept", $Trainer.party.any? { |m| m.equal?(mine) })
  t.assert("event still pending", NuzlockeSoulLink.compute_events.length == 1)
end

NuzlockeTestHarness.suite("Soul Link: my own ledger is ignored; alive partners never trigger") do |t|
  nuzlocke_sl_setup(t)
  mine = t.make_pokemon(:PIDGEY, 5); mine.nuzlocke_link_areas = ["Route 3"]
  t.set_party([mine])
  me = NuzlockeSoulLink.player_key
  NuzlockeSoulLink.state[:partners] = {
    me => nuzlocke_sl_partner_ledger("Me", "Route 3" => { "status" => "dead" }),
    "Alesia_1" => nuzlocke_sl_partner_ledger("Alesia", "Route 3" => { "species" => "SPEAROW", "name" => "S", "status" => "alive", "location" => "box" })
  }
  t.assert("no events", NuzlockeSoulLink.compute_events.empty?)
  mism = NuzlockeSoulLink.box_mismatches
  t.assert_eq("linked-box mismatch reported (mine party, theirs box)", 1, mism.length)
end

NuzlockeTestHarness.suite("Soul Link: perma-death records dead areas; fused survivor keeps its half's areas") do |t|
  nuzlocke_sl_setup(t)
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 1)   # Head dies -> keep BODY
  dead = t.make_pokemon(:RATTATA, 10, fainted: true); dead.nuzlocke_link_areas = ["Route 1"]
  fusion = t.make_pokemon(:B16H19, 20, fainted: true)
  fusion.nuzlocke_link_areas = ["Route 2", "Route 22"]
  fusion.nuzlocke_link_areas_head = ["Route 22"]
  t.set_party([dead, fusion])
  NuzlockeBattleRules.process_party_after_battle
  t.assert("unfused death recorded", NuzlockeSoulLink.state[:dead_areas].include?("Route 1"))
  t.assert("dead HEAD half's area recorded dead", NuzlockeSoulLink.state[:dead_areas].include?("Route 22"))
  t.refute("surviving BODY half's area NOT dead", NuzlockeSoulLink.state[:dead_areas].include?("Route 2"))
  survivor = $Trainer.party.compact.find { |m| m.species_data.id_number == 16 }
  t.assert_eq("survivor keeps only the body's area", ["Route 2"], survivor && survivor.nuzlocke_link_areas)
end

NuzlockeTestHarness.suite("Soul Link: fuse merges areas, unfuse split hands the head's back") do |t|
  nuzlocke_sl_setup(t)
  body = t.make_pokemon(:PIDGEY, 5); body.nuzlocke_link_areas = ["Route 3"]
  head = t.make_pokemon(:RATTATA, 5); head.nuzlocke_link_areas = ["Route 1"]
  NuzlockeSoulLink.merge_on_fuse(body, head)
  t.assert_eq("fusion carries both areas", ["Route 3", "Route 1"], body.nuzlocke_link_areas)
  t.assert_eq("head's areas remembered", ["Route 1"], body.nuzlocke_link_areas_head)
  new_head = t.make_pokemon(:RATTATA, 5)
  NuzlockeSoulLink.split_on_unfuse(body, new_head)
  t.assert_eq("body keeps its own area", ["Route 3"], body.nuzlocke_link_areas)
  t.assert_eq("new head gets its area back", ["Route 1"], new_head.nuzlocke_link_areas)
  t.assert("head bookkeeping cleared", body.nuzlocke_link_areas_head.nil?)
end

NuzlockeTestHarness.suite("Soul Link: forfeited first encounter -> failed area") do |t|
  nuzlocke_sl_setup(t)
  t.give_ball
  t.set_var(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  t.set_area("Route 9", 9)
  NuzlockeCaptureRules.note_wild_encounter_start([:PIDGEY, 5])
  NuzlockeSoulLink.note_wild_battle_end            # no catch happened
  t.assert("Route 9 recorded as failed", NuzlockeSoulLink.state[:failed_areas].include?("Route 9"))
  NuzlockeCaptureRules.clear_wild_encounter_flag
  t.set_area("Route 10", 10)
  NuzlockeCaptureRules.note_wild_encounter_start([:PIDGEY, 5])
  NuzlockeCaptureRules.mark_current_area_used      # caught it
  NuzlockeSoulLink.note_wild_battle_end
  t.refute("caught first encounter is NOT failed", NuzlockeSoulLink.state[:failed_areas].include?("Route 10"))
end

NuzlockeTestHarness.suite("Soul Link: room create / join / leave via the relay") do |t|
  nuzlocke_sl_setup(t)
  t.refute("not in a room initially", NuzlockeSoulLink.in_room?)
  code = NuzlockeSoulLink.create_room!
  t.assert_eq("room created with relay code", "ABC234", code)
  t.assert("in room", NuzlockeSoulLink.in_room?)
  t.assert("ledger pushed on create", $nuzlocke_test_relay[:pushed].length == 1)
  NuzlockeSoulLink.leave_room!
  t.refute("left the room", NuzlockeSoulLink.in_room?)
  t.assert_eq("relay leave called", 1, $nuzlocke_test_relay[:leave])
  t.assert_eq("bad code rejected", :invalid, NuzlockeSoulLink.join_room!("abc"))
  $nuzlocke_test_relay[:pull] = nil
  t.assert_eq("unknown room", :not_found, NuzlockeSoulLink.join_room!("ZZZZZZ"))
  $nuzlocke_test_relay[:pull] = { "Alesia_1" => nuzlocke_sl_partner_ledger("Alesia", {}) }
  t.assert_eq("join ok (lowercase input accepted)", :ok, NuzlockeSoulLink.join_room!("abc234"))
  t.assert_eq("room stored upper-cased", "ABC234", NuzlockeSoulLink.room)
  t.assert("partner cached", NuzlockeSoulLink.state[:partners].key?("Alesia_1"))
end

NuzlockeTestHarness.suite("Soul Link: push/pull cadence and relay backoff") do |t|
  nuzlocke_sl_setup(t)
  NuzlockeSoulLink.state[:room] = "ABC234"
  $nuzlocke_test_relay[:pull] = {}
  t.assert("first pull happens (never pulled)", NuzlockeSoulLink.pull_if_needed == true)
  t.refute("immediate second pull skipped (interval)", NuzlockeSoulLink.pull_if_needed)
  t.assert("forced pull happens", NuzlockeSoulLink.pull_if_needed(true) == true)
  NuzlockeSoulLink.dirty!
  t.assert("dirty -> push", NuzlockeSoulLink.push_if_needed == true)
  t.refute("clean -> no push", NuzlockeSoulLink.push_if_needed)
  NuzlockeSoulLink::Relay.define_singleton_method(:push) { |*_a| false }
  NuzlockeSoulLink.dirty!
  t.refute("relay failure -> push false", NuzlockeSoulLink.push_if_needed)
  t.assert("backoff armed", NuzlockeSoulLink.relay_down?)
  t.refute("during backoff, non-forced pull is skipped", NuzlockeSoulLink.pull_if_needed)
end

NuzlockeTestHarness.suite("Soul Link: Reset Run keeps the pairing, wipes the ledger state") do |t|
  nuzlocke_sl_setup(t)
  NuzlockeSoulLink.state[:room] = "ABC234"
  NuzlockeSoulLink.state[:dead_areas] = ["Route 1"]
  key = NuzlockeSoulLink.player_key
  cfg = NuzlockeSoulLink.export_config
  $PokemonGlobal.nuzlocke_soul_link = nil          # Game.load clobber
  NuzlockeSoulLink.import_config(cfg)
  t.assert_eq("room restored", "ABC234", NuzlockeSoulLink.room)
  t.assert_eq("player key restored", key, NuzlockeSoulLink.player_key)
  t.assert("dead areas wiped", NuzlockeSoulLink.state[:dead_areas].empty?)
  t.assert("marked dirty for re-publish", NuzlockeSoulLink.state[:dirty] == true)
end

NuzlockeTestHarness.suite("Soul Link: relay URL resolution") do |t|
  r = NuzlockeSoulLink::Relay
  File.delete(NuzlockeSoulLink::RELAY_URL_FILE) if File.file?(NuzlockeSoulLink::RELAY_URL_FILE)
  default_cfg = !NuzlockeSoulLink::DEFAULT_RELAY_URL.include?("REPLACE-ME")
  t.log("DEFAULT_RELAY_URL configured: #{default_cfg}")
  File.write(NuzlockeSoulLink::RELAY_URL_FILE, "https://example.workers.dev/\n")
  t.assert_eq("override file wins and trailing slash trimmed", "https://example.workers.dev", r.base_url)
  t.assert("configured? true with override", r.configured? == true)
  File.delete(NuzlockeSoulLink::RELAY_URL_FILE)
  t.assert_eq("falls back to the default", NuzlockeSoulLink::DEFAULT_RELAY_URL.sub(/\/+\z/, ""), r.base_url)
end

NuzlockeTestHarness.suite("Soul Link: mode default OFF and setting preserved by Reset Run") do |t|
  initializeNuzlockeMode
  t.assert("Soul Link OFF by default", $game_switches[SWITCH_NUZLOCKE_SOUL_LINK] == false)
  t.assert("preserved across reset", NUZLOCKE_RESET_PRESERVED_SWITCH_SYMS.include?(:SWITCH_NUZLOCKE_SOUL_LINK))
end

end # defined?(NuzlockeTestHarness)
