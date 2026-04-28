---
title: Canonical Fact/Dim Coverage
type: fact-dim-coverage
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_canonical_fact_dim.md
as_of_at_import: 2026-04-25
related:
---
**Why:** A knowledge-base project proposed canonical `fact_student_answer`, `fact_student_session`, `fact_battle`, `fact_economy_transaction`, `dim_student`, `dim_membership`, `dim_teacher`, `dim_classroom`. Only some exist today.

**How to apply:** When asked about canonical fact/dim coverage or data modeling gaps, reference this. For full per-model detail (materializations, descriptions, test coverage), load `artifact_math_game_inventory.md`.

## Existing fact_/dim_ models (as of 2026-04-20)

**Fact (9):** `fact_fluency_student_usage` (gold), `fact_fluency_events_refined` (silver), `fact_fluency_play_session_facts` (silver), `fact_session_event` (silver/web_events), `fact_user_login` (silver/web_events), `fact_access_code_redemption` (gold/memberships), `fact_district_event` (silver/school), `fact_school_digger_attributes` (silver/school), `fact_school_digger_attributes_district` (silver/school).

**Dim (7):** `dim_user` (silver/core), `dim_user_pii` (gold_pii/core), `dim_membership_package` (gold/memberships), `dim_school_digger_school` (silver/school), `dim_school_digger_level` (silver/school), `dim_school_digger_district` (silver/school), `dim_school_digger_school_location_pii` (gold_pii/school).

## Canonical set proposed vs. reality

| Proposed | Status | Existing substitute |
|---|---|---|
| `fact_student_answer` | PLANNED, not built | — |
| `fact_student_session` | PLANNED, not built | `math_game_sessions` (silver) covers game sessions |
| `fact_battle` | Substituted | `math_game_battles` (gold/game) |
| `fact_economy_transaction` | Substituted | `math_game_magicoin_transactions_v2` (gold/game) |
| `dim_student` | PLANNED, not built | `dim_user` + `users_refined` partial coverage |
| `dim_membership` | Substituted | `dim_membership_package` (gold/memberships) |
| `dim_teacher` | PLANNED, not built | — |
| `dim_classroom` | PLANNED, not built | — |
