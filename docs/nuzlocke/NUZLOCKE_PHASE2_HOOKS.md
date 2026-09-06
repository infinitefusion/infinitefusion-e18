# Nuzlocke Phase 2 — Enforcement Hook Map

> **Status (v1.0.0):** historical research document. The Battle, Capture and
> World groups, plus Cap Candy, are implemented (see `FEATURES.md`). The
> **Fusion/splicer group** and the **Evolution Roulette / Dex Lock / Seeded Run /
> Starter Fusion Lock** ideas were never signed off and are NOT built; their
> placeholder constant names were removed from the code. Treat the file:line
> citations below as approximate — they date from May 2026.

Research output (read-only survey, 2026-05). File:line citations were accurate at
time of writing — re-verify against current code before editing, especially after
an IF update. Preferred implementation style is **aliasing** the target method from
a Nuzlocke-owned file rather than editing core files in place — keeps the patch
update-resilient and lets parallel teams avoid touching the same files.

## Fusion helper signatures (shared)
- `get_head_id_from_symbol(id)` — `052_InfiniteFusion/Fusion/FusionUtils.rb:127`
- `get_body_id_from_symbol(id)` — `052_InfiniteFusion/Fusion/FusionUtils.rb:119`
- `getBasePokemonID(pokemon, body=true)` — `052_InfiniteFusion/Gameplay/Utilities/PokemonUtils.rb:283`
- `isFusion(num)` — `052_InfiniteFusion/Fusion/FusionUtils.rb:252`
- `dexNum(species)` — `052_InfiniteFusion/Fusion/FusionUtils.rb:244`
- `getFusionSpecies(body, head)` — `052_InfiniteFusion/Fusion/FusionUtils.rb:330`

## Battle group (→ NuzlockeBattleRules.rb)
- **Perma-death (unfused)** — `011_Battle/003_Battle/003_Battle_StartAndEnd.rb:510-516` `pbEndOfBattle`. Alias it; after super, iterate `$Trainer.party`, release fainted mons where `!isFusion(mon.species_data.id_number)`.
- **Perma-death (fused)** — split via `pbUnfuse` at `052_InfiniteFusion/Gameplay/Items/New Items effects.rb:1631` (preserves level/EXP/IVs, lines 1682-1686). On fused faint, branch on `VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE` (0=Off,1=Head,2=Body,3=Both): unfuse, then release head/body/both, surviving half back to PC/party.
- **Battle items (forbidden)** — `011_Battle/005_Battle scene/008_Scene_Commands.rb:11-24` `pbCommandMenu`. Alias; filter the Bag entry out of the `cmds` array when `SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED` is false.

## Capture/encounter group (→ NuzlockeCaptureRules.rb)
- **One catch per area** — `011_Battle/003_Battle/001_PokeBattle_BattleCommon.rb:208` `pbThrowPokeBall` (or commit point `pbRecordAndStoreCaughtPokemon` at `003_Battle_StartAndEnd.rb:517`). Area id = `$game_map.map_id`. Keep registry on `$PokemonGlobal` (new attr); block catch if area already present.
  - **Balls-first caveat (required):** an area's first encounter must NOT be counted/locked until the player actually has Poké Balls — otherwise pre-ball encounters (e.g. Route 1 before the mart) burn the area's catch. Gate the area-lock recording on the player having ≥1 ball: check the bag for any item where `GameData::Item.get(id).is_poke_ball?` (or `$PokemonBag.pbHasItem?(:POKEBALL)` as a minimum). If the player has no balls during an encounter, don't record that area as "used" — they get their real first-encounter once they can catch.
- **Force nicknames** — `001_PokeBattle_BattleCommon.rb:8-11` `pbStorePokemon` (or `promptCaughtPokemonAction` at `052_InfiniteFusion/Gameplay/Utilities/MenuUtils.rb:5`). Make the nickname prompt unconditional.
- **Starter Fusion Lock** — `001_PokeBattle_BattleCommon.rb:207` before `@caughtPokemon.push`. Fuse caught mon with `$Trainer.party[0]` (or `VAR_PLAYER_STARTER_CHOICE`) via `getFusionSpecies`.
- **Dupes Clause (additive)** — `012_Overworld/002_Battle triggering/003_Overworld_WildEncounters.rb:282-346` `choose_wild_pokemon`. After the `[species, level]` result, re-roll up to 3× if `player_owns_type?(species)` (iterate party+storage vs `GameData::Species.get(species).type1/type2`).

## Fusion/splicer group (→ NuzlockeFusionRules.rb)
- **Heritage Movepool** — `052_InfiniteFusion/Fusion/PokemonFusion.rb:960-973` `setFusionMoves`. Replace union of movesets with intersection of `GameData::Species.get(bodyID).moves` ∩ `...headID....moves`.
- **Monotype Fusion Mandate** — `New Items effects.rb:1615` `pbFuse`, gate before line 1621: block if head/body species share no type.
- **Fusion Permanence Lock** — `New Items effects.rb:1631` `pbUnfuse` + SUPERSPLICERS handlers (`915`, `1810`). Stub/refuse when locked.
- **Splice Economy** — `New Items effects.rb:1615-1628` `pbFuse`. Charge money/item before committing the fusion.

## World group (→ NuzlockeWorldRules.rb)
- **Evolution Roulette** — `014_Pokemon/001_Pokemon.rb:1328-1337` `check_evolution_internal`. Replace `evo[0]` target with a BST±50-matched random species.
- **Encounter Dex Lock** — Pokédex entry gate `016_UI/004_UI_Pokedex_Entry.rb:306` (`$Trainer.owned?`); battle UI opponent name/type at `011_Battle/005_Battle scene/004_PokeBattle_SceneElements.rb:265`. Hide data for un-owned species.
- **Seeded Run** — `srand(hash)` pattern exists at `017_Minigames/005_Minigame_Lottery.rb:8`. Seed before `get_randomized_bst_hash` (`025-Randomizer/randomizer.rb:72`) and other `.sample`/`.shuffle` points.
- **Guarantee Mart heals** — `016_UI/020_UI_PokeMart.rb:758` (`SWITCH_RANDOM_SHOP_ITEMS` branch). Ensure ≥1 healing item in generated stock.

## Cap Candy item (→ separate, touches item registration)
- Level cap: `getCurrentLevelCap()` — `052_InfiniteFusion/Gameplay/Utilities/BattleUtils.rb:43`.
- Effect template: Rare Candy at `013_Items/002_Item_Effects.rb:795-804`; level-set via `pbChangeLevel` (`013_Items/001_Item_Utilities.rb:118`).
- Registration: items live in `Data/items.dat` (binary) — needs PBS `items.txt` recompile or equivalent; plus an icon sprite.
