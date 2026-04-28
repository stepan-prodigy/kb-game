---
title: dippr — DAG Patterns
type: dag-patterns
owner: data-platform-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_dag_patterns.md
as_of_at_import: 2026-04-21
related:
---
**~119 DAGs total** at `dags/`. Naming is by verb-prefix; subfolders group by domain team. See `project_utils_modules.md` for the Python building blocks referenced below.

## Naming by prefix

| Prefix | Count | Purpose |
|---|---|---|
| `ingest_*` | ~89 | Data ingestion (DB/API → Delta Lake). Almost always triggers a Databricks job. |
| `dbt_*` | 6 | dbt execution and Delta/Elementary maintenance (see details below). |
| `optimize_*` | 1 | Table optimize jobs (e.g. `optimize_game_events_tables.py`). |
| `placement_*` | 2 | Email-outgoing pipelines for placement tests. |
| `clean_*`, `import_*`, `send_*`, `trigger_*`, `smoke_*` | misc | One-offs; check the file directly. |

## Subfolders (domain-owned DAGs)

- `dags/data_engineering/` — DE team ingestion and maintenance
- `dags/education_insights/` — Education team
- `dags/finance/` — Finance team
- `dags/math_game/` — Math Game team (see `project_game_dags.md`)

## Standard `ingest_*` DAG shape

    @dag(
        default_args=dag_default_args({"start_date": datetime(YYYY, MM, DD)}),
        schedule="30 1 * * *",            # cron, or None if trigger-only
        max_active_runs=1,
        catchup=False,
        tags=["engineering", "databricks_e2", "dbt_source"],
    )
    def ingest_something():
        """Docstring — describes source, destination, downstream dbt source ref."""
        if get_env() == Environment.PRODUCTION:
            DatabricksRunNowOperatorProduction(
                task_id="...",
                json={"job_id": 12345},    # Databricks job ID is hardcoded
            )

    dag = ingest_something()

Key imports: `utils.dag_util.dag_default_args`, `utils.dag_util.DatabricksRunNowOperatorProduction`, `utils.env_util.get_env, Environment`. Most ingest DAGs follow this template exactly.

## `dbt_*` DAGs

| DAG | Purpose |
|---|---|
| `dbt_e2_pipeline.py` | Production dbt DAG. Manifest-driven (one task per model) via `dbtRunner()` Python API. Runs daily 8:30 AM UTC. |
| `dbt_staging_pipeline.py` | Staging (preprod) variant. |
| `dbt_adhoc_run_dag.py` | On-demand dbt runs. |
| `dbt_delta_tables_maintenance.py` | Wraps a Databricks job for Delta table OPTIMIZE/VACUUM. |
| `dbt_maintenance_non_prod_tables.py` | Cleanup of non-prod sandbox tables. |
| `dbt_elementary.py` | Elementary observability. Triggered ALL_DONE after `dbt_e2_pipeline`. |

Production pipeline imports heavily from `utils/dbt_airflow_orchestration.py` and `utils/dbt_airflow_util.py`.

## Conventions when adding a DAG

- File name matches the inner `@dag` function name.
- Always env-gate real operators with `get_env() == Environment.PRODUCTION`.
- Start date as a literal `datetime(YYYY, MM, DD)` — never `days_ago()` or `datetime.now()`.
- `max_active_runs=1` and `catchup=False` unless there's a specific reason otherwise.
- Tags always include `"engineering"` and `"databricks_e2"`. Add domain tags (`"dbt_source"`, `"dbt"`, `"client_events"`, etc.) as needed.
- Assign the DAG on the last line: `dag = function_name()`.
- Docstring describes source, destination S3 path, and downstream dbt source reference.

## Cosmos vs. dbtRunner

`utils/cosmos_dippr_dbt.py` exposes `dippr_dbt_dag()` / `dippr_dbt_group()` factories wrapping Astronomer Cosmos. Currently only `dags/sample_cosmos.py` uses them. Prefer the existing custom `dbtRunner()` pattern (see `dbt_e2_pipeline.py`) unless there's a reason to introduce Cosmos.

## Streaming ingestion (not Airflow)

Some bronze tables are fed by streaming pipelines outside Airflow — notably `raw_client_events.math_game_events` (client-event-publisher). When tracing lineage, don't assume every bronze table has an ingest DAG.

## Testing DAGs

Use **devspace** for full Airflow deployment testing (per `AGENTS.md`). Unit tests only required when DAG code or `utils/` changes.
