---
title: Math Game — Combat
type: design-doc
owner: game-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_math_game_combat.md
as_of_at_import: 2026-04-24
related:
---
Parent overview: `project_math_game_product.md`.

Covers turn-based battle mechanics and the three design systems that govern balance: Combat Formula, Spell Effects, and Battle Reward Scaling. Load for any combat DDD, win-rate analysis, or reward/economy balance work.

## Battle system

Turn-based combat. Each turn the player selects an action (attack, spell, item, swap); a math question in the Question Interface (QI) must be answered for the action to resolve. The player controls the wizard plus up to 2 pets; opponents are wild creatures, zone or endgame bosses, festival opponents, roaming Titans, or other players (Duels).

Battle families:

| Family | Context |
|---|---|
| Wild encounter | Exploration in zones. |
| Boss | Zone bosses, endgame boss sequence, Puppet Master. |
| Dark Tower | 100-floor gauntlet. |
| Rift (PMR / Dragon Rift) | Post-endgame ruleset. |
| Duel | PvP. |
| Wizard Dash | Competitive math-speed mode. |
| Festival | Seasonal. |
| Titan | Roaming world boss. |

Reward and scaling rules differ by family — see Reward Scaling below and `project_math_game_activities.md` for mode-specific details.

## Math integration

Four adaptive algorithms select questions:

| Algorithm | Role |
|---|---|
| `default-strand-clusters` | Primary adaptive engine; dominant share of answers. |
| `placement-by-strand-test` | Initial assessment at onboarding level band. |
| `assignment` | Teacher-assigned content delivered silently during normal play. |
| `game-challenge` | Competitive speed mode (Wizard Dash). |

The system targets a moderate first-attempt correctness (Zone of Proximal Development). Grade 5 has a structural difficulty cliff. Multi-attempt questions are supported; support tools include hints, drawing tools, TTS, and manipulatives.

Science-subject QI events exist as a separate, smaller system with `subject="SCIENCE"`. Future architecture targets "Any Subject, Any Game" — subject-agnostic QI integration.

## Combat Formula (2025 overhaul)

Key design changes — governs all new balance analytics:

- **Dodge replaces "missed" attacks.** Dodge is now a first-class stat and outcome; older "missed" semantics are deprecated.
- **Pet base stats and growth curves rebuilt.** Pet stats are more determinative of outcomes than in prior iterations.
- **Spell damage scaled down** relative to auto-attacks, so stats matter more than spell choice.
- **Elemental relationships simplified.**

Key analytics questions tracked per Combat Formula DDD: win rate, one-shot kills, attacks-to-kill, dodge and crit rates. Standard segmentation: member × level band × battle family.

## Spell Effects

Modular status and buff effects attached to spells:

| Category | Examples |
|---|---|
| Per-element damage-over-time | Burn, Shock, Poison, etc. |
| Buffs ("Gift") | Applied at spell cast. |
| Delayed damage ("Bomb") | Resolves on a later turn. |
| Stat modifiers | Power Up/Down, Defence Up/Down, Bullseye, Regen. |

**Stacking has no cap.** This is a deliberate design choice — enables combo builds but also creates balance hotspots.

Key analytics question per Spell Effects DDD: are effects diversifying pet and spell usage? Standard segmentation: member × level band × spell.

A separate Spell Effects Tutorial DDD covers the onboarding moment where Spell Effects are introduced.

## Battle Reward Scaling

Rewards are scaled by the level difference between player and opponents via a multiplier (`rewards_scalar`):

| Relationship | Scalar direction |
|---|---|
| Player level < opponent level (disadvantage) | Scalar up — higher rewards. |
| Player level > opponent level (advantage) | Scalar down — lower rewards. |

**Hard Mode** applies a more aggressive scaling table to all battles once entered (see `project_math_game_world.md`).

**Exceptions** (scalar not applied): zone and endgame bosses, tutorial battles, quest battles, Duels, Wizard Dash.

**Member bonuses** stack on top of the scalar (approximate design ratios; exact values drift):

| Reward type | Member multiplier direction |
|---|---|
| Gold | Higher for members. |
| Zone currency | Higher for members. |
| LiveOps currency | Higher for members (largest relative bump). |
| XP (Stars) | Slight member bump. |

Reward-scalar distribution by member × level band is a standard analytics cut per the Battle Reward Scaling DDD.

## Related files

- `project_math_game_product.md` — parent overview.
- `project_math_game_world.md` — hard mode, bosses.
- `project_math_game_pets.md` — pet stats feed the Combat Formula.
- `project_math_game_activities.md` — battle-family-specific rules (Rifts, Duels, Wizard Dash).
- `project_math_game_economy.md` — currencies received from battle.
