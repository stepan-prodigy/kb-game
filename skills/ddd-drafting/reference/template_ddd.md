---
title: DDD Template
type: template
owner: data-team
last_modified: 2026-04-28
status: draft
---

# DDD Template

Canonical section order for a Data Design Document. Every DDD draft should hit every section; mark "TBD with <stakeholder>" rather than skipping.

## 1. Summary

One paragraph. What feature, what data work it demands, why it matters. The reader should be able to stop here if they only need the gist.

## 2. Stakeholders

| Role | Person/team | What they own |
|---|---|---|
| Product | | |
| Design | | |
| Engineering | | |
| Data | | |

## 3. Feature overview

- What the player does.
- What surfaces (client → backend → analytics) are affected.
- Any existing systems this extends or replaces.

Cite the source PRD / Confluence page.

## 4. Data model

### 4.1 New entities

For each entity:
- Name, granularity, primary key.
- Producer (which service emits it).
- Storage layer (bronze / silver / gold).

### 4.2 New events

For each event, link to the schema doc under `knowledge/event-schemas/`:
- Event name, phase enum (if applicable), required fields.
- Triggering conditions.
- Frequency expectation (per session, per player, per day).

### 4.3 Schema changes to existing entities

For each touched table:
- Field added/changed/deprecated.
- Migration plan.
- Backwards compatibility window.

## 5. Pipelines

- Bronze: raw event ingestion. Source topic / table.
- Silver: cleaned + typed event tables. Note any joins to dimensions.
- Gold: feature-specific aggregates. Mention downstream dashboards or models that consume them.

Cite existing dbt models that will be extended.

## 6. Dashboards & metrics

What we'll measure once the feature is live:
- Adoption (how many players touch it)
- Engagement (frequency, duration)
- Retention impact (vs. counterfactual)
- Funnel completion (if applicable)

Owners and review cadence per metric.

## 7. Open questions

Numbered list. Each item:
- Question.
- Who can answer.
- Blocks which downstream decision.

This section is the inbox — the DDD ships when the questions are tractable, not when the list is empty.

## 8. Timeline

| Milestone | Date | Owner |
|---|---|---|
| DDD reviewed | | |
| Schemas merged | | |
| Pipelines live | | |
| Dashboards live | | |

## 9. Related docs

- `knowledge/...` — kb-game pages this DDD grounds against.
- External: PRD, Figma, Confluence (with links).
- Prior DDDs covering adjacent features.
