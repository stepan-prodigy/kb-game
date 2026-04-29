---
title: kb-eval Scenarios
type: docs
owner: data-team
last_modified: 2026-04-28
status: draft
---

# kb-eval scenarios

Each `*.md` file in this directory (other than this README) declares one eval scenario via frontmatter. The kb-eval skill loads them, runs each against the live kb-game image's MCP `query` tool, and scores pass/fail.

## Scenario fields

| Field | Required | Notes |
|---|---|---|
| `name` | yes | Unique identifier, lowercase_with_underscores |
| `description` | yes | One line — what's being tested and why |
| `query` | yes | The natural-language query to send |
| `collection` | optional | `kb`, `skill-<name>`, or omit for unscoped |
| `rerank` | optional | `true` / `false`. Default: test both. |
| `expect_path` | recommended | List of file paths that should appear in top-k |
| `expect_substring` | optional | List of substrings expected in the retrieved chunks |
| `forbid_path` | optional | List of file paths that should NOT appear |
| `forbid_substring` | optional | List of substrings that should NOT appear |
| `top_k` | optional | Default 5 |
| `status` | optional | `skip` to exclude from runs; useful for in-progress scenarios |

## Body

The body of a scenario file is freeform — use it to record why the scenario exists, related arcs, and what failure would tell us.

## Naming convention

- `routing_*` — tests collection routing (right collection picked)
- `recall_*` — tests recall of a specific document or claim
- `precision_*` — tests false-positive guards (right things don't surface)
- `cross_*` — tests queries that should span multiple collections
- `comparison_*` — tests where memory-based retrieval should give a known answer; run alongside qmd retrieval to compare

## Source of scenarios

Scenarios should grow from real usage. The seed set was authored to exercise known content categories; subsequent scenarios should be added when an arc flags a retrieval gap or a kb-eval failure surfaces a class of query that isn't covered.
