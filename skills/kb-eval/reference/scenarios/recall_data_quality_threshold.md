---
name: recall_data_quality_threshold
description: Cheater-filter threshold is recallable from the data_quality page.
query: cheater filter threshold Math Game
collection: kb
rerank: false
expect_path:
  - knowledge/game-design/data_quality.md
expect_substring:
  - cheater
top_k: 5
---

# Notes

Tests recall of a specific operational claim (numerical threshold) from a domain page. This is a query type where exact-string match (BM25) often outperforms semantic search alone — a hybrid should pick it up.

If this fails on `rerank: false` but passes on `rerank: true`, that tells us the rerank model is masking a BM25/vector underperformance. Worth flagging in the report.
