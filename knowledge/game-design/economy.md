---
title: Math Game — Economy
type: design-doc
owner: game-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_math_game_economy.md
as_of_at_import: 2026-04-24
related:
---
Parent overview: `project_math_game_product.md`.

Covers the game's currency system, membership tiers and gates, and the conversion-trigger catalog. Load before any economy DDD, conversion-funnel model, or currency-sink analysis.

## Currencies

| Currency | Type | Server-secured? | Primary role |
|---|---|---|---|
| Magicoin | Premium | **Yes** (server-secured) | Gates pet rescue, evolution, merge, level-up, festival prize wheel. Core monetized currency. |
| Gold | Soft | **No** (client-side, insecure) | General purchases. Caps and roster are client-insecure — see `project_math_game_data_quality.md`. |
| Zone currency | Soft, zone-scoped | Zone-scoped | Florans / Shivers / Hot-Hots / Yars / Aeros. Spent inside each zone's economy. |
| Titan Shards | Activity | Yes | Earned from Titan battles; gate Titan-specific rewards. |
| Festival currency | LiveOps | Yes | Time-boxed per festival. |

**Key integrity rule:** Gold and client-rendered roster counts are not server-validated — analytics filters must apply resource thresholds (see data-quality file). Magicoin is trustworthy.

### Magicoin sinks (top categories)

Ordered by structural volume (magnitudes parked):

1. Pet rescue — largest sink.
2. Pet merge.
3. Pet evolution.
4. Level-up items.
5. Festival prize wheel.

Magicoin *insufficiency* events (the player tries to spend and lacks Magicoin) are dominated by pet-rescue — exceeding all non-pet sinks combined.

## Membership tiers

| Tier | Position | Role |
|---|---|---|
| Free | $0 | Default. Hits paywalls at pet evolution, higher-tier captures, Dark Tower post-floor-5, TT premium track, XP boost, multi-subject. |
| Core | Entry paid | Base membership, lower Magicoin monthly cap. |
| Plus | Mid paid | Higher Magicoin cap, broader feature access. |
| Ultra | Top paid | Highest Magicoin cap, multi-subject (Math + Science + English), unlimited Game Island. |

Exact prices and Magicoin caps drift with pricing experiments and regional differences — always re-check before citing numbers in a DDD.

**Important:** membership tier is not reliably present in most individual events — see `project_math_game_data_quality.md` for the known observability gap.

### Core gates (where non-members hit a wall)

| Gate | System |
|---|---|
| Dark Tower post-floor-5 | Activity |
| Pet evolution (Magicoin cost) | Pets |
| Higher-tier pet captures | Pets |
| XP boost | Progression |
| Treasure Track premium track | Activity |
| Rift buff choices (member gets 3 vs 2) | Activity |
| Multi-subject access (Ultra) | Platform |

## Conversion triggers

Catalog of the main in-game surfaces that prompt membership purchase:

| Trigger | Where it fires | Context asymmetry |
|---|---|---|
| Member Jar | Auto-surfaced post-battle at home. Dominant conversion-impression source. | Home-only: suppressed at school. |
| After-School Widget | Post-school-hours surface on MLP. | Offers Gold (school context) or Magicoin (home context). |
| Hard Lock (Magicoin) | Triggered when a player hits a Magicoin insufficiency on a gated action (typically pet). | Works on both contexts but heavier at home. |
| Member Videos | Video-preview of member perks, surfaced in specific moments. | Launched later than Hard Lock; partially substitutes. |
| Treasure Track premium | Claim-prompt when member-only TT rewards are skipped. | All contexts. |

**School vs home asymmetry:** conversion events are structurally suppressed during school-context sessions. School is the lead-generation surface; home is the monetization surface. See `project_math_game_sessions.md` for the school-vs-home structural behavior.

**OTP (One-Time Purchase)** was a separate transactional surface; currently disabled. Do not reference as active in new DDDs.

## Monetization experiments — structural findings

Directional only; magnitudes and specific cohort effects parked. Do not quote percentages from memory.

- **Hard Lock Magicoin** initially increased conversion; effect attenuated once Member Videos launched. Both are monetization surfaces that partially substitute.
- **Member Videos** added a conversion surface; positive effect.
- **Pet cost reductions** increased evolution activity and Magicoin-spender count — positive for engagement and conversion.
- **Festival removal** reduced conversion and home-play — festivals are a net-positive LiveOps driver.
- **Wizard Bank** (a member-benefit surface) increased core-tier purchases but reduced average selling price — tier-mix effect.
- **Linear Campaign** (restricted map access) increased both level-60 reach and rift engagement — progression and retention positive.

Quantified effects live in the experiment artifact, not memory.

## Related files

- `project_math_game_product.md` — parent overview.
- `project_math_game_pets.md` — largest Magicoin sink.
- `project_math_game_activities.md` — Treasure Track, Dark Tower, festivals, rifts — all tie into tier gates.
- `project_math_game_sessions.md` — school vs home structural asymmetry.
- `project_math_game_data_quality.md` — client-side-insecure fields, membership-tier gap.
