# kb-game — Knowledge Index

Indexed 29 pages across 6 top-level categories.

Structured data: [pages.json](pages.json).

## Contents

- [_meta](#meta) (4)
- [data-pipeline](#data-pipeline) (7)
- [dippr-platform](#dippr-platform) (5)
- [event-schemas](#event-schemas) (2)
- [game-design](#game-design) (9)
- [session-profiles](#session-profiles) (2)

## By type

- **analytics-taxonomy** (1) — see [#type-analytics-taxonomy](#type-analytics-taxonomy)
- **authoring-gaps** (1) — see [#type-authoring-gaps](#type-authoring-gaps)
- **corrections** (1) — see [#type-corrections](#type-corrections)
- **dag-inventory** (1) — see [#type-dag-inventory](#type-dag-inventory)
- **dag-patterns** (1) — see [#type-dag-patterns](#type-dag-patterns)
- **data-quality** (1) — see [#type-data-quality](#type-data-quality)
- **data-source** (1) — see [#type-data-source](#type-data-source)
- **dbt-macros** (1) — see [#type-dbt-macros](#type-dbt-macros)
- **design-doc** (7) — see [#type-design-doc](#type-design-doc)
- **devspace-workflow** (1) — see [#type-devspace-workflow](#type-devspace-workflow)
- **eval-system-legacy** (1) — see [#type-eval-system-legacy](#type-eval-system-legacy)
- **event-schema-contract** (1) — see [#type-event-schema-contract](#type-event-schema-contract)
- **event-taxonomy** (1) — see [#type-event-taxonomy](#type-event-taxonomy)
- **fact-dim-coverage** (1) — see [#type-fact-dim-coverage](#type-fact-dim-coverage)
- **kb-structure-legacy** (1) — see [#type-kb-structure-legacy](#type-kb-structure-legacy)
- **lineage** (2) — see [#type-lineage](#type-lineage)
- **models-inventory** (2) — see [#type-models-inventory](#type-models-inventory)
- **platform-overview** (1) — see [#type-platform-overview](#type-platform-overview)
- **session-profile** (1) — see [#type-session-profile](#type-session-profile)
- **skill-methodology** (1) — see [#type-skill-methodology](#type-skill-methodology)
- **utils-modules** (1) — see [#type-utils-modules](#type-utils-modules)

## Recently modified

- 2026-04-28 — [Authoring Gaps — Drafting Templates](_meta/authoring_gaps.md) __meta · authoring-gaps_
- 2026-04-28 — [Eval System (legacy from personal memory system; rewrite for kb-game)](_meta/eval_system_legacy.md) __meta · eval-system-legacy_
- 2026-04-28 — [kb Structure (legacy from personal memory system; rewrite for kb-game)](_meta/kb_structure_legacy.md) __meta · kb-structure-legacy_
- 2026-04-28 — [Skill Development Methodology](_meta/skill_development_methodology.md) __meta · skill-methodology_
- 2026-04-28 — [Canonical Fact/Dim Coverage](data-pipeline/fact_dim_coverage.md) _data-pipeline · fact-dim-coverage_
- 2026-04-28 — [Game DAGs](data-pipeline/game_dags.md) _data-pipeline · dag-inventory_
- 2026-04-28 — [Game Models — Curated Lineage](data-pipeline/lineage.md) _data-pipeline · lineage_
- 2026-04-28 — [Game Models — Full Lineage](data-pipeline/lineage_full.md) _data-pipeline · lineage_
- 2026-04-28 — [Math Game — Models Inventory (full)](data-pipeline/math_game_inventory.md) _data-pipeline · models-inventory_
- 2026-04-28 — [Game Models — Inventory (curated)](data-pipeline/models_inventory.md) _data-pipeline · models-inventory_
- 2026-04-28 — [segment_math_game_prod (Hub)](data-pipeline/segment_math_game_prod.md) _data-pipeline · data-source_
- 2026-04-28 — [dippr — DAG Patterns](dippr-platform/dag_patterns.md) _dippr-platform · dag-patterns_
- 2026-04-28 — [dippr — Custom dbt Macros](dippr-platform/dbt_macros.md) _dippr-platform · dbt-macros_
- 2026-04-28 — [dippr — Devspace Workflow](dippr-platform/devspace_workflow.md) _dippr-platform · devspace-workflow_
- 2026-04-28 — [dippr Platform Overview](dippr-platform/overview.md) _dippr-platform · platform-overview_
- 2026-04-28 — [dippr — utils Modules](dippr-platform/utils_modules.md) _dippr-platform · utils-modules_
- 2026-04-28 — [Common Event Log Schema](event-schemas/common_event_log_schema.md) _event-schemas · event-schema-contract_
- 2026-04-28 — [Math Game Event Taxonomy](event-schemas/math_game_event_taxonomy.md) _event-schemas · event-taxonomy_
- 2026-04-28 — [Math Game — Activities](game-design/activities.md) _game-design · design-doc_
- 2026-04-28 — [Math Game — Analytics Taxonomy](game-design/analytics_taxonomy.md) _game-design · analytics-taxonomy_
- 2026-04-28 — [Math Game — Combat](game-design/combat.md) _game-design · design-doc_
- 2026-04-28 — [Math Game — Corrections & Ambiguities](game-design/corrections.md) _game-design · corrections_
- 2026-04-28 — [Math Game — Data Quality](game-design/data_quality.md) _game-design · data-quality_
- 2026-04-28 — [Math Game — Economy](game-design/economy.md) _game-design · design-doc_
- 2026-04-28 — [Math Game — Pets](game-design/pets.md) _game-design · design-doc_

<a id="meta"></a>
## _meta

- **[Authoring Gaps — Drafting Templates](_meta/authoring_gaps.md)** — authoring-gaps · legacy-import · 2026-04-28 · data-team
  This file catalogues gaps where a drafting/authoring task has no dedicated reference template in memory. It mirrors the pattern of referencedddtemplate.md — a stable authored contract that the user iterates on — for…
- **[Eval System (legacy from personal memory system; rewrite for kb-game)](_meta/eval_system_legacy.md)** — eval-system-legacy · legacy-import · 2026-04-28 · data-team
  Purpose: Authoritative reference for the memory-eval architecture. Built to detect memory drift, routing misfires, and content inaccuracy before they degrade sessions. Read this before touching hooks, scenarios,…
- **[kb Structure (legacy from personal memory system; rewrite for kb-game)](_meta/kb_structure_legacy.md)** — kb-structure-legacy · legacy-import · 2026-04-28 · data-team
  Purpose: Meta-layer. Describes how memory works, not what's in it. Read before changing a memory file, adding a new one, or running an efficiency review.
- **[Skill Development Methodology](_meta/skill_development_methodology.md)** — skill-methodology · legacy-import · 2026-04-28 · data-team
  Captured from a multi-day arc that produced two composable skills (/confluence-research, /draft-ddd), a living architecture addendum (v2 → v6), and 7 features tested. 2-2.4M tokens spent; 50% load-bearing, 50%…

<a id="data-pipeline"></a>
## data-pipeline

- **[Canonical Fact/Dim Coverage](data-pipeline/fact_dim_coverage.md)** — fact-dim-coverage · legacy-import · 2026-04-28 · data-team
  Why: A knowledge-base project proposed canonical factstudentanswer, factstudentsession, factbattle, facteconomytransaction, dimstudent, dimmembership, dimteacher, dimclassroom. Only some exist today.
- **[Game DAGs](data-pipeline/game_dags.md)** — dag-inventory · legacy-import · 2026-04-28 · data-team
  Game-facing DAGs under dags/. See projectdagpatterns.md for general conventions.
- **[Game Models — Curated Lineage](data-pipeline/lineage.md)** — lineage · legacy-import · 2026-04-28 · data-team
  How to apply: Use this for quick lineage questions. Load artifactgamelineage.md for full lineage detail (cross-domain consumer table, raw sources, dead-ends, redundancies). Load projectsegmentmathgameprod.md for the…
- **[Game Models — Full Lineage](data-pipeline/lineage_full.md)** — lineage · legacy-import · 2026-04-28 · data-team
  Source. Original deep lineage scan was 2026-03-17 (92k tokens). This version applies corrections verified during the 2026-04-23 deep memory review and re-confirmed 2026-04-25. Counts reflect reality at re-verification,…
- **[Game Models — Inventory (curated)](data-pipeline/models_inventory.md)** — models-inventory · legacy-import · 2026-04-28 · data-team
  135 game models across 4 games. For full Math Game detail (file paths, materializations, descriptions, fact/dim coverage), load artifactmathgameinventory.md. English Game, Fact Fluency, and Game Island aren't in the…
- **[Math Game — Models Inventory (full)](data-pipeline/math_game_inventory.md)** — models-inventory · legacy-import · 2026-04-28 · data-team
  Generated: 2026-04-20 Project Root: /Users/stpn/Documents/repos/dippr/.claude/worktrees/suspicious-cartwright-ff7d40/dbte2pipelines/
- **[segment_math_game_prod (Hub)](data-pipeline/segment_math_game_prod.md)** — data-source · legacy-import · 2026-04-28 · data-team
  Silver-layer materialized view at models/silver/webevents/segmentmathgameprod.sql. Unions three upstream sources across three time windows to present a single continuous Math Game event stream.

<a id="dippr-platform"></a>
## dippr-platform

- **[dippr Platform Overview](dippr-platform/overview.md)** — platform-overview · legacy-import · 2026-04-28 · data-platform-team
  DIPPR (Data Ingest Platform Programmatic Resources) is Prodigy Game's dbt analytics repo. Covers all game products (Math, English, Fact Fluency, Game Island) and business domains (education, marketing, finance,…
- **[dippr — Custom dbt Macros](dippr-platform/dbt_macros.md)** — dbt-macros · legacy-import · 2026-04-28 · data-platform-team
  All custom macros live flat at dbte2pipelines/macros/ (46 files, 55 macros). Dispatch order in dbtproject.yml: ["prodigydbt", "sparkutils", "dbtutils"] — custom wins over packages.
- **[dippr — DAG Patterns](dippr-platform/dag_patterns.md)** — dag-patterns · legacy-import · 2026-04-28 · data-platform-team
  119 DAGs total at dags/. Naming is by verb-prefix; subfolders group by domain team. See projectutilsmodules.md for the Python building blocks referenced below.
- **[dippr — Devspace Workflow](dippr-platform/devspace_workflow.md)** — devspace-workflow · legacy-import · 2026-04-28 · data-platform-team
  Devspace is the CLI tool used to deploy local Airflow code to a personal k8s sandbox for end-to-end DAG testing. Full walkthrough at docs/airflowlocaldeployment.md.
- **[dippr — utils Modules](dippr-platform/utils_modules.md)** — utils-modules · legacy-import · 2026-04-28 · data-platform-team
  All utilities are in utils/. Already fully read and analyzed — do not re-read unless editing.

<a id="event-schemas"></a>
## event-schemas

- **[Common Event Log Schema](event-schemas/common_event_log_schema.md)** — event-schema-contract · legacy-import · 2026-04-28 · data-team
  The canonical 21-column common event log contract derived from segmentmathgameprod joined to the session pool and the external segmentation sheet. Use this when authoring DDDs, designing fact/dim models, or running…
- **[Math Game Event Taxonomy](event-schemas/math_game_event_taxonomy.md)** — event-taxonomy · legacy-import · 2026-04-28 · data-team
  Discovery-oriented index of Math Game event families mapped against the common event log's sessionactivity column. Load to find the right event(s) for a DDD question or fact-model domain before consulting the full…

<a id="game-design"></a>
## game-design

- **[Math Game — Activities](game-design/activities.md)** — design-doc · legacy-import · 2026-04-28 · game-team
  Parent overview: projectmathgameproduct.md.
- **[Math Game — Analytics Taxonomy](game-design/analytics_taxonomy.md)** — analytics-taxonomy · legacy-import · 2026-04-28 · data-team
  Purpose. Structural catalog of analytics domains, standard segmentation axes, named KPIs, and the standard guardrail pack. Load for DDD authoring, fact-model design, or framing analytics questions. Does not duplicate…
- **[Math Game — Combat](game-design/combat.md)** — design-doc · legacy-import · 2026-04-28 · game-team
  Parent overview: projectmathgameproduct.md.
- **[Math Game — Corrections & Ambiguities](game-design/corrections.md)** — corrections · legacy-import · 2026-04-28 · data-team
  Purpose. Track claims that have been corrected vs earlier external research, and remaining open ambiguities that should not be asserted as fact. Load before relying on any product claim whose provenance is external…
- **[Math Game — Data Quality](game-design/data_quality.md)** — data-quality · legacy-import · 2026-04-28 · data-team
  Purpose. Operational DQ facts for Math Game event streams. Load before designing DQ rules, trusting resource aggregates, or reasoning about suspect sessions. For upstream view context see projectsegmentmathgameprod.md;…
- **[Math Game — Economy](game-design/economy.md)** — design-doc · legacy-import · 2026-04-28 · game-team
  Parent overview: projectmathgameproduct.md.
- **[Math Game — Pets](game-design/pets.md)** — design-doc · legacy-import · 2026-04-28 · game-team
  Parent overview: projectmathgameproduct.md.
- **[Math Game — Product](game-design/product.md)** — design-doc · legacy-import · 2026-04-28 · game-team
  Single-page summary of what Prodigy Math Game is and how its parts fit together. Load this before any math-game product question; from here, route to the system-specific files listed under Related files.
- **[Math Game — World & Progression](game-design/world.md)** — design-doc · legacy-import · 2026-04-28 · game-team
  Parent overview: projectmathgameproduct.md.

<a id="session-profiles"></a>
## session-profiles

- **[Math Game — Sessions](session-profiles/sessions.md)** — design-doc · legacy-import · 2026-04-28 · game-team
  Parent overview: projectmathgameproduct.md.
- **[Session Profile — 2026-03-16 Balanced Sample](session-profiles/2026-03-16_balanced_sample.md)** — session-profile · legacy-import · 2026-04-28 · data-team
  ---

<a id="type-analytics-taxonomy"></a>
## By type: analytics-taxonomy (1)

- 2026-04-28 — [Math Game — Analytics Taxonomy](game-design/analytics_taxonomy.md)

<a id="type-authoring-gaps"></a>
## By type: authoring-gaps (1)

- 2026-04-28 — [Authoring Gaps — Drafting Templates](_meta/authoring_gaps.md)

<a id="type-corrections"></a>
## By type: corrections (1)

- 2026-04-28 — [Math Game — Corrections & Ambiguities](game-design/corrections.md)

<a id="type-dag-inventory"></a>
## By type: dag-inventory (1)

- 2026-04-28 — [Game DAGs](data-pipeline/game_dags.md)

<a id="type-dag-patterns"></a>
## By type: dag-patterns (1)

- 2026-04-28 — [dippr — DAG Patterns](dippr-platform/dag_patterns.md)

<a id="type-data-quality"></a>
## By type: data-quality (1)

- 2026-04-28 — [Math Game — Data Quality](game-design/data_quality.md)

<a id="type-data-source"></a>
## By type: data-source (1)

- 2026-04-28 — [segment_math_game_prod (Hub)](data-pipeline/segment_math_game_prod.md)

<a id="type-dbt-macros"></a>
## By type: dbt-macros (1)

- 2026-04-28 — [dippr — Custom dbt Macros](dippr-platform/dbt_macros.md)

<a id="type-design-doc"></a>
## By type: design-doc (7)

- 2026-04-28 — [Math Game — World & Progression](game-design/world.md)
- 2026-04-28 — [Math Game — Sessions](session-profiles/sessions.md)
- 2026-04-28 — [Math Game — Product](game-design/product.md)
- 2026-04-28 — [Math Game — Pets](game-design/pets.md)
- 2026-04-28 — [Math Game — Economy](game-design/economy.md)
- 2026-04-28 — [Math Game — Combat](game-design/combat.md)
- 2026-04-28 — [Math Game — Activities](game-design/activities.md)

<a id="type-devspace-workflow"></a>
## By type: devspace-workflow (1)

- 2026-04-28 — [dippr — Devspace Workflow](dippr-platform/devspace_workflow.md)

<a id="type-eval-system-legacy"></a>
## By type: eval-system-legacy (1)

- 2026-04-28 — [Eval System (legacy from personal memory system; rewrite for kb-game)](_meta/eval_system_legacy.md)

<a id="type-event-schema-contract"></a>
## By type: event-schema-contract (1)

- 2026-04-28 — [Common Event Log Schema](event-schemas/common_event_log_schema.md)

<a id="type-event-taxonomy"></a>
## By type: event-taxonomy (1)

- 2026-04-28 — [Math Game Event Taxonomy](event-schemas/math_game_event_taxonomy.md)

<a id="type-fact-dim-coverage"></a>
## By type: fact-dim-coverage (1)

- 2026-04-28 — [Canonical Fact/Dim Coverage](data-pipeline/fact_dim_coverage.md)

<a id="type-kb-structure-legacy"></a>
## By type: kb-structure-legacy (1)

- 2026-04-28 — [kb Structure (legacy from personal memory system; rewrite for kb-game)](_meta/kb_structure_legacy.md)

<a id="type-lineage"></a>
## By type: lineage (2)

- 2026-04-28 — [Game Models — Full Lineage](data-pipeline/lineage_full.md)
- 2026-04-28 — [Game Models — Curated Lineage](data-pipeline/lineage.md)

<a id="type-models-inventory"></a>
## By type: models-inventory (2)

- 2026-04-28 — [Math Game — Models Inventory (full)](data-pipeline/math_game_inventory.md)
- 2026-04-28 — [Game Models — Inventory (curated)](data-pipeline/models_inventory.md)

<a id="type-platform-overview"></a>
## By type: platform-overview (1)

- 2026-04-28 — [dippr Platform Overview](dippr-platform/overview.md)

<a id="type-session-profile"></a>
## By type: session-profile (1)

- 2026-04-28 — [Session Profile — 2026-03-16 Balanced Sample](session-profiles/2026-03-16_balanced_sample.md)

<a id="type-skill-methodology"></a>
## By type: skill-methodology (1)

- 2026-04-28 — [Skill Development Methodology](_meta/skill_development_methodology.md)

<a id="type-utils-modules"></a>
## By type: utils-modules (1)

- 2026-04-28 — [dippr — utils Modules](dippr-platform/utils_modules.md)

