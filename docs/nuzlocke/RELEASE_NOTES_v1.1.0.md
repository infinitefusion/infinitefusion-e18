# Nuzlocke Mode v1.1.0 — release notes

Paste this as the body when publishing the GitHub release for tag
`v1.1.0-nuzlocke` (Releases → Draft a new release → choose the tag).

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
- **Cap Candy**: optional reusable key item that raises one Pokémon to the current level cap.
- **Guaranteed Mart heals** for randomized runs.
- **Reset Run** from the pause menu, and optional **auto Reset Run on a wipe**.
- **Starter slot machine** next to the starter table in Oak's lab: reroll the three starters until you pick one (toggle in Nuzlocke settings).
- **Soul Link** (v1.1.0): Soullocke with a friend over a room code. Linked deaths, broken links, fusion-aware. Needs the relay from `tools/soul_link_relay/` deployed once.
- Optional randomization through the game's own randomizer.

## New / fixed in this build
- Shiny Clause, Set style, level cap and auto-reset-on-wipe are new.
- Static encounters (legendaries, Snorlax, scripted fights) are now catchable in first-encounter mode.
- First-encounter forfeit now actually works after normal wild battles (the per-battle flag was never being cleared).
- Cap Candy fixed end to end (it previously vanished at boot, collided with TM109, sat in the Berries pocket, had no icon and could not be bought).
- The empty-party soft-lock guard now fires (it was silently crashing).
- Catching (first encounters and perma-death) is gated on Oak's Poké Ball handout, not on having a ball, so randomized early balls can't burn a route. Block messages now say whether the area was caught in or the encounter was used up.
- Auto reset on wipe no longer fires when you flee a trainer.
- Reset Run (and auto reset on wipe) now rebuilds the game from a true new game and replays the intro's end state, then runs the game's own skip-to-starter. It previously restored a copy of your save taken after your first manual save, which could land you post-Pokédex.

Full checklist: `docs/nuzlocke/FEATURES.md`. Tests: drop an empty `nuzlocke_run_tests.flag` in the game folder and launch; results land in `nuzlocke_test_results.log`.
