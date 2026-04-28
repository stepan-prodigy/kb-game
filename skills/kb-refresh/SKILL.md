---
name: kb-refresh
description: Refresh a knowledge/<section> against its source-of-truth (Confluence, code, external docs). Drafts a refresh proposal as a diff and surfaces it for user-gated PR review.
---

# kb-refresh

Non-procedural refresh workflow. The other half of the two-stream review architecture (arc-review handles procedural; kb-refresh handles factual).

## Inputs

- **section** (e.g. `knowledge/event-schemas/`)
- optionally a specific page within the section
- source-of-truth handle (resolved per page from `source:` frontmatter or section convention)

## Workflow

### 1. Resolve source-of-truth

Each page declares its source. Look at:
- Frontmatter `source:` field (preferred — explicit URL or path)
- `imported_from:` provenance (if migrated from memory)
- Section convention (e.g. `event-schemas/` ← Segment tracking plan space)

If unresolved, halt and add a flag to `KB_PENDING.md`.

### 2. Fetch latest

- **Confluence**: via the Atlassian MCP server
- **Code / repo**: direct file read against the source repo
- **External**: WebFetch

### 3. Diff

Compare fetched content to current kb-game page. Surface:
- **New** sections to add
- **Changed** sections (show full diff, not just "changed")
- **Removed** sections (mark as deprecated, don't auto-delete)

### 4. Draft proposal

Write to `proposals/knowledge/<section>_<YYYY-MM-DD>.md`:

```markdown
# kb-refresh proposal — <section> — <date>

## Pages reviewed
- <path> ← <source-handle>

## Per-page changes
### <path>
- New: <list>
- Changed: <diff>
- Removed: <deprecation list>

## Open questions
- ...
```

### 5. Surface for review

User reviews the proposal, edits accept/reject decisions inline, then PRs the accepted edits to `main`.

### 6. Write own arc

`skills/kb-refresh/arcs/<date>_<topic>.md` capturing what worked / didn't in this refresh pass — typically: source-of-truth ambiguity, fetch failures, diff noise patterns.

## Cadence

- **Initially**: manually triggered per section.
- **Eventually**: scheduled per section, with `refresh_cadence` declared in section frontmatter (e.g. `monthly`, `quarterly`).

## Output

- `proposals/knowledge/<section>_<YYYY-MM-DD>.md`
- `skills/kb-refresh/arcs/<date>_<topic>.md`

## Quality bar

Done when:
- Every page in the section has been compared against source-of-truth.
- Every diff is surfaced (no silent drops).
- The proposal is reviewable without re-fetching.

NOT done when:
- Source-of-truth was inferred without confirming.
- "Changed" sections lack a full diff.
- Deprecations were applied without flagging for user decision.
