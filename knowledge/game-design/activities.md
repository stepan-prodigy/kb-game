---
title: Math Game — Activities
type: design-doc
owner: game-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_math_game_activities.md
as_of_at_import: 2026-04-24
related:
---
Parent overview: `project_math_game_product.md`.

Catalog of the major activity systems outside the main-story zones. Each entry lists structural rules relevant for DDDs and fact modeling. Magnitudes, engagement percentages, and member-mix ratios are parked — structural rules only.

## Dark Tower

- Hundred-floor sequential gauntlet. One-floor-at-a-time climbing.
- Member-gated past floor 5 — the most prominent free→paid wall in the game.
- Reward scaling via the standard rewards-scalar (see `project_math_game_combat.md`).
- Member mix skews heavily toward members due to the floor-5 gate.

## Dragon Isle and Rifts (PMR)

Unlocks after first Rift Key is earned. "PMR" = Puppet Master's Revenge, the endgame + Rift family. Two sub-systems share the Dragon Isle surface:

### Rift Runs (standard)

- Three-round structure.
- A **buff modifier** is applied from round 1.
- **Nerf modifiers stack per round** — difficulty escalates.
- **Buff choice count** is a member-vs-non-member structural asymmetry: **members get 3 buff choices, non-members 2**.
- **Pet-use-once restriction** — each pet can only participate in one round per run. Forces roster depth.

### Dragon Rifts

- Unlocked only after Puppet Master completion.
- **Single-boss-battle** format (not multi-round).
- A **Dragon Orb** gates entry; the orb is consumed **only on win** — losses preserve the orb.
- Dragon Orbs are earned from the Rift Run roulette.
- Boss types vary dramatically in difficulty — specific boss-type loss rates are directional only.

**Experimental finding:** a Member Locked Gold Rift increased WHAS and member home-battle volume. Sign positive; magnitudes parked.

## Treasure Track (TT)

- Battle-pass structure with **autocomplete quests** — quests complete silently during normal play.
- Two reward tracks: free and premium (member-only).
- **Magicoin is exclusively a member-track reward** — non-members cannot earn Magicoin via TT.
- **Reward-claim gap** — members claim substantially more rewards than non-members (free track is claimed at lower rate, partly because non-member rewards are smaller).
- Engagement scales upward by level band.
- Conversion prompts surface when non-members skip member-locked rewards.

## Festivals

- Primary seasonal / LiveOps system.
- Time-boxed events with festival-specific currencies, opponents, and prize wheels.
- Festival Battler sessions produce the highest player-level gains of any session archetype (see `project_math_game_sessions.md`).
- **Directional finding:** festival removal reduces both conversion and home-play — net-positive LiveOps driver.
- POTW (Pet of the Week) variants have shown negative effects on early-game conversion; level-gate planning under consideration.

## Wizard Dash

- Competitive math-speed mode.
- Uses the `game-challenge` QI algorithm (see `project_math_game_combat.md`).
- Structural note: reward scaling is **not applied** in Wizard Dash — excluded from the rewards-scalar.
- Completion rate is moderate — not all entries finish a full run.

## Titans

- Roaming world-boss encounters.
- Rewards include **Titan Shards** (see `project_math_game_economy.md`).
- Titan Shard full-spend cycle is partially opaque in current telemetry — see `project_math_game_data_quality.md`.

## Duels

- Player-vs-player battles.
- Structural note: reward scaling is **not applied** in Duels.
- Duels produce one of the most balanced archetypes across segments (members and non-members participate comparably relative to other modes).

## Dyno Dig

- Collection-oriented minigame.
- Rewards contribute to the broader currency and collection economy.
- Lower event volume than the core battle loop.

## House

- Customizable personal space. Decoration and item placement drive the system.
- **Observability gap:** house decoration events are incomplete in current telemetry — decoration-placement outcomes are hard to reconstruct. See `project_math_game_data_quality.md`.

## Activity interactions

- **Cross-mode pet use** — pets brought into Rifts are subject to the per-run restriction regardless of their other-mode activity.
- **Reward-scaling exclusions** — bosses, tutorials, quests, Duels, Wizard Dash are all excluded from the per-battle rewards-scalar. Hard mode applies to all non-excluded battles.
- **Conversion surfaces** — Dark Tower floor-5 gate, TT premium skip, and Rift Run buff-choice gap are the three strongest activity-driven conversion moments outside pet rescue/evolution.

## Related files

- `project_math_game_product.md` — parent overview.
- `project_math_game_combat.md` — reward-scaling rules, QI algorithms.
- `project_math_game_economy.md` — currencies, conversion triggers.
- `project_math_game_pets.md` — pet-use rules in Rifts.
- `project_math_game_sessions.md` — archetype names by activity.
- `project_math_game_world.md` — main-story zones and hard mode (distinct from activities here).
