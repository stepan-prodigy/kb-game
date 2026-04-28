---
name: ddd-drafting
description: Draft a Data Design Document (DDD) for a Prodigy game feature. Retrieves relevant knowledge from kb-game (event schemas, glossary, prior DDDs) and the ddd-drafting skill reference (templates, heuristics). Writes an arc at the end capturing what worked, what didn't, and proposed changes.
---

# DDD drafting

Draft a Data Design Document for a Prodigy game feature. Currently scoped to Math Game; Game Island joins next.

## Inputs

- **Feature name** (e.g. `Game Island progression`, `Math Game battles v2`)
- **Domain context** (which game, which area)
- **Source material** (Confluence link, PRD, design doc) — optional but ideal

## Workflow

### 1. Retrieve template + heuristics

Query the `skill-ddd-drafting` collection for the canonical DDD template and any heuristics that apply to the feature kind:

```
kb-game query "DDD template <feature-kind>" --collection skill-ddd-drafting
```

Always pull at least:
- `template_ddd.md` (structural skeleton)
- `heuristics.md` (do's and don'ts learned from prior arcs)

### 2. Retrieve domain facts

Query the `kb` collection for relevant event schemas, glossary terms, and prior DDDs covering adjacent areas:

```
kb-game query "<feature-name> event schema" --collection kb
kb-game query "<feature-name> glossary"     --collection kb
```

If the feature touches existing schemas, fetch them with `get` to ground the new DDD against current truth.

### 3. Draft

Follow `template_ddd.md`'s section order. For each section:
- Cite which kb-game doc(s) you grounded against (path + section).
- Flag any ambiguities you couldn't resolve from retrieved context — these become arc proposals.

### 4. Write the arc

Last step, before declaring the draft done. Create `skills/ddd-drafting/arcs/<YYYY-MM-DD>_<topic>.md`:

```markdown
---
date: <today>
skill: ddd-drafting
domain: <math-game | game-island | …>
user: <username>
status: proposed
target: <skill | knowledge | both>
---

## What worked
- (concrete things that helped — a specific heuristic, a retrieved doc)

## What didn't
- (concrete gaps — a missing template section, a kb doc that's stale or absent)

## Proposed change
- (one or two specific edits, scoped to skill or knowledge)
```

Keep it short. If you can't fill the four sections in 5 minutes, the arc is too ambitious — split it.

## Quality bar

A first-draft DDD is acceptable when:
- Every section in `template_ddd.md` is present (even if some say "TBD with stakeholder").
- Every factual claim is grounded — citation to a kb-game path or an explicit "open question".
- The arc is written.

A draft is NOT done when:
- The retrieval step was skipped.
- Facts are stated without grounding.
- The arc is missing.

## When to call other skills

If the feature also needs a GDD (game design doc), call `gdd-drafting` separately — they share domain context but have distinct templates. Don't try to produce both in one pass.

If the feature requires a new event schema, draft the DDD first, then file a separate kb-game PR adding the schema doc to `knowledge/event-schemas/`. The DDD references the planned schema path; the schema PR lands in parallel.
