---
name: routing_kb_for_game_design
description: Factual game-design query routes to the kb collection, not skill-*.
query: What pets exist in Math Game?
collection: kb
rerank: false
expect_path:
  - knowledge/game-design/pets.md
forbid_substring:
  - skill-
top_k: 5
---

# Notes

Tests collection routing. A pure game-design question should land in `kb`. If `skill-*` content surfaces in top-k, it indicates retrieval bleed across collections.

Comparison-with-memory baseline: this query should resolve via memory's `MEMORY_math_game.md` → `project_math_game_pets.md` route. kb-game retrieval should match or exceed that direct file lookup.
