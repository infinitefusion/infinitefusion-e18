## Thank you for downloading Pokémon Infinite Fusion!

Playing the game
---
**Windows**

Use **Game.exe** to play the game. That's it!

If you are experiencing issues such as long loading times, you can also try Game-performance.exe.

-----
**MacOS / Linux**

The game is not made to run natively on anything other than Windows. However, it is possible to play it Mac and Linux using Wine or Whiskey.

Refer to these tutorials:

[Wine install guide](https://hackmd.io/@PIF-Tech/MacWineGuide)

[Whiskey install guide](https://hackmd.io/@PIF-Tech/MacWhiskeyGuide)


Once Wine is installed on your computer, you can use "launch-wine.sh" to launch the game.

---
**Android**

To play Infinite Fusion on Android, you need to use a RPG Maker emulator called [JoiPlay](https://joiplay.net/).

[Android setup guide](https://hackmd.io/@PIF-Tech/AndroidGuide)

---
## Nuzlocke Mode (this fork)

This fork adds **Nuzlocke Mode** as a fifth game mode. Pick it under *New Game →
Which mode would you like to play?* and the Nuzlocke settings menu opens so you
can tune the rules before the run starts.

What it enforces (each has a toggle):

- **Catch rule** — only the first wild Pokémon you meet in each area can be
  caught (canonical), or one catch per area (lenient), or off. Static encounters
  count. Areas are the on-screen location names.
- **Perma-death** — fainted Pokémon are gone for good. For fusions choose whether
  the head, the body, or both halves die; a surviving half comes back unfused as
  the same individual. Held items return to your Bag.
- **Force nicknames** — every Pokémon you obtain must be nicknamed.
- **Dupes Clause** and **Shiny Clause** — skip species you already own (a fusion
  is a dupe only if you own both halves); shinies are always catchable and never
  spend an area.
- **Battle items forbidden**, **Trainer fleeing** allowed/disallowed, forced
  **Set battle style**, enforced **level caps**.
- **Cap Candy** — optional QoL item sold in every PokéMart that raises one
  Pokémon straight to the current level cap.
- **Reset Run** — pause-menu option that wipes the run (rerolling any
  randomization) while keeping your name and settings; optionally triggered
  automatically when your whole team is wiped.
- Optional **randomization** of the run, using the game's own randomizer.

Full status table: `docs/nuzlocke/FEATURES.md`. Rules rationale:
`docs/nuzlocke/NUZLOCKE_RULESET.md`.

**Downloading:** grab the latest release zip from the GitHub Releases page of
this repository, extract it anywhere, and run `InfiniteFusion.exe`. The game
downloads fusion sprites on first launch as usual. `INSTALL_OR_UPDATE.bat`
pulls the newest code from this fork's `nuzlocke-mode` branch (the folder must
be named `InfiniteFusion`).

---
## Contributing to the game

Pokémon Infinite Fusion is open-source! All of the game's code is located in the Data/Scripts folder.

We accept pull requests for bug fixes and minor features* (Please contact chardub on the game's Discord if you have a feature idea to get it pre-approved before you start working on it!)

**Note: Any pull request that modifies the RPG Maker files outside of the Scripts folder will be automatically denied. 
This includes any changes to the maps/game events. The reason for this is that unfortunately, the way RPG Maker XP's data
files are structured does not allow to easily see what the changes made are.**

To contribute:

- Fork the game's repo from https://github.com/infinitefusion/infinitefusion-e18
- Work from the **develop** branch to avoid merge conflicts 
- Open a pull request once you're done to merge into **develop**. A pull request should only contain a single feature or bug fix. Any PR that bundles multiple features/fixes will be denied.

**There is no guarantee that submitted pull requests will be accepted.*

---
## Useful links:
- [Wiki](https://infinitefusion.fandom.com/)
- [Discord](https://discord.gg/infinitefusion)
- [Reddit](https://www.reddit.com/r/PokemonInfiniteFusion/)
- [Pokecommunity](https://www.pokecommunity.com/showthread.php?t=347883)
- [Showdown](http://play.pokeathlon.com)
- [Fusion calculator](https://www.fusiondex.org/)

This is a free-to-play Pokémon fan game. If you paid any amount of money to play this game, you have been scammed. 
This game is not affiliated with Nintendo, Game Freak or Creatures Inc.