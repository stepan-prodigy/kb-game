---
title: Example Progression Event Schema
type: event-schema
owner: data-team
last_modified: 2026-04-28
status: draft
related:
---

# Example Progression Event Schema

> Placeholder page demonstrating the kb-game frontmatter contract and content shape. Replace with a real event schema (e.g. `progression_started`, `quest_completed`) once content migration begins.

Game progression events capture player movement through the core loop: starting an activity, advancing through it, and completing or abandoning it. They are the backbone of retention and engagement analytics.

## Fields

| Field | Type | Required | Notes |
|---|---|---|---|
| `event_id` | uuid | yes | Globally unique per event. |
| `session_id` | uuid | yes | Ties to the session profile. |
| `user_id` | string | yes | Player identifier. |
| `activity_id` | string | yes | The progression unit (quest, level, world). |
| `activity_kind` | enum | yes | `quest` \| `level` \| `world` \| `event`. |
| `phase` | enum | yes | `started` \| `advanced` \| `completed` \| `abandoned`. |
| `progress_pct` | float | when phase=advanced | 0.0–1.0. |
| `client_ts` | timestamp | yes | Local device time. |
| `server_ts` | timestamp | yes | Set on ingest. |

## Notes

- `session_id` semantics for offline-played sessions are not yet pinned down — open question before this schema goes stable.
- `activity_kind=event` is reserved for time-bounded promotional content; do not reuse for permanent activities.

## Validation

Schema lives in `dippr/dbt_e2_pipelines/models/silver/events/progression.sql` (planned). Until that lands, ingest this event as `lake.bronze.events_raw` filtered on `event_name = 'progression_*'`.
