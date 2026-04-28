---
title: Math Game — Models Inventory (full)
type: models-inventory
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/artifact_math_game_inventory.md
as_of_at_import: 2026-04-20
related:
---
# Prodigy Math Game dbt Model Inventory

**Generated:** 2026-04-20
**Project Root:** `/Users/stpn/Documents/repos/dippr/.claude/worktrees/suspicious-cartwright-ff7d40/dbt_e2_pipelines/`

---

## 1. Project Overview

**Project Name:** `prodigy_dbt` (v1.0.0)  
**Profile:** `databricks`  
**Warehouse:** Databricks Unity Catalog  
**File Format:** Delta Lake (auto-optimize enabled on all models)

### Targets and Schema Conventions

| Target | Catalog | Silver Schema | Gold Schema | Gold PII Schema |
|--------|---------|---------------|-------------|-----------------|
| `e2_dev` / `e2_dev_full` | `sandbox_dbt` | `silver` | `gold` | `gold_pii` |
| `e2_prod` | `production` | `silver` | `gold` | `gold_pii` |
| `staging` | `preprod` | `staging_silver` | `staging_gold` | `staging_gold_pii` |

### Default Configuration

- **Materialization:** Models use explicit configs; common patterns: `incremental` (merge strategy, liquid-clustered), `table`, `view`, `ephemeral`
- **Persist Docs:** `{"relation": true, "columns": true}` for silver/gold layers
- **Default Tags:** `["dbt", "daily"]` applied to all silver and gold models
- **Elementary Testing:** Disabled by default (`enable_elementary_models = false`); disabled alerts for duplicate suppression (16-hour interval)

---

## 2. Model Counts by Layer

| Layer | Total SQL Models |
|-------|------------------|
| **Silver** | 408 |
| **Gold** | 350 |
| **Gold PII** | 22 |
| **Events** | 2 |
| **TOTAL** | **782** |

### Game-Related Subfolder Breakdown

| Subfolder | Count |
|-----------|-------|
| `silver/game/` | 52 |
| `silver/math_game/` | 1 |
| `silver/game_island/` | 1 |
| `gold/game/` | 45 |
| `gold/game_island/` | 1 |
| `events/` (math_game_event_views) | 1 |
| **Game Ecosystem Total** | **101** |

---

## 3. Math Game Models — Full Inventory

### Silver Layer — Math Game & Game Event Models (53 models)

#### `models/silver/game/` (52 models)

**Materialization Summary:** 31 incremental, 6 table, 4 ephemeral, 1 view

High-level categories:
- **Sessions & Gameplay:** math_game_session_started, math_game_sessions_ordered, math_game_sessions, math_game_daily_play
- **Progression & Milestones:** math_game_student_funnel, math_game_student_annual_milestones, math_game_player_progression
- **Economy & Purchases:** math_game_user_payments, math_game_daily/weekly/monthly_user_payments, math_game_economy_price_aggs_by_level
- **Battles:** math_game_battle_actions, math_game_battle_resumed, historical_math_game_battle_refined
- **Items & Inventory:** math_game_item_received, math_game_item_removed, math_game_inventory_gear, game_inventory_otp_transactions_refined
- **Pets:** math_game_pet_details_viewed, math_game_pet_merged, math_game_pet_merge_cancelled
- **Gear/Shop:** math_game_player_gear_equipped, math_game_player_gear_first_received, math_game_shop_gear_purchased, math_game_shop_gear_previewed, math_game_shop_inventory_refined
- **Magicoin Economy:** math_game_magicoin_currency_events, math_game_magicoin_insufficient_currency, math_game_magicoin_session_balance
- **Engagement/Funnels:** math_game_segment_membership_cta_funnel, math_game_funnel_advanced
- **UI/Technical:** math_game_button_clicked, math_game_interface_opened, math_game_session_fps
- **Geography & Cohorts:** math_game_user_game_geo_location_locale_daily, math_game_daily_cohort_membership, math_game_daily_cohort_membership_synthetic
- **Quests/Zones:** math_game_quest_progress, math_game_zone_map_visits
- **Historical/Archived:** historical_game_discovery, historical_game_social, historical_game_source, game_sink (all ephemeral, cutoff pre-2022-11-07)

#### `models/silver/math_game/` (1 model)
- **burbio_key_events_combined:** Combined Burbio calendar/event data (incremental)

---

### Gold Layer — Math Game Analytics (45 models)

**Materialization Summary:** 26 incremental, 12 table, 7 other

High-level categories:
- **Core Engagement:** math_game_student_usage, math_game_monthly/weekly_student_usage, math_game_mobile_student_usage
- **Journey & Milestones:** math_game_student_journey, math_game_student_idle_time, math_game_user_milestones
- **Battles:** math_game_battles, math_game_daily_mobile_battles, battle_start/complete/participants/participant_outcomes (unified_events)
- **Magicoin Economy (v2):** math_game_magicoin_transactions_v2, math_game_magicoin_user_daily_v2
- **Magicoin Unified (v1+v2):** math_game_magicoin_transactions_unified, math_game_magicoin_user_daily_unified
- **Pets:** math_game_pet_properties, math_game_pet_merge_summary, pet_roster/roster_timeline/acquired/evolved/released (unified_events)
- **Gear:** math_game_gear_properties
- **Quests:** math_game_treasure_track_quest_complete, math_game_treasure_track_quest_progress
- **Endgame Content:** math_game_rift_runs, math_game_endgame_funnel, math_game_tutorial_complete
- **FTUE:** math_game_ftue_funnel (unified_events)
- **KPIs:** math_game_core_engagement_kpis, math_game_core_cta_funnel_kpis (core_kpi subfolder)
- **Experiments:** math_game_experiment_participant
- **Licensing:** math_game_licenses_flattened
- **OTP System:** otp_assignments, member_otp_assignments, non_member_otp_assignments, otp_reconstructed_assignments_daily, tt_mc_experiment_assignments, rounded_pet_centre_item_not_received
- **Membership:** math_game_member_weekly, math_game_member_monthly (math_game_member subfolder)
- **Cross-Game:** game_daily_battles, live_ops_calendar

#### `models/gold/game_island/` (1 model)
- **game_island_student_usage:** Game Island student usage/engagement (table)

---

### Event Views

#### `models/events/` (1 math game event view)
- **math_game_event_views:** Unified event view for real-time math game analytics (view)

---

## 4. Shared / Cross-Cutting Models (non-game but used by game)

| Model Name | File Path | Layer | Type | Purpose |
|-----------|-----------|-------|------|---------|
| dim_user | silver/core/ | silver | table | User dimension base |
| users_refined | silver/core/ | silver | table | Refined user attributes (user_type) |
| all_games_activated_sessions | gold/core/ | gold | incremental | Cross-game session activation |
| education_events_question_interface | silver/education/ | silver | incremental | Question interface events |
| all_math_game_events | silver/web_events/ | silver | incremental | Consolidated math game web events |
| segment_math_game_prod | silver/web_events/ | silver | incremental | Segment math game production events |
| fact_access_code_redemption | gold/memberships/ | gold | incremental | OTP/license redemption facts |
| dim_membership_package | gold/memberships/ | gold | table | Membership package dimensions |
| parent_student_played_game | gold/reverse_etl/ | gold | table | Student game play data for parent sync |
| parent_student_played_game_v2 | gold/reverse_etl/ | gold | table | v2 parent game play sync |

---

## 5. Canonical Fact/Dim Models — Present vs. Planned

### Existing Fact/Dim Models (16 total)

| Model Name | File Path | Layer | Type | Materialization |
|-----------|-----------|-------|------|-----------------|
| **Fact Models** | | | |
| fact_fluency_student_usage | gold/fact_fluency/ | gold | fact | table |
| fact_fluency_events_refined | silver/fact_fluency/ | silver | fact | incremental |
| fact_fluency_play_session_facts | silver/fact_fluency/ | silver | fact | table |
| fact_session_event | silver/web_events/ | silver | fact | incremental |
| fact_user_login | silver/web_events/ | silver | fact | incremental |
| fact_access_code_redemption | gold/memberships/ | gold | fact | incremental |
| fact_district_event | silver/school/ | silver | fact | incremental |
| fact_school_digger_attributes | silver/school/ | silver | fact | incremental |
| fact_school_digger_attributes_district | silver/school/ | silver | fact | incremental |
| **Dim Models** | | | |
| dim_user | silver/core/ | silver | dim | table |
| dim_user_pii | gold_pii/core/ | gold_pii | dim | table |
| dim_membership_package | gold/memberships/ | gold | dim | table |
| dim_school_digger_school | silver/school/ | silver | dim | incremental |
| dim_school_digger_level | silver/school/ | silver | dim | incremental |
| dim_school_digger_district | silver/school/ | silver | dim | incremental |
| dim_school_digger_school_location_pii | gold_pii/school/ | gold_pii | dim | table |

### Expected but Not Yet Built

- **fact_student_answer** — PLANNED (question-level answer facts)
- **fact_student_session** — PLANNED (covered by `math_game_sessions` in context)
- **fact_battle** — PRESENT as `math_game_battles`
- **fact_economy_transaction** — PRESENT as `math_game_magicoin_transactions_v2`
- **dim_student** — PLANNED (could extend dim_user)
- **dim_membership** — PRESENT as `dim_membership_package`
- **dim_teacher** — PLANNED
- **dim_classroom** — PLANNED

---

## 6. Sources (from sources.yml)

### Source Blocks Summary

| Source File | Source Names | Total Tables |
|-----------|-------------|-------------|
| silver/game/game_sources.yml | game | 8 |
| silver/game/experiment_sources.yml | experiment_sources | 3 |
| silver/game/magicoin_sources.yml | magicoin_sources, magicoin_gold_sources (legacy) | 3 |
| silver/game/math_game_economy_sources.yml | math_game_economy_google_sheets | 16 |
| silver/game/math_game_sessions_source.yml | game (silver layer) | 1 |
| silver/math_game/burbio_sources.yml | burbio | 5 |
| silver/fact_fluency/fact_fluency_source.yml | fact_fluency | 1 |
| silver/web_events/web_events_sources.yml | web_events | 3 |
| silver/core/core_sources.yml | core | 3+ |
| silver/identity/identity_sources.yml | identity | 2 |
| silver/education/education_sources.yml | elsi, education_raw | 6+ |

**Total Registered Sources:** ~11  
**Total Source Tables (game-related):** ~51

---

## 7. Tests & Documentation Coverage

### Schema Documentation by Subfolder

| Location | YAML Files | Est. Documented Models | Estimated % |
|----------|-----------|------------------------|------------|
| silver/game/ | 13 | ~40 of 52 | ~77% |
| silver/math_game/ | 2 | 1 of 1 | 100% |
| gold/game/ | ~30 | ~40 of 45 | ~89% |
| **Math Game Total** | ~45 | ~81 of 98 | ~83% |

### Generic Test Patterns

Across math-game schema.yml files:
- **unique** — ~60 models tested on `_surrogate_key` or user/session combos
- **not_null** — ~55 models tested on session_id, user_id, calendar_date
- **relationships** — ~30 models with FK integrity tests
- **dbt_utils.recency** — ~8 models (data freshness, 1–3 day SLAs)
- **elementary.volume_anomalies** — ~4 models (e.g., `math_game_play_session_facts`)
- **dbt_expectations** — Minimal use (~2 models)

**Overall Test Coverage:** ~70 of 98 math-game models have ≥1 column test.

### Elementary Data Observability

- **Status:** Disabled by default (`enable_elementary_models = false`)
- **Models:** Stored under `models/silver/elementary/edr/`, `data_monitoring/`, `run_results/`, `system/`
- **Purpose:** Data quality monitoring, alerting, and observability
- **Config:** Alerts disabled in dbt_project.yml (lines 36–45)

---

## Key Insights

1. **Game Ecosystem Scale:** 101 models across silver/gold covering sessions, battles, economy, pets, gear, quests, and engagement metrics.

2. **Materialization Strategy:** Heavily incremental with liquid clustering (performance optimization). Tables for aggregates and snapshots. Ephemeral for archived historical data (cutoff pre-2022-11-07).

3. **Economy Versioning:** Magicoin system has explicit v2 (post-2026-01-01) alongside legacy v1, unified via transparent view models.

4. **OTP/Licensing:** Parallel fact tables for assignments (member, non-member, general) plus reconstruction models for experiment tracking.

5. **Documentation:** 83% of game models have schema descriptions; silver/game subfolder has gaps (~23% undocumented).

6. **Test Coverage:** ~70% of models include column-level tests (unique, not_null, relationships); freshness and volume anomaly checks on key tables.

7. **Event Architecture:** Raw events → domain-specific refinements → unified analytic views (battle, pet, FTUE funnels).

8. **Canonical Dims:** No game-specific `dim_student` or `dim_classroom` yet; `dim_user` and `dim_membership_package` are reused.

---

## File Location

**Inventory Path:** `/Users/stpn/math_game_dbt_inventory.md`
