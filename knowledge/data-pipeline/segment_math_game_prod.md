---
title: segment_math_game_prod (Hub)
type: data-source
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_segment_math_game_prod.md
as_of_at_import: 2026-04-21
related:
---
## What it is

Silver-layer **materialized view** at `models/silver/web_events/segment_math_game_prod.sql`. Unions three upstream sources across three time windows to present a single continuous Math Game event stream.

- **No storage** — it's a view; queries hit underlying sources live.
- **Schema:** `silver` (dev/prod) or `staging_silver` (preprod).
- **Not a source.** Despite the name, it's a dbt `ref()`, not a `source()`. Naming predates the Segment → client-event-publisher cutover.

## Upstream (time-windowed unions)

| Window | Source | Notes |
|---|---|---|
| `event_received_date <= 2024-02-26` | `source('web_events', 'segment_math_game_events')` | Legacy Segment stream (decommissioned) |
| `2024-02-26 < date <= 2025-10-20` | `source('client_events', 'historical_all_math_game_events_frozen_2025_10_20')` | Frozen snapshot |
| `date > 2025-10-20` | `source('raw_client_events', 'math_game_events')` | Current client-event-publisher stream |

Cutover dates:
- **2024-02-26** — Segment → client-event-publisher migration
- **2025-10-20** — frozen snapshot ceased; current source takes over

Queries spanning these dates cross source boundaries; schema is aligned at the view layer.

## Schema

Standard Segment event shape:

| Column | Notes |
|---|---|
| `anonymousId` | Anon ID; set pre-login |
| `userId` | Authenticated user id (nullable) |
| `messageId` | Unique per event; dedup key (not_null test is `severity: warn` for last 7 days only) |
| `event` | **Event name** (e.g. `battle_started`, `pet_acquired`). Primary filter. |
| `type` | Segment type: `track`, `identify`, `page` |
| `properties` | struct/JSON — event-specific payload. Query with dot-path or `from_json`. |
| `context` | struct/JSON — client context (device, UA, timezone, app version) |
| `traits` | struct/JSON — identity traits |
| `timestamp`, `originalTimestamp`, `receivedAt`, `sentAt` | Multiple timestamps — see Gotchas |
| `event_received_date` | Partition column; use this for filtering |
| `ingest_date`, `ingest_time` | Ingest provenance |
| `projectId` | Source project. Post-2025-10-20 hardcoded to `math-game-events`. |
| `version`, `channel` | Schema version (`"2"` or `"3"`) and channel (`"client"`) — differ per window |
| `integrations` | Segment integration flags |
| `_rescued_data` | Databricks Autoloader — fields that didn't match schema. Non-empty means drift. |
| `src_filename` | Source file provenance |

## Sibling: `all_math_game_events`

Same directory. Simpler view — unions only post-2024-02-26 sources (frozen + current). Use it when pre-2024-02-26 data isn't needed.

## Downstream (48 direct refs)

- **Silver event parsing** (~27): `math_game_session_started`, `math_game_battle_actions`, `math_game_pet_merged`, `math_game_item_received`, `math_game_interface_opened`, `math_game_button_clicked`, etc. — per-event extraction.
- **Silver aggregates** (~5): `math_game_daily_cohort_membership`, `math_game_segment_membership_cta_funnel`, `math_game_daily_technical_metric_aggs`, `math_game_funnel_advanced`, `math_game_user_game_geo_location_locale_daily`.
- **Gold unified events** (~8): `math_game_unified_events/*` — `battle_start/complete/participants`, `pet_acquired/evolved/released`, `ftue_funnel`.
- **Gold analytics**: `math_game_battles`, `math_game_endgame_funnel`, `math_game_rift_runs`, `math_game_treasure_track_quest_*`, `math_game_student_idle_time`, `math_game_student_suspicious_activity`, `ml/membership_conversion_features`, reverse-ETL parent models.
- **Events layer**: `events/math_game_event_views.sql`.
- **Non-game**: `segment_pageviews`, `spam_redacted_users`, `parent__student_locked_feature_access_attempted`.

## Query patterns

- **Filter by `event` first** — the `properties` JSON structure varies per event name.
- **Extract properties** — `properties:field` dot-path (Databricks SQL) or `from_json(properties, schema)` for typed access.
- **Use `event_received_date` for partition pruning**, not `timestamp` or `receivedAt`.
- **Dedup on `messageId`** — test is warn-only; assume occasional duplicates.

## Gotchas

- **Multiple timestamps:** `timestamp` is client-adjusted; `receivedAt` is server receipt; `originalTimestamp` is client-raw. Prefer `receivedAt`-derived `event_received_date` for windowing.
- **Schema parity across cutovers:** `projectId`, `version`, `channel` differ per time window. Don't rely on consistency — pivot on `event_received_date` if you need window-specific behavior.
- **`_rescued_data` non-empty signals schema drift.** Monitor if you care about unknown fields.
- **`messageId` not_null is `severity: warn`** — assume occasional duplicates.
- **Freshness:** upstream `raw_client_events` has `warn_after: 24h`, `error_after: 26h`. Current stream is NOT an Airflow DAG — it's the client-event-publisher streaming pipeline. Alerts hit `#data-engineering-alerts`.

## Related streams

- `all_math_game_events` — post-2024-02-26 only (simpler).
- `source('raw_client_events', 'math_game_events')` — raw current stream.
- `source('raw_client_events', 'game_launcher_events')`, `'minigames_events'`, `'ela_game_events'` — sibling game streams.
- `source('web_events', 'segment_math_game_events')` — legacy Segment tail (pre-2024-02-26).
