---
title: Authoring Gaps — Drafting Templates
type: authoring-gaps
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_authoring_gaps.md
as_of_at_import: 2026-04-24
related:
---
This file catalogues gaps where a drafting/authoring task has **no dedicated `reference_*` template in memory**. It mirrors the pattern of `reference_ddd_template.md` — a stable authored contract that the user iterates on — for every task type that still lacks one.

Each entry: what's missing, current fallback, candidate future file, priority relative to the four target task types (DDD generation, dbt aggregate drafting, DQ checks, analytics engineering).

## Existing authoring templates (for reference)

| Task | File | Prefix |
|---|---|---|
| DDD drafting | `reference_ddd_template.md` | `reference_` |
| Airflow DAG authoring | `project_dag_patterns.md` | `project_` (has "Conventions when adding a DAG" section; not in `reference_` because naming predates the prefix) |
| Common event log contract | `reference_common_event_log_schema.md` | `reference_` |

## Gaps

### Gap 1: dbt model authoring/drafting (HIGH — blocks "dbt aggregate drafting" task type)

**What's missing.** There is no prescriptive "how to draft a new dbt model" reference. Current memory has descriptive content only:
- `project_dippr_overview.md` — what's configured (layers, post-hooks, CI)
- `project_dbt_macros.md` — catalog of ~55 custom macros
- `project_canonical_fact_dim.md` — what fact/dim models exist
- `project_game_models_inventory.md` / `artifact_math_game_inventory.md` — what exists

**Specifically missing:**
- Layer placement rules (when silver vs gold vs gold_pii vs semantic vs workspace)
- Materialization choice rules (view / table / incremental, with decision criteria)
- Naming conventions (model, CTE, column, test, schema, alias)
- Primary-key / grain conventions
- Audit columns conventions (`created_at`, `updated_at`, `batch_id`, `_dbt_loaded_at`)
- Required `meta` fields (owner group, tags, description)
- Incremental merge patterns — when to use `get_incremental_merge_since_sql`, `batch_load_offset_date`, unique-key patterns
- Required tests per layer (unique, not_null, relationships, freshness, custom generic)
- `schema.yml` structure — required columns, description conventions
- CTE and file structure patterns
- Event-ingestion-specific patterns (using `create_event_view`, event-family folder layout)
- CI registration / tag conventions (`dbt`, `daily`, `weekly`, `dbt_source`)

**Current fallback.** Confluence page *"dbt transformation guidelines"* (page ID 6039142402, space DGD) — referenced from the old Math Game KB but not verified recently. Plus `AGENTS.md` (testing commands only).

**Candidate future file.** `reference_dbt_model_template.md` — top-level MEMORY.md under "dbt project work (general)".

**Task-type relevance.** Critical for *dbt aggregate drafting*. High for *analytics engineering*. Medium for *DQ checks* (materialization affects DQ strategy).

### Gap 2: Data quality rule authoring (MEDIUM — blocks "DQ checks" task type)

**What's missing.** A general DQ-rule authoring template. Currently:
- `project_math_game_data_quality.md` — Math-Game-scoped DQ facts (cheater thresholds, filter rules, known gaps)
- `project_dbt_macros.md` — lists filter macros

**Specifically missing:**
- How to write a dbt generic test (schema.yml + custom test macros)
- When to use `dbt_expectations` vs dbt built-ins vs custom SQL tests
- Elementary test configuration patterns (anomaly detection, volume tests, freshness)
- Threshold selection conventions (warn vs error; absolute vs relative)
- Slack `#data-alerts` routing conventions
- `_rescued_data` handling patterns
- Expectations for Silver → Gold handoff tests

**Current fallback.** None documented in memory. Likely tribal/conventional; may exist in unscanned Confluence or in code examples under `dbt_e2_pipelines/tests/`.

**Candidate future file.** `reference_dq_test_template.md` — top-level MEMORY.md under "dbt project work (general)".

**Task-type relevance.** Critical for *DQ checks*. Medium for *dbt aggregate drafting*.

### Gap 3: Python utils authoring (LOW)

**What's missing.** No conventions file for new `utils/` modules. `project_utils_modules.md` catalogs what exists but does not prescribe.

**Specifically missing:**
- Module structure / public vs private API
- Type hints policy (mandatory? partial?)
- Error handling patterns (raise vs return None vs tuple)
- Logging and metrics conventions
- Testing requirements (when is a unit test required per AGENTS.md)
- When to extract a new module vs extend an existing one
- Dependency import rules (stdlib / third-party / internal)

**Current fallback.** AGENTS.md testing note; convention-by-inspection of existing utils.

**Candidate future file.** `reference_python_utils_template.md` — top-level MEMORY.md under "Airflow / Python utils". Lower priority since task volume is lower.

**Task-type relevance.** Medium-low for all four task types.

### Gap 4: dbt `schema.yml` / test / documentation authoring (SUBSET OF GAP 1)

Could be its own file or a section within `reference_dbt_model_template.md`. Either way noted here so it doesn't get lost.

**Specifically missing:** column description conventions, required column-level tests, model-level `config` vs `meta` placement, YAML ordering conventions.

### Gap 5: Segment / client-event-publisher event model authoring (LOW-MEDIUM)

**What's missing.** How to add a new event table to the silver events layer. `create_event_view` macro exists (documented in `project_dbt_macros.md`), but no end-to-end authoring recipe for a new event type.

**Specifically missing:**
- Where `create_event_view` callers live
- How to hook a new event into the client-event-publisher stream
- Naming conventions for event tables
- Segment tracking plan registration (Google Sheet `fivetran.google_sheets.game_event_segmentation`)
- `context_*` extraction pattern for new events

**Current fallback.** `reference_common_event_log_schema.md` (contract only, not authoring flow). Existing event models under `dbt_e2_pipelines/models/events/`.

**Candidate future file.** Could be a section in `reference_dbt_model_template.md` or a separate `reference_event_model_authoring.md`.

**Task-type relevance.** Medium for *dbt aggregate drafting* when the aggregate depends on a new event.

## Priority order for filling gaps

1. **Gap 1** (dbt model template) — blocks the single highest-frequency task type and the largest source of surface-area uncertainty in new work.
2. **Gap 2** (DQ rule template) — blocks a target task type; smaller scope than Gap 1.
3. **Gap 4** (schema.yml) — merge into Gap 1.
4. **Gap 5** (event model authoring) — merge into Gap 1 or defer.
5. **Gap 3** (Python utils) — lowest task-type volume; defer.

## Update procedure

When a gap gets filled:
1. Create the `reference_*` file.
2. Remove the gap entry below or mark it as "closed — see `reference_<name>.md`".
3. Update MEMORY.md (or MEMORY_*.md sub-router) with a routing entry for the new reference.
4. Register the file in `meta_memory_system.md` inventory.

This file stays around to record open gaps and to make them visible when a drafting task starts.
