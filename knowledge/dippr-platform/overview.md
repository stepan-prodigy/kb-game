---
title: dippr Platform Overview
type: platform-overview
owner: data-platform-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_dippr_overview.md
as_of_at_import: 2026-04-25
related:
---
**DIPPR** (Data Ingest Platform Programmatic Resources) is Prodigy Game's dbt analytics repo. Covers all game products (Math, English, Fact Fluency, Game Island) and business domains (education, marketing, finance, teacher, parent).

See `AGENTS.md` for project structure, testing rules, and commands. This file covers what's not there.

## Stack
- dbt >= 1.7.0, profile: `databricks`, warehouse: Databricks Unity Catalog
- Delta Lake with auto-optimize + deletion vectors
- Airflow (118+ DAGs) on Kubernetes
- Elementary v0.20.0 + Slack alerts to `#data-alerts`
- CI/CD: GitHub Actions, PRs against `develop`

## Environments / targets

| Target | Catalog | Purpose |
|---|---|---|
| `e2_dev` | `sandbox_dbt` | Local dev (default) |
| `e2_dev_full` | `sandbox_dbt` | Full dev runs |
| `e2_prod` | `production` | Production (30 threads) |
| `staging` | `preprod` | CI/staging (50 threads) |
| `ci` | `preprod` | GitHub Actions |

## Model layers (as of 2026-04-20, ~782 total)
- **Silver** (~408): refined/staged data by source domain
- **Gold** (~350): business-ready aggregations
- **Gold PII** (~22): PII-isolated; owned by EdCROWs
- **Events** (2): raw event view definitions

## Key packages
`dbt_utils` v1.1.1, `spark_utils` v0.3.0, `elementary` v0.20.0, `dbt_expectations` v0.10.9

## Scheduling
- Default tags on all models: `["dbt", "daily"]`
- Weekly models run Sundays, monthly on 1st
- Selector logic in `utils/dbt_airflow_orchestration.py`

## Production DAG
- `dbt_e2_pipeline_v4`: daily at 8:30 AM UTC, manifest-driven (one Airflow task per model), uses `dbtRunner()` Python API
- Followed by `dbt_elementary` DAG (ALL_DONE trigger)

## CI
- State-based: `dbt build --select state:modified+1` against `develop` baseline
- Excludes: `tag:disabled tag:temp_backfill path:models/gold_pii/`
- SQLFluff lints changed SQL; warns if model > 100 lines

## Post-hooks (all layers)
```
{{ set_ownership_macro() }}
{{ set_tags_macro() }}
```
Sets Databricks Unity Catalog tags and ownership on every model.
