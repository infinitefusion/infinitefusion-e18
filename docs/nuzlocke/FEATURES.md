# Nuzlocke Mode — Feature Checklist

Status of every Nuzlocke feature in this fork, as of release `v1.1.0-nuzlocke`.
"Tested" means a suite exists in `Data/Scripts/052_Tests/` and runs through the
boot-time harness (see **Running the tests** at the bottom).

Legend: ✅ implemented & tested · ☑ implemented (seam not unit-testable) · ❌ not built

## Core rules

| # | Feature | Setting (Nuzlocke settings menu) | Default | Status |
|---|---------|-----------------------------------|---------|--------|
| 1 | Nuzlocke as a game mode (5th mode in New Game) | — | — | ✅ |
| 2 | Nuzlocke settings sub-menu (opens after picking the mode) | — | — | ✅ |
| 3 | Optional randomization inside a Nuzlocke run | Randomization | Off | ✅ |
| 4 | Catch rule: First encounter only (canonical) | Catch rule → First only | **First only** | ✅ |
| 5 | Catch rule: One catch per area (lenient) | Catch rule → Per area | — | ✅ |
| 6 | Catch rule: Off | Catch rule → Off | — | ✅ |
| 7 | Area = displayed area name (a route split across maps is one area) | — | — | ✅ |
| 8 | Balls-first: encounters before you own a Poké Ball never burn an area | — | — | ✅ |
| 9 | Static / scripted encounters (legendaries, Snorlax, event fights) count as the area's first encounter and are catchable | — | — | ✅ *new in v1.0.0* |
| 10 | Fleeing / KO'ing the first encounter forfeits the area (first-only mode) | — | — | ✅ *fixed in v1.0.0* — the per-battle flag was never cleared after normal wild battles, so later wilds in the same area stayed catchable |
| 11 | Perma-death, unfused Pokémon | Perma-death (unfused) | On | ✅ |
| 12 | Perma-death, fused: Off / Head dies / Body dies / Both die | Perma-death (fused) | **Both** | ✅ |
| 13 | Surviving half is the same individual (IVs, EVs, nature, shiny, item, nickname) | — | — | ✅ |
| 14 | Held item of a dead Pokémon returns to the Bag | — | — | ✅ |
| 15 | Perma-death armed only once you have ever owned a Poké Ball (one-way ratchet) | — | — | ✅ |
| 16 | Death notices shown after evolutions / post-battle events | — | — | ✅ |
| 17 | Soft-lock guard: empty party after a "can lose" battle triggers the normal blackout | — | — | ✅ *fixed in v1.0.0* — the guard called `Kernel.pbStartOver`, which raises under Ruby 3 and was silently swallowed |
| 18 | Force nicknames on catch, starter, gifts, trades, egg hatch | Force nicknames | On | ✅ |
| 19 | "OK on the species name" does not count as a nickname | — | — | ✅ |
| 20 | Dupes Clause (species already owned is skipped; a fusion is a dupe only if BOTH halves are owned) | Dupes Clause | On | ✅ |
| 21 | Shiny Clause (shiny wilds always catchable, never spend or forfeit an area) | Shiny Clause | On | ✅ *new in v1.0.0* |
| 22 | Wild fusion IS your encounter (catch it or forfeit) | — | — | ✅ |
| 23 | Battle items forbidden (Poké Balls still allowed) | Battle items | Forbidden | ✅ |
| 24 | Trainer fleeing: Allowed (partial-forfeit) / Disallowed (canonical) | Trainer fleeing | Allowed | ✅ |
| 25 | Set battle style forced | Battle style → Set | Player's choice | ✅ *new in v1.0.0* |
| 26 | Level cap enforced (no EXP / Rare Candy past the next gym's cap) | Level cap → Enforced | Player's choice | ✅ *new in v1.0.0* (reuses the game's own level-cap system) |
| 27 | Guarantee every PokéMart stocks an HP-healing item (randomized runs) | Guarantee Mart heals | On | ✅ |
| 28 | Cap Candy item (raises one Pokémon to the current level cap; sold in every PokéMart while on) | Cap Candy | Off | ✅ *completed in v1.0.0* — previously unbuyable, no icon, wrong pocket, ID collided with TM109, and the item vanished at boot |
| 29 | Reset Run (pause menu: wipe progress, reroll randomization, keep name, look & settings) | Enable Reset Run | On | ✅ *rebuilt in v1.1.1* — now a genuine new game + intro replay + the game's own skip-to-starter, instead of a saved copy of the player's game |
| 30 | Reset Run lands you at starter selection in Oak's lab, pre-Pokédex | — | — | ✅ *fixed in v1.1.1* — the old copy was taken after the first save, so saving after the Pokédex made resets land post-Pokédex |
| 31 | Auto Reset Run on a full wipe | On wipe → Reset run | Blackout | ✅ *new in v1.0.0* |
| 32 | Soul Link (Soullocke) with a partner over a room-code relay: linked deaths, broken links, fusion-aware, linked-box warnings | Soul Link | Off | ✅ *new in v1.1.0* (needs the relay deployed, see `tools/soul_link_relay/`) |

## Not built (by design)

These came out of the May research pass but were never signed off in the
ruleset decision log, so they are not in the game and have no switches:

- Separate encounter slots for fishing / surfing / rock smash within one area
  (v1 treats the whole named area as one slot).
- Species/ban list (legendaries, pseudo-legendaries).
- Dupes Clause by evolution line (current clause is by exact species).
- Level-cap **BST tiers** for fusions.
- "Phase 2 extras" from the hook-map research: Heritage Movepool, Monotype
  Fusion Mandate, Fusion Permanence Lock, Splice Economy, Evolution Roulette,
  Encounter Dex Lock, Seeded Run, Starter Fusion Lock. Their placeholder
  constant names were removed from the code in v1.0.0 so nothing dead remains.
- Soul Link type clause and hard-enforced linked boxes (warning only).

## Known limitations

- **Double wild battles + Shiny Clause:** if one of the two wilds is shiny, the
  area's first encounter is given back for the whole battle (the non-shiny
  partner is not separately tracked). Rare; lenient in the player's favour.
- **Cap Candy** is a runtime-registered item (no `items.dat` rebuild). It lives
  in the Medicine pocket with id 9646. Its name/description are hard-coded in
  English (they bypass the translation tables).
- **Auto Reset on wipe** fires on your first overworld step after the blackout
  (rebuilding the game from inside the post-battle sequence is not safe).
- **Reset Run** re-asks the rival's name (that is part of the game's own
  skip-to-starter routine) and keeps your name, character, outfit and unlocks.
- **Soul Link** is honor-system by design: the game applies what a partner's
  ledger says after a prompt. The relay URL must be set before shipping a
  build (`DEFAULT_RELAY_URL`), or per-install via `soul_link_relay.txt`.
- **Old saves** from before v1.0.0: the new toggles default to Off except Shiny
  Clause, which reads as Off until you turn it on in the Nuzlocke settings
  (only `initializeNuzlockeMode` sets defaults, and it runs at New Game).

## Running the tests

1. Create an empty file named `nuzlocke_run_tests.flag` in the game folder.
2. Launch the game. It runs every suite before the title screen, writes
   `nuzlocke_test_results.log`, deletes the flag and exits.
3. Read the log: every line is `[OK]` or `[FAIL]`, with a summary at the end.

`nuzlocke_realsave_check.flag` containing a save-slot name (e.g. `File A`) does
the same against a real save, read-only (see `NuzlockeTestHarness.rb`).
