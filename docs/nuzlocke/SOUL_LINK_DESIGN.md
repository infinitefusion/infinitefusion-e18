# Soul Link — Design & Implementation

Status: **implemented (v1.1.0)** as the zero-provider relay variant. The
original option analysis is kept below for the record.

## What shipped

- **Toggle:** Nuzlocke settings → *Soul Link: On*. Off by default.
- **Pairing:** pause menu → *Soul Link* → *Create a room* shows a 6-character
  code; the partner picks *Join a room* and types it. No accounts, no logins.
- **Transport:** a Cloudflare Worker + KV relay (`tools/soul_link_relay/`).
  Each player POSTs their own ledger and GETs everyone else's. The relay URL is
  `NuzlockeSoulLink::DEFAULT_RELAY_URL`, overridable by a `soul_link_relay.txt`
  file next to the exe.
- **Linking:** every acquired Pokémon (catch, starter, gift, trade, hatch) is
  tagged with the area it was obtained in. Pokémon obtained before Soul Link
  was switched on fall back to the map they were met on.
- **Fusions** carry both halves' areas. A linked death of either half releases
  the whole fusion. Unfusing hands the head its own areas back; a perma-death
  survivor keeps only its half's areas.
- **Linked death:** partner's area is `dead` → your Pokémon linked to that
  area must be released (confirmation prompt; "Not now" re-asks on the next
  sync). Held item goes back to the Bag.
- **Broken link:** partner's area is `failed` (they forfeited the first
  encounter) → same release.
- **Linked boxes:** party/box mismatches are listed on the Soul Link screen,
  never enforced.
- **Cadence:** push when something changed (after battles, on map change);
  pull at most every 30 s on map change, and on demand from the screen.
  Prompts fire on the next overworld step, never mid-transfer. A dead relay
  triggers a 2-minute backoff so it can't stall the game repeatedly.
- **Reset Run** keeps the room pairing and re-publishes a fresh ledger.
- **Type clause:** not included (decision 3).

## Ledger format (one per player)

```json
{ "v": 1, "name": "Matt", "key": "Matt_12345", "updated": 1725600000,
  "areas": { "Route 3": { "species": "PIDGEY", "name": "Bird",
                          "status": "alive", "location": "party" },
             "Route 4": { "status": "dead" }, "Route 5": { "status": "failed" } } }
```
`alive` wins over `dead`, `dead` over `failed`, when the same area has several
sources.

## Deploying the relay

See `tools/soul_link_relay/README.md`. Until a URL is set the in-game screen
says the relay isn't configured.

---

# Original proposal (May 2026)

## What a Soul Link (Soullocke) is

Two players run a Nuzlocke in parallel. Encounters in the same area are
**linked**: my Route 3 catch and your Route 3 catch share one soul.

Canonical rules (Nuzlocke University / r/nuzlocke):

1. **Linked deaths** — if one linked Pokémon faints, its partner is dead too.
2. **Linked catches** — if one player fails to catch their area encounter, the
   other player's catch from that area is released ("the link is broken").
3. **Linked boxes** — linked pairs are either both in the party or both boxed.
4. **Type clause** (common) — linked Pokémon cannot share a primary type.
5. Optional: linked shinies exempt, dupes clause applies to both players' boxes.

Infinite Fusion has no networking, no multi-instance sync, and no way for one
running game to see another save. So any real 2-player Soul Link is **honor
system + bookkeeping**, or a single-player reinterpretation.

## Option A — Two-player, honor-system link ledger (recommended)

The game becomes the *ledger* for one player's side of a Soullocke. Each player
runs their own copy; the partner's state is entered by hand.

**What the game does**

- Every catch is auto-tagged with its **link key** = area name (the same key the
  catch rule already uses). Stored on the Pokémon (`pkmn.nuzlocke_link_area`).
- New **Soul Link** screen in the pause menu, listing every owned Pokémon with
  its link area and state: *Linked* / *Partner failed catch* / *Partner died*.
- Two actions per area: **"Partner failed the catch here"** (releases my
  Pokémon from that area — rule 2) and **"Partner's Pokémon died"** (perma-kills
  mine — rule 1, using the existing perma-death path so items return to the
  Bag and fusions resolve by the Head/Body/Both setting).
- Rule 3 becomes a **warning**, not a hard block: the party screen shows a
  small link icon and the Soul Link screen flags mismatches you report. (The
  game cannot know the partner's party, so it cannot enforce it.)
- Rule 4 (type clause) is enforceable *locally* only against what the partner
  reports; simplest as a toggle that makes you enter the partner's catch type
  when you record a link (Off by default).
- **Fusions:** a fusion carries the link areas of *both* halves. If either half
  is link-killed, the fusion follows the fused perma-death setting.
- **Export/import:** a "Copy link summary" option that writes
  `soul_link_<slot>.txt` (area → species → status) so partners can compare over
  Discord. No network code.

**Effort:** ~3 script files (SoulLinkLedger, SoulLinkScreen, SoulLinkRules), a
`PokemonGlobalMetadata` registry, one Pokémon attribute, tests through the
existing harness. Reuses perma-death, catch-rule and Reset Run code unchanged.

**Trade-off:** it is a good tool for people actually running a Soullocke with a
friend, but nothing is *automatic*; a dishonest partner can be ignored.

## Option B — Single-player "Fused Soul Link"

Reinterpret the link for one player: every catch is soul-linked to the
**previous catch** (or to a random living, unlinked Pokémon). When one dies,
the other dies. Linked pairs must be both in party or both boxed (this one *is*
enforceable — the PC screen can refuse the deposit/withdraw).

This is a real, self-contained challenge mode with no honor system. It doubles
the stakes of perma-death and pairs naturally with fusion: **fusing two linked
Pokémon "seals" the link** (they already share a fate), which gives the player a
genuine strategic reason to fuse.

**Effort:** smaller than A (no screen for reporting, no export), but needs a
PC-storage hook and a party-screen indicator.

**Trade-off:** it is not what most people mean by "Soul Link"; it is a new
variant. Worth doing only if the appeal is the extra difficulty rather than
playing with a friend.

## Option C — Both, sharing one ledger

A + B on the same registry: links are area-keyed; in single-player the partner
is the previous catch, in two-player the partner is whatever the player
reports. Most code is shared. Do A first, then B as a preset on top.

## Decisions needed before building

1. Which option (A is my recommendation; C if you want both eventually).
2. Rule 3 (linked boxes): warning only, or hard-enforce in single-player.
3. Type clause: include or skip.
4. Fusion ruling: does a fusion count as linked to *both* halves' partners (my
   recommendation: yes), or only the head's.
5. Should Reset Run clear the ledger (yes, it is run progress) — trivial.

## What already exists that Soul Link would reuse

- Area keys: `NuzlockeCaptureRules.current_area_key` (display name).
- Perma-death execution incl. fusions and item return:
  `NuzlockeBattleRules.process_party_after_battle` and `build_survivor`.
- Catch bookkeeping hooks: `pbThrowPokeBall` alias, `note_wild_encounter_start`.
- Persistent per-save registry pattern: `PokemonGlobalMetadata` attrs.
- Reset Run settings preservation lists.
- The boot-time test harness for suites.
