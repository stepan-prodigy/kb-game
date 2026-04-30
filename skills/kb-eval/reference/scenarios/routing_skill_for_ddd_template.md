---
name: routing_skill_for_ddd_template
description: A query for the DDD template should hit the skill-ddd-drafting collection.
query: DDD template section structure
collection: skill-ddd-drafting
rerank: false
expect_path:
  - skills/ddd-drafting/reference/template_ddd.md
forbid_substring:
  - knowledge/event-schemas
top_k: 5
---

# Notes

Tests the inverse of `routing_kb_for_game_design`: a procedural-template query should land in `skill-ddd-drafting`, not in factual `kb` content. If `knowledge/event-schemas/` surfaces here, retrieval is leaking factual pages into a procedural query.
