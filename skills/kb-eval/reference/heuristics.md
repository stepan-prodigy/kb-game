---
title: kb-eval Heuristics
type: heuristics
owner: data-team
last_modified: 2026-04-28
status: draft
---

# kb-eval Heuristics

Seed list. Grows from arcs.

## Scenario design

- **Scenarios come from real queries.** Pull from arcs (especially "What didn't" sections) and review notes — don't invent scenarios in isolation. A scenario without a real query that motivated it tends to drift from how the system is actually used.
- **Both recall and precision.** Every scenario should declare what *should* surface AND, where applicable, what should NOT. Recall-only evals miss the false-positive class.
- **Collection-scoped scenarios test routing.** If a query is meant for the `skill-ddd-drafting` collection, run it both with that scope and unscoped — failures in the unscoped run flag retrieval bleed.

## Running

- **Test `rerank: true` and `rerank: false` separately.** They often diverge — rerank can both rescue and demote. Where rerank latency matters (Apple Silicon under colima, agent loops), the no-rerank baseline is the production path and needs its own eval coverage.
- **Eval the live image, not the source corpus.** kb-eval runs against `docker run -i <image>`, not against `qmd` against the source tree. The image is what users hit.

## Reporting

- **Regressions matter more than absolute pass rates.** A 95%-pass eval that flips three previously-passing scenarios is more interesting than a 60%-pass eval with stable failures.
- **First-run noise.** When the scenario set first goes live, ~half the failures are scenarios that were never exercised. Capture, fix scenarios first, then judge regressions.

## Coverage

- **A scenario covering a recurring arc theme is more valuable than a scenario covering a unique gap.** Themes recur; uniques don't. Bias scenario growth toward what arcs flag repeatedly.
- **When a scenario fails repeatedly, capture it as an arc.** Eval coverage is kb-eval's own responsibility — improving its scenarios improves the system's ability to evaluate itself.
