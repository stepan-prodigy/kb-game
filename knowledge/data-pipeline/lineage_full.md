---
title: Game Models — Full Lineage
type: lineage
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/artifact_game_lineage.md
as_of_at_import: 2026-04-25
related:
---
**Source.** Original deep lineage scan was 2026-03-17 (~92k tokens). This version applies corrections verified during the 2026-04-23 deep memory review and re-confirmed 2026-04-25. Counts reflect reality at re-verification, not at original scan.

**How to apply:** Use as the authoritative lineage map for game-model dependency questions. The curated summary in `project_game_lineage.md` is faster but less detailed.

---

## Critical Hub Models

| Model | Layer | Direct Refs | Role |
|---|---|---|---|
| `segment_math_game_prod` | Silver/web_events | **48** | Master event hub — feeds nearly everything via a 3-window union (see `project_segment_math_game_prod.md` for upstream source detail) |
| `math_game_student_usage` | Gold | **29** | Core user-level analytics hub — still the most-referenced gold model in the repo |
| `math_game_sessions` | Silver | **17** | Session backbone |
| `math_game_user_milestones` | Gold | **14** | Milestone backbone |
| `math_game_daily_cohort_membership` | Silver | 10+ | Experiment/cohort assignment engine |

Note: prior memory claimed "88+ / 34+ / 20+ / 15+" for these — corrected against `dbt ls` and grep counts during the 2026-04-23 review.

---

## Primary Data Paths

### Path 1 — Main Event Stream (CRITICAL)

`segment_math_game_prod` is itself a dbt **`ref()`** (silver-layer materialized view), not a `source()`. It unions three time-windowed upstream sources:

- pre-2024-02-26: `source('web_events', 'segment_math_game_events')` (legacy Segment)
- 2024-02-26 → 2025-10-20: `source('client_events', 'historical_all_math_game_events_frozen_2025_10_20')`
- post-2025-10-20: `source('raw_client_events', 'math_game_events')` (current client-event-publisher)

See `project_segment_math_game_prod.md` for full upstream detail.

Downstream:
```
ref('segment_math_game_prod')
  → ~27 silver event parsing models (incremental)
    → silver aggregation layer
      → gold core models
```

### Path 2 — Student Usage Hub (CRITICAL)
```
math_game_sessions + users_refined + math_game_user_milestones
  + game_daily_battles + answers_users_daily_aggregate + 8 more
    → math_game_student_usage [gold]
      → 25+ gold and cross-domain consumers
```

### Path 3 — Experiment/Cohort Path
```
segment_math_game_prod + users_refined + math_game_student_usage
  + math_game_user_milestones + tt_mc_experiment_assignments
    → math_game_daily_cohort_membership [silver]
      → math_game_experiment_participant [gold]
        → math_game_core_cta_funnel_kpis
        → otp_reconstructed_assignments_daily
```

### Path 4 — Battle Unification
```
segment_math_game_prod + historical_math_game_battle_refined
  → math_game_battle_participants
    → math_game_battle_participant_outcomes
      → math_game_battles → game_daily_battles
```

### Path 5 — Pet Lifecycle
```
segment_math_game_prod + math_game_pet_properties + historical sources
  → math_game_pet_acquired → math_game_pet_roster_timeline
  → math_game_pet_evolved, math_game_pet_released, math_game_pet_roster
```

### Path 6 — Economy/Magicoin (v2 unified)

Current state uses v2 and unified variants. v1 names (`math_game_magicoin_transactions`, `_fill_balance`, `_user_daily`) may be deprecated; verify against current dbt graph.

```
math_game_item_received + math_game_sessions + rounded_pet_centre_item_not_received
  + math_game_interface_opened + math_game_button_clicked + math_game_student_usage
    → math_game_magicoin_transactions_v2 (and `_unified` variants)
      → downstream economy aggregates and gold/memberships consumers
```

See `project_game_models_inventory.md` § payments for the full unified-vs-v1 picture.

### Path 7 — Historical Cold Start (ephemeral, narrow)

5 ephemeral pre-2022 models used only in `math_game_ftue_funnel` and `math_game_pet_acquired` for incremental seeding.

---

## Cross-Domain Consumers of Game Models

These non-game gold models depend on game outputs — confirms which game models are load-bearing:

| Consumer | Depends On |
|---|---|
| `core/student_activity_daily` | `math_game_student_usage` |
| `core/all_games_activated_sessions` | multiple game models |
| `core/daily_license_status` | `math_game_student_usage` |
| `core/school_milestones` | `math_game_student_usage` |
| `core/daily_school_activity_snapshot` | `math_game_student_usage` |
| `core/user_journey_conversion_rates` | `math_game_student_usage` |
| `finance/conversion_by_activated_cohort` | `math_game_student_journey`, `math_game_student_usage` |
| `finance/daily_pacing/math_activations` | `math_game_student_usage` |
| `finance/daily_pacing/math_mras` | `math_game_student_usage` |
| `education/students_time_on_task_daily` | `math_game_student_usage` |
| `education/students_time_on_task_by_location_daily` | `math_game_student_usage` |
| `education/curriculum_progress_monthly` | `math_game_battles` |
| `growthbook/growthbook_student_activation` | `math_game_student_usage` |
| `ml/membership_conversion_features` | `math_game_student_usage` |
| `segment_events/segment_math_funnel_*` | `math_game_student_usage` |
| `teacher/educators_experiments_math_*` | `math_game_student_usage` |
| `total_platform/total_platform_student_usage` | `math_game_student_usage` |
| `state_challenge/math_game_student_suspicious_activity` | `math_game_student_usage` |

---

## Non-Game Dependencies (Referenced BY Game Models)

### User/Identity
- `users_refined` — **59 refs / 68 occurrences** (most-referenced non-game model across game stack — significantly more central than prior memory claimed)
- `student_registration_origin` — 3+ refs
- `identity_session_summary` — `math_game_ftue_funnel`
- `identity_daily_login_summary` — `math_game_student_usage`

### Dimensions/Lookups
- `date_dimension`, `paid_licenses`, `paid_license_dim`, `chosen_grade_dim`
- `livedata_teacher_location_dim`, `livedata_school_locations_refined`, `livedata_school_locations_nces_refined`
- `geo_location_countries`

### Education Platform
- `daily_teacher_activity_summary`, `daily_active_parents`
- `teacher_student_attachment_teacher_attribution_history`
- `parent_student_attachment_history`
- `answers_users_daily_aggregate` — feeds directly into `math_game_student_usage`

### Finance/Payments
- `payments_transactions_refined` → `math_game_user_payments`
- `historical_usd_exchange_rate`, `netsuite_usd_exchange_rate_refined`

### Raw Sources (via source())

| Source | Key Tables |
|---|---|
| `game` | `math_game_play_session_facts`, `game_assets`, `game_all_events_categorized_v2`, `game_inventory_otp_item_prices`, `game_inventory_otp_transactions` |
| `web_events` | `segment_math_game_events` (legacy, pre-2024-02-26), `segment_ela_game_prod` |
| `client_events` | `historical_all_math_game_events_frozen_2025_10_20` (cutover frozen window) |
| `raw_client_events` | `math_game_events` (current — fed by client-event-publisher streaming pipeline, not an Airflow DAG) |
| `fact_fluency` | `factfluency_events` |
| `experiment_sources` | `otp_assignment`, `member_otp_assignment`, `non_member_otp_assignment` |
| `magicoin_sources` | `rounded_pet_centre_item_not_received` |
| `math_game_economy_google_sheets` | 13 sheets feeding `math_game_shop_inventory_refined` |
| `live_ops_calendar_source` | `live_ops_calendar` |
| `tt_mc_experiment_assignments` | `tt_mc_assignment` |

---

## Dead Ends (Silver models with no known gold or cross-domain consumers)

Identified during 2026-03-17 scan; **not re-verified 2026-04-25** — treat as deprecation candidates pending current-state confirmation. May be queried directly from BI tools.

`math_game_battle_actions`, `math_game_battle_resumed`, `math_game_session_fps`, `math_game_sessions_ordered`, `math_game_daily_play`, `math_game_pet_details_viewed`, `math_game_pet_merge_cancelled`, `math_game_player_gear_equipped`, `math_game_player_progression_restricted`, `math_game_inventory_gear`, `math_game_zone_map_visits`, `math_game_user_game_geo_location_locale_daily`, `math_game_funnel_advanced`, `math_game_student_funnel`, `math_game_economy_low_currency_events`, `math_game_session_started`, `math_game_daily_technical_metric_aggs`, `game_daily_student_sink`, `game_daily_student_ww_usage`, `student_ff_question_answered`, `student_ff_question_shown`, `student_ff_session_device_details`, `english_game_fog_removed`

---

## Potential Redundancies

| Issue | Models |
|---|---|
| Duplicate session representations | `math_game_sessions` (active) vs `math_game_sessions_ordered` (unreferenced) |
| Synthetic cohort duplication | `math_game_daily_cohort_membership` vs `math_game_daily_cohort_membership_synthetic` — unclear if both are needed |
| OTP assignment layering | 4 separate models (`otp_assignments`, `member_otp_assignments`, `non_member_otp_assignments`, `otp_reconstructed_assignments_daily`) for one concept |
