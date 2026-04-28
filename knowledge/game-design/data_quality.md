---
title: Math Game — Data Quality
type: data-quality
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_math_game_data_quality.md
as_of_at_import: 2026-04-24
related:
---
**Purpose.** Operational DQ facts for Math Game event streams. Load before designing DQ rules, trusting resource aggregates, or reasoning about suspect sessions. For upstream view context see `project_segment_math_game_prod.md`; for the derived 21-column schema see `reference_common_event_log_schema.md`.

## Field integrity

| Field | Integrity class | Notes |
|---|---|---|
| Gold | client-side insecure | Arbitrary client values possible; extreme outliers observed far above the legitimate p99 distribution. Do not trust raw aggregates. |
| Pet roster size | client-side insecure | Client can report arbitrarily large rosters; outliers observed well above any legitimate long-tail value. |
| Magicoin | server-secured | No client-side inflation path. Safe to aggregate directly. |
| Level / XP | client-side modifiable | Levels outside the documented 1–150 band are suspect; cheaters may write arbitrary levels. |

## Cheater / suspect-session signature

Structural characteristics (not prevalence). A session exhibiting two or more of these is a candidate for exclusion in resource analyses:

- Shorter-than-typical duration relative to event count.
- Low event count overall; zero or near-zero pet captures.
- Outlier resource values (gold, roster) far above the legitimate distribution.
- Null or out-of-range player level.
- Repeat anomalous sessions from the same user identifier.

### Authored filters (apply when running resource/economy analyses)

- **`gold > 200000`** — exclude.
- **`pet_roster > 500`** — exclude.
- **`player_level` outside 1–150** — exclude.

Thresholds above are structural filter constants, not observed percentiles. Revisit when product-design changes shift legitimate upper bounds.

## Recommended filters by analysis type

| Analysis type | Suspect-session filter | Rationale |
|---|---|---|
| Engagement (sessions, playtime, battles, answers) | None required | Cheater impact on session-level counts is small; filtering adds more selection bias than signal. |
| Resource / economy (gold, roster, Magicoin velocity, transactions) | Apply authored filters (`gold > 200K`, `roster > 500`, level out of 1–150) | Aggregates blow up without filters because resource fields are client-insecure. |
| Conversion / monetization | Optional — apply authored filters when the metric depends on resource state; otherwise none | Conversion events are server-secured; resource-field contamination only matters for derived features. |
| Retention | None required | Retention is user-level; filtering removes legitimate power-user tails. |

## Schema drift / `_rescued_data` semantics

- `_rescued_data` is populated by Databricks Autoloader when an event contains fields that didn't match the declared schema.
- **Non-empty `_rescued_data` = schema drift.** Monitor this column if you care about unknown or newly introduced fields.
- Drift does not necessarily break a pipeline — it silently loses properties. Add a column test (`_rescued_data IS NULL` severity warn) when building a new fact/dim that depends on a specific property presence.
- When an event lands with populated `_rescued_data`, treat the unmatched fields as unmapped; do not attempt to parse them in dbt until the schema has been updated upstream.

## Freshness SLAs

Per `project_segment_math_game_prod.md`:

- Upstream `raw_client_events` source: **warn_after 24h**, **error_after 26h**.
- Stream is not an Airflow DAG — it's the client-event-publisher streaming pipeline. Alerts route to `#data-engineering-alerts`.
- Downstream freshness for derived Core-layer fact models is not separately documented; inherit the upstream SLA unless a model declares its own.

## Duplicate policy

- **Dedup key:** `messageId` (per-event GUID).
- **Test severity:** warn-only (`severity: warn`) on `messageId IS NOT NULL`, restricted to the last 7 days.
- Assume occasional duplicates will survive into silver. Incremental fact models that cannot tolerate duplicates must apply an explicit `row_number() over (partition by messageId)` filter.

## Known observability gaps

Structural gaps — areas where current event coverage is insufficient to answer common questions. Each impacts a domain of analysis.

| Gap | Impact |
|---|---|
| House decoration state and events | Cannot measure house engagement depth or decoration-as-progression signal. |
| Rift reroll cost mechanism | Cannot reconstruct the economic cost of rift rerolls from events. |
| Membership tier not emitted on events | Tier (Core / Plus / Ultra) must be joined from user dim at query time; per-event tier state not available. |
| Spell elements not extracted | Spell-effect and element-level combat analysis requires property parsing that isn't available in the common schema. |
| Friend list / social graph | Social-feature analytics impossible; PvP / duel peer structure not reconstructable. |
| End-to-end conversion funnel | Funnel-entry → checkout → renewal chain is not linkable across events in a single stream. |
| Multi-day retention linkage | Session-to-session linkage within a user is weak; cross-day cohort tracking depends on derived models, not events. |
| Battle variant not in common schema | Battle-type sub-classification (tutorial vs festival vs rift) requires joins to session context. |
| Rift run-level event linkage | Rift rounds within a run are hard to reconstruct without heuristics on timestamp ordering. |

## Pointers

- Upstream view and timestamp/partition guidance: `project_segment_math_game_prod.md`.
- 21-column common-event-log contract and per-event extraction map: `reference_common_event_log_schema.md`.
- Event-family index: `project_math_game_event_taxonomy.md`.
- Corrections / ambiguities that affect DQ interpretation: `project_math_game_corrections_and_ambiguities.md`.
