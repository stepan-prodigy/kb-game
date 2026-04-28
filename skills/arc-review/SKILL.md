---
name: arc-review
description: Compile a week's worth of arcs from a target skill into proposed changes (procedural fixes vs. domain facts). Drafts a review note and surfaces diffs for user-gated PR review.
---

# arc-review

Meta-skill for the procedural review stream. Processes another skill's `arcs/` inbox into PR-ready proposals.

## Inputs

- **target skill name** (e.g. `ddd-drafting`)
- **review window** (default: past 7 days)

## Workflow

### 1. List arcs

`ls skills/<target>/arcs/` for files matching the date window. Read each.

### 2. Triage

For each arc, classify the proposed-change target:

| Target | Goes where |
|---|---|
| Procedural fix | `skills/<target>/SKILL.md` or `skills/<target>/reference/` |
| Domain fact | `knowledge/<section>/<page>.md` |
| Duplicate | Close, note in review |
| Discuss | Tag for sync; defer |

### 3. Compile

Group related arcs. For each group, draft a concrete proposed change:
- File path to edit
- Before/after snippet
- Justification (cite the arcs that motivated it)

### 4. Write the review note

Output to `skills/<target>/reviews/<YYYY-MM-DD>.md`:

```markdown
# <target> review — <date>

## Arcs processed
- <date>_<topic>.md → <action>

## Proposed changes
### Change 1: <description>
- File: <path>
- Diff: <before/after>
- Arcs: <list>

## Deferred
- <arc> → reason

## Closed (duplicates / noise)
- <arc> → reason
```

### 5. Optional — open draft PRs

For accepted changes, draft PRs against kb-game on a feature branch. User review gates the merge.

### 6. Write own arc

`skills/arc-review/arcs/<date>_<topic>.md` capturing what worked / didn't in this review pass. The arc-review skill itself improves through compounding arcs like any other skill.

## Output

- `skills/<target>/reviews/<YYYY-MM-DD>.md`
- (optional) feature branch with PR(s)
- `skills/arc-review/arcs/<date>_<topic>.md`

## Quality bar

A review is done when:
- Every arc in the window has an explicit disposition (proposed / deferred / closed).
- Every "proposed" change cites at least one arc as evidence.
- The review note is committable as-is.

A review is NOT done when:
- Arcs were skimmed but not classified.
- "Proposed" changes lack a diff or file path.
- Hard cases were silently dropped instead of explicitly deferred.
