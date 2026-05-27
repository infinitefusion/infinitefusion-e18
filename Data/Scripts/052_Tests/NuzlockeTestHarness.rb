# Nuzlocke Test Harness (DEV ONLY)
# ---------------------------------
# A boot-time unit-test runner for the Nuzlocke Mode logic. It runs ONLY when a
# flag file ("nuzlocke_run_tests.flag") exists in the game directory, so normal
# play is completely unaffected. When flagged, it runs assertions against the
# REAL loaded code (real constants, real GameData, real Pokemon/fusion helpers),
# writes PASS/FAIL results to "nuzlocke_test_results.log", deletes the flag
# (one-shot), and hard-exits the process so an automated runner can read the log.
#
# It NEVER touches real save files: every test swaps in throwaway in-memory
# Game_Switches / Game_Variables / mock globals and restores the originals after.
#
# Hook: we alias Game.set_up_system (003_Game processing/001_StartGame.rb), which
# runs right before the title screen and AFTER Game.initialize -> GameData.load_all,
# so all data and helpers are available.

module NuzlockeTestHarness
  FLAG_PATH = "nuzlocke_run_tests.flag"
  LOG_PATH  = "nuzlocke_test_results.log"

  module_function

  def run_if_flagged
    return unless File.file?(FLAG_PATH)
    begin
      File.delete(FLAG_PATH) rescue nil   # one-shot: never auto-run twice
      run_all
    rescue => e
      write_crash(e)
    end
    # Hard stop so the autonomous runner can read the log without the title
    # screen blocking on input.
    exit!(0)
  end

  # ---- logging -------------------------------------------------------------
  def log_line(s)
    @log ||= []
    @log << s.to_s
  end

  def assert(name, cond)
    @pass ||= 0; @fail ||= 0
    if cond
      @pass += 1
      log_line("  [OK]   #{name}")
    else
      @fail += 1
      log_line("  [FAIL] #{name}")
    end
  end

  # Assert with an explanatory actual/expected line for easier debugging.
  def assert_eq(name, expected, actual)
    ok = (expected == actual)
    assert("#{name} (expected=#{expected.inspect} actual=#{actual.inspect})", ok)
  end

  def section(title)
    log_line("")
    log_line("-- #{title} --")
  end

  def flush_log
    body = (@log || []).join("\n") + "\n"
    File.open(LOG_PATH, "w") { |f| f.write(body) }
  rescue => e
    # Last resort: try the errorlog-style echo so something surfaces.
    echoln("[NuzlockeTestHarness] could not write log: #{e.message}") if defined?(echoln)
  end

  def write_crash(e)
    log_line("")
    log_line("!! HARNESS CRASH: #{e.class}: #{e.message}")
    (e.backtrace || []).first(12).each { |b| log_line("    #{b}") }
    flush_log
  end

  # ---- runner --------------------------------------------------------------
  def run_all
    @log = []; @pass = 0; @fail = 0
    log_line("=== Nuzlocke Test Harness ===")
    log_line("time: #{Time.now}")

    safe("constants")            { test_constants }
    safe("reset preserve")       { test_reset_preserve_restore }
    safe("build_survivor")       { test_build_survivor }
    safe("area key")             { test_area_key }
    safe("player_has_balls?")    { test_player_has_balls }
    safe("gating helpers")       { test_gating_helpers }

    log_line("")
    log_line("=== SUMMARY: #{@pass} passed, #{@fail} failed ===")
    flush_log
  end

  # Run one test block, catching errors so one failure can't abort the suite.
  def safe(label)
    yield
  rescue => e
    @fail ||= 0; @fail += 1
    log_line("  [ERROR] #{label}: #{e.class}: #{e.message}")
    log_line("      #{(e.backtrace || []).first}")
  end

  # ---- tests ---------------------------------------------------------------

  def test_constants
    section("Constants resolve and are integers")
    switch_syms = [
      :SWITCH_NUZLOCKE_MODE, :SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA,
      :SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, :SWITCH_NUZLOCKE_FORCE_NICKNAMES,
      :SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, :SWITCH_NUZLOCKE_RESET_ENABLED,
      :SWITCH_RANDOM_WILD, :SWITCH_RANDOM_TRAINERS, :SWITCH_RANDOM_ITEMS, :SWITCH_RANDOM_TMS
    ]
    switch_syms.each do |sym|
      assert("#{sym} defined", Object.const_defined?(sym))
      assert("#{sym} is Integer", Object.const_defined?(sym) && Object.const_get(sym).is_a?(Integer))
    end
    var_syms = [:VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, :VAR_RANDOMIZER_WILD_POKE_BST]
    var_syms.each do |sym|
      assert("#{sym} defined", Object.const_defined?(sym))
    end
  end

  def test_reset_preserve_restore
    section("Reset Run preserves Nuzlocke + randomizer settings across Game.load clobber")
    orig_sw = $game_switches; orig_va = $game_variables
    begin
      $game_switches = Game_Switches.new
      $game_variables = Game_Variables.new
      # The player's chosen settings before a reset:
      $game_switches[SWITCH_NUZLOCKE_MODE] = true
      $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] = true
      $game_switches[SWITCH_RANDOM_WILD] = true
      $game_variables[VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE] = 2

      preserved_switches, preserved_vars = nuzlocke_reset_capture_settings

      # Simulate Game.load(snapshot) clobbering everything to a stale/blank state:
      $game_switches = Game_Switches.new
      $game_variables = Game_Variables.new
      assert("perma-death OFF immediately after clobber (proves the bug exists without restore)",
             $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] == false)
      assert("random-wild OFF after clobber",
             $game_switches[SWITCH_RANDOM_WILD] == false)

      # Apply the fix:
      nuzlocke_reset_restore_settings(preserved_switches, preserved_vars)

      assert("perma-death restored ON", $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] == true)
      assert("nuzlocke MODE restored ON", $game_switches[SWITCH_NUZLOCKE_MODE] == true)
      assert("random-wild restored ON", $game_switches[SWITCH_RANDOM_WILD] == true)
      assert_eq("fused perma-death var restored", 2, $game_variables[VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE])
    ensure
      $game_switches = orig_sw; $game_variables = orig_va
    end
  end

  def test_build_survivor
    section("Fusion half-selection logic (what build_survivor uses to pick the survivor)")
    # NOTE: we can't construct a Pokemon object this early in boot (calc_stats
    # needs game state), so we test the DECISION logic build_survivor relies on
    # -- getBasePokemonID / isFusion -- directly. Stat/IV/EXP preservation is
    # verified in-game via the debug path. :B16H19 = body Pidgey(16) head Rattata(19).
    fusion_id = GameData::Species.get(:B16H19).id_number
    pidgey_id = GameData::Species.get(:PIDGEY).id_number
    log_line("    fusion_id=#{fusion_id} pidgey_id=#{pidgey_id}")

    assert("isFusion(:B16H19) true", (isFusion(fusion_id) rescue false) == true)
    assert("isFusion(:PIDGEY) false", (isFusion(pidgey_id) rescue true) == false)
    # build_survivor(fused, keep_body=true) -> getBasePokemonID(id, true) -> BODY species
    assert_eq("keep_body=true selects BODY species (16)", 16, getBasePokemonID(fusion_id, true))
    # build_survivor(fused, keep_body=false) -> getBasePokemonID(id, false) -> HEAD species
    assert_eq("keep_body=false selects HEAD species (19)", 19, getBasePokemonID(fusion_id, false))
    # A non-fusion resolves to itself (build_survivor would never run on it, but verify the helper)
    assert_eq("non-fusion getBasePokemonID returns self", pidgey_id, getBasePokemonID(pidgey_id, true))
  end

  def test_area_key
    section("current_area_key returns name, falls back to map_id when blank/nil")
    fake = Struct.new(:name, :map_id)
    orig = $game_map
    begin
      $game_map = fake.new("Route 1", 5)
      assert_eq("named area", "Route 1", NuzlockeCaptureRules.current_area_key)
      $game_map = fake.new("", 5)
      assert_eq("blank name -> map_id string", "5", NuzlockeCaptureRules.current_area_key)
      $game_map = fake.new(nil, 7)
      assert_eq("nil name -> map_id string", "7", NuzlockeCaptureRules.current_area_key)
    ensure
      $game_map = orig
    end
  end

  def test_player_has_balls
    section("player_has_balls? detects Poke Balls in the bag")
    fakebag = Struct.new(:pockets)
    orig = $PokemonBag
    begin
      $PokemonBag = fakebag.new([[[:POTION, 1]], [[:POKEBALL, 5]]])
      assert("true when a Poke Ball is present", NuzlockeCaptureRules.player_has_balls? == true)
      $PokemonBag = fakebag.new([[[:POTION, 1]], [[:ANTIDOTE, 2]]])
      assert("false when only non-balls present", NuzlockeCaptureRules.player_has_balls? == false)
      $PokemonBag = nil
      assert("false when bag is nil", NuzlockeCaptureRules.player_has_balls? == false)
    ensure
      $PokemonBag = orig
    end
  end

  def test_gating_helpers
    section("Switch-gated helpers respect SWITCH_NUZLOCKE_MODE")
    orig = $game_switches
    begin
      $game_switches = Game_Switches.new
      # Mode OFF: everything inert regardless of sub-switches.
      $game_switches[SWITCH_NUZLOCKE_MODE] = false
      $game_switches[SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED] = false
      $game_switches[SWITCH_NUZLOCKE_FORCE_NICKNAMES] = true
      assert("battle_items_forbidden? false when mode OFF", NuzlockeCaptureRules.battle_items_forbidden? == false)
      assert("force_nicknames_active? false when mode OFF", NuzlockeCaptureRules.force_nicknames_active? == false)

      # Mode ON:
      $game_switches[SWITCH_NUZLOCKE_MODE] = true
      assert("battle_items_forbidden? true (items not allowed)", NuzlockeCaptureRules.battle_items_forbidden? == true)
      $game_switches[SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED] = true
      assert("battle_items_forbidden? false (items allowed)", NuzlockeCaptureRules.battle_items_forbidden? == false)
      assert("force_nicknames_active? true when mode ON + switch ON", NuzlockeCaptureRules.force_nicknames_active? == true)
      $game_switches[SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA] = true
      assert("one_catch_per_area_active? true", NuzlockeCaptureRules.one_catch_per_area_active? == true)
    ensure
      $game_switches = orig
    end
  end
end

#===============================================================================
# Install the boot hook: run the harness (only if flagged) right after the
# engine finishes Game.set_up_system. Guarded so it installs at most once.
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
