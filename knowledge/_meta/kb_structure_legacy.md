---
title: kb Structure (legacy from personal memory system; rewrite for kb-game)
type: kb-structure-legacy
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/meta_memory_system.md
as_of_at_import: 2026-04-24
related:
---
**Purpose:** Meta-layer. Describes how memory works, not what's in it. Read before changing a memory file, adding a new one, or running an efficiency review.

## Structure

All files live under `~/.claude/projects/-Users-stpn-Documents-repos-dippr/memory/`, grouped by prefix:

- `feedback_*` — behavior/efficiency rules. Apply to every response.
- `project_*` — curated DIPPR facts: inventories, lineage, pending work, config.
- `artifact_*` — large generated references (full model inventories, lineage dumps, dated session profiles). Loaded on trigger same as project files; separated by prefix so it's clear they're regeneratable or sample-conditional.
- `reference_*` — stable authored contracts (DDD template, canonical event-log schema). Hand-maintained, treated as source-of-truth; size uncapped but should be editable end-to-end.
- `meta_*` — self-referential files (like this one).
- `MEMORY_*.md` — topic sub-routers. Loaded from `MEMORY.md` when a domain is referenced; the sub-router then routes to topic-specific files. See "Sub-routers" below.

### When to use `~/Documents/claude/` instead of memory

Rare. Only when the file needs to be human-shareable outside Claude (emailed, inspected with other tools) or is too large/binary to sit comfortably in memory. Default is memory.

### Required frontmatter

    ---
    name: short human-readable name
    description: one-line description of when to load this file
    type: feedback | project | artifact | meta
    as_of: YYYY-MM-DD
    ---

`MEMORY.md` is the always-loaded router. Every other file is loaded on demand when a trigger in MEMORY.md matches.

### Size guidelines

- `MEMORY.md`: ≤30 lines. When a domain's entries grow past ~5 lines, extract into a `MEMORY_<domain>.md` sub-router.
- `MEMORY_*.md` sub-routers: uncapped; keep organized by topic. No frontmatter (they're indexes, not memories).
- `feedback_*` / `project_*` / `meta_*`: aim ~50 lines, hard cap ~150.
- `reference_*`: uncapped but keep readable end-to-end (~300 lines is a reasonable soft ceiling).
- `artifact_*`: uncapped (loaded on demand only).

If a curated topic grows past ~150 lines, split it or demote detail into a sibling `artifact_*` file.

### Sub-routers

When a single domain accumulates many files (≥5) and dominates top-level `MEMORY.md`, split it:

1. Create `MEMORY_<domain>.md` with the same "router, no frontmatter" shape as top-level `MEMORY.md`.
2. Move all domain file entries from `MEMORY.md` into the sub-router, grouped by purpose.
3. Replace those entries in `MEMORY.md` with a single pointer section: "`## <domain> work → see [MEMORY_<domain>.md](MEMORY_<domain>.md)`".

Sub-routers are loaded from the top-level router on demand (same trigger model as other memory files). They must not themselves reference other sub-routers — keep the tree shallow.

## Update procedure (manual, current phase)

When memory is wrong or incomplete mid-session:

1. Fix the specific claim with a targeted edit — avoid blanket rewrites.
2. Update the `as_of` date in the file's frontmatter (or add inline "as of YYYY-MM-DD" for a specific section that changed).
3. If routing changes, update `MEMORY.md`.
4. If a new topic emerges, create a new file with the right prefix and add a trigger line to `MEMORY.md`.

## Efficiency review (manual trigger now, automatable later)

Run when user requests it or when recurring staleness is observed during normal work.

### Checklist

1. **Staleness scan** — list files with `as_of` dates. Flag anything > 60 days.
2. **Size scan** — line counts per file. Flag curated files > 150 lines.
3. **Contradiction scan** — spot-check 3–5 claims from memory against current code via Grep/Glob. Log mismatches.
4. **Routing audit** — for each MEMORY.md entry, ask "would I load this for the trigger as written?" Flag weak triggers.
5. **Coverage gaps** — note topics that came up in recent sessions but weren't in memory. Candidates for new files.
6. **Artifact freshness** — for each `artifact_*`, decide whether regeneration is needed.

Output: short findings report. Execute fixes only after user approval.

### Future automation

When a scheduled review is set up:

- Convert the checklist into a recurring scheduled agent (weekly or monthly).
- Store review reports as dated outputs: either `artifact_review_YYYY-MM-DD.md` in memory, or `~/Documents/claude/reviews/YYYY-MM-DD.md` for human access.
- Use the `as_of` frontmatter field to target stale files automatically.

## Current inventory

### Top-level routers and always-loaded

| File | Type | Trigger |
|---|---|---|
| `MEMORY.md` | router | always loaded |
| `feedback_behavior.md` | feedback | always applies |
| `feedback_token_efficiency.md` | feedback | before batch reads or agent spawns |
| `feedback_git_workflow.md` | feedback | always applies — git operations |

### Sub-routers

| File | Scope |
|---|---|
| `MEMORY_math_game.md` | all Prodigy Math Game files: product, event schema, DDD, analytics, DQ, game-specific dbt/Airflow, session profiles |

### General DIPPR (top-level)

| File | Type | Trigger (in MEMORY.md) |
|---|---|---|
| `project_dippr_overview.md` | project | dbt/Airflow config beyond AGENTS.md |
| `project_dbt_macros.md` | project | before editing dbt models |
| `project_utils_modules.md` | project | before editing utils/ or writing a DAG |
| `project_dag_patterns.md` | project | before writing or modifying an Airflow DAG |
| `project_devspace_workflow.md` | project | testing DAG/utils changes against a k8s sandbox |
| `project_pending_work.md` | project | ambiguous task start |
| `project_authoring_gaps.md` | project | before starting a drafting task; tracks missing `reference_*` templates |
| `meta_memory_system.md` | meta | before modifying memory |
| `meta_eval_system.md` | meta | before modifying eval hooks, scenarios, or skills |
| `meta_skill_development_methodology.md` | meta | before designing or iterating on a heavy-duty skill |

Files under `MEMORY_math_game.md` are not enumerated here — that sub-router is the authoritative listing for Math Game memory.
