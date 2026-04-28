---
title: Math Game — Product
type: design-doc
owner: game-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_math_game_product.md
as_of_at_import: 2026-04-24
related:
---
Single-page summary of what Prodigy Math Game is and how its parts fit together. Load this before any math-game product question; from here, route to the system-specific files listed under Related files.

## Identity

Prodigy Math Game is a freemium, curriculum-aligned RPG targeting grades 1–8 (ages ~6–14). It embeds math questions into turn-based combat: academic effort is the energy that powers gameplay. Positioned so kids "beg to play at home" while teachers and parents see learning gains.

## Core loop

Explore → Battle → Solve Math → Earn Rewards → Power Up.

1. **Explore** a world map organized as zone → map. Fog-of-war ("Puppet Master's dark magic") is cleared by completing zone quests.
2. **Battle** turn-based against wild creatures, bosses, festival opponents, or other players. Wizard plus up to 2 pets.
3. **Solve Math** via the Question Interface (QI), which gates each action. Four adaptive algorithms select questions (see combat/activities files).
4. **Earn Rewards** — XP (called Stars), gold, zone currencies, gear, pet capture opportunities. Rewards scale by level difference.
5. **Power Up** — XP advances player and pet levels, unlocking zones, gear, and pet evolutions.

Battle is the dominant activity family. See `project_math_game_combat.md`.

## Stakeholders

Three groups shape the product and any analytics work must segment for them:

- **Students** — experience it as a game. Direct engagement target.
- **Teachers** — use it as a curriculum tool with assignments and tracking. Drive school-context usage.
- **Parents** — make purchasing decisions for membership. Drive home-context monetization.

## Platform context

The broader Prodigy platform has multiple products; Math Game is the core. Other products affect math usage primarily via cross-promotion and Ultra-tier value perception.

| Product | Role |
|---|---|
| Prodigy Math Game | Core math RPG. This KB. |
| Prodigy English | Village Builder, separate subject. |
| Game Island | Hub for single/multiplayer minigames (aka Prodigy Arcade). |
| Math Facts | Fact-fluency practice. |

See `project_math_game_sessions.md` for cross-product context signals.

## Tier structure

| Tier | Price point | Role |
|---|---|---|
| Free | $0 | Default. Capped access to conversion-gated systems. |
| Core | entry paid tier | Base membership features. |
| Plus | mid paid tier | Higher Magicoin cap, more features. |
| Ultra | top paid tier | Multi-subject (Math, Science, English) and unlimited Game Island. |

Exact prices and caps drift; see `project_math_game_economy.md` for tier gates and currencies.

## Standard gameplay stage bands

Used for all segmentation. Levels outside 1–150 are erratic and may reflect client-side manipulation.

| Band | Levels |
|---|---|
| Onboarding | 1–5 |
| Early game | 6–30 |
| Early mid-game | 31–55 |
| Late mid-game | 56–70 |
| Late game | 71–90 |
| Endgame | 91–100 |
| Elder game | 101–150 |

## Key product-design constants

- 5 main-story zones with 5 zone bosses, then endgame boss sequence ending at the Puppet Master.
- 100-floor Dark Tower, member-gated past floor 5.
- Pets have 4 evolution stages; ~100+ species across starter, base, and evolvable families.
- 885 math skills across 131 strands in 55 curricula.
- 21-column common event log with a 4-column collapsing pattern.

## Related files

- `project_math_game_world.md` — zones, story progression, bosses, hard mode, quests, player level progression.
- `project_math_game_pets.md` — capture → level → evolve → merge → team lifecycle; Gearsite; conversion role.
- `project_math_game_combat.md` — battle system, Combat Formula, Spell Effects, Reward Scaling.
- `project_math_game_economy.md` — currencies, membership tiers and gates, conversion triggers.
- `project_math_game_activities.md` — Dark Tower, Rifts, Treasure Track, Festivals, Wizard Dash, Titans, Duels, Dyno Dig, House.
- `project_math_game_sessions.md` — tutorial flow, session duration bands, archetype names, school vs home context.

Data-pipeline views (complement, don't duplicate):

- `project_segment_math_game_prod.md` — source view for Math Game events.
- `project_game_models_inventory.md` — dbt model inventory.
- `project_game_lineage.md` — model dependency graph.
- `project_game_dags.md` — Airflow ingestion DAGs.

Schema/analytics/DQ files are drafted separately (e.g. `reference_common_event_log_schema.md`, `project_math_game_event_taxonomy.md`, `project_math_game_data_quality.md`).
