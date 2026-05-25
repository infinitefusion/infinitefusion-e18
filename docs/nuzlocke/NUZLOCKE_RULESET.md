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
  ⚠ DECISION #26 — add a strictness mode: **First-encounter-only** vs
  **One-per-area**. Recommend a 3-way: `Off / First encounter only / One per area`.
- **Area identity:** `$game_map.name` (the location-signpost name) — matches the
  "Met at" convention; a route split across sub-maps counts as one area. ✅ shipped.
- **Encounter-slot nuance (canon):** fishing / surfing / rock-smash are *separate*
  encounter slots from walking in the same area. ⚠ DECISION — v1 treats the whole
  named area as one slot (simpler). Revisit if you want fishing to grant its own.
- **Balls-first caveat (ours):** encounters before you own a Poké Ball never burn
  the area. ✅ shipped.

### 1.2 Permanent Fainting (Permadeath)
- **Canon:** a fainted Pokémon is "dead" — permanently released/boxed. Revival
  items forbidden. Whole party faints = run lost.
- **Our settings:** `SWITCH_NUZLOCKE_PERMA_DEATH_UNFUSED` (unfused: on/off) and
  `VAR_NUZLOCKE_FUSED_PERMA_DEATH_MODE` (fused: 0 Off / 1 Head / 2 Body / 3 Both).
- **Status:** ✅ shipped, now gated balls-first (perma-death inert until you own a
  ball, so the pre-catch rival fight can't kill your starter).
- ⚠ DECISION #21 — optional auto-reset the run on a full party wipe (vs normal
  blackout). Needs its own toggle, e.g. `On wipe: Reset run / Blackout`.

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
| **Dupes Clause** | If your first encounter is a species (or evo-line) you already own, you may skip it and keep searching. | `SWITCH_NUZLOCKE_DUPES_CLAUSE_ADDITIVE` (1217) + `VAR_NUZLOCKE_DUPES_CLAUSE_REROLL_ATTEMPTS` (default 3). ⚠ DECISION on fusion matching — see §4.1. |
| **Shiny Clause** | A shiny encounter may be caught WITHOUT spending the area's catch (you get the shiny *and* your normal encounter). | ⚠ DECISION — add `SWITCH_NUZLOCKE_SHINY_CLAUSE` (recommend default On). Not yet wired. |
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
- ⚠ DECISION — match dupes on **either half** (recommend) vs head-only. Affects the
  Dupes Clause reroll logic.

### 4.2 Does unfusing dodge perma-death?
- **Community consensus:** NO. If a **fused** Pokémon faints, **both** components are
  dead. Unfusing a *living* fusion is legal but never resurrects a dead half.
- **Our twist (user-requested):** the Head/Body/Both setting lets a chosen half
  *survive* when the fusion faints — this is intentionally **more lenient than
  canon** (canon = Both). Default stays **Both (3)** = canonical. ✅ honored.

### 4.3 Which species register on first-encounter / catch?
- **Community:** varies — Option A (strict): only non-fused encounters count, fused
  ones are skipped; Option B (lenient): a fusion IS the encounter, accept or forfeit.
- ⚠ DECISION — recommend **Option B** (a wild fusion is your encounter) as default;
  it's simpler and matches "what you see is your encounter."

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
| Set battle style | Hardcore | ⚠ optional toggle, not yet wired. |
| Level caps / no overleveling | Hardcore | §4.4 — later. |
| Guarantee Mart healing items | (IF QoL, ours) | `SWITCH_NUZLOCKE_GUARANTEE_HEALING_ITEMS` — Wave 2 world team. |
| Cap Candy (raise to level cap) | (ours, QoL) | `SWITCH_NUZLOCKE_CAP_CANDY_ENABLED` — Wave 2 item team. |

---

## 6. Variants (potential future presets)
- **Hardcore Nuzlocke** — Set mode + level caps + no battle items. (Could be a one-tap preset that flips our toggles.)
- **Wonderlocke** — every catch is Wonder-Traded for a random mon. (No Wonder Trade in IF → likely N/A.)
- **Soullocke** — 2-player linked deaths. (Out of scope, single-player.)
- **Cagelocke** — post-gym cage matches. (Out of scope / manual.)
- **Egglocke** — eggs replace encounters. (Possible later.)
- **Ceqlocke** — could not find authoritative definition; skip unless user defines it.

---

## 7. Open Decisions Summary (need user sign-off)
1. **#26 Catch rule strictness:** `Off / First encounter only / One per area`? Default?
2. **Encounter slots:** keep whole named area = 1 slot, or split fishing/surf? (recommend keep simple)
3. **Dupes fusion matching:** either half (recommend) vs head-only.
4. **Fusion as encounter:** Option B accept-the-fusion (recommend) vs Option A skip-fusions.
5. **Shiny Clause:** add it, default On? (recommend yes)
6. **#21 Auto-reset on wipe:** add `On wipe: Reset / Blackout` toggle? Default Blackout.
