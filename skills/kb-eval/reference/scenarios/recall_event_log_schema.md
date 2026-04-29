---
name: recall_event_log_schema
description: Common Event Log Schema page is recalled for canonical-contract queries.
query: 21-column common event log schema
collection: kb
rerank: false
expect_path:
  - knowledge/event-schemas/common_event_log_schema.md
expect_substring:
  - "21"
top_k: 5
---

# Notes

Memory baseline: this is one of the most-loaded references in DDD authoring. The 21-column contract is the canonical reference cited by the DDD template. If kb-game can't recall this for a canonical query, the system fails for the most common case.
