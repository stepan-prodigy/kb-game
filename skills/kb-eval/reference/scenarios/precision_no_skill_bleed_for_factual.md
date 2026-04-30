---
name: precision_no_skill_bleed_for_factual
description: Factual recall query (unscoped) should not surface heuristics/templates as top results.
query: What is the Math Game core gameplay loop?
rerank: false
expect_path:
  - knowledge/game-design/product.md
forbid_substring:
  - heuristics
  - template_
top_k: 3
---

# Notes

Precision guard. Factual queries about game design should not have skill heuristics or templates show up in top-3 — those are procedural docs and surfacing them for a factual query indicates retrieval bleed across collections.

Tighter `top_k: 3` because at top-5 some procedural surfacing is acceptable; the test is whether they DOMINATE.
