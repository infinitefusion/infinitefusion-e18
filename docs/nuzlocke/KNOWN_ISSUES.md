# Nuzlocke Mode — issue tracker

Running list of reported problems and their status. Add new ones at the top of
**Open**; move to **Fixed** with the commit that closed them.

## Open

- (none)

## Wishlist / not started

- Custom reroll graphic: the terminal (`BWComputer`) can be swapped for a
  hand-drawn charset by pointing map 77 event "Nuzlocke slot machine" page 2
  at the new file.
- Soul Link: untested in-game so far; relay URL must be set first.
- Soul Link co-op battles (idea, not started): when one player enters a
  battle, their partner's Pokémon join it as a double battle. Two tiers:
  - Tier 1, "partner snapshot": the game pulls the linked player's current
    party from the relay and starts the battle with them as an AI-controlled
    ally on your side. IF already supports this through `$PokemonGlobal.partner`
    (`001_Overworld_BattleStarting.rb`, wild and trainer paths), so it is
    mostly relay plumbing plus rules for what a fainted ally Pokémon means.
    The other player is not interrupted and does not choose moves. Feasible.
    Soul Link already pairs catches by area, so the natural ally is not the
    partner's whole party but the counterpart of each of your Pokémon: your
    Route 1 catch always fights next to their Route 1 catch. Must be an
    option, never forced: every battle as a double would change the game's
    balance (gym leaders, rival fights, wild 2v1s), so gate it behind its own
    setting, and consider "wild only", "trainers only" and "all" as values.
  - Tier 2, "true co-op": both players pick moves each turn, exchanged through
    the relay in lockstep. Needs a shared RNG seed with identical `rand` call
    order on both clients, a wait/timeout UI, disconnect handling, and a
    Durable Object (not KV) for turn ordering; mkxp-z has no WebSockets, so
    it would poll. Fragile and large. Not planned unless Tier 1 lands first.

## Fixed

- Added: Dupes Clause now matches by evolution line (default): owning any stage
  makes every stage of that line a dupe, fusion halves included. "Exact species"
  remains available in Nuzlocke settings.
- Added: Repel Toggle key item (Nuzlocke settings → Repel Toggle): switches an
  endless Repel on and off from the Bag or the ready menu. Saved with the game;
  turning the setting off removes the item and switches the repel off.
- Added: Cap Candy and Field Medkit can be registered to the ready menu.
  (v1.1.1)

- Existing saves could not change any Nuzlocke setting (the menu only opened
  at New Game): the Help Man in Pokémon Centers now offers "Nuzlocke settings"
  in Nuzlocke runs. (v1.1.1)

- Added: encounter slots per method / per rod (Nuzlocke settings), and the
  Field Medkit key item. (v1.1.1)

- Cap Candy "Use" in the Bag did nothing: the item was registered with
  field_use 2 (a from-Bag handler in this engine) instead of 5 (usable on a
  Pokémon, not consumed), and a stale duplicate handler in
  "New Items effects.rb" overrode the real one. (v1.1.1)
- Player sprite naked / invisible after Reset Run: the scene's global
  spriteset kept a Sprite_Player bound to the old Game_Player. (v1.1.1)
- Fleeing a trainer with "On wipe: Reset run" reset the run: IF routes a flee
  through the blackout routine; auto-reset now requires a real wipe. (v1.1.1)
- Randomized early Poké Ball counted as a route's first encounter: catching is
  now gated on Oak's handout (switch 988 / Pokédex). (v1.1.1)
- Block message said "already caught" for a forfeited encounter: three
  distinct messages now. (v1.1.1)
- Cap Candy vanished from randomized marts: it is a key item handed out
  directly. (v1.1.1)
- Reset Run landed post-Pokédex: rebuilt from a true new game instead of a
  saved copy. (v1.1.1)
- Slot machine was half a Game Corner bank and sat badly on the rug: replaced
  by the BWComputer terminal charset at (16,15) with a blinking screen; the
  potted plant (tiles + easter-egg event) moved to (7,13)-(7,14). (v1.1.1)
