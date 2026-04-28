---
title: kb-refresh Heuristics
type: heuristics
owner: data-team
last_modified: 2026-04-28
status: draft
---

# kb-refresh Heuristics

Seed list. Grows from arcs.

## Source-of-truth resolution

- **`source:` frontmatter is the contract.** If absent, refresh halts and adds a TODO to `KB_PENDING.md`. Don't infer.
- **Multi-source pages list every contributor** in `source:` as a list. The diff step considers all of them.
- **kb-game is canonical for team-owned content.** If Confluence and kb-game disagree on a page that the team owns (anything under `game-design/`, `event-schemas/` for our events, or `_meta/`), the refresh proposes updating *Confluence*, not kb-game.

## Diffing

- **Always diff before drafting; don't redraft from scratch.** Whole-file rewrites destroy in-flight edits and review history.
- **Section deletion is a strong signal — surface, don't apply.** Confirm with the user that it's intentional, not a temporary source edit.
- **Diff noise (whitespace, list-marker style, link rewrites) gets filtered before the proposal.** Otherwise the proposal becomes unreadable.

## Cadence

- **Don't refresh more often than the source changes.** Pages with `last_modified_at_source` < 30 days old usually don't need a refresh pass; check the source's metadata first.
- **Cadence per section, not per page.** Mixed-cadence pages within one section produces noisy proposals.
