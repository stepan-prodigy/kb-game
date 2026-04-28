---
title: DDD Drafting Heuristics
type: heuristics
owner: data-team
last_modified: 2026-04-28
status: draft
---

# DDD Drafting Heuristics

Rules of thumb learned from real DDD drafts. Each heuristic should cite the arc(s) that produced it once we have a few cycles of review under our belt. Until then, treat this as a seed list to iterate against.

## Grounding

- **Cite or flag.** Every factual claim either cites a `knowledge/` path with section, or appears under "Open questions". No floating assertions.
- **Pull schemas before drafting events.** If the feature emits new events, retrieve adjacent schemas first. Mismatched field names between sibling events is the most common arc.
- **Glossary first.** When a term shows up in the PRD that doesn't appear in `knowledge/game-design/glossary*`, flag it as Q1 in Open Questions before the section that uses it.

## Section discipline

- **Stakeholders before feature overview.** Knowing who reviews shapes how much detail belongs in each later section.
- **TBD is a tool.** Sections marked "TBD with <stakeholder>" are valid output. Empty sections are not.
- **Funnel metrics need event coverage.** If section 6 lists a funnel metric, every step must map to an event in section 4.2. Otherwise you can't actually measure what you proposed.

## Scope

- **One DDD, one feature.** If two features share schemas, write two DDDs and link them. Bundled DDDs collapse stakeholder review.
- **Schema changes get their own PR.** The DDD references planned schemas; the actual `knowledge/event-schemas/<event>.md` lands in a parallel PR. Keeps review surfaces clean.

## When to stop drafting

- All template sections present (some may say "TBD").
- Every factual claim is grounded or in Open Questions.
- Open Questions list has explicit owners — not just "TBD".
- Arc written.

If you're tempted to keep drafting past these criteria, that's signal to ship and iterate via review. Perfect DDDs don't ship; reviewed DDDs do.
