#===============================================================================
# Nuzlocke Capture Rules (Phase 2 enforcement)
#
# Implemented purely by reopening / aliasing — this file is the ONLY file that
# changes for these features, so it stays update-resilient and avoids stepping on
# parallel teammates editing the core catch/overworld files.
#
# Features:
#   1. One catch per area (SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA)
#      - Area identity = the displayed area NAME ($game_map.name), so a route
#        split across multiple sub-maps counts as ONE area.
#      - "Area used" is recorded ONLY on a SUCCESSFUL catch. Fleeing or defeating
#        the first encounter does NOT burn the area. (Common romhack reading; it
#        is also the only event we can detect cleanly without touching the
#        overworld encounter code that a teammate owns.)
#      - Balls-first caveat: an area never becomes "used" while the player has no
#        Poke Balls, and a catch is only blocked when the player actually has
#        balls (no point blocking a throw that cannot happen). So pre-ball
#        encounters never consume the area's one allowed catch.
#   2. Force nicknames (SWITCH_NUZLOCKE_FORCE_NICKNAMES)
#      - Every caught Pokemon is nicknamed unconditionally (the optional yes/no
#        confirm is skipped). Vanilla optional behavior is preserved when off.
#   3. Shiny Clause (SWITCH_NUZLOCKE_SHINY_CLAUSE)
#      - A shiny wild Pokemon is always catchable, regardless of the catch rule,
#        and catching it never spends the area. In first-encounter mode a shiny
#        also never burns the area's first encounter: the next non-shiny wild is
#        still the area's real first encounter.
#   4. Static / scripted wild battles (legendaries, Snorlax, event fights) go
#      through the same first-encounter bookkeeping as walking encounters, via a
#      wrapper on pbWildBattleCore / pbSafariBattle. Without that wrapper those
#      battles never fired EncounterModifier, so in first-encounter mode they
#      could never be caught.
#
# Everything is gated on SWITCH_NUZLOCKE_MODE. When that switch is off, every
# alias falls straight through to the original implementation.
#===============================================================================

#===============================================================================
# Registry of areas where a catch has already been used up, stored on the save.
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :nuzlocke_caught_areas          # areas where a catch was SUCCESSFUL
  attr_accessor :nuzlocke_first_encounter_areas # areas whose first encounter has occurred (caught or not)
  attr_accessor :nuzlocke_ever_had_balls        # one-way ratchet for balls-first gating
end

module NuzlockeCaptureRules
  module_function

  # Master gate. Anything Nuzlocke-related is inert unless this is on.
  def nuzlocke_active?
    return false if !$game_switches
    return $game_switches[SWITCH_NUZLOCKE_MODE]
  end

  # Catch-rule modes.
  CATCH_RULE_OFF             = 0
  CATCH_RULE_FIRST_ENCOUNTER = 1   # canonical: only the first wild seen per area is catchable
  CATCH_RULE_ONE_PER_AREA    = 2   # lenient: any one catch per area

  # Resolve the active catch-rule mode. Prefers the 3-state VAR; falls back to the
  # legacy SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA boolean (=> One-per-area) so existing
  # saves and the existing test suites keep working unchanged.
  def catch_rule_mode
    return CATCH_RULE_OFF if !nuzlocke_active?
    m = (pbGet(VAR_NUZLOCKE_CATCH_RULE_MODE) rescue 0) || 0
    return m if m.is_a?(Integer) && m > 0
    return CATCH_RULE_ONE_PER_AREA if $game_switches[SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA]
    return CATCH_RULE_OFF
  end

  # True when any catch restriction is active (either mode). Drives the catch
  # interception in triggerCanUseInBattle and the record-on-success in pbThrowPokeBall.
  def one_catch_per_area_active?
    return catch_rule_mode != CATCH_RULE_OFF
  end

  #-----------------------------------------------------------------------------
  # First-encounter-only support.
  #-----------------------------------------------------------------------------
  # Areas whose first encounter has already occurred (whether or not it was caught).
  # Persistent on the save; lazily initialised. nil $PokemonGlobal => [].
  def first_encounter_areas
    return [] if !$PokemonGlobal
    $PokemonGlobal.nuzlocke_first_encounter_areas ||= []
    return $PokemonGlobal.nuzlocke_first_encounter_areas
  end

  # Transient (per-battle) flag: is the CURRENT wild battle this area's designated
  # first encounter (and therefore the one battle in which a catch is allowed)?
  def current_is_first_encounter?
    return $nuzlocke_current_is_first_encounter == true
  end

  # Called at wild-encounter start (EncounterModifier). In first-encounter mode,
  # if the player has balls and this area's first encounter hasn't happened yet,
  # record it now and flag THIS battle as the catchable first encounter. The
  # balls-first caveat means pre-ball encounters never "use up" the first slot.
  #-----------------------------------------------------------------------------
  # Dupes Clause.
  #-----------------------------------------------------------------------------
  def dupes_clause_active?
    return false if !nuzlocke_active?
    return $game_switches[SWITCH_NUZLOCKE_DUPES_CLAUSE]
  end

  # Decompose a Pokemon into the base species id(s) it represents for ownership:
  # a fusion counts as BOTH its head and body species; a normal mon as itself.
  def owned_species_of(pkmn)
    return [] if !pkmn
    id = (pkmn.species_data.id_number rescue nil)
    return [] if !id
    if (isFusion(id) rescue false)
      body = (getBasePokemonID(id, true) rescue nil)
      head = (getBasePokemonID(id, false) rescue nil)
      return [body, head].select { |s| s.is_a?(Integer) && s > 0 }
    end
    return [id]
  end

  # The set (hash) of base species ids the player owns, scanning party + storage
  # and decomposing every fusion into its halves ("owned in any capacity").
  def owned_species_set
    owned = {}
    if $Trainer && $Trainer.party
      $Trainer.party.each { |pk| owned_species_of(pk).each { |s| owned[s] = true } }
    end
    if $PokemonStorage && $PokemonStorage.respond_to?(:boxes)
      ($PokemonStorage.boxes rescue []).each do |box|
        next if !box
        (box.pokemon rescue []).each { |pk| owned_species_of(pk).each { |s| owned[s] = true } }
      end
    end
    return owned
  end

  # True if a wild encounter is a "dupe" the clause lets you skip:
  #   - non-fusion: you already own that species.
  #   - fusion: you own BOTH halves (if either half is new, it's catchable).
  def wild_is_dupe?(species)
    return false if species.nil?
    id = (GameData::Species.get(species).id_number rescue nil)
    return false if !id
    owned = owned_species_set
    if (isFusion(id) rescue false)
      body = (getBasePokemonID(id, true) rescue nil)
      head = (getBasePokemonID(id, false) rescue nil)
      return false if !body || !head
      return owned[body] && owned[head] ? true : false   # dupe only if BOTH owned
    end
    return owned[id] ? true : false
  end

  # Pull the species out of an EncounterModifier encounter ([species, level]).
  def encounter_species(encounter)
    return encounter[0] if encounter.is_a?(Array)
    return encounter
  end

  #-----------------------------------------------------------------------------
  # Shiny Clause.
  #-----------------------------------------------------------------------------
  def shiny_clause_active?
    return false if !nuzlocke_active?
    return $game_switches[SWITCH_NUZLOCKE_SHINY_CLAUSE] ? true : false
  end

  # The area key that THIS battle freshly recorded as first-encountered (nil if
  # this battle didn't record one). Lets the Shiny Clause give the area back.
  def area_recorded_this_battle
    return $nuzlocke_area_recorded_this_battle
  end

  # True when every opposing, non-fainted battler in +battle+ is shiny (in a
  # single wild battle: the one wild you'd throw at). Used to exempt the throw
  # from the catch rule. Objects without the battle API (test doubles, nil)
  # are never exempt.
  def opposing_wild_shiny?(battle)
    return false if !battle || !battle.respond_to?(:eachOtherSideBattler)
    found = false
    all_shiny = true
    battle.eachOtherSideBattler(0) do |b|
      found = true
      all_shiny = false if !(b.shiny? rescue false)
    end
    return found && all_shiny
  end

  # Called with every wild Pokemon that is actually about to be fought (from the
  # pbWildBattleCore / pbSafariBattle wrappers and Events.onWildPokemonCreate).
  # If it is shiny and the Shiny Clause is on, give back the first-encounter slot
  # this battle just recorded, so the shiny never spends the area.
  def note_wild_pokemon(pkmn)
    return if !pkmn
    return if !shiny_clause_active?
    return if !(pkmn.shiny? rescue false)
    area = $nuzlocke_area_recorded_this_battle
    return if !area
    first_encounter_areas.delete(area)
    $nuzlocke_area_recorded_this_battle = nil
  end

  # Register the wilds of a battle started through pbWildBattleCore(*args).
  # Mirrors the engine's own argument walk: Pokemon objects (roamers, scripted
  # fights), [species, level] pairs, or species followed by level. Idempotent:
  # a walking encounter already registered via EncounterModifier is a no-op here
  # because the area is already in first_encounter_areas.
  def note_wild_battle_args(args)
    return if !args.is_a?(Array)
    pending_species = nil
    args.each do |arg|
      if arg.is_a?(Pokemon)
        note_wild_encounter_start([arg.species, arg.level])
        note_wild_pokemon(arg)
      elsif arg.is_a?(Array)
        note_wild_encounter_start(arg)
      elsif pending_species
        note_wild_encounter_start([pending_species, arg])
        pending_species = nil
      else
        pending_species = arg
      end
    end
  rescue => e
    PBDebug.log("[Nuzlocke] note_wild_battle_args failed: #{e.message}") if defined?(PBDebug)
  end

  def note_wild_encounter_start(encounter = nil)
    return if catch_rule_mode != CATCH_RULE_FIRST_ENCOUNTER
    return if !catching_unlocked?
    # Dupes Clause: a dupe wild does NOT count as the area's first encounter -- it
    # is skipped (and stays uncatchable, since it's never flagged), leaving the
    # area open so the next non-dupe wild becomes the real first encounter. A
    # fusion with at least one NEW half is not a dupe, so it remains catchable.
    if dupes_clause_active? && encounter && wild_is_dupe?(encounter_species(encounter))
      return
    end
    area = current_area_key
    return if area.nil?
    # Only flag the battle catchable when this call FRESHLY records the area's
    # first encounter. We deliberately do NOT reset the flag to false otherwise:
    # EncounterModifier fires once PER wild in a battle, so a double battle's 2nd
    # mon would otherwise clear the flag the 1st mon set. Between battles the flag
    # is reset to false by clear_wild_encounter_flag (onWildBattleEnd), so a later
    # battle in an already-encountered area stays non-catchable.
    if !first_encounter_areas.include?(area)
      first_encounter_areas.push(area)
      $nuzlocke_current_is_first_encounter = true
      $nuzlocke_area_recorded_this_battle = area
    end
  end

  # Clear the transient per-battle state when the wild battle ends. Called from
  # the pbWildBattleCore / pbSafariBattle wrappers (ensure) and onWildBattleEnd.
  def clear_wild_encounter_flag
    $nuzlocke_current_is_first_encounter = false
    $nuzlocke_area_recorded_this_battle = nil
  end

  def force_nicknames_active?
    return false if !nuzlocke_active?
    return $game_switches[SWITCH_NUZLOCKE_FORCE_NICKNAMES]
  end

  # Post-acquisition force-nickname loop. Called by paths that need to enforce
  # naming AFTER an engine routine has already given the player an optional
  # prompt (e.g. pbHatch -- which has its own inline confirm+entry that
  # bypasses pbNickname). If the mon ends up with no real nickname, this
  # re-prompts via pbEnterPokemonName until the name is non-empty and isn't
  # the species name. Bounded at 5 attempts so a stuck UI can't hang. No-op on
  # already-nicknamed mons (the existing nickname stands).
  def force_nickname_loop!(pokemon)
    return if !pokemon
    return if pokemon.respond_to?(:shadowPokemon?) && pokemon.shadowPokemon?
    species_name = pokemon.speciesName
    attempts = 0
    while (pokemon.name.nil? || pokemon.name.to_s.strip == "" || pokemon.name == species_name) &&
          attempts < 5
      pbMessage(_INTL("In a Nuzlocke, every Pokémon must be nicknamed!")) if attempts > 0
      entered = pbEnterPokemonName(_INTL("{1}'s nickname?", species_name),
                                   0, Pokemon::MAX_NAME_SIZE, "", pokemon)
      pokemon.name = entered if entered && entered.to_s.strip != ""
      attempts += 1
    end
  end

  # True when nuzlocke is on AND battle items are forbidden. Battle-items
  # enforcement now lives ENTIRELY in ItemHandlers.triggerCanUseInBattle below
  # (the parallel NuzlockeBattleRules.rb no longer blocks the whole bag). When
  # this is true, any item that is NOT a Poke Ball is blocked; Poke Balls stay
  # usable (still subject to the one-catch block).
  def battle_items_forbidden?
    return false if !nuzlocke_active?
    return !$game_switches[SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED]
  end

  # Returns the list of area keys where the player has already used their catch.
  # Keys are the displayed area NAME strings (see current_area_key). nil is
  # treated as [] (lazy init).
  #
  # NOTE: keying switched from numeric map_id to the displayed area name so a
  # route split across several sub-maps counts as ONE area. Older saves that
  # stored integer map_ids will simply start fresh under the new string keying
  # (a previously-burned area becomes catchable again). This is acceptable for a
  # dev-stage feature.
  def caught_areas
    return [] if !$PokemonGlobal
    $PokemonGlobal.nuzlocke_caught_areas ||= []
    return $PokemonGlobal.nuzlocke_caught_areas
  end

  # The area key for the current map: the displayed location/area NAME, matching
  # what the player sees on the location signpost. The signpost is built from
  # $game_map.name (see 012_Overworld/001_Overworld.rb:394), which resolves the
  # map's display name via pbGetMessage(MessageTypes::MapNames, map_id) in
  # 004_Game classes/004_Game_Map.rb:133. We reuse that same name so our "area"
  # matches the on-screen area name. Falls back to the map_id as a string only
  # if no name resolves, so this never returns nil/crashes.
  def current_area_key
    return nil if !$game_map
    name = ($game_map.name rescue nil)
    return name if name.is_a?(String) && !name.strip.empty?
    return $game_map.map_id.to_s
  end

  # Backwards-compatible accessor. Older code referred to current_area_id; it now
  # returns the name-based key.
  def current_area_id
    return current_area_key
  end

  # Live check: does the bag hold at least one Poke Ball right now? Used only to
  # decide whether a throw is even possible (no point blocking an impossible
  # throw). It does NOT unlock catching -- see catching_unlocked?.
  def player_has_balls?
    return false if !$PokemonBag
    bag_pockets = ($PokemonBag.pockets rescue nil)
    return false if !bag_pockets
    bag_pockets.each do |pocket|
      next if !pocket
      pocket.each do |entry|
        next if !entry
        item_id = entry[0]
        next if !item_id
        item = (GameData::Item.get(item_id) rescue nil)
        next if !item
        return true if item.is_poke_ball?
      end
    end
    return false
  end

  # The story moment catching becomes legal: Professor Oak hands over the
  # Pokedex and the first Poke Balls (Oak's lab event sets this switch right
  # after "$Trainer.has_pokedex = true"). Holding a ball is NOT enough -- in a
  # randomized run an item can turn into a Poke Ball long before that, and an
  # encounter fought with it must not count as an area's first encounter.
  OAK_POKEBALLS_SWITCH = 988

  def story_unlocked?
    return true if $game_switches && $game_switches[OAK_POKEBALLS_SWITCH]
    return true if $Trainer && $Trainer.respond_to?(:has_pokedex) && $Trainer.has_pokedex
    return false
  end

  # One-way ratchet: once catching has been unlocked at any point in the run
  # (Oak's handout, or clear evidence of past catches on older saves), the
  # rules stay armed forever -- even if the Pokedex flag or bag state changes.
  # Gates both first-encounter recording and perma-death, so the pre-catch
  # starter rival fight can never kill the starter.
  def ever_had_balls?
    return false if !$PokemonGlobal
    return true  if $PokemonGlobal.nuzlocke_ever_had_balls
    if story_unlocked?
      $PokemonGlobal.nuzlocke_ever_had_balls = true
      return true
    end
    # Migration heuristic for existing saves.
    if $Trainer && $Trainer.party && $Trainer.party.compact.length > 1
      $PokemonGlobal.nuzlocke_ever_had_balls = true
      return true
    end
    if $PokemonStorage && $PokemonStorage.respond_to?(:boxes)
      ($PokemonStorage.boxes rescue []).each do |box|
        next if !box
        if (box.pokemon rescue []).compact.any?
          $PokemonGlobal.nuzlocke_ever_had_balls = true
          return true
        end
      end
    end
    return false
  end

  # True if the current area's one allowed catch has already been used.
  def current_area_used?
    area = current_area_key
    return false if area.nil?
    return caught_areas.include?(area)
  end

  # Mark the current area as having had its catch used (idempotent).
  def mark_current_area_used
    area = current_area_key
    return if area.nil?
    list = caught_areas
    list.push(area) if !list.include?(area)
  end

  # Alias with the intent spelled out.
  def catching_unlocked?
    return ever_had_balls?
  end

  # Why a catch attempt in the current area is blocked right now, or nil if it
  # isn't. Only blocks when nuzlocke + a catch rule are on and the player
  # actually has balls (no reason to block an impossible throw).
  #   :locked         -- Oak hasn't handed out Poke Balls yet (randomized early ball)
  #   :area_caught    -- a Pokemon was already caught in this area
  #   :encounter_used -- this area's first encounter came and went (first-only mode)
  def catch_block_reason
    mode = catch_rule_mode
    return nil if mode == CATCH_RULE_OFF
    return nil if !player_has_balls?
    return :locked if !catching_unlocked?
    case mode
    when CATCH_RULE_ONE_PER_AREA
      return current_area_used? ? :area_caught : nil
    when CATCH_RULE_FIRST_ENCOUNTER
      return :area_caught if current_area_used?
      return :encounter_used if !current_is_first_encounter?
    end
    return nil
  end

  def should_block_catch?
    return !catch_block_reason.nil?
  end

  def catch_block_message(reason)
    case reason
    when :locked         then _INTL("You can't catch Pokémon until Professor Oak gives you Poké Balls!")
    when :area_caught    then _INTL("You already caught a Pokémon in this area!")
    when :encounter_used then _INTL("You already used up your encounter in this area!")
    else nil
    end
  end
end

#===============================================================================
# Block a catch attempt at item-selection time, BEFORE the ball is registered or
# consumed. ItemHandlers.triggerCanUseInBattle returning false stops
# pbRegisterItem from ever running, so no ball is spent and the round is not
# consumed. The player can still battle, run, or use other items normally.
#===============================================================================
module ItemHandlers
  class << self
    unless method_defined?(:nuzlocke_orig_triggerCanUseInBattle) ||
           respond_to?(:nuzlocke_orig_triggerCanUseInBattle)
      alias_method :nuzlocke_orig_triggerCanUseInBattle, :triggerCanUseInBattle

      def triggerCanUseInBattle(item, pkmn, battler, move, firstAction, battle, scene, showMessages = true)
        is_ball = (GameData::Item.get(item).is_poke_ball? rescue false)
        # Battle-items lock: when items are forbidden, block everything that is
        # NOT a Poke Ball. Balls are deliberately exempt here (they are only ever
        # gated by the one-catch rule below), so catching stays possible.
        if !is_ball && NuzlockeCaptureRules.battle_items_forbidden?
          if showMessages && scene && scene.respond_to?(:pbDisplay)
            scene.pbDisplay(_INTL("No items allowed in this challenge!"))
          end
          return false
        end
        # Catch rule: block a Poke Ball when this area's catch is spent, the
        # first encounter has come and gone, or catching isn't unlocked yet.
        # Shiny Clause: a shiny wild is always catchable once catching is unlocked.
        if is_ball && NuzlockeCaptureRules.one_catch_per_area_active?
          reason = NuzlockeCaptureRules.catch_block_reason
          if reason && reason != :locked &&
             NuzlockeCaptureRules.shiny_clause_active? &&
             NuzlockeCaptureRules.opposing_wild_shiny?(battle)
            reason = nil
          end
          if reason
            if showMessages && scene && scene.respond_to?(:pbDisplay)
              scene.pbDisplay(NuzlockeCaptureRules.catch_block_message(reason))
            end
            return false
          end
        end
        return nuzlocke_orig_triggerCanUseInBattle(item, pkmn, battler, move, firstAction, battle, scene, showMessages)
      end
    end
  end
end

#===============================================================================
# Catch / store hooks. Aliased on the shared module so both PokeBattle_Battle and
# PokeBattle_SafariZone (which both `include PokeBattle_BattleCommon`) pick them up.
#===============================================================================
module PokeBattle_BattleCommon
  #-----------------------------------------------------------------------------
  # Record "area used" only on a SUCCESSFUL catch. We detect success by watching
  # @caughtPokemon grow across the original call (it only pushes on a 4-shake
  # capture). Fleeing/defeating never grows it, so the area is not burned.
  #-----------------------------------------------------------------------------
  unless method_defined?(:nuzlocke_orig_pbThrowPokeBall)
    alias_method :nuzlocke_orig_pbThrowPokeBall, :pbThrowPokeBall
    def pbThrowPokeBall(idxBattler, ball, catch_rate = nil, showPlayer = false)
      before = (@caughtPokemon.is_a?(Array) ? @caughtPokemon.length : 0)
      result = nuzlocke_orig_pbThrowPokeBall(idxBattler, ball, catch_rate, showPlayer)
      if NuzlockeCaptureRules.one_catch_per_area_active?
        after = (@caughtPokemon.is_a?(Array) ? @caughtPokemon.length : 0)
        if after > before
          # Shiny Clause: catching a shiny never spends the area.
          target = (@battlers.is_a?(Array) ? @battlers[idxBattler] : nil) rescue nil
          shiny_exempt = NuzlockeCaptureRules.shiny_clause_active? &&
                         target && (target.shiny? rescue false)
          NuzlockeCaptureRules.mark_current_area_used if !shiny_exempt
        end
      end
      return result
    end
  end

  #-----------------------------------------------------------------------------
  # Force-nickname: make the optional "give a nickname?" prompt unconditional.
  #
  # The original pbStorePokemon body is:
  #     if pbDisplayConfirm(_INTL("Would you like to give a nickname...")) ...
  # We don't want to duplicate the whole store routine, so instead we set a flag
  # and intercept pbDisplayConfirm (below): while the flag is set, that one
  # confirm auto-answers "yes", so the original always opens the name entry. No
  # double prompt, no duplicated store logic. When the switch is off the flag is
  # never set and pbDisplayConfirm behaves exactly as vanilla.
  #-----------------------------------------------------------------------------
  unless method_defined?(:nuzlocke_orig_pbStorePokemon)
    alias_method :nuzlocke_orig_pbStorePokemon, :pbStorePokemon
    def pbStorePokemon(pkmn)
      if NuzlockeCaptureRules.force_nicknames_active? && pkmn && !pkmn.shadowPokemon?
        @nuzlocke_force_nick = true
        begin
          result = nuzlocke_orig_pbStorePokemon(pkmn)
        ensure
          @nuzlocke_force_nick = false
        end
        # Post-store force-nick loop (#7): in the battle path the engine uses
        # @scene.pbNameEntry, which accepts "OK on the species name" as the
        # nickname -- bypassing the force. After the engine stores the mon,
        # re-prompt via the same scene until the name actually differs from the
        # species name. Bounded at 5 attempts so a stuck scene can't hang.
        species_name = pkmn.speciesName rescue nil
        if species_name && @scene && @scene.respond_to?(:pbNameEntry)
          attempts = 0
          while (pkmn.name.nil? || pkmn.name.to_s.strip == "" || pkmn.name == species_name) &&
                attempts < 5
            @scene.pbDisplay(_INTL("In a Nuzlocke, every Pokémon must be nicknamed!")) if @scene.respond_to?(:pbDisplay)
            pkmn.name = @scene.pbNameEntry(_INTL("{1}'s nickname?", species_name), pkmn)
            attempts += 1
          end
        end
        return result
      end
      return nuzlocke_orig_pbStorePokemon(pkmn)
    end
  end
end

#===============================================================================
# pbDisplayConfirm lives on the concrete battle classes (not the shared module),
# so the auto-yes interception used by force-nickname is aliased here. While the
# @nuzlocke_force_nick flag (set by pbStorePokemon above) is on, the single
# "give a nickname?" confirm answers yes so the name entry always opens.
#===============================================================================
class PokeBattle_Battle
  unless method_defined?(:nuzlocke_orig_pbDisplayConfirm)
    alias_method :nuzlocke_orig_pbDisplayConfirm, :pbDisplayConfirm
    def pbDisplayConfirm(msg)
      return true if @nuzlocke_force_nick
      return nuzlocke_orig_pbDisplayConfirm(msg)
    end
  end
end

class PokeBattle_SafariZone
  unless method_defined?(:nuzlocke_orig_pbDisplayConfirm)
    alias_method :nuzlocke_orig_pbDisplayConfirm, :pbDisplayConfirm
    def pbDisplayConfirm(msg)
      return true if @nuzlocke_force_nick
      return nuzlocke_orig_pbDisplayConfirm(msg)
    end
  end
end

#===============================================================================
# Force-nickname for the STARTER and GIFT Pokemon.
#
# Caught wild Pokemon are nicknamed via the battle's own pbStorePokemon /
# pbDisplayConfirm path (handled above). The starter and gift Pokemon take a
# DIFFERENT path: pbAddPokemon / pbAddToParty / pbAddPokemonID ->
# pbNicknameAndStore -> pbNickname (019_Utilities/002_Utilities_Pokemon.rb:8),
# which uses the global pbConfirmMessage - a method our battle hooks never see,
# so those Pokemon kept getting the optional yes/no prompt.
#
# pbNickname is a top-level function (a private instance method on Object), so
# we reopen Object and wrap it: when force-nicknames is active, skip the
# "Would you like to give a nickname?" confirm and open the name entry directly
# (mirroring the one line the original runs on "yes"). Eggs are left alone -
# they're named after hatching. When the switch is off, the original runs
# verbatim. This covers EVERY non-catch acquisition: starter, gifts, fusion
# results, in-game trades, etc.
#===============================================================================
#===============================================================================
# Egg-hatch force-nickname (#11). pbHatch has its OWN inline confirm+entry that
# bypasses our pbNickname wrap entirely (016_UI/001_Non-interactive UI/
# 003_UI_EggHatching.rb:224). We alias pbHatch so AFTER the original runs we
# loop the player into a real nickname if they bailed out -- using the shared
# force_nickname_loop! helper. Idempotent: a player who already nicknamed during
# the hatch dialog short-circuits the helper immediately.
#===============================================================================
class Object
  unless private_method_defined?(:nuzlocke_orig_pbHatch) ||
         method_defined?(:nuzlocke_orig_pbHatch)
    alias_method :nuzlocke_orig_pbHatch, :pbHatch
    def pbHatch(pokemon)
      result = nuzlocke_orig_pbHatch(pokemon)
      if NuzlockeCaptureRules.force_nicknames_active?
        NuzlockeCaptureRules.force_nickname_loop!(pokemon)
      end
      return result
    end
  end
end

class Object
  unless private_method_defined?(:nuzlocke_orig_pbNickname) ||
         method_defined?(:nuzlocke_orig_pbNickname)
    alias_method :nuzlocke_orig_pbNickname, :pbNickname
    def pbNickname(pkmn)
      if NuzlockeCaptureRules.force_nicknames_active? && pkmn &&
         !(pkmn.respond_to?(:egg?) && pkmn.egg?) &&
         !(pkmn.respond_to?(:shadowPokemon?) && pkmn.shadowPokemon?)
        species_name = pkmn.speciesName
        # Loop the entry until they give a name that's not the species name and
        # not empty: hitting OK on the default species name used to "skip" the
        # force (#7). Bounded so a stuck UI can't hang -- after 5 refusals we
        # accept whatever they entered.
        5.times do
          entered = pbEnterPokemonName(_INTL("{1}'s nickname?", species_name),
                                       0, Pokemon::MAX_NAME_SIZE, "", pkmn)
          if entered && entered.to_s.strip != "" && entered != species_name
            pkmn.name = entered
            return
          end
          pbMessage(_INTL("In a Nuzlocke, every Pokémon must be nicknamed!"))
        end
        # Fallback: cap reached, accept what's there (defensive against UI hang).
        pkmn.name = pbEnterPokemonName(_INTL("{1}'s nickname?", species_name),
                                       0, Pokemon::MAX_NAME_SIZE, "", pkmn)
        return
      end
      return nuzlocke_orig_pbNickname(pkmn)
    end
  end
end

#===============================================================================
# First-encounter recording hooks.
#   - EncounterModifier fires as a wild encounter is generated: mark the area's
#     first encounter (first-encounter mode only) and flag this battle catchable.
#   - onWildBattleEnd clears the transient per-battle flag.
# Both are defined in 012_Overworld (loaded before this file), so they exist here.
#===============================================================================
# Stored as constants so tests can invoke the EXACT proc objects the engine holds
# and assert their persistent outcome -- without depending on other mods' procs in
# the shared EncounterModifier chain. note_wild_encounter_start is itself a no-op
# unless first-encounter mode is active, so the proc is safe to register always.
module NuzlockeCaptureRules
  ENCOUNTER_START_PROC = proc { |encounter|
    NuzlockeCaptureRules.note_wild_encounter_start(encounter)
    encounter
  }
  WILD_BATTLE_END_PROC = proc { |_sender, _e|
    NuzlockeCaptureRules.clear_wild_encounter_flag
  }
end

EncounterModifier.register(NuzlockeCaptureRules::ENCOUNTER_START_PROC) if defined?(EncounterModifier)
if defined?(Events) && Events.respond_to?(:onWildBattleEnd)
  Events.onWildBattleEnd += NuzlockeCaptureRules::WILD_BATTLE_END_PROC
end

#===============================================================================
# Wild-battle entry wrappers.
#
# pbWildBattleCore is the single funnel for every wild battle (walking
# encounters, static/scripted fights, roamers, double wilds). Wrapping it does
# two things the EncounterModifier hook alone cannot:
#   * Static / scripted battles never pass through EncounterModifier, so in
#     first-encounter mode they were never flagged catchable. note_wild_battle_args
#     registers them exactly like a walking encounter (idempotent for walking
#     encounters, which are already registered).
#   * The engine only triggers Events.onWildBattleEnd for Safari / Bug Contest /
#     roamer battles, NOT for ordinary wild battles -- so the per-battle
#     "this is the first encounter" flag used to leak into the NEXT battle in the
#     same area. The ensure block clears it after every wild battle.
# While the wrapper is active ($nuzlocke_wild_battle_pending) the
# onWildPokemonCreate hook below sees the generated wilds (for the Shiny Clause);
# outside a battle (roamer generation, catching contest) it stays inert.
#===============================================================================
module NuzlockeCaptureRules
  WILD_POKEMON_CREATE_PROC = proc { |_sender, e|
    NuzlockeCaptureRules.note_wild_pokemon(e[0]) if $nuzlocke_wild_battle_pending
  }

  def self.wrap_wild_battle(args)
    note_wild_battle_args(args)
    $nuzlocke_wild_battle_pending = true
    begin
      return yield
    ensure
      $nuzlocke_wild_battle_pending = false
      # Soul Link needs to know about a forfeited first encounter before the
      # per-battle bookkeeping is cleared.
      NuzlockeSoulLink.note_wild_battle_end if defined?(NuzlockeSoulLink)
      clear_wild_encounter_flag
    end
  end
end

if defined?(Events) && Events.respond_to?(:onWildPokemonCreate)
  Events.onWildPokemonCreate += NuzlockeCaptureRules::WILD_POKEMON_CREATE_PROC
end

class Object
  unless private_method_defined?(:nuzlocke_orig_pbWildBattleCore) ||
         method_defined?(:nuzlocke_orig_pbWildBattleCore)
    alias_method :nuzlocke_orig_pbWildBattleCore, :pbWildBattleCore
    def pbWildBattleCore(*args)
      NuzlockeCaptureRules.wrap_wild_battle(args) { nuzlocke_orig_pbWildBattleCore(*args) }
    end
  end

  if method_defined?(:pbSafariBattle) || private_method_defined?(:pbSafariBattle)
    unless private_method_defined?(:nuzlocke_orig_pbSafariBattle) ||
           method_defined?(:nuzlocke_orig_pbSafariBattle)
      alias_method :nuzlocke_orig_pbSafariBattle, :pbSafariBattle
      def pbSafariBattle(species, level)
        NuzlockeCaptureRules.wrap_wild_battle([[species, level]]) { nuzlocke_orig_pbSafariBattle(species, level) }
      end
    end
  end
end
