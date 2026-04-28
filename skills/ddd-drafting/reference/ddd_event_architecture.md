---
title: DDD Event Architecture Patterns
type: architecture-patterns
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/reference_ddd_event_architecture.md
as_of_at_import: 2026-04-24
related:
---
Companion to `reference_ddd_template.md`. The template is the Confluence-mirrored authoring contract (what a DDD must contain). This file is the accumulated craft layer (how approved DDDs have handled recurring event-architecture challenges). Updated from comparisons of real DDDs against drafts.

## 0a. DDD scoping — extension vs standalone

Before drafting events, determine whether the feature is:

- **Standalone** — first DDD for this feature; nothing pre-existing to extend.
- **Extension of a prior feature with its own DDD** — e.g., Pet Merge 2.0 extends Pet Merge V1 DDD; Member-locked Rifts extends PMR DDD; Wizard Bank V2 extends Wizard Bank DDD.

For extension features, the right scope is **changes only** — new events, new fields on existing events, deprecated events. Refer the reader to the parent DDD for the unchanged baseline.

### How to detect a parent DDD

During research (Step 1 of `/draft-ddd`):

1. Note the feature name. If it has a version suffix (`2.0`, `V2`, `Phase 2`, "Member-locked X"), assume a parent exists.
2. CQL search for parent: `title ~ "<base feature name>" AND title ~ "DDD" AND space.key = "GD"`. Look for an older DDD with the same base name.
3. If a parent is found AND not in `--exclude-pages`:
   - Fetch its body to understand existing event coverage.
   - Set the scope flag: this draft covers **changes only**.

### When a parent DDD exists

In the new DDD's Section 1 (Scope), state explicitly:

> *"This DDD is built on top of [Parent DDD link]. It covers only the events and fields that change in [feature 2.0]. For the unchanged baseline (UI events, funnel events, base conversion events), refer to the parent DDD."*

In Section 5 (Event Tables), include only:
- **New events** introduced by this version.
- **Existing events with new fields added** (mark as "Existing, extended"; cite the parent DDD's event row by index for reference).
- **Deprecated events** (see §4b below).

Do NOT include events that already appear in the parent DDD unchanged. Drafting them again is duplication and creates a fork-risk if the parent updates independently.

### Worked example

The real Pet Merge 2.0 DDD (page 5412880411) opens with:
> *"This DDD is built on top of the Pet Merge DDD and therefore includes only the events that require changes to support the new system (Pet Merge 2.0). For a complete list of existing triggers and events, please refer to the [Pet Merge DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/4704600072)."*

The body covers ~9 events (changes only): Pet Details Viewed (extended), Pet Captured (new field), Pet Merged (multiple new fields), Pet Merge Cancelled (extended), Item Removed (extended), Pet Evolved (extended), Pet Evolution Cancelled, Team Updated, plus 2 deprecated events (Fetch Pet Roster, Pet Released — strikethrough). UI / funnel / conversion events that pet-merge inherits from V1 are NOT redocumented.

**Anti-pattern.** Drafting a standalone full DDD for a V2 feature when a V1 DDD exists. Forks the documentation; UI/funnel events drift between V1 and V2 DDDs as either evolves; reviewer has to mentally diff against V1.

## 1. Multi-level UI pattern — menu → item popup → action button

Most feature UIs are **not single-level**. A menu surfaces items; clicking an item opens a popup; the popup contains action buttons (wear / remove / buy / preview). Each level needs its own `Interface Opened` event, and the action buttons need their own `Button Clicked` events — not collapsed into a single "click-equips" model.

**Rule.** If a feature has a UI layer that (a) opens via click from a parent UI and (b) contains further actionable controls, model it as a **separate Interface Opened event** rather than collapsing into the parent.

**Worked example (Wizard Costumes real DDD):**

```
UI1: Interface Opened  interface_name = "costumes_menu"     (P0)
  ↓ click a costume card (UI13: Button Clicked, costumesItemCard-button)
UI2: Interface Opened  interface_name = "item_info"          (P2)
  ↓ click "wear" button (UI8: Button Clicked, wear-button) or
  ↓ click "remove" button (UI9: Button Clicked, remove-button)
IA1: Item Equipped  (or IA2: Item Unequipped)
```

Five UI events + one IA event, not one UI → one IA. The extra events cost little and buy:
- Engagement-without-commit signal (UI13 click without wear)
- Wear-intent signal (UI8 click) separate from equip (IA1) — decouples "wanted to equip" from "equip succeeded"
- Dwell time on item popup — diagnostic signal for confusion

**Anti-pattern.** Collapsing `click_card → equip` into a single IA1 event. Misses all three diagnostic signals above.

**When to use a single level.** Only when the UI has no popup / sub-modal — e.g., a binary toggle, a tab switch. If there's a popup or a modal-in-modal, use multi-level.

### 1a. Conversion-trigger modals get their own Interface Opened event

When a button click opens a **funnel-entry modal** (membership purchase, OTP, shop), fire **two events**:

1. `Button Clicked` on the trigger control (e.g., wear-button on a member-locked costume → `failure_reason = "member_locked"`).
2. `Interface Opened` for the modal itself (e.g., `interface_name = "membership_parent_ad"`, P0).

THEN fire `Game Purchase Funnel Entered` (or equivalent) to start the funnel.

Why two: the `Interface Opened` measures **UX delivery** (did the modal actually render). The funnel-entered event measures **analytics state** (did the funnel session begin). They can diverge — a modal can render but the funnel script can fail to initialize, or vice versa. Splitting them lets you debug each in isolation.

**Worked example (Wizard Costumes real DDD):**

```
UI8 (Button Clicked: wear-button on member-locked) → click_id
  ↓
IA3 (Item Equip Failed: failure_reason = "member_locked") → funnel_id from click_id
  ↓
UI3 (Interface Opened: membership_parent_ad) → P0  ← measures UX delivery
  ↓
C1 (Game Purchase Funnel Entered) → funnel_id from IA3 → measures analytics state
```

**Anti-pattern.** Collapsing the modal-render event into `Game Purchase Funnel Entered`. You lose UX/analytics debug separability.

### 1b. Navigation return events — bidirectional flow

If a feature modal contains a tab, button, or affordance that navigates *back* to a parent context (e.g., "Backpack" tab from within the Costumes menu, "Continue Playing" from a results modal), fire a `Tab Clicked` or `Button Clicked` event for the return navigation.

**Why.** Bidirectional engagement is a real signal — players who can navigate freely between feature and surrounding context behave differently from players who only forward-navigate. The return-tab click measures discovery-of-back-path and is materially distinct from a close-button click.

**Worked example (Wizard Costumes real DDD):**

```
UI11 (Tab Clicked: tab_name = "backpack", interface_name = "costumes_menu") — P2
```

**Anti-pattern.** Treating return navigation as just a Close event. Loses the directionality signal.

## 2. `instance_id` / `interaction_id` inheritance chain

Session reconstruction requires threading identifiers across related events. Real DDDs establish an inheritance chain: parent event generates a UUID; each child event inherits it; downstream state-change events carry the same UUID.

**Chain pattern (Wizard Costumes real DDD):**

```
UI1 (Interface Opened: costumes_menu)
    → generates instance_id (UUID)
      ↓ inherited
UI2 (Interface Opened: item_info) — carries instance_id from UI1 — generates its own instance_id too
      ↓ inherited
UI8 (Button Clicked: wear-button) — inherits instance_id from UI2, generates click_id (UUID)
      ↓ inherited
IA1 (Item Equipped) — inherits click_id as interaction_id
IA3 (Item Equip Failed) — inherits click_id as funnel_id (into C1)
IA4 (Player Avatar Updated) — inherits click_id as transaction_id
```

The chain lets analysts reconstruct "player clicked X in menu Y → triggered action Z" without joins across wall-clock time or player_id + session_uuid heuristics.

**Rule.** Every `Interface Opened` event should generate an `instance_id`. Every `Button Clicked` inside a modal should inherit the modal's `instance_id` AND generate its own `click_id`. Every state-change event (Item Equipped, Item Received, Funnel Advanced) should inherit the upstream `click_id` under an appropriate name (`interaction_id` / `transaction_id` / `funnel_id`).

**Anti-pattern.** Only using `session_uuid` + timestamp ordering. Works for low-volume clean sessions; breaks in multi-modal or rapid-action flows.

**When to skip.** If the feature has no multi-step action chain (e.g., a single-event notification), inheritance doesn't apply. Otherwise: use it.

## 3. Priority assignment heuristics

The template defines P0 / P1 / P2 but doesn't prescribe allocation. Approved DDDs follow a rough rule:

| Priority | Typical events |
|---|---|
| **P0** | Events answering a named hypothesis cluster's primary metric. Conversion funnel entered events. Core item state changes (equipped, unequipped, equip-failed). Funnel start/complete steps. |
| **P1** | Secondary engagement signals (close events, dwell timers, tab switches between feature-primary divisions). Member-lock failure events before the funnel opens. Return-to-feature step in feature funnel. |
| **P2** | Completeness/debugging events — tutorial funnel mid-steps, video playback (started / loaded / error), per-click navigation within a popular menu, impression events. Redundant events useful for cross-reference during investigation. |

**Common mistake.** Over-promoting events to P0 because they feel important. The real Wizard Costumes DDD has only about 40% of events at P0 — the rest are P1 or P2. Draft-writers tend to over-P0. When in doubt, P1.

## 4. New events: introduce one, document why

Approved DDDs are disciplined about introducing new events. Wizard Costumes real DDD introduces exactly one: `Costume Previewed` (preview without commit). Research meta alone doesn't discipline this — the drafter must restrain themselves.

**Rule.** Introduce a new event **only** when:
1. No existing Segment event captures the signal, AND
2. The signal is material to at least one named hypothesis cluster, AND
3. A brief one-paragraph justification can be written without hand-waving.

**Anti-pattern.** Inventing new events to capture signals that can be derived from existing events + session state (e.g., "Costume Seen" to capture pool-rotation seen-state; derivable from Item Equipped + general_pool_version + a denormalized flag).

### 4 caveat — event classification: cross-reference multiple sources, flag discrepancies

There is no single authoritative "is this event in production" source available to the drafter. Every source has known failure modes:

| Source | Strength | Failure mode |
|---|---|---|
| `project_math_game_event_taxonomy.md` (memory) | Refreshed regularly; reflects current understanding | May include events introduced by past DDDs that did or didn't ship; can be **forward-looking** (event in taxonomy because a DDD said it would exist) |
| [Segment Event Definitions](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3494445057) Confluence page (and child domain pages) | Intended as production-truth; Segment-tracking-plan-aligned | Frequently **stale** — domain pages can lag actual production telemetry by weeks/months. Some pages are stubs (e.g., Combat Events Revamp page 3340435492 was a stub at time of last test) |
| Release notes / Jira tickets | Closer to ship-truth | Scattered; hard to discover; not always linked to events |
| dbt models referencing the event (DIPPR memory: `project_math_game_event_taxonomy.md`, model inventory) | If a dbt model joins on the event, the event likely fires in prod | Selection bias — only events used downstream are visible |

**No single source is ground truth. Cross-reference at least the first two.**

### Classification procedure

For every event in your draft, do the following:

1. **Check `project_math_game_event_taxonomy.md`** — does the event appear?
2. **Check the Segment Event Definitions page** (and its domain children, e.g., Combat Events Revamp 3340435492, Player Identity & Avatar Events 3194979621) — does the event appear?

   **CRITICAL: how to check Segment Event Definitions pages.** Do NOT rely on `getConfluencePage` with `contentFormat: "markdown"` for these pages — the markdown extractor returns empty body for many of them due to macros / embedded property tables. Empty markdown body is **not** evidence of an absent or stub page. Use one of these reliable methods instead:

   - **CQL text search (preferred):** `text ~ "<event_text>" AND space.key = "DGD" AND ancestor = 3494445057`. This searches indexed content including macro-rendered text. Returns hits if the event is documented anywhere under the Segment Event Definitions hierarchy.
   - **ADF format fetch + grep:** `getConfluencePage` with `contentFormat: "adf"` returns full structured JSON. Extract `.body` and grep for the event name. Caveat: ADF body can be ~2-3 MB; pipe through `jq` to extract just the body before greppning.
   - **Fetch the parent page descendants** (`getConfluencePageDescendants` on 3494445057) to enumerate domain children, then check each.

3. **Check release notes / Jira if accessible** — has the event shipped?
4. **Cross-reference the result:**

| Taxonomy | Segment defs | Likely state | Classify | Flag in Reviewer Notes §B / §C |
|---|:---:|---|---|---|
| ✓ | ✓ | Confident **Existing** | Existing | No flag needed |
| ✓ | ✗ | Ambiguous — might be in prod with stale Segment page, OR might be unshipped DDD intent | Existing (with caveat) OR New (with caveat) — pick based on best signal (release notes, dbt usage) | **Flag discrepancy.** Note source disagreement; reviewer to confirm. |
| ✗ | ✓ | Likely **Existing** but taxonomy missing it — taxonomy hasn't been refreshed | Existing | Flag taxonomy gap |
| ✗ | ✗ | Confident **New** | New | No flag needed |

5. **If you are drafting a DDD that introduces the event**, you are the introducer regardless of source presence — classify as **New** and note in §B that "this DDD is the introducing source; event may appear in taxonomy/Segment defs because [a future-tense reference / past-DDD intent]."

### What to record in Reviewer Notes §B

Every event in your draft gets a one-line provenance entry:

> **NE1: `event_text` (event)** — Sources: taxonomy [✓/✗], Segment defs [✓/✗], release notes [✓/✗/not-checked]. Classification: [Existing | New]. Discrepancy: [none | description of source disagreement, reviewer to verify].

For events with discrepancies, also add a §C entry naming the doc inconsistency.

### Worked example — Spell Effects

A drafter writing a fresh Spell Effects DDD in 2026 sees:
- `Spell Status Effect Applied` in `project_math_game_event_taxonomy.md` ✓
- Same event NOT visible in Segment Event Definitions / Combat Events Revamp page (which is a stub) ✗

The drafter cannot tell from these two sources alone whether the event is already in production (Segment page is just stale) or planned-but-not-yet-shipped (taxonomy is forward-looking from a DDD that may not have shipped).

**Right behavior:** Pick a classification based on best-available signal (release notes if accessible, dbt models if any join on the event), AND flag the source discrepancy explicitly in §B + §C. The reviewer is the human who knows the actual production state and can resolve.

**Anti-pattern.** Picking one source dogmatically and not flagging the discrepancy. Either "always trust taxonomy" or "always trust Segment defs" hides real source disagreement from the reviewer.

### 4b. Event deprecation pattern

When a feature **removes** an event family (event no longer fires after this release), include the event row in the relevant section with **strikethrough formatting** and a deprecation note. This signals to dbt model maintainers, downstream analytics, and tracking-plan owners that:

1. The event will stop arriving in production after this release.
2. Downstream models should be updated to drop dependent fields or move to alternative events.
3. The Segment tracking plan / Common Event Log Schema should be updated to remove or annotate the deprecation.

**Format example (real Pet Merge 2.0 DDD pattern):**

```markdown
## ~~Fetch Pet Roster~~

Deprecate this event in [feature]. Last fired in [version]. Reason: [why deprecated].

| ~~Index~~ | ~~Event Trigger~~ | ~~field 1~~ | ~~field 2~~ |
| --- | --- | --- | --- |
| ~~FPR1~~ | ~~The player initiates pet merge~~ | ~~"pet merge"~~ | ~~JSON object…~~ |
```

**When to use deprecation rows:**

- Event was previously documented in the parent DDD or in production telemetry, and this release stops its emission.
- Event is being replaced by a new event (note the replacement in the deprecation rationale).
- Event was experimental and is being retired.

**When NOT to use deprecation rows:**

- Event continues to fire but with reduced scope or different field values — that's an extension, not a deprecation.
- Event was only documented but never shipped — silently drop it; no need to call out in the new DDD.

**Reviewer Notes interaction.** Deprecations should appear in §B provenance table with `Classification = Deprecated` and a §C entry naming what the deprecation impacts downstream (dbt models, dashboards, alerts).

### 4a. Placement of new events — UI vs IA vs FA

When a new event clears the three-question rule, place it in the section that matches its **semantic counterpart**:

| Event captures | Place in | Example |
|---|---|---|
| Click, hover, preview, dwell on a UI control | UI section | `Costume Previewed` (UI12 in real Wizard Costumes DDD) |
| Item state change, possession, equipment, identity | IA section | (none in real WC DDD; would be e.g., `Costume Granted` if there were direct purchases) |
| Funnel milestone, completion, achievement progress | FA section | (none in real WC DDD; would be a new tutorial-funnel step) |
| Conversion / monetization signal | C section | (none in real WC DDD; existing funnel events cover this) |
| Combat or spell action | Combat section | `spell_effect_applied` (real Spell Effects DDD) |

**Heuristic.** If the new event answers "what did the player click or look at?" it belongs in UI. If it answers "what state changed about the player?" it belongs in IA. Choose by reader's mental model, not by where it's *generated* in code.

**Anti-pattern.** Putting `Costume Previewed` in IA because previewing changes the avatar visually. The previewing is a UI-level interaction; the avatar-update side effect already has IA4 (`Player Avatar Updated`). The preview event itself belongs in UI.

## 5. Economy / Combat sections — call out non-applicability

If a feature doesn't touch economy or combat, don't delete the section — explicitly state it's **not applicable** and why. This avoids the reviewer wondering whether you forgot.

Real DDD example: section 5.4 Economy states "During the Beta, there is no direct purchase of costumes..." Similarly section 5.7 Combat Events would state "Costumes do not change combat...".

## 6. Pre-draft checklist

Before writing a DDD:

- [ ] Template loaded (`reference_ddd_template.md`)
- [ ] This addendum loaded (`reference_ddd_event_architecture.md`)
- [ ] **At least one exemplar DDD fetched** as style reference — PMR & Rifts (4397891585) for complex funnels, Spell Effects (5108105217) for extending existing events, First Pet Rescue (5478481921) for FTUE features, Combat Formula (5250514946) for pre/post evaluation design.
- [ ] Feature brief synthesized (what does the UI look like, what layers does it have, what's the phase)
- [ ] Multi-level UI question answered: is there a popup inside the main menu? If yes, plan for separate Interface Opened events.
- [ ] Instance_id inheritance plan: identify the top-level Interface Opened and the IA action event; list the chain.

## 7. Post-draft review pass

After writing the draft and before finalization:

- [ ] **Multi-level UI check.** For every UI modal in the feature, is there an Interface Opened event? For every button inside that modal that causes a state change, is there a separate Button Clicked event?
- [ ] **Conversion-trigger modal split (§1a).** If a click opens a funnel-entry modal (MLP, OTP, shop), is there a separate Interface Opened event for the modal AND a separate Funnel Entered event? Don't collapse them.
- [ ] **Navigation return events (§1b).** If the feature modal has a tab or button that navigates back to a parent (e.g., Backpack tab from inside Costumes), fire a Tab Clicked / Button Clicked for it. Don't fold into Close.
- [ ] **New event placement (§4a).** Is each new event in the section matching its semantic counterpart (UI for clicks/previews, IA for state changes, FA for milestones, C for conversion)?
- [ ] **instance_id threading.** Pick one representative action (e.g., "equip a costume"). Can you trace the UUID chain from Interface Opened → Button Clicked → IA event? If any link is missing the inheritance, add it.
- [ ] **Priority sanity.** Count events at each priority level. If > 60% are P0, reassess — likely over-promoted. Re-read the template's P0/P1/P2 definitions and downgrade events that are "nice-to-have for debugging."
- [ ] **New event audit.** Count new events introduced. For each, verify against Section 4 rule above. If the signal can be derived from existing events + session state, drop the new event and add a derivation note.
- [ ] **Event classification cross-reference (§4 caveat).** For every event in the draft (Existing AND New), record source presence in the taxonomy and the Segment Event Definitions page. When sources disagree, flag the discrepancy in Reviewer Notes §B + §C — don't dogmatically trust one source. Reviewer resolves.
- [ ] **Section 5.4 Economy / 5.7 Combat.** If the feature doesn't touch these, explicitly state N/A and why. Don't silently omit.
- [ ] **Edge cases cross-reference.** Check real-DDD edge cases list (Morph Marbles, offline/degraded, tutorial scripted flows) against your suppressions. Also pull from QA Plan's impact analysis for feature-specific suppressions.
- [ ] **Suppression rules scope.** Confirm every suppression rule names the event it suppresses explicitly.
- [ ] **Standard-fields note.** Section 5.0 must include the Common Event Log Schema reference.
- [ ] **Segmentation axes.** Member × level band × home/school required. Add feature-specific axes (device, locale, experiment arm) only if feature-relevant.

## 7.5. Verbosity discipline (final pass)

Standardized output drives downstream workflows (dbt aggregate drafting, engagement analysis, future tooling). But repetition/verbosity that doesn't increase functional value is cuttable. After the §7 checklist, do this verbosity audit:

**Cut entirely from the DDD body:**

- **§0 "DDD Scope" boilerplate.** ("A DDD does X, doesn't do Y") — readers know what a DDD is. The template's §0 is meta-guidance, not feature content.
- **§6 "Quick Checklist" (the boilerplate template version).** A generic checkbox list adds nothing. Replace with the structured **Reviewer Notes appendix** (§9 below) which captures feature-specific findings.
- **Justification paragraphs that restate event-table content.** "Notes on UI table" / "Notes on IA table" are useful only when documenting *non-table-visible* information (instance_id chains, derivation rules, exception scope). Cut those that restate descriptions.
- **"What is a DDD" framing prose at section openings.** Replace with one-line opener: "DDD for [feature]; phase: [phase]; evaluation: [design]."

**Consolidate (don't restate):**

- **Per-domain N/A subsections** (§5.5 Economy: N/A, §5.7 Combat: N/A as separate sub-sections) → single "Domains not applicable" callout listing all in one paragraph.
- **Segmentation axes** stated in §2.x Success Metrics, §3.x Edge cases, AND §5.0 Global conventions → state once in §2.x; reference from elsewhere.
- **Standard guardrail pack** if listed verbatim AND mentioned per-cluster → list by name once; reference (don't re-explain individual guardrails inline; the analytics taxonomy file owns those definitions).

**Compress to structured form (functional gain via parseability):**

- **Hypothesis clusters as long prose** → bullets with explicit event references:
  > **H1: Discoverability & usability.** Treatment players find Costumes via ≥1 of 4 entry points within first session.
  > - *Risk (UXR):* HUD noticed-but-not-clicked.
  > - *Measured by:* `Interface Opened` (UI1) entry-point split via `origin_id`; FA1 → FA2 conversion.
- **New-event justifications** → 1-line with provenance check:
  > **NE1: `Costume Previewed`** — preview without commit. Existing UI events don't capture render-state during preview. Material to H2 + H3. Provenance: not in Segment Event Definitions 3494445057, classified New.
- **Suppression rules** → table form (rule / suppressed event / discriminator / allowed events / reason). Drives DQ filter macros directly.
- **§5.0 Global conventions** → field-table for instance_id/click_id/funnel_id semantics rather than narrative paragraph.

**Net effect.** Drafts ~30% shorter without losing functional content. Structured forms (tables, bullets with event refs) parse cleanly into dbt model definitions and DQ macros without human re-translation.

## 8. Common drift patterns to watch

| Drift | How it shows up | Fix |
|---|---|---|
| Over-eventing conversion funnel | 5+ explicit rows for membership funnel (entered / impression / hand-off / quit / complete / step-error) | Real DDD uses ONE row (C1 Entered) + prose: "Other funnel events should fire as usual with inherited funnel_id." |
| Over-eventing feature funnel | 9+ FA rows including return-session, second-day-change | Real DDDs cap at ~6 FA rows (first-time milestones only). Derive return-engagement from Item Equipped timestamps. |
| Collapsing multi-level UI | 1 UI event per feature mode | Add Interface Opened for popup/modal layers. |
| Inventing new events from TDD detail | TDD mentions "TRACKING NEW COSTUMES SEEN" → drafter invents "Costume Seen" event | Derive from Item Equipped + pool version. New event only if derivation is impractical. |
| Missing the item popup tier | Click card → equip (one event chain) | Card click → Interface Opened (popup) → wear/remove button → IA event (four-stage chain). |

## 9. Reviewer Notes appendix (structure)

Every DDD draft should end with a **Reviewer Notes** appendix — replaces the boilerplate quick checklist. This is where the drafter captures decisions, findings, and caveats that the human reviewer needs to evaluate. It stays in the DDD body (not moved to step log) because it's the artifact the reviewer reads alongside the DDD.

**Required structure:**

### A. Design decisions

Capture choices that an alternate drafter or reviewer might reasonably question. Each entry: decision + alternative considered + rationale.

Examples:
- *"Modeled `wear` and `remove` button clicks as separate UI events (UI8, UI9) inheriting from item_info popup's instance_id. Considered: collapsing into IA1 directly. Rationale: addendum §1 multi-level UI requires separate Button Clicked for state-changing actions inside a popup; click_id inheritance enables wear-without-equip detection."*
- *"Classified `Spell Effect Applied` as **New** despite presence in `project_math_game_event_taxonomy.md`. Provenance check: not in Segment Event Definitions 3494445057. Per addendum §4 caveat: taxonomy ≠ production-truth."*

### B. Event classification provenance (cross-reference table)

For every event in the draft — Existing AND New — record source-presence and any disagreement:

| Index | event | Taxonomy | Segment defs | Release notes / dbt | Classification | Discrepancy |
|---|---|:---:|:---:|:---:|---|---|
| BA1 | `battle_action_performed` | ✓ | ✓ | ✓ (used in dbt) | Existing | none |
| NE1 | `costume_previewed` | ✗ | ✗ | ✗ | New | none |
| BA3 | `spell_effect_applied` | ✓ | ✗ (stub page) | unknown | Existing (likely shipped; see §C) | **taxonomy ↔ Segment page disagreement** |

When sources disagree, the row's `Discrepancy` column states the disagreement; a corresponding §C entry names the doc inconsistency. **Don't dogmatically trust one source.** Capture both findings; reviewer resolves.

### C. Doc inconsistencies surfaced in research

Cross-doc differences that affect the draft. Each entry: docs involved + nature of inconsistency + how the drafter resolved it.

Examples:
- *"GDD says feature is in Beta; release-notes page indicates production launch on 2025-12-10. Resolved: treated as post-release DDD with pre/post evaluation."*
- *"TDD title singular ('Wizard Costume') vs GDD/QA Plan plural. Confirmed typo from body content; not a separate feature."*
- *"TDB (page X) proposed morph-marble-based item type; TDD commits to new secure-inventory type. TDB is superseded; design follows TDD."*

### D. Open questions / TBDs flagged

Items where the drafter could not resolve from research alone and requires reviewer input. Each: question + relevant docs + drafter's tentative position.

Examples:
- *"Should `Costume Previewed` (NE1) link back to the originating `Interface Opened` (UI2) via instance_id? GDD doesn't address. Tentative: yes, inherit instance_id from UI2."*
- *"Hard Mode is a cohort discriminator, not a suppression. Confirmed via release-notes page; reviewer should validate."*

### E. Confidence flags

Sections where the drafter's confidence is low — typically due to incomplete source docs or ambiguous semantics. Each: section + reason.

Examples:
- *"§2.4 Segmentation: device/locale axes added based on QA Plan risk callouts; not explicitly required by analytics taxonomy. Reviewer to confirm."*
- *"§5.4 Membership funnel: only C1 explicit; assumed standard funnel events (hand-off, complete, quit, step-error) fire downstream with inherited funnel_id. Reviewer to verify."*

### F. Post-draft review pass — fixes applied

What §7 caught and what was changed. Brief — bullet list per fix.

Examples:
- *"Initial UI table had 14 rows incl. duplicate Tab Clicked; consolidated to 11."*
- *"P0 share initially 65% (over the 60% threshold); downgraded UI5, FA7, FA8 to P1; final 42%."*
- *"Initially proposed `Costume Seen` as new event for pool-rotation tracking; addendum §4 derivation rule caught — dropped, derivable from IA1 + general_pool_version."*

---

This structure makes the DDD self-contained for review: a reviewer sees the design choices, the provenance checks, the inconsistencies the drafter handled, and the open questions — all without re-deriving any of it.

## Related files

- `reference_ddd_template.md` — the Confluence-mirrored authoring contract (what to include)
- `reference_common_event_log_schema.md` — the 21-column schema that every DDD links in Section 5.0
- `project_math_game_event_taxonomy.md` — event family index for picking existing Segment events
- `project_math_game_analytics_taxonomy.md` — domains, segmentation, KPI catalog, guardrail pack

## Revision triggers

Update this file when:
- A real DDD review surfaces a pattern not captured here
- An approved DDD uses a new event-architecture idiom worth codifying
- A draft-vs-real comparison (like the Wizard Costumes test, 2026-04-24) identifies a recurring gap
