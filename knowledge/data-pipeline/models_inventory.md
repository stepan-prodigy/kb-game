---
title: Game Models — Inventory (curated)
type: models-inventory
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_game_models_inventory.md
as_of_at_import: 2026-04-21
related:
---
**~135 game models across 4 games.** For full Math Game detail (file paths, materializations, descriptions, fact/dim coverage), load `artifact_math_game_inventory.md`. English Game, Fact Fluency, and Game Island aren't in the artifact — see below.

## Math Game (~100 models)
- **Raw event source:** `source('web_events', 'segment_math_game_prod')` — the hub, 88+ downstream refs
- **Other raw inputs:** `source('game', 'math_game_play_session_facts')`, `source('game', 'game_all_events_categorized_v2')`, historical pre-2022 cold-start sources
- **Silver** (52 in `silver/game/`, 1 in `silver/math_game/`): event parsing, sessions, battles, pets, gear, items, Magicoin v1/v2, progression, funnels, payments
- **Gold** (45 in `gold/game/`): `math_game_student_usage` (34+ downstream refs — the analytics hub), `math_game_battles`, `math_game_magicoin_transactions_unified`, treasure-track quests, KPIs, experiments, OTP/licensing
- **Unified event view:** `events/math_game_event_views`
- Full inventory: `artifact_math_game_inventory.md`

## English Game (~18 models)
- **Raw event source:** `source('web_events', 'segment_ela_game_prod')`
- **Silver** (`silver/english_game/`): sessions (base, active, answers, location, timezone), accumulating user facts (install, FTUE, activate, village), membership, experiment assignments, fog/exploration
- **Gold** (`gold/english_game/`): `english_game_daily_user_facts`, `english_game_accumulating_user_facts`, `english_game_session_facts`, `english_game_experiment_assignment_facts`
- **Unified event view:** `events/english_game_event_views`

## Fact Fluency (~13 models)
- **Raw event source:** `source('fact_fluency', 'factfluency_events')`
- **Silver** (`silver/fact_fluency/`): `fact_fluency_events_refined`, `fact_fluency_play_session_facts`, `student_ff_*` (entry, events, question_answered/shown, race_start/end, device_context, session_device_details), `teacher_ff_events`, `teacher_ff_events_all`
- **Gold**: `fact_fluency_student_usage`

## Game Island (~3 models)
- **Raw event source:** ingested via `silver/web_events/`
- **Silver**: `game_island_play_session_facts`, `game_island_events_refined`
- **Gold**: `game_island_student_usage`

## Cross-game components
- **Game Launcher** — `silver/web_events/game_launcher_events` (entry point for all games)
- **Activated sessions across games** — `gold/core/all_games_activated_sessions`
- **Parent-side reverse ETL** — `gold/reverse_etl/parent_student_played_game`, `_v2`

## Payments & revenue (cross-game, critical for every game's analytics)

Payments data sits outside the game folders but feeds every game's revenue, conversion, and membership-lifecycle analytics. Source of truth for real-money transactions, membership state, and FX.

- **Raw sources:**
  - `silver/payments/payments_sources.yml` — Prodigy payments service
  - `silver/stripe/stripe_sources.yml` — Stripe webhooks and invoices
  - `silver/netsuite/netsuite_sources.yml` — accounting system (bookings, FX rates)
- **Silver hubs:**
  - `payments_transactions_refined` — canonical transaction table
  - `netsuite_usd_exchange_rate_refined`, `historical_usd_exchange_rate` — FX for non-USD revenue
- **Gold hubs:**
  - `gold/core/paid_licenses`, `paid_license_dim` — license/subscription state
  - `gold/memberships/dim_membership_package` — SKU dimension
  - `gold/memberships/fact_access_code_redemption` — OTP/access-code redemptions
  - `gold/core/paid_membership_status_daily`, `agg_paid_membership_conversions`, `agg_paid_membership_churn_rates` — membership lifecycle KPIs
  - `gold/core/daily_cashbooking_stats`, `core_metrics_cashbooking` — revenue recognition
- **Game-side consumers:**
  - Math Game: `math_game_user_payments` → `math_game_daily/weekly/monthly_user_payments`; `math_game_licenses_flattened`; `math_game_member_weekly`, `math_game_member_monthly`
  - English Game: membership models in `silver/english_game/`
  - Cross-game aggregates: `agg_paid_membership_conversions`, `agg_paid_membership_churn_rates`
- **In-game economy (virtual currency — NOT real money, tracked separately):**
  - Silver: `math_game_economy_price_aggs_by_level`, `game_inventory_otp_transactions_refined`, `game_inventory_otp_item_prices_refined`
  - Gold: `math_game_magicoin_transactions_unified`, `math_game_magicoin_user_daily_unified` (v1+v2 merged)

## Non-game connection points (where game models read from other domains)

Finance/payments are covered separately in § Payments & revenue above.

| Domain | Upstream model | Consumed by |
|---|---|---|
| Identity | `users_refined` (silver/core) | 34+ game models incl. `math_game_student_usage` |
| Identity | `identity_session_summary` | `math_game_ftue_funnel` |
| Identity | `identity_daily_login_summary` | `math_game_student_usage` |
| Identity | `student_registration_origin` | 3+ game models |
| Education | `answers_users_daily_aggregate` | `math_game_student_usage` (direct feed) |
| Education | `daily_teacher_activity_summary` | student-usage joins |
| Education | `parent_student_attachment_history` | reverse-ETL parent joins |
| Dimensions | `date_dimension`, `chosen_grade_dim` | many game models |
| Location | `livedata_teacher_location_dim*`, `livedata_school_locations*`, `geo_location_countries` | location joins in usage/KPI models |

For the reverse direction (non-game models that read game output), see `project_game_lineage.md` → "Cross-Domain Consumers of Game Models."

## Source YAML files (game + payments)
- `silver/game/game_sources.yml` — core game events (math_game_play_session_facts, game_all_events_categorized_v2, etc.)
- `silver/game/magicoin_sources.yml` — in-game currency raw tables
- `silver/game/experiment_sources.yml` — OTP/experiment assignment raw tables
- `silver/game/math_game_economy_sources.yml` — economy/pricing Google Sheets (16 tables)
- `silver/game/math_game_sessions_source.yml` — session data
- `silver/math_game/burbio_sources.yml` — Burbio school calendar
- `silver/fact_fluency/fact_fluency_source.yml` — FF raw events
- `silver/web_events/web_events_sources.yml` — Segment streams (math, ela, launcher)
- `silver/payments/payments_sources.yml`, `silver/stripe/stripe_sources.yml`, `silver/netsuite/netsuite_sources.yml` — revenue sources
