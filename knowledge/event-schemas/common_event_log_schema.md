---
title: Common Event Log Schema
type: event-schema-contract
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/reference_common_event_log_schema.md
as_of_at_import: 2026-04-24
related:
---
The canonical 21-column common event log contract derived from `segment_math_game_prod` joined to the session pool and the external segmentation sheet. Use this when authoring DDDs, designing fact/dim models, or running schema-aware event analysis where a consistent shape across event types is required.

## Relationship to `project_segment_math_game_prod.md`

- `project_segment_math_game_prod.md` documents the **upstream raw view** — schema is whatever Segment/client-event-publisher emits, varying JSON `properties` per event type.
- **This file** defines the **derived 21-column contract** on top of that view: session-metadata join, explicit event ordering, and a 4-column collapse of the per-event payload into reviewable semantic slots.

## The 21 columns

### Core Identity (3)

| Column | Type | Source | Semantics |
|---|---|---|---|
| `user_id` | STRING | `e.userId` | Session owner identity |
| `calendar_date` | DATE | `e.event_received_date` | Partition anchor |
| `session_uuid` | STRING | `properties:session_uuid` | Session grouping key; universal across all event types |

### Session Metadata (4 — joined from session pool)

| Column | Type | Source | Semantics |
|---|---|---|---|
| `session_level` | INT | `s.level` | Player level at session start; stable segmentation axis |
| `is_member` | BOOLEAN | `s.is_member` | Membership gate — critical segmentation axis |
| `estimated_play_location` | STRING | `s.estimated_play_location` | Time-based heuristic (school if 8am–4pm weekday, else home) |
| `client_indicated_play_location` | STRING | `s.client_indicated_play_location` | Player's chosen game mode in client. May be NULL. Matters because `"school"` mode suppresses most monetization triggers in favor of play-at-home prompts. |

### Event Identity & Timing (5)

| Column | Type | Source | Semantics |
|---|---|---|---|
| `server_timestamp` | TIMESTAMP | `e.receivedAt` | Server receipt time — canonical ordering clock |
| `event` | STRING | `e.event` | Event name (e.g. `Battle Started`) |
| `event_order` | INT | `ROW_NUMBER() OVER (PARTITION BY user_id, session_uuid ORDER BY receivedAt)` | Explicit sequence within session |
| `seconds_since_last_event` | INT | `LAG(receivedAt)` window | Gap analysis |
| `minutes_since_last_event` | DECIMAL | Derived from above | Human-readable gap for manual review |

### High-Frequency Context (4)

| Column | Type | Source | Semantics |
|---|---|---|---|
| `player_level` | INT | `properties:level` | Real-time level during event; tracks within-session progression |
| `map_name` | STRING | `properties:map` | Current map screen within zone (e.g., `B3`, `C8`) |
| `zone_name` | STRING | `properties:zone` | Current zone — major navigable area (e.g., `lamplight`, `forest`) |
| `session_activity` | STRING | `COALESCE(ui_override_case, seg.session_activity, 'unmapped')` | Feature/activity classification; see UI override rules below |

### 4-Column Collapsing Pattern (context_*)

Per-event `CASE WHEN` collapses the most important payload into four semantic slots. Each slot has a consistent meaning across event types.

| Column | Type | Semantic Role | Typical Values |
|---|---|---|---|
| `context_name` | STRING | Primary identifier — "what" | `button_name`, `item_name`, `pet_name`, `battle_type`, `experiment_id` |
| `context_info` | STRING | Secondary qualifier — "detail" | `source_type`, `npc_type`, `outcome`, `interface_name`, `variation_id` |
| `context_amount` | STRING | Numeric / quantity (STRING for flexibility across int/decimal) | `item_count`, `duration`, `mp_recovered`, `progression_value`, `pet_rarity` |
| `context_id` | STRING | Linking / tracking identifier | `transaction_id`, `battle_id`, `instance_id`, `skill_id`, `funnel_id` |

### Audit (1)

| Column | Type | Source | Semantics |
|---|---|---|---|
| `properties` | STRING | `e.properties` | Raw JSON payload; fallback for fields not extracted into the 4 context columns |

## Worked examples of the 4-column collapse

**Battle event — `Battle Action Performed`:**
- `context_name` = `action_name` (e.g. `basic_attack`)
- `context_info` = `target_name`
- `context_amount` = `action_damage`
- `context_id` = `battle_id`

**Economy event — `Item Received`:**
- `context_name` = `item_name`
- `context_info` = `source_type`
- `context_amount` = `item_count`
- `context_id` = `transaction_id`

**UI event — `Button Clicked`:**
- `context_name` = `button_name`
- `context_info` = `COALESCE(destination_name, interface_name)`
- `context_amount` = NULL
- `context_id` = `instance_id`

## UI override rules

Generic UI events (`Button Clicked`, `Interface Opened`, `Tab Clicked`) would otherwise collapse into a single `ui` `session_activity`. The schema layers overrides to reclassify them to feature-specific activities by inspecting `button_name` / `interface_name` / `tab_name`:

| Pattern match (LOWER + LIKE) | Reclassified `session_activity` |
|---|---|
| `button_name = 'map-button'` | `world` |
| `interface_name IN ('world_map', 'zone_goals')` | `world` |
| text contains `treasure%track` | `treasure_track` |
| text contains `festival` | `festival` |
| text contains `store` | `economy` |
| `tab_name = 'Gear'` | `gear` |

Priority order: UI override first, then the base segmentation-sheet value, then `'unmapped'`.

## Excluded ubiquitous properties

These properties appear in most event types but are excluded from the schema because they add no differentiating value for session review:

| Property | Appears in | Why excluded |
|---|---|---|
| `subject` | nearly all events | Always present, never differentiating |
| `game_locale` | most events | Too coarse for session-level analysis |
| `charged_level` | most events | Redundant with `session_level` / `player_level` |
| `is_school_hours` | most events | Derivable from timestamp; redundant with `estimated_play_location` |
| `difficulty_tier` | most events | Too coarse for most analyses |

Available in raw `properties` for any analysis that needs them.

## SQL skeleton

Pseudocode showing the join shape and where the CASE-WHEN collapsing lives. Full ~500-line implementation lives in Confluence 6101434383.

```sql
WITH session_events AS (
  SELECT
    e.event_received_date, e.userId, e.receivedAt, e.event, e.properties,
    s.level AS session_level, s.is_member,
    s.estimated_play_location, s.client_indicated_play_location,
    seg.session_activity AS base_session_activity
  FROM production.silver.segment_math_game_prod e
  INNER JOIN adhoc.game.stepan__session_pool_standard s
    ON e.userId = CAST(s.user_id AS STRING)
   AND e.event_received_date = s.calendar_date
   AND e.properties:session_uuid = s.session_uuid
  LEFT JOIN fivetran.google_sheets.game_event_segmentation seg
    ON e.event = seg.event
  WHERE e.event_received_date = <date>
)
SELECT
  -- Core Identity, Session Metadata, Event Identity, Timing ...
  ROW_NUMBER() OVER (PARTITION BY userId, properties:session_uuid ORDER BY receivedAt) AS event_order,
  TIMESTAMPDIFF(SECOND, LAG(receivedAt) OVER (...), receivedAt) AS seconds_since_last_event,
  -- High-Frequency Context ...
  COALESCE(
    CASE  -- UI override rules
      WHEN event = 'Button Clicked' AND properties:button_name = 'map-button' THEN 'world'
      WHEN event IN ('Button Clicked','Interface Opened','Tab Clicked')
           AND LOWER(COALESCE(properties:interface_name, properties:button_name, properties:tab_name, ''))
               LIKE '%treasure%track%' THEN 'treasure_track'
      -- ... festival, economy, world, gear
      ELSE NULL
    END,
    COALESCE(base_session_activity, 'unmapped')
  ) AS session_activity,
  -- 4-column collapse: per-event CASE WHEN ...
  CASE WHEN event = 'Battle Action Performed' THEN properties:action_name
       WHEN event = 'Item Received' THEN properties:item_name
       -- ... ~85 event types
  END AS context_name,
  -- context_info, context_amount (CAST AS STRING), context_id similarly
  properties  -- raw audit
FROM session_events
```

## Known ad-hoc dependencies

**Flag: ad-hoc; may churn.** Two upstream inputs to the contract are not productionized:

| Dependency | What it is | Churn risk |
|---|---|---|
| `adhoc.game.stepan__session_pool_standard` | Session pool carrying `level`, `is_member`, play-location signals per `(user_id, calendar_date, session_uuid)`. Ad-hoc, single-owner. | High — artifact is a personal workspace table; any refresh or rename breaks the join. |
| `fivetran.google_sheets.game_event_segmentation` | External Google Sheet mapped via Fivetran, supplying base `session_activity` per `event`. | High — living sheet; new events or renames invalidate specific rows. Individual CASE branches break when properties are added/renamed. The *patterns* (4-column collapse, UI override layer) are durable. |

Both should be productionized before downstream fact/dim models materialize off this contract.

## Pointers

- Full executable SQL: Confluence 6101434383.
- Schema narrative and per-event extraction rationale: Confluence 6101106712.
- Event taxonomy index (which event covers what): `project_math_game_event_taxonomy.md`.
- Upstream raw view: `project_segment_math_game_prod.md`.
