---
title: kb-eval Comparison Workflow (memory vs kb-game)
type: docs
owner: data-team
last_modified: 2026-04-28
status: draft
---

# Comparison workflow — memory vs. kb-game

The cleanup of migrated memory files is gated on kb-game reaching ≥ parity with the memory-based retrieval system. This doc defines what "parity" means and how to measure it.

## Two retrieval surfaces

| Surface | Mechanism | Used by |
|---|---|---|
| **Memory** | `Read` tool against file paths resolved through `MEMORY.md` and `MEMORY_math_game.md` routers | All current Claude Code sessions |
| **kb-game** | `qmd query` via the kb-game MCP server | Future state |

Same content, two access paths. The eval measures whether the new path is at least as effective as the old.

## Two eval modes

### Mode 1 — Retrieval recall (automatable)

Each scenario in `scenarios/` declares an `expect_path`. Run the same scenario against both surfaces and compare:

| Surface | How to run the scenario | Pass criterion |
|---|---|---|
| Memory | (1) Apply the router heuristic from `MEMORY.md` to pick a candidate path. (2) Read the candidate. (3) Check whether the body answers the query. | The router resolved to a file in `expect_path` AND the file contained the answer. |
| kb-game | `docker run --rm -i kb-game:dev` MCP query with the scenario's parameters | Top-k contained at least one path in `expect_path` AND no `forbid_*` violations. |

Both surfaces produce a per-scenario pass/fail. The aggregate report compares pass rates side-by-side.

### Mode 2 — Draft quality (manual scoring)

Pick one Math Game feature. Run the same drafting brief through:

1. **Memory path** — the existing `/draft-ddd` skill (which loads `reference_ddd_template.md` from memory and routes via `MEMORY_math_game.md`).
2. **kb-game path** — the new `kb-game/skills/ddd-drafting/SKILL.md` (which queries the kb-game MCP server).

Score each output on five axes (1–5 each):

| Axis | What it measures |
|---|---|
| **Section completeness** | Did the draft hit every section in the canonical template? |
| **Citation accuracy** | Are factual claims grounded with specific path/section citations that resolve? |
| **Section ordering** | Does the draft follow the template section order? |
| **Open-question quality** | Did the draft surface real gaps with explicit owners? |
| **Domain accuracy** | Are factual claims about Math Game correct? (subjective, requires reviewer familiar with the feature) |

Total: 25 points possible. kb-game must reach ≥ memory's score (with a tolerance band of ±2 points for noise) to clear the parity gate.

## Reporting

Reports live at `evals/<YYYY-MM-DD>_comparison.md`:

```markdown
# kb-eval comparison — <date>

## Image
<image:tag>

## Mode 1 — Retrieval recall
- Memory: pass X/N (Y%)
- kb-game: pass X/N (Y%)
- Disagreements: list scenarios where one passed and the other didn't

## Mode 2 — DDD draft scoring
- Feature: <name>
- Memory total: X/25
- kb-game total: Y/25
- Per-axis breakdown: ...

## Verdict
- Parity? yes / no
- Notable gaps: ...
- Action items (arcs to file): ...
```

## Cleanup gate

The migrated memory files (the 31 files imported on 2026-04-28) are eligible for deletion once:

- Mode 1 reaches ≥ memory's pass rate, AND
- Mode 2 reaches ≥ memory's draft-quality total within tolerance, AND
- One full `arc-review` cycle has run on `skills/kb-eval/arcs/` to consume any failure modes surfaced.

Until those three conditions land, the personal memory files remain the safety net.
