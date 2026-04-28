---
title: Math Game — Corrections & Ambiguities
type: corrections
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_math_game_corrections_and_ambiguities.md
as_of_at_import: 2026-04-24
related:
---
**Purpose.** Track claims that have been corrected vs earlier external research, and remaining open ambiguities that should not be asserted as fact. Load before relying on any product claim whose provenance is external research (Gemini Web Research, Fandom wiki, older marketing copy) or a pre-v4.1 knowledge base. Authoritative product claims live in `project_math_game_product.md` and the sibling system files; this file is the "don't get tricked" list.

## Confirmed corrections

| Incorrect claim | Original source | Correction | Source of correction |
|---|---|---|---|
| "Stars is a separate currency" | Fandom wiki / Gemini Web Research | Stars = XP; there is no separate Stars currency. | v4.1 KB § Progression |
| "Charged Levels are active in the game" | Older product docs | **Charged Levels are deprecated.** Do not reference in new DDDs or models. | v4.1 KB § Progression; also in `project_math_game_world.md` |
| "`tower_town` event = Dark Tower" | Event-name pattern matching | `tower_town` is a distinct surface and **does not** correspond to the Dark Tower activity. | v4.1 KB § Corrections |
| "Crystal Caverns is a current zone" | Older marketing / wiki | Crystal Caverns has been **removed** from the active game. | v4.1 KB § Corrections |
| "Dodge is a new mechanic alongside Missed" | Prior combat docs | Dodge **replaces** "Missed" attacks in the 2025 combat overhaul. | Combat Formula DDD; v4.1 KB |
| "Spell choice dominates combat outcome" | Older meta guides | Spell damage was scaled down so that **stats are more important than spell choice**. | Combat Formula DDD; v4.1 KB |
| "OTP is a current conversion channel" | Marketing pages | OTP (one-time-purchase) is currently **disabled** in product. | v4.1 KB § Economies |
| "Evolutions are free" | Casual/wiki framing | Evolutions cost Magicoin and are the core conversion wall. | v4.1 KB § Pet System |
| "Base pets are evolving endgame pets" | Imprecise terminology | Base pets are **non-evolving** endgame species, distinct from starters. | v4.1 KB § Pet System |
| "Member tiers include only Free and Premium" | Older pricing copy | Tier structure is Free / Core / Plus / Ultra, with Ultra granting multi-subject access. | v4.1 KB § Monetization |
| "Monetization is equally active in school and home" | External assumption | Monetization prompts are **suppressed in school mode** (`client_indicated_play_location`). | v4.1 KB § School vs Home |
| "`session_uuid` = play session" | Event-naming assumption | `session_uuid` is a WebSocket connection ID, **not** a play session. Play session = <20-min event gaps. | v4.1 KB § Session Measurement |
| "Rift pets have no pet-use restriction" | Older guides | Rift Runs enforce a **pet-use-once restriction** across rounds. | PMR & Rifts DDD; v4.1 KB |
| "Dragon Orb is consumed on entry" | Wiki | Dragon Orb is consumed **only on win** of the Dragon Rift boss battle. | PMR & Rifts DDD; v4.1 KB |
| "Dark Tower is fully free" | Marketing | Dark Tower is **member-gated past floor 5**. | v4.1 KB § Activities |
| "All battles use the same reward formula" | Older design | **Hard mode uses a more aggressive scaler**; bosses, tutorials, quests, duels, Wizard Dash are exceptions. | Battle Reward Scaling DDD |
| "Gearsite is a generic starter pet" | Marketing | Gearsite is a **member-exclusive evo2 bonus** pet from tutorial. | v4.1 KB § Pet System |

## Remaining ambiguities

Open items where the mechanism or semantic is not confirmed. Do not assert these as fact without fresh verification.

- **Rift reroll cost mechanism** — the economic cost structure of rerolling rift modifiers is not reconstructable from current events. Impact: cannot model reroll economy or friction.
- **Titan Shard full lifecycle** — the full earn→spend cycle for Titan Shards is not fully documented; specific sinks and cap behavior are unclear. Impact: seasonal-currency analytics underspecified.
- **`astralDragon` difficulty interpretation** — the extreme loss rate on `astralDragon` boss is not clearly explained (design intent vs. bug vs. mechanic interaction). Impact: combat-balance reporting on this boss is unreliable.
- **`play_at_home_video` targeting** — who is shown `play_at_home_video` events and under what triggers is not clearly documented. Impact: cannot segment exposure or measure lift cleanly.
- **`_rescued_data` canonical remediation path** — when a drift is detected, there is no documented single-source playbook for who updates the schema and on what cadence. Impact: silent property loss can persist.
- **Multi-day session linkage** — whether a given analytics model should treat multi-session play as a single behavioral unit is not standardized. Impact: retention and tutorial-completion measurement designs vary across DDDs.
- **Membership tier on events** — tier (Core / Plus / Ultra) is not emitted per-event; the canonical way to attach tier for analysis is not standardized across models.
- **Science / non-math subject QI integration** — "Any Subject, Any Game" architecture is aspirational; current event coverage for non-math QI is thin and not fully mapped.

## Superseded research pointers

- **Archived page 6106382338** and **Web Research page 6101663754** may still contain pre-correction claims (especially on Stars, Charged Levels, `tower_town`, Crystal Caverns, pricing). Treat any claim sourced from those pages with suspicion and verify against the items above.
- The previous monolithic artifact `artifact_prodigy_math_game_knowledge_base.md` was a summary of v4.1 KB; if corrections in this file conflict with that artifact, this file wins.

## Pointers

- Authoritative product claims: `project_math_game_product.md` (and sibling `project_math_game_*` system files — combat, economy, world, pets, activities).
- Event contract and surface semantics: `reference_common_event_log_schema.md`, `project_math_game_event_taxonomy.md`.
- DQ consequences (schema drift, suspect sessions) that interact with some ambiguities: `project_math_game_data_quality.md`.
