---
title: Math Game — Analytics Taxonomy
type: analytics-taxonomy
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_math_game_analytics_taxonomy.md
as_of_at_import: 2026-04-24
related:
---
**Purpose.** Structural catalog of analytics domains, standard segmentation axes, named KPIs, and the standard guardrail pack. Load for DDD authoring, fact-model design, or framing analytics questions. Does not duplicate the fact/dim inventory in `project_canonical_fact_dim.md`; does not restate DDD section structure — see `reference_ddd_template.md` for DDD-specific authoring conventions.

## Analytics domains

| Domain | Primary questions | Feeding models |
|---|---|---|
| Core Loop | Math efficiency (answers/session, correctness), battle→answer conversion, academic yield by archetype | See `project_canonical_fact_dim.md` for available fact/dim; event-level via `reference_common_event_log_schema.md` |
| Retention | Archetype tracking, bounce vs engaged classification, level-band transitions, multi-day return, extra-core feature exposure | See `project_canonical_fact_dim.md`; session pool documented via `project_segment_math_game_prod.md` |
| Monetization | Conversion funnel effectiveness, gating resistance, school→home mode switching, Magicoin velocity, evolution-cancel signals | See `project_canonical_fact_dim.md` (economy/transactions); conversion events via `project_math_game_event_taxonomy.md` |
| LiveOps | Festival lift, Treasure Track pacing, POTW level gating, seasonal currency flow | See `project_canonical_fact_dim.md` |
| Combat Balance | Win rate, one-shot kills, attacks-to-kill, dodge/crit rates, reward-scaler distribution, rift difficulty | See `project_canonical_fact_dim.md` (battles); combat events via `project_math_game_event_taxonomy.md` |
| Onboarding | Tutorial completion (multi-session), first-session funnel, math-discovery friction, Magicoin tutorial impact | See `project_canonical_fact_dim.md`; FTUE funnels via `reference_common_event_log_schema.md` |
| Pet Economy | Capture→evolution funnel, starter abandonment, base-pet distribution, merge engagement, pet-rescue insufficiency | See `project_canonical_fact_dim.md` |

## Standard segmentation axes

Every DDD and every domain-level fact model must preserve these cuts unless explicitly out of scope:

- **Member vs non-member** (paid license at event time).
- **Level band** (named bands below).
- **Home vs school** (play context; see `client_indicated_play_location` semantics — monetization suppressed in school mode).
- **Feature-specific** axis as required (e.g., class-code vs non-class-code, device/platform, locale).

### Level bands (product-design constants)

| Band | Range | Notes |
|---|---|---|
| Onboarding | 1–5 | Tutorial territory |
| Early | 6–30 | Core adoption window |
| Early-Mid | 31–55 | Progression depth |
| Late-Mid | 56–70 | Pre-endgame ramp |
| Late | 71–90 | Zone-boss window |
| Endgame | 91–100 | Puppet Master / hard-mode unlock |
| Elder | 101–150 | Post-PM replay territory |

Levels outside 1–150 are erratic and typically client-tampered (see `project_math_game_data_quality.md`).

## KPI catalog

Names only, with one-line definition, owning domain, and directional goal. KPI baseline values are stripped from memory — look up current values in reporting dashboards.

| KPI | Definition (one-line) | Domain | Directional goal |
|---|---|---|---|
| W0 Cvr | Week-0 conversion rate of new players to paid membership | Monetization | higher = better |
| 4-week Cash / Activation | Revenue per activated user over first 4 weeks | Monetization | higher = better |
| M1 Renewal | First-month subscription renewal rate | Monetization | higher = better |
| 4-week Retention | Share of new users active in week 4 | Retention | higher = better |
| Home Rate (all-user) | Share of users with any home-context play over window | Retention | higher = better |
| Home Rate (member) | Home-rate scoped to members | Retention | higher = better |
| Member Home Rate | Synonym for member home rate | Retention | higher = better |
| Member Stickiness | Share of members active on a given measurement window | Retention | higher = better |
| WHAS | Weekly Home Active Students | Retention | higher = better |
| WRAS | Weekly Registered Active Students | Retention | higher = better |

## Standard guardrail pack

Every experiment or feature rollout must report these cuts split by the standard segmentation axes unless explicitly excluded. Effect sizes are experiment-specific and are not reported here.

- **Engagement:**
  - session rate (sessions per user per window)
  - share of users with at least one battle
  - battles per user
  - average playtime per user (overall and member)
  - home-playtime per user
- **Math activity:**
  - math-answer volume per active user
  - share of users with at least one answered question
- **Retention:**
  - D1 retention (for FTUE-affecting changes)
  - D7 retention
- **Monetization:**
  - subscription conversion rate
  - conversion-attempt volume (funnel-entered events)
  - OEC / eLTV approximation (sales price × paid-retention proxy)
  - "do-no-harm" threshold on primary monetization KPI
- **Progression:**
  - tutorial completion (for FTUE-affecting changes)
  - average level gain split by level band (guard late-game slowdown when relevant)
- **Reliability:**
  - error-event rate per session (engine, network, client errors)
  - load-failure rate during onboarding flows

## Pointers

- DDD-specific structure, hypothesis-cluster patterns, P0/P1/P2 priorities, index codes: `reference_ddd_template.md`.
- Available fact/dim models and canonical coverage gaps: `project_canonical_fact_dim.md`.
- Event families and session-activity categories feeding these domains: `project_math_game_event_taxonomy.md`.
- Common 21-column event contract: `reference_common_event_log_schema.md`.
