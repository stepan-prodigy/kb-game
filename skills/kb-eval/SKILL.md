---
name: kb-eval
description: Evaluate retrieval quality of the kb-game image. Runs routing scenarios and content Q&A against the live MCP server, scores against expected results, reports pass/fail and drift.
---

# kb-eval

Quality eval for kb-game. Analogous to memory-eval but scoped to the kb-game retrieval surface.

## Inputs

- **scenario set** (default: `skills/kb-eval/reference/scenarios/`)
- **target image** (default: `kb-game:dev`)

## Scenario shape

Each scenario is a YAML/markdown file declaring:
- `query` — the natural-language query
- `collection` — `kb` / `skill-<name>` / null (any)
- `rerank` — true/false
- `expect` — list of file paths or substrings that should appear in top-k
- `forbid` — list of file paths or substrings that should NOT appear (false-positive guards)

## Workflow

### 1. Load scenarios

Read every `*.md` under the scenario directory. Skip any with `status: skip`.

### 2. Run via MCP

Spin up `docker run --rm -i <image>` and pipe `tools/list` then per-scenario `query` calls through the qmd MCP server.

### 3. Score

For each scenario:
- Did expected chunks appear in top-k? (recall)
- Did forbidden chunks stay out? (precision guard)
- Were the right collections hit?
- Pass/fail with details

### 4. Report

Write to `evals/<YYYY-MM-DD>.md`:

```markdown
# kb-eval — <date>

## Image
<image:tag>

## Summary
- Total scenarios: N
- Pass: X (Y%)
- Fail: Z

## Failures
### <scenario name>
- Query: ...
- Expected: ...
- Got: ...
- Why: ...

## Regressions vs <prior date>
- ...

## New failures (drift indicators)
- ...
```

### 5. Write own arc

`skills/kb-eval/arcs/<date>_<topic>.md` covering scenarios that need updating, false-positive patterns to add, etc.

## Output

- `evals/<YYYY-MM-DD>.md`
- `skills/kb-eval/arcs/<date>_<topic>.md`

## Quality bar

A run is done when:
- Every scenario produced a pass/fail with evidence.
- Failures cite specific top-k results, not just "didn't work".
- Regressions vs. prior eval are surfaced (or "first run" is noted).

NOT done when:
- Scenarios were skipped without `status: skip`.
- Failures lack the actual retrieved chunks.
- Drift between rerank-on and rerank-off wasn't tested for any scenario where it matters.
