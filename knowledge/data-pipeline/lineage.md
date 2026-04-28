---
title: Game Models — Curated Lineage
type: lineage
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_game_lineage.md
as_of_at_import: 2026-04-25
related:
---
**How to apply:** Use this for quick lineage questions. Load `artifact_game_lineage.md` for full lineage detail (cross-domain consumer table, raw sources, dead-ends, redundancies). Load `project_segment_math_game_prod.md` for the central event hub's upstream source detail.

---

## Critical Hub Models

| Model | Layer | Direct Refs | Role |
|---|---|---|---|
| `segment_math_game_prod` | Silver | 48 | Master event hub. A `ref()`, not a `source()` — internally unions 3 time-windowed upstream sources (see `project_segment_math_game_prod.md`). |
| `math_game_student_usage` | Gold | 29 | Core user-level analytics hub. Most-referenced gold model in the repo. |
| `math_game_sessions` | Silver | 17 | Session backbone. |
| `math_game_user_milestones` | Gold | 14 | Milestone backbone. |
| `math_game_daily_cohort_membership` | Silver | 10+ | Experiment/cohort assignment engine. |

---

## Primary Data Paths (summaries)

- **Path 1 — Main Event Stream.** `ref('segment_math_game_prod')` → ~27 silver event-parsing models → silver aggregations → gold core models. The hub is itself a ref(), not a source. Upstream 3-window union detail: `project_segment_math_game_prod.md`.
- **Path 2 — Student Usage Hub.** `math_game_sessions` + `users_refined` + `math_game_user_milestones` + 8 more → `math_game_student_usage` → 25+ gold/cross-domain consumers.
- **Path 3 — Experiment/Cohort.** `segment_math_game_prod` + identity + cohort sources → `math_game_daily_cohort_membership` → `math_game_experiment_participant` → `math_game_core_cta_funnel_kpis`.
- **Path 4 — Battle Unification.** `segment_math_game_prod` + historical → `math_game_battle_participants` → `_outcomes` → `math_game_battles` → `game_daily_battles`.
- **Path 5 — Pet Lifecycle.** `segment_math_game_prod` + pet properties → `math_game_pet_acquired` → `_roster_timeline` → `_evolved`, `_released`, `_roster`.
- **Path 6 — Economy/Magicoin (v2 unified).** Item events + sessions + interface events → `math_game_magicoin_transactions_v2` (and `_unified` variants). v1 names may be deprecated; verify against current dbt graph.
- **Path 7 — Historical Cold Start.** 5 ephemeral pre-2022 models for incremental seeding (narrow use).

---

## Most Load-Bearing Non-Game Dependency

- `users_refined` — **59 refs / 68 occurrences** in game models. Most-referenced non-game model across the game stack — significantly more central than prior memory claimed.

For the full non-game dependency map, raw-source table, cross-domain consumer list, and dead-ends, load `artifact_game_lineage.md`.

---

## Dead-ends and redundancies (high-level)

- **23 silver models** with no known dbt downstream consumers (deprecation candidates pending business-context confirmation; may be queried by BI tools). Full list in `artifact_game_lineage.md`.
- **Known redundancies:** `math_game_sessions_ordered` likely duplicate of `math_game_sessions`; OTP assignment models layered across 4 separate models; cohort membership has a synthetic variant of unclear purpose.
