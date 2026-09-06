# Nuzlocke Mode — Feature Checklist

Status of every Nuzlocke feature in this fork, as of release `v1.1.0-nuzlocke`.
"Tested" means a suite exists in `Data/Scripts/052_Tests/` and runs through the
boot-time harness (see **Running the tests** at the bottom).

Legend: ✅ implemented & tested · ☑ implemented (seam not unit-testable) · ❌ not built

## Core rules

| # | Feature | Setting (Nuzlocke settings menu) | Default | Status |
|---|---------|-----------------------------------|---------|--------|
| 1 | Nuzlocke as a game mode (5th mode in New Game) | — | — | ✅ |
| 2 | Nuzlocke settings sub-menu (opens after picking the mode, and from the Help Man in any Pokémon Center during the run; randomization is only offered at New Game) | — | — | ✅ *Help Man entry new in v1.1.1* |
| 3 | Optional randomization inside a Nuzlocke run | Randomization | Off | ✅ |
| 4 | Catch rule: First encounter only (canonical) | Catch rule → First only | **First only** | ✅ |
| 5 | Catch rule: One catch per area (lenient) | Catch rule → Per area | — | ✅ |
| 6 | Catch rule: Off | Catch rule → Off | — | ✅ |
| 7 | Area = displayed area name (a route split across maps is one area) | — | — | ✅ |
| 7b | Encounter slots: one per area (strict), one per method (walking / surfing / fishing / special: webs, rock smash, headbutt, scripted wilds), or per method with each rod its own slot | Encounter slots | **Per method** | ✅ *new in v1.1.1* |
| 8 | Balls-first: nothing counts (no first encounters, no perma-death) until Professor Oak hands out Poké Balls, so a randomized early Poké Ball can't burn a route | — | — | ✅ *fixed in v1.1.1* (was "a ball in the bag") |
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
| 28 | Cap Candy: a reusable key item in your Bag that raises one Pokémon to the current level cap | Cap Candy | Off | ✅ *reworked in v1.1.1* — now a key item handed out directly (mart stock is randomized away in randomized runs) |
| 28b | Field Medkit: a reusable key item that fully heals the party anywhere outside battle | Field Medkit | Off | ✅ *new in v1.1.1* |
| 28c | All three key items can be registered to the ready menu (Bag → Register) | — | — | ✅ *new in v1.1.1* |
| 28d | Repel Toggle: a key item that switches an endless Repel on and off (same level rule as a normal Repel; an incense still overrides it) | Repel Toggle | Off | ✅ *new in v1.1.1* |
| 29 | Reset Run (pause menu: wipe progress, reroll randomization, keep name, look & settings) | Enable Reset Run | On | ✅ *rebuilt in v1.1.1* — now a genuine new game + intro replay + the game's own skip-to-starter, instead of a saved copy of the player's game |
| 30 | Reset Run lands you at starter selection in Oak's lab, pre-Pokédex | — | — | ✅ *fixed in v1.1.1* — the old copy was taken after the first save, so saving after the Pokédex made resets land post-Pokédex |
| 31 | Auto Reset Run on a full wipe (not on fleeing a trainer or other scripted blackouts with living Pokémon) | On wipe → Reset run | Blackout | ✅ *new in v1.0.0, fixed in v1.1.1* |
| 32 | Soul Link (Soullocke) with a partner over a room-code relay: linked deaths, broken links, fusion-aware, linked-box warnings | Soul Link | Off | ✅ *new in v1.1.0* (needs the relay deployed, see `tools/soul_link_relay/`) |
| 33 | Starter reroll terminal in Oak's lab (right of the starter table; the potted plant moved to the left wall) that rerolls the three starters until you pick one. Randomized runs redraw within the randomizer's BST window; classic runs get a random grass/fire/water trio from every generation | Starter slot machine | On | ✅ *new in v1.1.1* (map 77: one added event, the plant's two tiles and its event moved from (16,13-14) to (7,13-14)) |

## Not built (by design)

These came out of the May research pass but were never signed off in the
ruleset decision log, so they are not in the game and have no switches:

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
- **Cap Candy** is a runtime-registered key item (no `items.dat` rebuild), id
  9646. Its name/description are hard-coded in English (they bypass the
  translation tables). The Bag is re-synced on every map change.
- **Auto Reset on wipe** fires on your first overworld step after the blackout
  (rebuilding the game from inside the post-battle sequence is not safe).
- **Reset Run** re-asks the rival's name (that is part of the game's own
  skip-to-starter routine) and keeps your name, character, outfit and unlocks.
- **Soul Link** is honor-system by design: the game applies what a partner's
  ledger says after a prompt. The relay URL must be set before shipping a
  build (`DEFAULT_RELAY_URL`), or per-install via `soul_link_relay.txt`.
- **Old saves**: toggles added after the save was started read as Off (and
  Encounter slots as Per area) until you set them via the Help Man in a Pokémon
  Center → Nuzlocke settings; only `initializeNuzlockeMode` applies the defaults, at New Game.

## Running the tests

1. Create an empty file named `nuzlocke_run_tests.flag` in the game folder.
2. Launch the game. It runs every suite before the title screen, writes
   `nuzlocke_test_results.log`, deletes the flag and exits.
3. Read the log: every line is `[OK]` or `[FAIL]`, with a summary at the end.

`nuzlocke_realsave_check.flag` containing a save-slot name (e.g. `File A`) does
the same against a real save, read-only (see `NuzlockeTestHarness.rb`).
