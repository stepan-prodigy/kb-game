---
title: arc-review Heuristics
type: heuristics
owner: data-team
last_modified: 2026-04-28
status: draft
---

# arc-review Heuristics

Seed list. Will grow from arcs once a few review cycles have run.

## Triage

- **When in doubt skill vs. knowledge → prefer skill.** Adding to a workflow is reversible (the next review can undo it). Adding to `knowledge/` sets precedent and harder to walk back.
- **Three or more arcs flagging the same gap is a strong signal.** Promote to a PR even if each individual arc was soft.
- **Close duplicates aggressively.** Reviews bloat from arcs that never reach disposition. A noted-as-duplicate arc is closed, not pending.
- **Defer is fine; ambiguity is not.** If a hard case can't be resolved this week, write the deferral explicitly with an owner and a re-look date.

## Drafting proposed changes

- **Always include a path + diff.** "Update SKILL.md to clarify X" is not a proposal; "skills/ddd-drafting/SKILL.md:42 — change `Y` to `Z`" is.
- **Cite the arcs.** Every proposal links the arcs it consolidates. This is how future reviews trace why a change landed.
- **Smallest viable change.** A two-line clarification beats a section rewrite. Compounding works through small diffs.

## Scope

- **Don't edit other skills' arcs.** arc-review reads from `skills/<target>/arcs/` and writes to `skills/<target>/reviews/`. The arc files themselves are immutable historical record.
- **One target skill per review pass.** Mixing arc-review across skills makes the review note hard to read and PRs hard to scope.
