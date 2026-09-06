# Infinite Fusion Nuzlocke Mode — Hard Ruleset

Authoritative ruleset for IF Nuzlocke Mode, synthesized from community research
(Bulbapedia, Nuzlocke University, Nuzlocke Forums, r/PokemonInfiniteFusion, IF
Fandom FAQ). Each rule notes: **canon** (what the community treats as standard),
our **setting** (the toggle that controls it), the **default**, and **enforcement
status** in the mod. Decisions still open are marked **⚠ DECISION**.

There is **no official** IF Nuzlocke mode upstream — every rule is community
convention, so where conventions disagree we pick a sensible default and expose a
toggle.

---

## 1. The Two Core Rules (every Nuzlocke has these)

### 1.1 Limited Encounters — FIRST encounter per area only
- **Canon (strict):** In each area you may only catch the **first** wild Pokémon
  you encounter. If it faints or flees, the area is **forfeited** — no second
  chances for the rest of the run.
- **Lenient variant (what we shipped first):** any *one* catch per area (you can
  KO/flee and still catch a later one).
- **Our setting:** `SWITCH_NUZLOCKE_ONE_CATCH_PER_AREA` (currently lenient).
  ✅ DECIDED #26 — replace with a 3-way **catch-rule mode**
  (`Off / First encounter only / One per area`), **default = First encounter
  only** (canonical), switchable so players can loosen it. Needs a new VAR
  (boolean switch → 3-state var) + first-encounter tracking/forfeit logic.
- **Area identity:** `$game_map.name` (the location-signpost name) — matches the
  "Met at" convention; a route split across sub-maps counts as one area. ✅ shipped.
- **Encounter-slot nuance (canon):** fishing / surfing / rock-smash are *separate*
  encounter slots from walking in the same area. ✅ shipped (v1.1.1) as
  `VAR_NUZLOCKE_ENCOUNTER_SLOTS`: Per area (strict) / **Per method** (default:
  land, water, fishing, special) / Per rod (each rod its own fishing slot).
  Webs and other scripted wild battles are "special".
- **Static / scripted encounters (ours):** legendaries, Snorlax, event fights go
  through the same first-encounter bookkeeping as walking encounters. ✅ shipped
  (v1.0.0). Before that they never registered and could not be caught at all in
  first-encounter mode.
- **Balls-first caveat (ours):** encounters before you own a Poké Ball never burn
  the area. ✅ shipped.

### 1.2 Permanent Fainting (Permadeath)
- **Canon:** a fainted Pokémon is "dead" — permanently released/boxed. Revival
  items forbidden. Whole party faints = run lost.
- **Our settings:** `SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED` (unfused: on/off) and
  `VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE` (fused: 0 Off / 1 Head / 2 Body / 3 Both).
- **Status:** ✅ shipped, now gated balls-first (perma-death inert until you own a
  ball, so the pre-catch rival fight can't kill your starter).
- ✅ #21 shipped (v1.0.0) — `SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE`, menu toggle
  `On wipe: Blackout / Reset run`, default Blackout. The reset fires on the first
  overworld step after the blackout.

---

## 2. Nickname Rule
- **Canon:** ALL Pokémon must be nicknamed — caught, starter, AND gifts.
- **Our setting:** `SWITCH_NUZLOCKE_FORCE_NICKNAMES`.
- **Status:** ✅ shipped for caught mons; ✅ now also forces starter + gifts
  (global `pbNickname` wrap). Eggs named on hatch.

---

## 3. Standard Supplementary Clauses

| Clause | Canon definition | Our plan |
|---|---|---|
| **Dupes Clause** | If your first encounter is a species (or evo-line) you already own, you may skip it and keep searching. | ✅ shipped — `SWITCH_NUZLOCKE_DUPES_CLAUSE`, default On. Fusion matching per §4.1. |
| **Shiny Clause** | A shiny encounter may be caught WITHOUT spending the area's catch (you get the shiny *and* your normal encounter). | ✅ shipped (v1.0.0) — `SWITCH_NUZLOCKE_SHINY_CLAUSE`, **default On**. A shiny wild is exempt from the catch-rule limit and never burns/forfeits the area. |
| **Species Clause** | Usually = Dupes by evolutionary line (own any stage → can't catch others in that line). | Fold into Dupes Clause as "by evo line" (recommend). |
| **Ban List** | Legendaries / pseudo / OP species banned from use. | Optional, low priority. Can piggyback on existing legendary handling. |

---

## 4. Fusion-Specific Rulings (IF — must be decided, no firm community consensus)

### 4.1 Dupes / Species Clause with fusions
- **Community:** component-based — a fusion counts by its **head and/or body**
  species, not as a unique entity. Some runners trigger dupes if **either** half
  is owned; some only the head.
- **Documented strategy:** catch a fusion that contains a dupe half, unfuse, release
  the dupe half, keep the valid one.
- ✅ DECIDED (refined 2026-05-27) — a wild is a skippable **dupe** only when it
  brings NO new species:
  - **Non-fusion:** dupe if you already own that species.
  - **Fusion:** dupe only if you own **BOTH** halves. If **either** half is a
    species you don't own, the fusion is **catchable** (it brings new genetics) —
    "you can catch a fusion if one of them isn't the dupe."
  Ownership is "in ANY capacity": the scan walks party + storage and decomposes
  every owned fusion into its head+body species. A dupe does **not** count as the
  area's first encounter — it's skipped and the next non-dupe wild becomes the
  real first encounter ("reroll on your next encounter"). Implemented in
  `NuzlockeCaptureRules` (wild_is_dupe? / owned_species_set), gated on
  `SWITCH_NUZLOCKE_DUPES_CLAUSE`, default On, tied to first-encounter mode.

### 4.2 Does unfusing dodge perma-death?
- **Community consensus:** NO. If a **fused** Pokémon faints, **both** components are
  dead. Unfusing a *living* fusion is legal but never resurrects a dead half.
- **Our twist (user-requested):** the Head/Body/Both setting lets a chosen half
  *survive* when the fusion faints — this is intentionally **more lenient than
  canon** (canon = Both). Default stays **Both (3)** = canonical. ✅ honored.

### 4.3 Which species register on first-encounter / catch?
- **Community:** varies — Option A (strict): only non-fused encounters count, fused
  ones are skipped; Option B (lenient): a fusion IS the encounter, accept or forfeit.
- ✅ DECIDED — **Option B**: a wild fusion IS your encounter. You catch it or forfeit
  the area; fusions are not skipped for being fused. (Dupes Clause may still skip it
  per §4.1, and Shiny Clause exempts shinies.)

### 4.4 Level caps & fusion BST
- **Community:** gym-based level caps (12/22/… per badge) and BST tiers (≤560 early,
  rising per badge) are popular in Hardcore runs.
- **Our plan:** optional, lower priority (separate from Cap Candy). Could expose a
  "Level cap enforcement" toggle later.

---

## 5. Optional / "Soft" Difficulty Rules

| Rule | Canon status | Our handling |
|---|---|---|
| No items in battle | Hardcore-variant standard | `SWITCH_NUZLOCKE_BATTLE_ITEMS_ALLOWED` — ✅ shipped (blocks non-ball items; balls always allowed). |
| Set battle style | Hardcore | `SWITCH_NUZLOCKE_SET_BATTLE_STYLE` — ✅ shipped (v1.0.0), default off. |
| Level caps / no overleveling | Hardcore | `SWITCH_NUZLOCKE_LEVEL_CAP` — ✅ shipped (v1.0.0), default off; forces the game's own level-cap system on. |
| Guarantee Mart healing items | (IF QoL, ours) | `SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS` — ✅ shipped. |
| Cap Candy (raise to level cap) | (ours, QoL) | `SWITCH_NUZLOCKE_CAP_CANDY_ENABLED` — ✅ shipped (v1.0.0): runtime-registered item, sold in every PokéMart while on. |
| Field Medkit (full party heal outside battle) | (ours, QoL) | `SWITCH_NUZLOCKE_MEDKIT_ENABLED` — ✅ shipped (v1.1.1): key item, registerable to the ready menu. |
| Repel Toggle (endless Repel on/off) | (ours, QoL) | `SWITCH_NUZLOCKE_REPEL_TOGGLE_ENABLED` — ✅ shipped (v1.1.1): key item, state saved in `$PokemonGlobal.nuzlocke_repel_on`; hooks `isRepelActive`. |

---

## 6. Variants (potential future presets)
- **Hardcore Nuzlocke** — Set mode + level caps + no battle items. (Could be a one-tap preset that flips our toggles.)
- **Wonderlocke** — every catch is Wonder-Traded for a random mon. (No Wonder Trade in IF → likely N/A.)
- **Soullocke** — 2-player linked deaths. See `SOUL_LINK_DESIGN.md` (proposal).
- **Cagelocke** — post-gym cage matches. (Out of scope / manual.)
- **Egglocke** — eggs replace encounters. (Possible later.)
- **Ceqlocke** — could not find authoritative definition; skip unless user defines it.

---

## 7. Decisions Log

**Resolved (user sign-off 2026-05-25):**
1. **#26 Catch rule:** 3-way `Off / First encounter only / One per area`, **default
   First encounter only**, switchable. ✅
2. **Fusion as encounter:** Option B — the wild fusion IS your encounter. ✅
3. **Dupes + fusion (refined 2026-05-27):** a fusion is a dupe only if you own
   **BOTH** halves; if **either** half is new the fusion is catchable. Non-fusion
   dupe if owned. Dupes are skipped (don't count as the first encounter).
   Ownership scanned in any capacity (standalone or fusion half). ✅ Implemented +
   tested (SWITCH_NUZLOCKE_DUPES_CLAUSE, default On). 
4. **Shiny Clause:** add it, **default On**; shinies don't spend/forfeit the area. ✅

**Defaulted (will proceed unless you say otherwise):**
5. **Encounter slots:** keep whole named area = 1 encounter slot for v1 (no separate
   fishing/surf slot). Simpler; revisit later.
6. **#21 Auto-reset on wipe:** default to the normal **Blackout** (already shipped);
   auto-reset-on-wipe deferred to its own optional toggle later.

**Constants (all shipped):** `VAR_NUZLOCKE_CATCH_RULE_MODE` (1220),
`SWITCH_NUZLOCKE_DUPES_CLAUSE` (1218), `SWITCH_NUZLOCKE_TRAINER_FLEE_ALLOWED` (1219),
`SWITCH_NUZLOCKE_SHINY_CLAUSE` (1210), `SWITCH_NUZLOCKE_SET_BATTLE_STYLE` (1211),
`SWITCH_NUZLOCKE_LEVEL_CAP` (1212), `SWITCH_NUZLOCKE_AUTO_RESET_ON_WIPE` (1213).

See `FEATURES.md` for the per-feature status table.
