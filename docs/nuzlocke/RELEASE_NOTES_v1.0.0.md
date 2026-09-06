# Nuzlocke Mode v1.0.0 — release notes

Paste this as the body when publishing the GitHub release for tag
`v1.0.0-nuzlocke` (Releases → Draft a new release → choose the tag).

---

First downloadable build of Nuzlocke Mode for Pokémon Infinite Fusion (based on IF 6.7.2).

## Install
1. Download **Source code (zip)** below and extract it anywhere.
2. Run `InfiniteFusion.exe` (or `InfiniteFusion-performance.exe`). Fusion sprites download on first launch as usual.
3. New Game → *Which mode would you like to play?* → **Nuzlocke Mode**. The Nuzlocke settings menu opens before the run starts.

To update later, rename the folder to `InfiniteFusion` and run `INSTALL_OR_UPDATE.bat` (pulls this fork's `nuzlocke-mode` branch).

## Rules included (every one has a toggle)
- Catch rule: **First encounter only** (canonical) / One per area / Off. Static encounters count. Balls-first: pre-Poké-Ball encounters never burn an area.
- **Perma-death** for unfused Pokémon; fused Pokémon die by Head / Body / **Both** (default), the surviving half returns unfused as the same individual. Held items go back to the Bag.
- **Force nicknames** on catches, starter, gifts, trades and hatched eggs.
- **Dupes Clause** (a fusion is a dupe only if you own both halves) and **Shiny Clause** (shinies always catchable, never spend an area).
- **Battle items forbidden** (Poké Balls still work), **trainer fleeing** allowed/disallowed.
- **Set battle style** and **level cap** enforcement (Hardcore options, off by default).
- **Cap Candy**: optional item sold in every PokéMart that raises one Pokémon to the current level cap.
- **Guaranteed Mart heals** for randomized runs.
- **Reset Run** from the pause menu, and optional **auto Reset Run on a wipe**.
- Optional randomization through the game's own randomizer.

## New / fixed in this build
- Shiny Clause, Set style, level cap and auto-reset-on-wipe are new.
- Static encounters (legendaries, Snorlax, scripted fights) are now catchable in first-encounter mode.
- First-encounter forfeit now actually works after normal wild battles (the per-battle flag was never being cleared).
- Cap Candy fixed end to end (it previously vanished at boot, collided with TM109, sat in the Berries pocket, had no icon and could not be bought).
- The empty-party soft-lock guard now fires (it was silently crashing).

Full checklist: `docs/nuzlocke/FEATURES.md`. Tests: drop an empty `nuzlocke_run_tests.flag` in the game folder and launch; results land in `nuzlocke_test_results.log`.
