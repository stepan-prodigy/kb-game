---
title: Game DAGs
type: dag-inventory
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_game_dags.md
as_of_at_import: 2026-04-21
related:
---
Game-facing DAGs under `dags/`. See `project_dag_patterns.md` for general conventions.

## Event stream ingests

**Not all game event streams are fed by Airflow.** The current `raw_client_events.math_game_events` stream is fed by the **client-event-publisher streaming pipeline** (outside Airflow). Airflow DAGs listed below handle batch ingestion from S3.

| DAG | Feeds (raw `source` table) | Notes |
|---|---|---|
| `ingest_client_events_production.py` | `raw_client_events.game_launcher_events` (visible task) | Triggers Databricks job from `s3://prodigy-segment-events/client-event-logs/`. Tagged `client_events`. Task list may expand. |
| `ingest_client_events_staging.py` | Staging variant of above | Preprod |
| `ingest_english_game_events.py` | `raw_client_events.ela_game_events` (likely) | Verify on next review |
| `ingest_factfluency_events.py` | `fact_fluency.factfluency_events` | Fact Fluency raw events |
| `ingest_minigames_events.py` | `raw_client_events.minigames_events` | Game Island / minigames |

## Game-specific API / DB ingests

| DAG | Feeds | Notes |
|---|---|---|
| `ingest_game_api_data.py` | `source('game', ...)` — game API data | |
| `ingest_game_character_to_lake.py` | game character data | |
| `ingest_game_inventory.py` | `game.game_inventory_otp_transactions`, `game.game_inventory_otp_item_prices` | Feeds `silver/game/game_inventory_otp_*_refined` (Magicoin economy) |
| `ingest_game_survey_to_lake.py` | Game survey data | |

## `dags/math_game/` subfolder

| DAG | Purpose |
|---|---|
| `ingest_math_game_play_session.py` | Feeds `source('game', 'math_game_play_session_facts')` — critical game source for session-level facts |
| `backfill_math_game_play_session.py` | Backfill variant of the above |

## Game calendar / external

| DAG | Feeds |
|---|---|
| `ingest_burbio_key_events.py` | Burbio school calendar → `silver/math_game/burbio_key_events_combined` |

## Game-specific maintenance

| DAG | Purpose |
|---|---|
| `optimize_game_events_tables.py` | OPTIMIZE/VACUUM on game event tables in Delta Lake |

## Pipeline that runs game dbt models

All ~135 game models run daily via `dbt_e2_pipeline.py` (the manifest-driven production DAG). No game-specific dbt DAG — game models are in the main pipeline and filtered by tags.

## Dependency map (raw source → silver hub → first gold)

    client-event-publisher streaming (NOT Airflow)
      → raw_client_events.math_game_events        (bronze)
        → silver/web_events/segment_math_game_prod (hub view, 48 direct refs)
          → 27+ silver event-parsing models → gold unified events

    ingest_game_inventory.py (Airflow)
      → game.game_inventory_otp_transactions
        → silver/game/game_inventory_otp_transactions_refined
          → Magicoin economy (gold)

    ingest_math_game_play_session.py (Airflow)
      → game.math_game_play_session_facts
        → feeds math_game_sessions silver hub

    ingest_burbio_key_events.py (Airflow)
      → burbio source tables
        → silver/math_game/burbio_key_events_combined

    ingest_factfluency_events.py (Airflow)
      → fact_fluency.factfluency_events
        → silver/fact_fluency/fact_fluency_events_refined
          → fact_fluency_student_usage (gold)

For deep detail on the Math Game event hub itself, load `project_segment_math_game_prod.md`.
