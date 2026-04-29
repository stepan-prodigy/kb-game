---
name: recall_session_profile_march
description: Dated session-profile artifact is retrievable by date reference.
query: March 2026 balanced session sample numerics
collection: kb
rerank: false
expect_path:
  - knowledge/session-profiles/2026-03-16_balanced_sample.md
top_k: 5
---

# Notes

Tests retrieval by date and content shape. The artifact name encodes the date (`2026-03-16`); the query references it textually ("March 2026"). This is a routing edge case — vector search may or may not bridge the gap between "March 2026" and "2026-03-16".

If this fails consistently, it's a flag to either (a) include date strings in canonical formats in the page body, or (b) tweak query expansion behavior.
