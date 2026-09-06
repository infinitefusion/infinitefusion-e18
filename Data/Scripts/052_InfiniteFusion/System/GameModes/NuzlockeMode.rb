# frozen_string_literal: true

def initializeNuzlockeMode()
  $game_switches[SWITCH_NUZLOCKE_MODE] = true
  $game_switches[SWITCH_NUZLOCKE_AT_LEAST_ONCE] = true
  $game_switches[SWITCH_NUZLOCKE_MODE_INTRO] = true
  $game_switches[SWITCH_NUZLOCKE_RESET_ENABLED] = true

  # Default the gameplay toggles to the canonical Nuzlocke rules.
  # Players can opt out of any of these via the Nuzlocke settings menu.
  $game_switches[SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA] = true   # legacy flag (kept for back-compat)
  # Canonical catch rule = First encounter only. (0=Off, 1=First encounter, 2=One per area)
  pbSet(VAR_NUZLOCKE_CATCH_RULE_MODE, 1)
  # Encounter slots default to one per METHOD (walking, surfing, fishing,
  # special) -- the split variant. 0 = one per area (strict canon), 2 = rods split.
  pbSet(VAR_NUZLOCKE_ENCOUNTER_SLOTS, 1)
  $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] = true
  $game_switches[SWITCH_NUZLOCKE_FORCE_NICKNAMES] = true
  # Dupes Clause on by default: skip duplicate encounters (a fusion still counts
  # as catchable if either half is a new species).
  $game_switches[SWITCH_NUZLOCKE_DUPES_CLAUSE] = true
  # Trainer fleeing allowed by default -- preserves IF's behavior, which combined
  # with perma-death produces a Nuzlocke-flavored partial-forfeit (whoever fainted
  # is gone, the rest get out). Player can switch to Disallowed for a strict run.
  $game_switches[SWITCH_NUZLOCKE_TRAINER_FLEE_ALLOWED] = true
  # Shiny Clause on by default (community standard): a shiny wild is always
  # catchable and never spends or forfeits the area's encounter.
  $game_switches[SWITCH_NUZLOCKE_SHINY_CLAUSE] = true
  # Hardcore extras default OFF: Set battle style and forced level caps are
  # opt-in ("Hardcore Nuzlocke" rules), and a wipe blacks out normally unless the
  # player opts into auto Reset Run.
  $game_switches[SWITCH_NUZLOCKE_SET_BATTLE_STYLE] = false
  $game_switches[SWITCH_NUZLOCKE_LEVEL_CAP] = false
  $game_switches[SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE] = false
  # Soul Link is opt-in: it needs a partner and a room code.
  $game_switches[SWITCH_NUZLOCKE_SOUL_LINK] = false
  # Starter slot machine in Oak's lab: on by default (a Nuzlocke lives or dies
  # by its starter; rerolling costs nothing but the player's honour).
  $game_switches[SWITCH_NUZLOCKE_STARTER_REROLL] = true

  # Fused perma-death defaults to "Both" (the most punishing canonical option).
  pbSet(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 3)

  # Items: battle items off (classic Nuzlocke "no heals in battle" variant),
  # Cap Candy off by default (opt-in QoL), healing-item guarantee on (prevents
  # the Randomized Nuzlocke from leaving the player without any heals).
  $game_switches[SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED] = false
  $game_switches[SWITCH_NUZLOCKE_CAP_CANDY_ENABLED] = false
  $game_switches[SWITCH_NUZLOCKE_MEDKIT_ENABLED] = false
  $game_switches[SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS] = true
  NuzlockeKeyItems.sync_all! if defined?(NuzlockeKeyItems)
end
