# Nuzlocke Test Harness (DEV ONLY)
# ---------------------------------
# A boot-time unit/scenario test runner for Nuzlocke Mode. Runs ONLY when a flag
# file ("nuzlocke_run_tests.flag") exists in the game directory, so normal play
# is unaffected. When flagged it: sets up minimal globals + UI stubs, runs every
# registered suite against the REAL loaded code (real GameData, real Pokemon and
# fusion helpers), writes PASS/FAIL to "nuzlocke_test_results.log", deletes the
# flag (one-shot), and hard-exits so an automated runner can read the log.
#
# NEVER touches real saves: globals are throwaway in-memory mocks, UI calls
# (pbMessage etc.) are stubbed to capture text, and we exit! before the game
# proceeds, so the stubs never affect real play.
#
# Hook: aliases Game.set_up_system (runs right before the title screen, after
# Game.initialize -> GameData.load_all, so all data/helpers exist).
#
# EXTENDING: other files in 052_Tests can register suites:
#     NuzlockeTestHarness.suite("My area") do |t|
#       t.reset_state             # (already called before each suite)
#       t.set_switch(SWITCH_NUZLOCKE_MODE, true)
#       t.assert("desc", cond)
#       t.assert_eq("desc", expected, actual)
#       pk = t.make_pokemon(:PIKACHU, 10, fainted: true)
#     end
# Helpers available on `t`: reset_state, set_switch, set_var, give_ball,
# empty_bag, set_party, set_area, make_pokemon, captured_msgs, log, assert,
# assert_eq, refute.

#-------------------------------------------------------------------------------
# Lightweight test doubles (only ever used by the harness).
#-------------------------------------------------------------------------------
# Bag double: exposes pockets for player_has_balls? and records pbStoreItem calls
# so we can assert held items are returned to the bag on perma-death.
class NuzlockeTestBag
  attr_accessor :pockets, :stored_items
  def initialize(pockets = []); @pockets = pockets; @stored_items = []; end
  def pbStoreItem(item, _qty = 1); @stored_items << item; true; end
end

# need_refresh accessor so pbSet ($game_map.need_refresh = true) works on the double.
NuzlockeTestMap = Struct.new(:name, :map_id) do
  attr_accessor :need_refresh
end unless defined?(NuzlockeTestMap)

class NuzlockeTestPokedex
  def set_seen(_s); end
  def set_owned(_s); end
  def register(_p); end
end

class NuzlockeTestStorage
  attr_reader :stored
  def initialize; @stored = []; end
  def pbStoreCaught(p); @stored << p; -1; end
  def full?; false; end
end

# Fallback PokemonGlobal stand-in (only used if the real PokemonGlobalMetadata
# can't be constructed at boot). Just needs the attr we rely on.
class NuzlockeTestGlobal
  attr_accessor :nuzlocke_caught_areas
end

# Battle-scene double: captures messages routed through pbDisplay.
class NuzlockeTestScene
  def pbDisplay(msg); ($nuzlocke_test_msgs ||= []) << msg.to_s; nil; end
  def pbDisplayPaused(msg); pbDisplay(msg); end
end

# Battle double for hooks that read @caughtPokemon / @canLose.
NuzlockeTestBattle = Struct.new(:caughtPokemon, :canLose) unless defined?(NuzlockeTestBattle)

class NuzlockeTestTrainer
  attr_accessor :party
  def initialize; @party = []; @pokedex = NuzlockeTestPokedex.new; end
  def pokedex; @pokedex; end
  def party_full?; @party.length >= 6; end
  def save_slot; "TEST"; end
end

module NuzlockeTestHarness
  FLAG_PATH = "nuzlocke_run_tests.flag"
  LOG_PATH  = "nuzlocke_test_results.log"
  # Real-save verification: flag file contains a save slot name (e.g. "File B").
  # Loads that REAL save's values into the live globals and runs the actual
  # functions against the real $Trainer/bag/$PokemonGlobal/$PokemonStorage --
  # NOT mocks. Read-only + in-memory only; never calls Game.save, so the save
  # file on disk is never modified, and exit! follows immediately.
  REALSAVE_FLAG = "nuzlocke_realsave_check.flag"
  REALSAVE_LOG  = "nuzlocke_realsave_results.log"

  @suites = []
  def self.suites; @suites; end
  def self.suite(name, &blk); @suites << [name, blk]; end

  module_function

  #-- entry point (hooked from Game.set_up_system) ---------------------------
  def run_if_flagged
    if File.file?(REALSAVE_FLAG)
      slot = (File.read(REALSAVE_FLAG).strip rescue "")
      File.delete(REALSAVE_FLAG) rescue nil
      @log_path = REALSAVE_LOG
      begin
        run_realsave_check(slot)
      rescue => e
        write_crash(e)
      end
      exit!(0)
    end
    return unless File.file?(FLAG_PATH)
    File.delete(FLAG_PATH) rescue nil   # one-shot
    begin
      run_all
    rescue => e
      write_crash(e)
    end
    exit!(0)   # hard stop so the runner can read the log
  end

  #-- runner -----------------------------------------------------------------
  def run_all
    @log = []; @pass = 0; @fail = 0
    setup_test_env
    log_line("=== Nuzlocke Test Harness ===")
    log_line("time: #{Time.now}")
    log_line("suites: #{NuzlockeTestHarness.suites.length}")
    NuzlockeTestHarness.suites.each do |name, blk|
      section(name)
      begin
        reset_state
        blk.call(self)
      rescue => e
        @fail += 1
        log_line("  [ERROR] #{e.class}: #{e.message}")
        log_line("      #{(e.backtrace || []).first}")
      end
    end
    log_line("")
    log_line("=== SUMMARY: #{@pass} passed, #{@fail} failed ===")
    flush_log
  end

  #-- environment setup ------------------------------------------------------
  def setup_test_env
    $game_switches  ||= Game_Switches.new
    $game_variables ||= Game_Variables.new
    $game_temp      ||= (Game_Temp.new rescue nil)
    $game_system    ||= (Game_System.new rescue nil)
    stub_ui
    stub_engine
  end

  # Stub engine entry points that the enforcement seams call out to, so we can
  # observe behavior without driving real UI or the real randomizer. Only done
  # when flagged; the harness always exit!s, so real play never sees these.
  def stub_engine
    $nuzlocke_test_nick_prompted = false
    $nuzlocke_test_shuffles = []
    # Force-nickname seam: record that the name-entry screen was opened.
    Object.send(:define_method, :pbEnterPokemonName) { |*_a| $nuzlocke_test_nick_prompted = true; "TESTNICK" }
    # Default the optional confirm to "no" so non-forced paths never name.
    Object.send(:define_method, :pbConfirmMessage) { |*_a| false }
    # Reshuffle dispatch seam: record which shuffles ran.
    Object.send(:define_method, :pbShuffleItems) { |*_a| ($nuzlocke_test_shuffles ||= []) << :items }
    Object.send(:define_method, :pbShuffleTMs)   { |*_a| ($nuzlocke_test_shuffles ||= []) << :tms }
    Kernel.define_singleton_method(:pbShuffleDex)      { |*_a| ($nuzlocke_test_shuffles ||= []) << :dex }
    Kernel.define_singleton_method(:pbShuffleTrainers) { |*_a| ($nuzlocke_test_shuffles ||= []) << :trainers }
    # triggerCanUseInBattle seam: make the underlying original return a sentinel
    # so a "pass-through" (allowed) is distinguishable from a block (false).
    if defined?(ItemHandlers) && ItemHandlers.respond_to?(:nuzlocke_orig_triggerCanUseInBattle)
      ItemHandlers.singleton_class.send(:define_method, :nuzlocke_orig_triggerCanUseInBattle) { |*_a| :ORIG }
    end
  end

  # Replace UI/flow calls with capturing no-ops. Safe because the harness always
  # exit!s and never returns to real gameplay. Done at runtime (only when
  # flagged), so normal play never sees these stubs.
  def stub_ui
    $nuzlocke_test_msgs = []
    Object.send(:define_method, :pbMessage)        { |*a| ($nuzlocke_test_msgs ||= []) << (a[0]).to_s; nil }
    Object.send(:define_method, :pbMessageNoSound) { |*a| ($nuzlocke_test_msgs ||= []) << (a[0]).to_s; nil }
    $nuzlocke_test_startover = false
    # blackout guard calls Kernel.pbStartOver; capture instead of warping.
    Kernel.define_singleton_method(:pbStartOver) { |*_a| $nuzlocke_test_startover = true }
    Object.send(:define_method, :pbStartOver)     { |*_a| $nuzlocke_test_startover = true }
  end

  # Fresh, isolated globals before every suite so suites can't bleed into each other.
  def reset_state
    $game_switches  = Game_Switches.new
    $game_variables = Game_Variables.new
    $PokemonBag     = NuzlockeTestBag.new([])
    $Trainer        = NuzlockeTestTrainer.new
    $PokemonStorage = NuzlockeTestStorage.new
    $game_map       = NuzlockeTestMap.new("Test Area", 1)
    # One-catch registry lives on $PokemonGlobal. Use the real class so we also
    # exercise the nuzlocke_caught_areas accessor we added; fall back to a stub
    # if it can't be constructed this early in boot.
    $PokemonGlobal  = (PokemonGlobalMetadata.new rescue nil)
    $PokemonGlobal  = NuzlockeTestGlobal.new unless $PokemonGlobal.respond_to?(:nuzlocke_caught_areas)
    $nuzlocke_test_msgs = []
    $nuzlocke_test_startover = false
    $nuzlocke_test_nick_prompted = false
    $nuzlocke_test_shuffles = []
    $nuzlocke_current_is_first_encounter = false
  end

  #-- helpers exposed to suites ----------------------------------------------
  def set_switch(id, v); $game_switches[id] = v; end
  def set_var(id, v);    $game_variables[id] = v; end
  def give_ball;  $PokemonBag = NuzlockeTestBag.new([[[:POKEBALL, 5]]]); end
  def empty_bag;  $PokemonBag = NuzlockeTestBag.new([]); end
  def set_party(arr); $Trainer.party = arr; end
  def set_area(name, map_id = 1); $game_map = NuzlockeTestMap.new(name, map_id); end
  def captured_msgs; $nuzlocke_test_msgs || []; end
  def startover_triggered?; $nuzlocke_test_startover == true; end

  # Build a real Pokemon. fainted:true sets HP to 0 via the ivar (so fainted?
  # returns true) without needing a setter.
  def make_pokemon(species, level = 10, fainted: false, held: nil)
    pk = Pokemon.new(species, level, nil)
    pk.instance_variable_set(:@hp, 0) if fainted
    pk.item = held if held
    pk
  end

  # Build a real egg (egg? is `@steps_to_hatch > 0`).
  def make_egg(species = :PIKACHU, level = 5)
    pk = Pokemon.new(species, level, nil)
    pk.instance_variable_set(:@steps_to_hatch, 5)
    pk
  end

  # Test doubles + seam observers.
  def fake_scene; NuzlockeTestScene.new; end
  def fake_battle(caught = [], can_lose = false); NuzlockeTestBattle.new(caught, can_lose); end
  def nick_prompted?; $nuzlocke_test_nick_prompted == true; end
  def shuffles; $nuzlocke_test_shuffles || []; end
  def bag_stored_items; ($PokemonBag && $PokemonBag.respond_to?(:stored_items)) ? $PokemonBag.stored_items : []; end

  #-- assertions / logging ---------------------------------------------------
  def assert(name, cond)
    if cond
      @pass += 1; log_line("  [OK]   #{name}")
    else
      @fail += 1; log_line("  [FAIL] #{name}")
    end
  end

  def assert_eq(name, expected, actual)
    assert("#{name} (expected=#{expected.inspect} actual=#{actual.inspect})", expected == actual)
  end

  def refute(name, cond); assert(name, !cond); end

  def log(s); log_line("    #{s}"); end
  def log_line(s); (@log ||= []) << s.to_s; end
  def section(t); log_line(""); log_line("-- #{t} --"); end

  def flush_log
    File.open(@log_path || LOG_PATH, "w") { |f| f.write((@log || []).join("\n") + "\n") }
  rescue => e
    echoln("[NuzlockeTestHarness] log write failed: #{e.message}") if defined?(echoln)
  end

  # Count Poke Balls in the REAL bag independently of player_has_balls?, so we can
  # cross-check that helper against ground truth.
  def real_ball_count
    n = 0
    pockets = ($PokemonBag.pockets rescue nil)
    return 0 if !pockets
    pockets.each do |pocket|
      next if !pocket
      pocket.each do |entry|
        next if !entry
        item = (GameData::Item.get(entry[0]) rescue nil)
        n += 1 if item && (item.is_poke_ball? rescue false)
      end
    end
    n
  end

  # Load a REAL save's values into the live globals and run the actual code paths
  # against them. Read-only + in-memory; never persists (no Game.save), exit! after.
  def run_realsave_check(slot)
    @log = []; @pass = 0; @fail = 0
    log_line("=== Nuzlocke REAL-SAVE Check ===")
    log_line("time: #{Time.now}")
    log_line("slot: #{slot.inspect}")
    stub_ui   # capture pbMessage/pbStartOver so nothing tries to render

    path = File.join(SaveData::SAVE_DIR, "#{slot}.rxdata")
    unless File.file?(path)
      log_line("!! SAVE NOT FOUND: #{path}")
      flush_log; return
    end
    data = SaveData.read_from_file(path)
    SaveData.load_all_values(data)   # loads $Trainer/bag/global/storage/switches/vars (no scene/map setup)
    log_line("loaded real save: trainer=#{($Trainer.name rescue '?')} party=#{($Trainer.party.length rescue '?')} bag=#{($PokemonBag ? 'yes' : 'nil')}")

    # 1. player_has_balls? vs an independent scan of the real bag.
    section("player_has_balls? vs real bag")
    balls = real_ball_count
    log_line("independent Poke Ball count in real bag: #{balls}")
    assert("player_has_balls? matches the real bag (#{balls > 0})",
           (NuzlockeCaptureRules.player_has_balls? == (balls > 0)))

    # 2. owned_species_set against the real party + storage.
    section("owned_species_set on real party + storage")
    owned = NuzlockeCaptureRules.owned_species_set
    party_sp = ($Trainer.party.compact.map { |p| p.species } rescue [])
    log_line("party species: #{party_sp.inspect}")
    log_line("owned base-species count (party+storage, fusions decomposed): #{owned.keys.length}")
    has_fusion = ($Trainer.party.compact.any? { |p| isFusion(p.species_data.id_number) } rescue false)
    log_line("party contains a fusion: #{has_fusion}")
    assert("ownership scan non-empty when party non-empty",
           $Trainer.party.compact.empty? || !owned.empty?)

    # 3. build_survivor fidelity on a REAL fusion, if the save has one.
    section("build_survivor on a real fusion")
    fusion = ($Trainer.party.compact.find { |p| isFusion(p.species_data.id_number) } rescue nil)
    if fusion
      log_line("real fusion: #{fusion.species} lv#{fusion.level} shiny=#{fusion.shiny?} item=#{fusion.item_id.inspect}")
      s = NuzlockeBattleRules.build_survivor(fusion, true)
      if s
        log_line("survivor: #{s.species} lv#{s.level} shiny=#{s.shiny?} item=#{s.item_id.inspect}")
        assert("survivor level == fusion level", s.level == fusion.level)
        assert("survivor IVs == fusion IVs", s.iv == fusion.iv)
        assert("survivor shiny matches fusion", s.shiny? == fusion.shiny?)
      else
        assert("build_survivor produced a survivor", false)
      end
    else
      log_line("no fusion in this save's party; build_survivor real check skipped")
    end

    # 4. REAL perma-death on the real party (in-memory only; disk never written).
    section("perma-death on the real party (in-memory)")
    $game_switches[SWITCH_NUZLOCKE_MODE] = true
    $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] = true
    ($PokemonBag.pbStoreItem(:POKEBALL) rescue nil)   # satisfy balls-first, in-memory
    victim = ($Trainer.party.compact.find { |p| !(isFusion(p.species_data.id_number)) } rescue nil)
    if victim
      vsp = victim.species; vitem = victim.item_id
      before = $Trainer.party.compact.length
      log_line("victim (unfused): #{vsp} item=#{vitem.inspect}; party before=#{before}")
      victim.instance_variable_set(:@hp, 0)            # faint in-memory
      NuzlockeBattleRules.process_party_after_battle
      after = $Trainer.party.compact.length
      log_line("party after: #{$Trainer.party.compact.map { |p| p.species }.inspect} (size #{after})")
      assert("real fainted unfused victim removed from real party", after == before - 1)
      if vitem
        assert("victim's held item returned to the REAL bag",
               ($PokemonBag.pbHasItem?(vitem) rescue false) == true)
      else
        log_line("victim held no item; item-return assertion skipped")
      end
    else
      log_line("no unfused party member to test perma-death; skipped")
    end

    log_line("")
    log_line("=== REAL-SAVE SUMMARY: #{@pass} passed, #{@fail} failed ===")
    log_line("(disk save was NOT written; this ran in memory only)")
    flush_log
  end

  def write_crash(e)
    log_line(""); log_line("!! HARNESS CRASH: #{e.class}: #{e.message}")
    (e.backtrace || []).first(12).each { |b| log_line("    #{b}") }
    flush_log
  end
end

#===============================================================================
# Core suites (foundational coverage). Domain/scenario suites live in sibling
# files and register themselves the same way.
#===============================================================================

NuzlockeTestHarness.suite("Constants resolve and are integers") do |t|
  [:SWITCH_NUZLOCKE_MODE, :SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA,
   :SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, :SWITCH_NUZLOCKE_FORCE_NICKNAMES,
   :SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, :SWITCH_NUZLOCKE_RESET_ENABLED,
   :SWITCH_RANDOM_WILD, :SWITCH_RANDOM_TRAINERS, :SWITCH_RANDOM_ITEMS, :SWITCH_RANDOM_TMS].each do |sym|
    t.assert("#{sym} is a defined Integer",
             Object.const_defined?(sym) && Object.const_get(sym).is_a?(Integer))
  end
  [:VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, :VAR_RANDOMIZER_WILD_POKE_BST].each do |sym|
    t.assert("#{sym} defined", Object.const_defined?(sym))
  end
end

NuzlockeTestHarness.suite("Reset Run preserves settings across Game.load clobber") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_switch(SWITCH_RANDOM_WILD, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 2)
  preserved_switches, preserved_vars = nuzlocke_reset_capture_settings
  # Simulate Game.load clobbering everything to blank/stale:
  $game_switches = Game_Switches.new
  $game_variables = Game_Variables.new
  t.assert("perma-death OFF right after clobber (bug exists without restore)",
           $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] == false)
  nuzlocke_reset_restore_settings(preserved_switches, preserved_vars)
  t.assert("perma-death restored ON", $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] == true)
  t.assert("nuzlocke MODE restored ON", $game_switches[SWITCH_NUZLOCKE_MODE] == true)
  t.assert("random-wild restored ON", $game_switches[SWITCH_RANDOM_WILD] == true)
  t.assert_eq("fused perma-death var restored", 2, $game_variables[VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE])
end

NuzlockeTestHarness.suite("Fusion half-selection (build_survivor's decision)") do |t|
  fusion_id = GameData::Species.get(:B16H19).id_number   # body Pidgey(16), head Rattata(19)
  pidgey_id = GameData::Species.get(:PIDGEY).id_number
  t.assert("isFusion(:B16H19) true",  (isFusion(fusion_id) rescue false) == true)
  t.assert("isFusion(:PIDGEY) false", (isFusion(pidgey_id) rescue true) == false)
  t.assert_eq("keep_body=true selects BODY (16)", 16, getBasePokemonID(fusion_id, true))
  t.assert_eq("keep_body=false selects HEAD (19)", 19, getBasePokemonID(fusion_id, false))
  t.assert_eq("non-fusion resolves to self", pidgey_id, getBasePokemonID(pidgey_id, true))
end

NuzlockeTestHarness.suite("current_area_key name / blank / nil fallback") do |t|
  t.set_area("Route 1", 5)
  t.assert_eq("named area", "Route 1", NuzlockeCaptureRules.current_area_key)
  t.set_area("", 5)
  t.assert_eq("blank -> map_id", "5", NuzlockeCaptureRules.current_area_key)
  $game_map = NuzlockeTestMap.new(nil, 7)
  t.assert_eq("nil -> map_id", "7", NuzlockeCaptureRules.current_area_key)
end

NuzlockeTestHarness.suite("player_has_balls? bag detection") do |t|
  t.give_ball
  t.assert("true with a Poke Ball", NuzlockeCaptureRules.player_has_balls? == true)
  $PokemonBag = NuzlockeTestBag.new([[[:POTION, 1]], [[:ANTIDOTE, 2]]])
  t.assert("false with only non-balls", NuzlockeCaptureRules.player_has_balls? == false)
  $PokemonBag = nil
  t.assert("false with nil bag", NuzlockeCaptureRules.player_has_balls? == false)
end

NuzlockeTestHarness.suite("Switch-gated helpers respect MODE") do |t|
  t.set_switch(SWITCH_NUZLOCKE_MODE, false)
  t.set_switch(SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, false)
  t.set_switch(SWITCH_NUZLOCKE_FORCE_NICKNAMES, true)
  t.assert("battle_items_forbidden? false when MODE off", NuzlockeCaptureRules.battle_items_forbidden? == false)
  t.assert("force_nicknames_active? false when MODE off", NuzlockeCaptureRules.force_nicknames_active? == false)
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.assert("battle_items_forbidden? true (items not allowed)", NuzlockeCaptureRules.battle_items_forbidden? == true)
  t.set_switch(SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, true)
  t.assert("battle_items_forbidden? false (items allowed)", NuzlockeCaptureRules.battle_items_forbidden? == false)
  t.assert("force_nicknames_active? true (MODE on + switch on)", NuzlockeCaptureRules.force_nicknames_active? == true)
end

#===============================================================================
# Real-party perma-death scenario (proves Pokemon construction + the actual
# post-battle processing run end to end).
#===============================================================================
NuzlockeTestHarness.suite("Battle perma-death: real party rebuild") do |t|
  t.give_ball                                   # balls-first gate satisfied
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  t.set_var(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 1)   # Head dies -> keep BODY

  healthy = t.make_pokemon(:PIKACHU, 12)
  dead_unfused = t.make_pokemon(:RATTATA, 10, fainted: true)
  dead_fusion  = t.make_pokemon(:B16H19, 20, fainted: true)  # body Pidgey(16) / head Rattata(19)
  t.set_party([healthy, dead_unfused, dead_fusion])

  NuzlockeBattleRules.process_party_after_battle
  party = $Trainer.party

  t.assert("healthy Pikachu survived", party.any? { |m| m && m.species == :PIKACHU })
  t.assert("fainted UNFUSED Rattata permanently removed",
           party.none? { |m| m && m.species == :RATTATA && !(isFusion(m.species_data.id_number) rescue false) })
  t.assert("fainted FUSION removed from party",
           party.none? { |m| m && (isFusion(m.species_data.id_number) rescue false) })
  surviving_half = party.find { |m| m && m.species_data.id_number == 16 }
  t.assert("surviving BODY half (species 16) returned unfused", !surviving_half.nil?)
  t.assert_eq("final party size = healthy + surviving half", 2, party.compact.length)
  t.log("post-battle party: #{party.compact.map { |m| m.species }.inspect}")
end

NuzlockeTestHarness.suite("Battle perma-death OFF before balls (balls-first gate)") do |t|
  t.empty_bag                                   # no balls yet
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, true)
  dead = t.make_pokemon(:RATTATA, 6, fainted: true)
  t.set_party([dead])
  NuzlockeBattleRules.process_party_after_battle
  t.assert("fainted mon NOT removed (no balls yet = perma-death inert)",
           $Trainer.party.any? { |m| m && m.species == :RATTATA })
end

NuzlockeTestHarness.suite("One-catch-per-area registry across areas") do |t|
  t.give_ball
  t.set_switch(SWITCH_NUZLOCKE_MODE, true)
  t.set_switch(SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA, true)
  t.set_area("Route 1", 10)
  t.assert("Route 1 not blocked initially", NuzlockeCaptureRules.should_block_catch? == false)
  NuzlockeCaptureRules.mark_current_area_used
  t.assert("Route 1 blocked after a catch", NuzlockeCaptureRules.should_block_catch? == true)
  t.set_area("Route 2", 11)
  t.assert("Route 2 still catchable (different area)", NuzlockeCaptureRules.should_block_catch? == false)
  t.set_area("Route 1", 10)
  t.assert("Route 1 still blocked on return", NuzlockeCaptureRules.should_block_catch? == true)
  t.empty_bag
  t.assert("Route 1 NOT blocked once balls are gone (balls-first)", NuzlockeCaptureRules.should_block_catch? == false)
end

#===============================================================================
# Install the boot hook (guarded so it installs at most once).
#===============================================================================
module Game
  class << self
    unless private_method_defined?(:nuzlocke_orig_set_up_system) ||
           method_defined?(:nuzlocke_orig_set_up_system)
      alias_method :nuzlocke_orig_set_up_system, :set_up_system
      def set_up_system
        nuzlocke_orig_set_up_system
        NuzlockeTestHarness.run_if_flagged
      end
    end
  end
end
