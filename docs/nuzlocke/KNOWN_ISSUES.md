# Nuzlocke Mode — issue tracker

Running list of reported problems and their status. Add new ones at the top of
**Open**; move to **Fixed** with the commit that closed them.

## Open

- (none)

## Wishlist / not started

- Custom slot machine graphic: replace the Game Corner tile with a hand-drawn
  charset (`Graphics/Characters/nuzlocke_slot_machine.png`, 4x4 cells) once
  the art exists; then point map 77 event "Nuzlocke slot machine" page 2 at it.
- Soul Link: untested in-game so far; relay URL must be set first.

## Fixed

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
- Slot machine blocked the plant / faced the wrong way: moved to (15,17) on
  the cleared shelf row with a stool at (14,17). (v1.1.1)
