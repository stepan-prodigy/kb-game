---
title: Math Game — Sessions
type: design-doc
owner: game-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_math_game_sessions.md
as_of_at_import: 2026-04-24
related:
---
Parent overview: `project_math_game_product.md`.

Covers how a session is shaped: the tutorial path, session-duration bands as design constructs, the named archetypes used for segmentation, school-vs-home behavioral asymmetries, and the broader Prodigy platform context. Load for any session-level analytics, onboarding work, or segmentation design.

## Play-session definition

The canonical play-session boundary uses a **<20-minute event gap** — events in the same session are separated by <20 min; a longer gap closes the session. This differs from `session_uuid`, which is a WebSocket connection ID and can be shorter or longer than a play session. Always use the play-session definition for behavioral analytics.

## Tutorial flow

Multi-step, multi-session. No first session completes the full tutorial — tutorial completion is a multi-session commitment.

Canonical path:

1. First battle (wizard only; serves as the placement test via `placement-by-strand-test` algorithm).
2. Progress from level 1 to level 3.
3. Starter pet selection — 5 evo1 starters offered; members also receive the Gearsite evo2 bonus.
4. **Magicoin tutorial** — triggered only if the player is in a home context. Introduces the premium currency and the First Pet Rescue moment. Has its own DDD (First Pet Rescue).
5. Second battle — introduces pet use and capture. First wild-pet capture target: Forest Neek.
6. Tutorial marked complete; player enters Firefly Forest freely.

Tutorial suppression rules: many conversion surfaces and live-ops prompts are **suppressed during tutorial / scripted flows**. DDDs must handle this as an edge case — see `reference_ddd_template.md` (drafted separately).

## Session duration — structural bands

Session length is heavily right-skewed. Bands used for segmentation (structural; specific medians/p90s are parked):

| Band | Role |
|---|---|
| Short | Under the short-session threshold. Mix of daily check-ins, quick battles, and onboarding failures. |
| Standard | Core engagement bucket — one full loop or more. |
| Long | Multi-activity sessions, often member-at-home. |

Structural relationships (directional, no magnitudes):

- Session duration **stabilizes** around early mid-game — shorter and more variable at onboarding.
- **Members at home** produce the longest sessions.
- **School context compresses** sessions relative to home, at the same level band and membership.

## Session archetypes

Named behavioral clusters used for segmentation. Names only — specific share percentages are parked.

**Light-session archetypes** (single-loop or minimal-engagement):

- Single Battle
- Casual Battler
- Non-Combat

**Heavy-session archetypes** (multi-activity or deep engagement):

- Explorer+Battle
- Festival Battler (heavily member-skewed; produces the highest level gains)
- Battle Grinder
- Dueler
- Rift Runner

**Short-session sub-archetypes** (diagnostic breakdown of short-band sessions):

- Daily Check-in (healthy; most short sessions)
- Quick Battle
- Onboarding Load Failure
- Onboarding Incomplete Tutorial
- Mid-Tutorial Returnees
- Anomalies

Use these names when segmenting; do not invent new names.

## School vs home — structural asymmetry

Two play-context signals exist and must be disambiguated:

| Signal | Meaning | Trustworthiness |
|---|---|---|
| `estimated_play_location` | Inferred from time-of-day and usage patterns | Noisier but always present. |
| `client_indicated_play_location` | Client-declared context; player-/product-selectable | Authoritative when present; **used by the client to suppress monetization in school mode**. |

Structural asymmetries (directional, no magnitudes):

| Dimension | School sessions | Home sessions |
|---|---|---|
| Duration | Shorter | Longer |
| Battle volume | Fewer battles | More battles |
| Conversion-event volume | **Suppressed by client** | Dominant surface |
| Archetype mix | Tilts toward Light | Tilts toward Heavy |
| Member Jar | Suppressed | Auto-surfaced post-battle |

School is the lead-generation surface; home is the monetization surface. Home-play rate is the single most-watched structural metric. See `project_math_game_economy.md` for the conversion-trigger catalog.

## Cross-product platform context

The broader Prodigy platform includes Game Island, Math Facts, and Prodigy English (see `project_math_game_product.md`). Structural context for math-game analytics:

- **Ultra membership** unlocks multi-subject access and unlimited Game Island — cross-product value perception is largest at the top tier.
- **Game Island promotion** on the MLP is under active experimentation (MLP Experiment). Aggressive member-locking on Game Island has been shown to reduce overall engagement.
- **Cross-game identity** — consistent identity mapping across products is required for cross-product analytics; coverage is weaker for cross-game flows than for the core math RPG. Analysts should verify player-id join coverage before producing cross-product metrics.
- **Prodigy English** (Village Builder) is a separate subject product, not a math-game mode. Cross-product flow is primarily through MLP and membership.

## Related files

- `project_math_game_product.md` — parent overview.
- `project_math_game_activities.md` — activity-driven archetypes map here.
- `project_math_game_economy.md` — conversion-trigger mechanics, tier gates.
- `project_math_game_pets.md` — onboarding pet moments.
- `project_math_game_world.md` — zone progression.
