---
title: dippr — Devspace Workflow
type: devspace-workflow
owner: data-platform-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_devspace_workflow.md
as_of_at_import: 2026-04-21
related:
---
**Devspace** is the CLI tool used to deploy local Airflow code to a personal k8s sandbox for end-to-end DAG testing. Full walkthrough at `docs/airflow_local_deployment.md`.

## Requirements (one-time)

- `devspace` CLI (v6.x — pin in `devspace.yaml` under `require.devspace`).
- `helm` ≥ 3.2.2, `kubectl` ≥ 1.18.0.
- `edctl` for k8s context switching.
- A personal k8s sandbox (set up via Infrastructure — see `#sandboxes` or `#ask-infrastructure`).

## Setup per machine

1. Switch k8s context to staging:

       edctl k8s configure       # Staging / Engineering / k8s-ci-staging
       edctl k8s ctx -A          # verify `* k8s-ci-staging-engineering` is current

2. Create `.env` from `.env.example`; fill `DATABRICKS_E2_TOKEN` or `DATABRICKS_STAGING_TOKEN`. Never commit tokens; the `.env` creates k8s secrets consumed by `pod_template_devspace.yml`.
3. Set `SANDBOX_NAMESPACE` in `pod_template_devspace.yml` to your sandbox name (convention: first initial + last name, e.g. `dshi`). **Leaving it blank fails every task** — the postgres URI bakes in this namespace and otherwise resolves to an unresolvable hostname.

## Deploy and tear down

    devspace use namespace YOUR_SANDBOX_NAME
    devspace dev              # builds image, deploys via Helm, opens localhost:8080
    devspace purge            # always tear down when done

## Key gotcha: workers use a pre-built image

`devspace dev` syncs your local code to **scheduler and web pods only**. Airflow workers run a pre-built Docker image — changes to code executed in a task body (operators, utils imported by tasks) require a rebuild. `devspace dev` builds by default; use `--skip-build` only when no task-execution code changed.

## Common commands

| Command | Purpose |
|---|---|
| `devspace list deployments` | show deployment status |
| `devspace dev --skip-build` | deploy using the last-built image |
| `devspace render --skip-build` | dump generated Helm config (debugging) |
| `devspace build -p preview` | build a specific profile's image |
| `devspace run test` | run unit tests (`pytest test/`) inside the deployed web pod |
| `devspace run scale-down-unit-test` / `scale-up-unit-test` | scale web replicas to 0 / 1 |

Custom `devspace run` shortcuts are defined in `devspace/commands.yaml`.

## Config layout

`devspace.yaml` imports six files from `devspace/`:

| File | Contains |
|---|---|
| `images.yaml` | Docker image build definitions |
| `deployments.yaml` | Helm deployment specs |
| `dev.yaml` | Dev-mode file sync + port forwarding |
| `vars.yaml` | Templated variables |
| `profiles.yaml` | Named profiles (`preview`, `staging-candidate`) — mutate the base config |
| `commands.yaml` | `devspace run <name>` shortcuts |

## PR preview profile

Adding the **`preview`** label to a PR triggers the preview profile in CI — useful to confirm your changes deploy cleanly. Verify the printed host URL responds.

## Upgrading devspace

- Update the pin in `devspace.yaml` → `require.devspace:`.
- Run `devspace print` to surface config errors before deploy.
- Also update `.github/actions/setup-devspace` version references in CI workflows.
- Verify each profile in `profiles.yaml` with `devspace print -p <profile>`.

## When to use

- Testing DAG code paths end-to-end in a real Airflow deployment.
- Validating `utils/` changes that affect DAG behavior.
- **Not needed for dbt model changes** — use `dbt build --select MODEL --target e2_dev` (per `AGENTS.md`).
- **Not needed for pure unit-test changes** — `pytest test/` runs locally.
