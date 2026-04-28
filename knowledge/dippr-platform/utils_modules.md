---
title: dippr — utils Modules
type: utils-modules
owner: data-platform-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_utils_modules.md
as_of_at_import: 2026-04-25
related:
---
All utilities are in `utils/`. Already fully read and analyzed — do not re-read unless editing.

**Why:** These modules wire Airflow orchestration to dbt execution and observability. Understanding them is needed for any DAG or orchestration work.

**How to apply:** When working on DAGs, error handling, K8s config, or dbt execution — reference this summary instead of re-reading files.

## Module Summary

| Module | Purpose |
|---|---|
| `dbt_airflow_constants.py` | Shared path/target/DAG ID constants used across all modules |
| `env_util.py` | Reads `DEPLOYMENT_ENVIRONMENT` env var, returns `Environment` enum (dev/staging/production) |
| `dag_util.py` | Default DAG args, Databricks operators (staging/prod), deferrable TriggerDagRun, most-recent-execution helper |
| `dbt_airflow_util.py` | Loads manifest.json, filters models in scope, maps sources→models, manages weekly/monthly exclude selectors, processes dbt runner results |
| `dbt_airflow_orchestration.py` | `load_manifest()` reads dbt `manifest.json`; `model_snapshot_in_scope()` applies exclusion-tag filtering for the manifest-driven DAG |
| `dbt_bash_operator.py` | Custom BashOperator wrapping dbt CLI. Handles SIGTERM→SIGINT translation for clean Databricks query cancellation |
| `cosmos_dippr_dbt.py` | Wraps Astronomer Cosmos — `dippr_dbt_dag()` and `dippr_dbt_group()` factories. Only instantiates if current env matches target env list |
| `dbt_e2_artifacts_copy.py` | Copies dbt artifacts (run_results, manifest, catalog, elementary report) to S3 after runs |
| `s3_util.py` | Thin S3Hook wrapper for single-file uploads |
| `error_util.py` | Central error handling: Slack webhook alerts, DataDog `operation_error` metrics, downstream owner alerting (within-DAG and cross-DAG via ExternalTaskSensor) |
| `metrics.py` | `send_metric()` — DogStatsD increment with tags |
| `dependency_detection.py` | Recursively finds all upstream task IDs in Airflow DAG — used by error_util for blast radius alerting |
| `external_task_sensor.py` | Deferrable ExternalTaskSensor that waits on most-recent execution (not current logical date) |
| `connection_util.py` | Programmatic Airflow connection management — currently only Hightouch (reverse ETL) |
| `identity_oauth_util.py` | Fetches client credentials OAuth token from internal Identity service |
| `github_util.py` | Fetches latest release tag of `prodigy-databricks-core` repo |
| `k8s_executor_custom_config.py` | K8s pod resource configs: `k8s_dbt_executor_config` (1100Mi/1500m CPU for dbt), `k8s_L_size_executor_config` (2000Mi/2000m) |
| `event_util.py` | Pandas helpers for flattening dict/list-of-dict columns in event DataFrames |
| `classroom_cup_utils.py` | `is_on_cycle()` — ShortCircuitOperator helper for irregular DAG schedules (e.g. every 2 weeks) |
