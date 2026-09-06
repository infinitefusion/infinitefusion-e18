# Nuzlocke Reset Run
# ------------------
# Wipes the run back to starter selection while keeping the player's identity
# (name, gender/character, outfit and unlocks), the Nuzlocke + randomizer
# settings, the Soul Link pairing, and the save slot.
#
# HOW: the run is rebuilt from a genuine NEW GAME (SaveData new-game values),
# then the intro's end state is replayed by hand (the switches/variables the
# Intro map sets, minus the interactive parts we already know the answers to),
# and finally the game's own "skip to starter selection" common event is run --
# the same one the splicer-demo Skip (CTRL) uses. So the result is exactly the
# state a brand-new player is in when they skip the intro: pre-Pokedex, pre-
# starter, Oak's lab.
#
# WHY NOT A SAVED COPY OF THE PLAYER'S GAME: the first version stored a copy
# of the player's own save on the first step after the intro AND after the
# first manual save. If the first save happened after getting the Pokedex, the
# copy was of a post-Pokedex game, so a reset put the player back into a
# half-finished story (rival renamed, but Oak's lab already past starter
# selection). Rebuilding from new-game values has no timing dependency and
# works on every existing save.

#===============================================================================
# Availability
#===============================================================================
# Reset Run is available as soon as the intro is over. (During the intro the
# player hasn't chosen a name yet, and there is nothing to reset.)
def nuzlocke_reset_available?
  return false if !$game_switches || !$game_switches[SWITCH_NUZLOCKE_MODE]
  return false if $game_switches[SWITCH_DURING_INTRO]
  return false if !$Trainer
  return true
end

#===============================================================================
# Common event lookup by name (so reset doesn't break when upstream
# renumbers common events on update). Falls back to +fallback_id+ if given.
#===============================================================================
def find_common_event_id_by_name(name, fallback_id = nil)
  return fallback_id if !$data_common_events
  $data_common_events.each_with_index do |ev, i|
    next if ev.nil?
    evname = (ev.name.to_s.dup.force_encoding("UTF-8") rescue ev.name.to_s)
    return i if evname == name
  end
  return fallback_id
end

# Common events the intro / skip flow uses (looked up by name, id as fallback).
NUZLOCKE_CE_APPLY_RANDOMIZER = ["APPLY randomizer options", 28].freeze
NUZLOCKE_CE_SKIP_TO_STARTER  = ["les trucs du début du jeu", 29].freeze   # what "skip intro" runs after its Yes/No

#===============================================================================
# Settings preservation.
#
# These lists name the switches/vars that represent the player's chosen
# SETTINGS (not run progress) and must survive the new-game rebuild.
#===============================================================================
NUZLOCKE_RESET_PRESERVED_SWITCH_SYMS = [
  # --- Nuzlocke rule switches ---
  :SWITCH_NUZLOCKE_MODE, :SWITCH_NUZLOCKE_MODE_INTRO, :SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA,
  :SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED, :SWITCH_NUZLOCKE_FORCE_NICKNAMES,
  :SWITCH_NUZLOCKE_RESET_ENABLED, :SWITCH_NUZLOCKE_AT_LEAST_ONCE,
  :SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED, :SWITCH_NUZLOCKE_CAP_CANDY_ENABLED,
  :SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS, :SWITCH_NUZLOCKE_DUPES_CLAUSE,
  :SWITCH_NUZLOCKE_TRAINER_FLEE_ALLOWED, :SWITCH_NUZLOCKE_SHINY_CLAUSE,
  :SWITCH_NUZLOCKE_SET_BATTLE_STYLE, :SWITCH_NUZLOCKE_LEVEL_CAP,
  :SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE, :SWITCH_NUZLOCKE_SOUL_LINK,
  :SWITCH_NUZLOCKE_STARTER_REROLL, :SWITCH_NUZLOCKE_MEDKIT_ENABLED,
  # --- Randomizer configuration switches (define how the run randomizes) ---
  :SWITCH_RANDOMIZED_AT_LEAST_ONCE, :SWITCH_RANDOMIZED_MODE_INTRO,
  :SWITCH_RANDOM_WILD, :SWITCH_RANDOM_WILD_AREA, :SWITCH_RANDOM_WILD_TO_FUSION,
  :SWITCH_RANDOM_TRAINERS, :SWITCH_RANDOM_STARTERS, :SWITCH_RANDOM_STARTER_FIRST_STAGE,
  :SWITCH_RANDOM_ITEMS, :SWITCH_RANDOM_ITEMS_GENERAL, :SWITCH_RANDOM_FOUND_ITEMS,
  :SWITCH_RANDOM_ITEMS_DYNAMIC, :SWITCH_RANDOM_ITEMS_MAPPED, :SWITCH_RANDOM_TMS,
  :SWITCH_RANDOM_GIVEN_ITEMS, :SWITCH_RANDOM_GIVEN_TMS, :SWITCH_RANDOM_SHOP_ITEMS,
  :SWITCH_RANDOM_FOUND_TMS, :SWITCH_WILD_RANDOM_GLOBAL, :SWITCH_RANDOM_STATIC_ENCOUNTERS,
  :SWITCH_RANDOM_WILD_ONLY_CUSTOMS, :SWITCH_RANDOM_GYM_PERSIST_TEAMS,
  :SWITCH_GYM_RANDOM_EACH_BATTLE, :SWITCH_RANDOM_GYM_CUSTOMS, :SWITCH_RANDOMIZE_GYMS_SEPARATELY,
  :SWITCH_RANDOMIZED_GYM_TYPES, :SWITCH_RANDOM_GIFT_POKEMON, :SWITCH_RANDOM_HELD_ITEMS,
  :SWITCH_DEFINED_RIVAL_STARTER, :SWITCH_RANDOMIZED_WILD_POKEMON_TO_FUSIONS,
  :SWITCH_RANDOM_WILD_LEGENDARIES, :SWITCH_RANDOM_TRAINER_LEGENDARIES,
  :SWITCH_RANDOM_GYM_LEGENDARIES, :SWITCH_DONT_RANDOMIZE
].freeze

NUZLOCKE_RESET_PRESERVED_VAR_SYMS = [
  :VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE,
  :VAR_NUZLOCKE_CATCH_RULE_MODE,
  :VAR_NUZLOCKE_ENCOUNTER_SLOTS,
  :VAR_RANDOMIZER_WILD_POKE_BST
].freeze

# Capture {switch_id => value} for every preserved switch that is currently defined.
def nuzlocke_reset_capture_settings
  switches = {}
  NUZLOCKE_RESET_PRESERVED_SWITCH_SYMS.each do |sym|
    next if !Object.const_defined?(sym)
    id = Object.const_get(sym)
    switches[id] = $game_switches[id]
  end
  vars = {}
  NUZLOCKE_RESET_PRESERVED_VAR_SYMS.each do |sym|
    next if !Object.const_defined?(sym)
    id = Object.const_get(sym)
    vars[id] = $game_variables[id]
  end
  return [switches, vars]
end

# Re-apply preserved settings on top of the freshly-built game.
def nuzlocke_reset_restore_settings(switches, vars)
  switches.each { |id, val| $game_switches[id] = val } if switches
  vars.each { |id, val| $game_variables[id] = val } if vars
end

# Explicit progress wipe. The new-game rebuild already produces empty party/
# bag/storage/money; this is kept as a standalone helper (and safety net).
def nuzlocke_reset_wipe_progress
  $Trainer.party.clear if $Trainer && $Trainer.party
  $PokemonBag = PokemonBag.new if defined?(PokemonBag)
  $PokemonStorage = PokemonStorage.new if defined?(PokemonStorage)
  $Trainer.money = 0 if $Trainer && $Trainer.respond_to?(:money=)
end

#===============================================================================
# Re-run randomization shuffles based on currently-active switches
# Shape copied from RepairUtils.rb lines 66-72.
#===============================================================================
def nuzlocke_reset_reshuffle_randomizers
  if $game_switches[SWITCH_RANDOM_TRAINERS]
    Kernel.pbShuffleTrainers()
  end
  if $game_switches[SWITCH_RANDOM_WILD]
    range = pbGet(VAR_RANDOMIZER_WILD_POKE_BST)
    range = 25 if range.nil? || range == 0
    Kernel.pbShuffleDex(range, 1)
  end
  if $game_switches[SWITCH_RANDOM_ITEMS] && defined?(pbShuffleItems)
    pbShuffleItems()
  end
  if $game_switches[SWITCH_RANDOM_TMS] && defined?(pbShuffleTMs)
    pbShuffleTMs()
  end
end

#===============================================================================
# Identity preservation: everything about the PLAYER (not the run) that the
# intro would have asked for, plus cosmetics/unlocks that are account-level.
#===============================================================================
NUZLOCKE_RESET_PLAYER_IVARS = %i[
  @name @character_ID @trainer_type @skin_tone
  @clothes @hat @hat2 @hair @hair_color @hat_color @hat2_color @clothes_color
  @unlocked_clothes @unlocked_hats @unlocked_hairstyles @unlocked_card_backgrounds
  @dyed_hats @dyed_clothes @favorite_hat @favorite_hat2 @favorite_clothes
  @last_worn_outfit @last_worn_hat @last_worn_hat2 @card_background
  @new_game_plus_unlocked @save_slot @last_time_saved
].freeze

# Variables the Intro map fills from the player's answers.
NUZLOCKE_RESET_IDENTITY_VARS = [52, 84, 99].freeze   # 52 = VAR_TRAINER_GENDER, 84 = name, 99 = intro number

def nuzlocke_reset_capture_identity
  ivars = {}
  if $Trainer
    NUZLOCKE_RESET_PLAYER_IVARS.each do |iv|
      ivars[iv] = $Trainer.instance_variable_get(iv) if $Trainer.instance_variable_defined?(iv)
    end
  end
  vars = {}
  NUZLOCKE_RESET_IDENTITY_VARS.each { |id| vars[id] = $game_variables[id] } if $game_variables
  return { ivars: ivars, vars: vars }
end

def nuzlocke_reset_restore_identity(identity)
  return if !identity.is_a?(Hash) || !$Trainer
  ivars = identity[:ivars] || {}
  # Character (gender sprite/trainer type) first, the way the intro does it.
  char_id = ivars[:@character_ID]
  pbChangePlayer(char_id) if char_id.is_a?(Integer) && char_id >= 0 && defined?(pbChangePlayer)
  ivars.each { |iv, val| $Trainer.instance_variable_set(iv, val) }
  (identity[:vars] || {}).each { |id, val| $game_variables[id] = val } if $game_variables
  refreshPlayerOutfit if defined?(refreshPlayerOutfit)
rescue => e
  echoln("[NuzlockeReset] restore_identity: #{e.message}")
end

#===============================================================================
# Intro replay: the non-interactive state the Intro map (295) leaves behind.
# Interactive parts (mode choice, name, gender, randomizer menu) are replaced by
# the preserved settings + identity.
#===============================================================================
NUZLOCKE_INTRO_MAP_ID   = 295
NUZLOCKE_DEMO_MAP_ID    = 157   # splicer demo map; "skip intro" flips its event 1 to the skipped page
NUZLOCKE_INTRO_SWITCHES = [971, 909, 800, 799, 910, 668, 825, 108].freeze   # set ON at intro start

def nuzlocke_reset_apply_intro_state
  return if !$game_switches || !$game_variables
  $game_variables[199] = 0
  NUZLOCKE_INTRO_SWITCHES.each { |id| $game_switches[id] = true }
  # The intro seeds the item/TM randomization tables even when unused.
  pbShuffleItems if defined?(pbShuffleItems)
  pbShuffleTMs   if defined?(pbShuffleTMs)
  # Intro finished: its events flip to their inert self-switch pages.
  if $game_self_switches
    (1..4).each { |ev| $game_self_switches[[NUZLOCKE_INTRO_MAP_ID, ev, "A"]] = true }
    $game_self_switches[[NUZLOCKE_DEMO_MAP_ID, 1, "A"]] = true
  end
  $game_switches[SWITCH_DURING_INTRO] = false
  pbSet(VAR_CURRENT_GYM_TYPE, -1) if defined?(VAR_CURRENT_GYM_TYPE) && $game_switches[SWITCH_RANDOMIZED_MODE_INTRO]
end

#===============================================================================
# The heavy steps, split out so the harness can stub them.
#===============================================================================
def nuzlocke_reset_drop_global_spriteset(scene)
  return if !scene.instance_variable_defined?(:@spritesetGlobal)
  sg = scene.instance_variable_get(:@spritesetGlobal)
  (sg.dispose rescue nil) if sg
  scene.instance_variable_set(:@spritesetGlobal, nil)
end

# Rebuild every save value from its new-game default (bootup values such as
# $PokemonSystem / $game_system are untouched, exactly like New Game from the
# title screen) and start on the game's start map.
def nuzlocke_reset_fresh_game!
  SaveData.mark_values_as_unloaded
  Game.start_new
  initialize_alt_sprite_substitutions if defined?(initialize_alt_sprite_substitutions)
  # Nothing on the intro map may start running: we're replaying its outcome.
  if $game_map && $game_map.respond_to?(:events) && $game_map.events
    $game_map.events.each_value { |event| event.clear_starting if event.respond_to?(:clear_starting) }
  end
  $game_temp.common_event_id = 0 if $game_temp
end

# Apply the randomizer exactly like the end of the intro (common event 28),
# falling back to the direct shuffle calls if the event can't be found.
def nuzlocke_reset_apply_randomizer!
  id = find_common_event_id_by_name(*NUZLOCKE_CE_APPLY_RANDOMIZER)
  if id && $data_common_events && $data_common_events[id]
    pbCommonEvent(id)
  else
    nuzlocke_reset_reshuffle_randomizers
  end
end

# The game's own "skip to starter selection" routine: running shoes, rival
# naming, story switches, transfer to Oak's lab.
def nuzlocke_reset_skip_to_starter!
  clear_all_images if defined?(clear_all_images)
  id = find_common_event_id_by_name(*NUZLOCKE_CE_SKIP_TO_STARTER)
  if id && $data_common_events && $data_common_events[id]
    pbCommonEvent(id)
    return true
  end
  # Last resort: the full "skip intro" event (asks Skip? first, then runs 29).
  id = find_common_event_id_by_name("skip intro", 105)
  if id && $data_common_events && $data_common_events[id]
    pbCommonEvent(id)
    return true
  end
  echoln("[NuzlockeReset] skip-to-starter common event not found")
  pbMessage(_INTL("Your run has been reset. Head to Professor Oak's lab to pick your starter."))
  return false
end

#===============================================================================
# Public entry-point (pause menu, and the auto reset on wipe).
# +confirm+ false skips the "are you sure?" prompt (the wipe was the decision).
#===============================================================================
def nuzlocke_reset_run(confirm = true)
  if !nuzlocke_reset_available?
    pbMessage(_INTL("Reset Run isn't available right now."))
    return false
  end
  if confirm && !pbConfirmMessageSerious(_INTL("This will wipe ALL progress and start the run over from your starter. Your name, look and Nuzlocke settings stay. Continue?"))
    return false
  end

  pbMessage(_INTL("Resetting your run. This may take a minute...\\^"))

  # Capture what survives.
  identity                            = nuzlocke_reset_capture_identity
  preserved_switches, preserved_vars  = nuzlocke_reset_capture_settings
  soul_link_cfg = defined?(NuzlockeSoulLink) ? NuzlockeSoulLink.export_config : nil
  active_slot   = identity[:ivars][:@save_slot]

  # Hang onto the live Scene_Map. Game.start_new does `$scene = Scene_Map.new`;
  # a fresh Scene_Map has no spritesets until its main loop runs, and any
  # rendering in between (shuffle progress, messages) would crash. We restore
  # the live scene and rebuild its spritesets for the new map instead.
  original_scene = $scene

  if $game_map && $game_map.respond_to?(:events) && $game_map.events
    $game_map.events.each_value { |event| event.clear_starting if event.respond_to?(:clear_starting) }
  end
  $game_temp.common_event_id = 0 if $game_temp
  pbMapInterpreter&.clear
  pbMapInterpreter&.setup(nil, 0, 0)

  # 1. Genuine new game.
  nuzlocke_reset_fresh_game!

  # 2. Mode + settings (canonical Nuzlocke defaults, then the player's choices).
  initializeNuzlockeMode
  nuzlocke_reset_restore_settings(preserved_switches, preserved_vars)

  # 3. Who the player is.
  nuzlocke_reset_restore_identity(identity)
  $Trainer.save_slot = active_slot if active_slot && $Trainer.respond_to?(:save_slot=)

  # 4. What the intro leaves behind.
  nuzlocke_reset_apply_intro_state
  NuzlockeSoulLink.import_config(soul_link_cfg) if soul_link_cfg && defined?(NuzlockeSoulLink)

  # Reclaim the live scene and rebuild ALL its spritesets for the start map.
  # The global spriteset (player sprite + pictures) is normally kept for the
  # scene's whole life, and its Sprite_Player stays bound to the Game_Player
  # object it was created with. Game.start_new made a NEW $game_player, so the
  # old sprite would keep drawing the orphaned old player (naked, wrong map)
  # while the real player had no sprite at all. Drop it so createSpritesets
  # builds a fresh one against the new $game_player and the restored outfit.
  if original_scene.is_a?(Scene_Map)
    $scene = original_scene
    original_scene.disposeSpritesets
    nuzlocke_reset_drop_global_spriteset(original_scene)
    RPG::Cache.clear if defined?(RPG::Cache) && RPG::Cache.respond_to?(:need_clearing) && RPG::Cache.need_clearing
    original_scene.createSpritesets
    refreshPlayerOutfit if defined?(refreshPlayerOutfit)
  end

  # 5. Randomizer, as the intro applies it (silent when nothing is randomized).
  nuzlocke_reset_apply_randomizer!

  # 6. Skip to starter selection (Oak's lab), like CTRL on the splicer demo.
  nuzlocke_reset_skip_to_starter!

  # Persist the fresh run in the same slot, without the "overwrite?" prompt a
  # begun-new-game normally triggers on the next manual save.
  Game.save(active_slot) if active_slot
  $PokemonTemp.begunNewGame = false if $PokemonTemp

  $game_temp.transition_processing = true if $game_temp
  return true
end

#===============================================================================
# Auto Reset Run on a wipe (SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE).
#
# A blackout in a Nuzlocke is a wipe: under perma-death the whole team is gone,
# and even with perma-death off the canonical rule is "whiteout = run over".
# When the toggle is on we let the engine's own pbStartOver finish (it heals the
# empty/fainted party and warps to the last Pokemon Center), flag the wipe on
# $PokemonGlobal (so it survives a save/quit), and perform the actual Reset Run
# on the player's next overworld step -- pbStartOver runs from inside the
# post-battle sequence, where rebuilding the game state and the map
# scene is not safe. The step hook is onStepTakenTransferPossible, the engine's
# own hook for step handlers that may transfer the player.
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :nuzlocke_auto_reset_pending
end

def nuzlocke_auto_reset_active?
  return false if !$game_switches
  return false if !$game_switches[SWITCH_NUZLOCKE_MODE]
  return $game_switches[SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE] ? true : false
end

# True when the party has nobody left to fight with. Must be evaluated BEFORE
# pbStartOver runs, because the blackout routine heals the party.
def nuzlocke_party_wiped?
  return false if !$Trainer || !$Trainer.party
  return true if $Trainer.party.compact.empty?
  return $Trainer.able_pokemon_count == 0 if $Trainer.respond_to?(:able_pokemon_count)
  return $Trainer.party.compact.all? { |p| p.egg? || p.fainted? }
end

# Called around a blackout with the pre-blackout wipe state. Arms the pending
# auto-reset only for a real wipe: IF also routes "fled from a trainer" and a
# few scripted losses through pbStartOver with living Pokemon, and those are
# not the end of a run. Bug Contest "start over" is a contest loss, never arms.
def nuzlocke_flag_auto_reset_after_wipe(wiped = nuzlocke_party_wiped?)
  return if !wiped
  return if !nuzlocke_auto_reset_active?
  return if !$PokemonGlobal
  return if defined?(pbInBugContest?) && pbInBugContest?
  return if !nuzlocke_reset_available?
  $PokemonGlobal.nuzlocke_auto_reset_pending = true
end

# Performs the armed reset. Returns true if a reset ran.
def nuzlocke_run_pending_auto_reset
  return false if !$PokemonGlobal || !$PokemonGlobal.nuzlocke_auto_reset_pending
  $PokemonGlobal.nuzlocke_auto_reset_pending = false
  return false if !nuzlocke_auto_reset_active?
  return false if !nuzlocke_reset_available?
  pbMessage(_INTL("Your whole team was wiped out... The run is over."))
  nuzlocke_reset_run(false)
  return true
end

class Object
  unless private_method_defined?(:nuzlocke_orig_pbStartOver) ||
         method_defined?(:nuzlocke_orig_pbStartOver)
    alias_method :nuzlocke_orig_pbStartOver, :pbStartOver
    def pbStartOver(gameover = false)
      wiped = nuzlocke_party_wiped?           # before the blackout heals everyone
      nuzlocke_orig_pbStartOver(gameover)
      nuzlocke_flag_auto_reset_after_wipe(wiped)
    end
  end
end

Events.onStepTakenTransferPossible += proc { |_sender, e|
  handled = e[0]
  next if handled[0]
  next if !$PokemonGlobal || !$PokemonGlobal.nuzlocke_auto_reset_pending
  handled[0] = true if nuzlocke_run_pending_auto_reset
}
