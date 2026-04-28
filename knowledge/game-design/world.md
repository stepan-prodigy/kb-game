---
title: Math Game — World & Progression
type: design-doc
owner: game-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_math_game_world.md
as_of_at_import: 2026-04-24
related:
---
Parent overview: `project_math_game_product.md`.

Covers the spatial and narrative structure of the game world and how the player progresses through it. Load when writing a world/progression DDD, modeling zone-level or boss-level facts, or reasoning about player-level progression.

## Spatial hierarchy

The world is organized as **zone → map**. A zone is a named area with one or more map screens; players resume in their last-visited zone on login. Zones include main-story zones plus activity zones (Dark Tower, Dragon Isle, festival zones, House, etc. — see `project_math_game_activities.md`).

## Main-story progression

Linear zone progression, each zone gated by a multi-step quest chain ending in a zone boss. The entire map is covered in "fog of war" (the Puppet Master's dark magic) at start; clearing quests reveals new areas.

| Order | Zone | Boss | Hard-mode mirror |
|---:|---|---|---|
| 1 | Firefly Forest | Gerald | forest_hard |
| 2 | Shiverchill Mountains | Ice Wyrm | shiverchill_hard |
| 3 | Bonfire Spire | Cebollini | bonfire_spire_hard |
| 4 | Shipwreck Shore | Old One | shipwreck_shore_hard |
| 5 | Skywatch | Cloud Boss | skywatch_hard |

Each zone has a double-digit quest count; specific counts drift with content updates.

**Pippet** is a recurring villain across all zones. **Cloaked Wizards** are special non-boss opponents with element-specific variants and appear across zones.

## Endgame boss sequence

Triggered after all five zone bosses plus keystone collection:

1. Pippet (recurring villain reappears as a gate).
2. Five Illusion Bosses — shadow versions of the zone bosses. Each is harder than the last.
3. **Puppet Master (PM)** — final boss. Reliable completion requires high-end levels of the standard bands (endgame range).

Completing PM unlocks **Hard Mode** (zone-hard mirrors) and **Dragon Rifts** (see `project_math_game_activities.md`).

**Directional finding:** an experiment reducing difficulty on Shadow Nasty Cloud and PM increased completion without harming core metrics. Sign positive; magnitude in the experiment artifact.

## Hard mode

Post-PM replay of the main campaign at higher levels. Each zone has a _hard mirror. Hard mode uses a more aggressive reward-scaling table than the base campaign — applies to all battles once entered (see `project_math_game_combat.md`). The Elder-game level band maps to hard-mode progression.

## Zone currencies

Each main-story zone has a dedicated soft currency used within that zone's economy:

| Zone | Currency |
|---|---|
| Firefly Forest | Florans |
| Shiverchill Mountains | Shivers |
| Bonfire Spire | Hot-Hots |
| Shipwreck Shore | Yars |
| Skywatch | Aeros |

Additional world-relevant currencies (Titan Shards, festival currencies, Magicoin, Gold) are catalogued in `project_math_game_economy.md`.

## Player-level progression

Player level advances via XP (called **Stars**). Rate of gain varies by gameplay stage band and by membership — members gain faster in early and mid-game. Near-zero gains at Late-game (levels 76–100), producing the "XP wall" before Endgame.

**Charged Levels are deprecated** — do not use in new models or DDDs.

Progression is driven by multiple activity families; Festival Battler-style sessions produce the highest level gains (see `project_math_game_activities.md` for festival mechanics).

Pet XP is a parallel, more-frequent progression track — covered in `project_math_game_pets.md`.

## Quests

Two roles:

- **Zone quest chains** — gate zone-boss access. Structural: each zone is a multi-step chain terminating in the boss fight. Rare per-event compared to battle/QI volume.
- **Treasure Track quests** — battle-pass autocomplete quests. Not zone-tied. See `project_math_game_activities.md`.

**Directional finding:** a Linear-Campaign experiment restricting map access and funneling players through story quests increased both level-60 reach and rift engagement. Sign positive on both; magnitudes in the experiment artifact.

## Related files

- `project_math_game_product.md` — parent overview.
- `project_math_game_combat.md` — battle mechanics, reward scaling, hard-mode scalar.
- `project_math_game_activities.md` — Dark Tower, Rifts, festivals, Titans, etc. (non-story zones).
- `project_math_game_economy.md` — currencies and gates.
- `project_math_game_pets.md` — pet progression.
