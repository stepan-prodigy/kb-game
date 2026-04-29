---
name: cross_ddd_authoring_with_event_grounding
description: Mid-draft DDD query should pull from BOTH skill-ddd-drafting (template) and kb (event facts).
query: How do I structure the events table for a P0 progression event?
rerank: false
expect_path:
  - skills/ddd-drafting/reference/template_ddd.md
  - knowledge/event-schemas/common_event_log_schema.md
top_k: 8
---

# Notes

Tests cross-collection retrieval. A real DDD-drafting question references both procedural conventions (P0/P1/P2 priority pack from the template) AND factual event-schema content (the 21-column contract). Top-k should contain at least one chunk from each collection.

If only skill-ddd-drafting content appears, retrieval is over-scoping to procedural; if only factual appears, it's missing the procedural anchor. The DDD-drafting workflow needs both.

Comparison-with-memory baseline: memory routing would explicitly load both `reference_ddd_template.md` AND `reference_common_event_log_schema.md` because `MEMORY_math_game.md` lists them in the "Analytics & DDD authoring" section. kb-game must surface at least one chunk from each via a single hybrid query.
