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
  $game_switches[SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED] = true
  $game_switches[SWITCH_NUZLOCKE_FORCE_NICKNAMES] = true

  # Fused perma-death defaults to "Both" (the most punishing canonical option).
  pbSet(VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE, 3)

  # Items: battle items off (classic Nuzlocke "no heals in battle" variant),
  # Cap Candy off by default (opt-in QoL), healing-item guarantee on (prevents
  # the Randomized Nuzlocke from leaving the player without any heals).
  $game_switches[SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED] = false
  $game_switches[SWITCH_NUZLOCKE_CAP_CANDY_ENABLED] = false
  $game_switches[SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS] = true
end
