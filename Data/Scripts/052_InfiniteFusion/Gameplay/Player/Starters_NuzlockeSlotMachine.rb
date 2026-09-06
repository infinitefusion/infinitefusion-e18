#===============================================================================
# Nuzlocke starter slot machine
#
# A terminal event beside the starter table in Oak's lab (map 77, event
# "Nuzlocke slot machine", charset BWComputer) rerolls the three starters while starter selection is
# open. The rerolled trio is stored on the save and served through obtainStarter,
# so the three Poke Balls (and the rival's pick via setRivalStarter) all see it.
#
#   * Randomized starters (SWITCH_RANDOM_STARTERS): each slot is re-drawn from
#     the same pool and BST window the wild randomizer uses for that starter's
#     dex number (Bulbasaur / Charmander / Squirtle), honouring the legendary and
#     first-stage settings. "Reroll just those three" without touching the rest
#     of the shuffled dex.
#   * Classic starters: one random grass, fire and water starter from the
#     official starter lists (all generations), never the current trio.
#
# This file must load AFTER Gameplay/Player/Starters.rb (it aliases
# obtainStarter); the "Starters_" prefix sorts it right behind it.
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :nuzlocke_starter_override   # [species, species, species] or nil
  attr_accessor :nuzlocke_starter_spins      # how many times the machine was used
end

module NuzlockeStarterSlots
  module_function

  STARTER_SELECTION_SWITCH = 3      # ON while Oak lets you pick from the table (see map 77 ball events)
  STARTER_DEX_NUMBERS      = [1, 4, 7].freeze   # what obtainRandomizedStarter rerolls through
  MAX_DRAWS                = 400

  def enabled?
    return false if !$game_switches
    return false if !$game_switches[SWITCH_NUZLOCKE_MODE]
    return false if !$game_switches[SWITCH_NUZLOCKE_STARTER_REROLL]
    return false if $game_switches[SWITCH_LEGENDARY_MODE]
    return true
  end

  def selection_open?
    return $game_switches && $game_switches[STARTER_SELECTION_SWITCH] ? true : false
  end

  def override
    return nil if !$PokemonGlobal
    ov = $PokemonGlobal.nuzlocke_starter_override
    return (ov.is_a?(Array) && ov.length == 3) ? ov : nil
  end

  def spins
    return 0 if !$PokemonGlobal
    return $PokemonGlobal.nuzlocke_starter_spins || 0
  end

  def current_trio
    return (0..2).map { |i| obtainStarter(i) }
  end

  def species_name(sp)
    data = (sp.is_a?(GameData::Species) ? sp : GameData::Species.try_get(sp))
    return data ? data.real_name : sp.to_s
  end

  #-----------------------------------------------------------------------------
  # Pools
  #-----------------------------------------------------------------------------
  # Mirror of pbShuffleDex's pool choice.
  def randomizer_pool
    include_fusions = $game_switches[SWITCH_RANDOM_WILD_TO_FUSION] ? true : false
    only_customs    = $game_switches[SWITCH_RANDOM_WILD_ONLY_CUSTOMS] && include_fusions
    pool = only_customs ? (getCustomSpeciesList(true) rescue nil) : nil
    pool = get_pokemon_list(include_fusions) if !pool.is_a?(Array) || pool.empty?
    return pool
  end

  # One draw for +dex_num+ with the randomizer's BST window and legendary rule
  # (same loop shape as get_randomized_bst_hash, with the window widening every
  # 5 misses so it always terminates). Returns a dex number.
  def draw_random_like(dex_num, range, pool, exclude = [])
    range = 1 if range.nil? || range <= 0
    target  = getStatsTotal(getBaseStatsFormattedForRandomizer(dex_num))
    min_bst = target - range
    max_bst = target + range
    include_legendaries = $game_switches[SWITCH_RANDOM_WILD_LEGENDARIES] ? true : false
    current_id = GameData::Species.get(dex_num).id
    pick = nil
    MAX_DRAWS.times do |j|
      cand = pool.sample
      next if cand.nil? || exclude.include?(cand)
      bst = getStatsTotal(getBaseStatsFormattedForRandomizer(cand))
      ok  = bst > min_bst && bst < max_bst &&
            legendaryOk(current_id, GameData::Species.get(cand).id, include_legendaries)
      if ok
        pick = cand
        break
      end
      if (j + 1) % 5 == 0
        min_bst -= 1
        max_bst += 1
      end
    end
    return pick || pool.sample
  end

  def reroll_randomized
    pool  = randomizer_pool
    range = (pbGet(VAR_RANDOMIZER_WILD_POKE_BST) rescue nil)
    range = 25 if !range.is_a?(Integer) || range <= 0
    picked = []
    STARTER_DEX_NUMBERS.each do |dex|
      cand = draw_random_like(dex, range, pool, picked)
      if $game_switches[SWITCH_RANDOM_STARTER_FIRST_STAGE]
        baby = (GameData::Species.get(cand).get_baby_species(false) rescue nil)
        cand = GameData::Species.get(baby).id_number if baby
      end
      picked.push(cand)
    end
    return picked.map { |n| GameData::Species.get(n).id }
  end

  def reroll_classic(current = [])
    lists = [Settings::GRASS_STARTERS, Settings::FIRE_STARTERS, Settings::WATER_STARTERS]
    return lists.map do |list|
      choices = list - current
      choices = list if choices.empty?
      choices.sample
    end
  end

  # Perform a reroll, store it, return the new trio as species symbols.
  def reroll!
    current = current_trio.map { |sp| sp.id rescue sp }
    trio = $game_switches[SWITCH_RANDOM_STARTERS] ? reroll_randomized : reroll_classic(current)
    trio = trio.map { |sp| GameData::Species.get(sp).id }
    $PokemonGlobal.nuzlocke_starter_override = trio
    $PokemonGlobal.nuzlocke_starter_spins = spins + 1
    return trio
  end
end

#===============================================================================
# Serve the rerolled trio through the engine's own starter lookup.
#===============================================================================
class Object
  unless private_method_defined?(:nuzlocke_orig_obtainStarter) ||
         method_defined?(:nuzlocke_orig_obtainStarter)
    alias_method :nuzlocke_orig_obtainStarter, :obtainStarter
    def obtainStarter(starterIndex = 0)
      ov = NuzlockeStarterSlots.override
      if ov && ov[starterIndex]
        data = GameData::Species.try_get(ov[starterIndex])
        return data if data
      end
      return nuzlocke_orig_obtainStarter(starterIndex)
    end
  end
end

#===============================================================================
# The map event's script call. The event is the "BWComputer" terminal charset
# (facing left/up = screen on, down/right = screen off; step animation makes
# the screen flicker), so a reroll is animated by blinking the screen.
#===============================================================================
NUZLOCKE_SLOT_EVENT_NAME = "Nuzlocke slot machine"

def nuzlocke_slot_event
  return nil if !$game_map || !$game_map.respond_to?(:events) || !$game_map.events
  return $game_map.events.values.find { |e| (e.name rescue nil) == NUZLOCKE_SLOT_EVENT_NAME }
end

def nuzlocke_slot_pull_animation
  ev = nuzlocke_slot_event
  return if !ev || !defined?(PBMoveRoute) || !defined?(pbMoveRoute)
  (pbSEPlay("SlotsCoin") rescue nil)
  pbMoveRoute(ev, [PBMoveRoute::DirectionFixOff,
                   PBMoveRoute::TurnDown, PBMoveRoute::Wait, 6,
                   PBMoveRoute::TurnLeft, PBMoveRoute::Wait, 4,
                   PBMoveRoute::TurnDown, PBMoveRoute::Wait, 6,
                   PBMoveRoute::TurnLeft, PBMoveRoute::DirectionFixOn], true)
rescue => e
  PBDebug.log("[Nuzlocke] terminal animation failed: #{e.message}") if defined?(PBDebug)
end

def pbNuzlockeStarterSlotMachine
  if !NuzlockeStarterSlots.enabled?
    pbMessage(_INTL("A terminal labeled 'STARTER REROLL'. The screen is dark."))
    return false
  end
  if !NuzlockeStarterSlots.selection_open?
    pbMessage(_INTL("A terminal labeled 'STARTER REROLL'. It's locked."))
    return false
  end
  names = NuzlockeStarterSlots.current_trio.map { |sp| NuzlockeStarterSlots.species_name(sp) }
  cmds = [_INTL("Reroll!"), _INTL("Leave it")]
  choice = pbMessage(_INTL("A terminal labeled 'STARTER REROLL'. It rerolls the three Pokémon on the table.\nRight now: {1}, {2} and {3}.", names[0], names[1], names[2]), cmds, cmds.length)
  return false if choice != 0
  nuzlocke_slot_pull_animation
  3.times do
    (pbSEPlay("SlotsStop") rescue nil)
    if defined?(Graphics) && Graphics.respond_to?(:update)
      6.times { Graphics.update; Input.update if defined?(Input) }
    end
  end
  trio = NuzlockeStarterSlots.reroll!
  new_names = trio.map { |sp| NuzlockeStarterSlots.species_name(sp) }
  pbMessage(_INTL("\\se[]Beep! The Poké Balls now hold {1}, {2} and {3}!", new_names[0], new_names[1], new_names[2]))
  return true
end
