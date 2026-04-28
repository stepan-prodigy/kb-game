---
title: DDD Template (verbatim Confluence source)
type: template
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/reference_ddd_template.md
as_of_at_import: 2026-04-24
related:
---
**Source sync.** Verbatim from Confluence page 6113787907, [*Data Design Document Template and Guidelines*](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6113787907), in space GD (Math Game Development). Last synced 2026-04-24 from Confluence version 4 (last modified there 2026-04-08). Edit this file as source of truth; Confluence is the human-readable mirror.

---

*(Aligned to Wizard Costumes DDD)*

**Author:** Stepan Oskin

**Date:** 2026‑04‑08

---

This page defines the **scope, structure, and expectations** for all Data Design Documents (DDDs) used in Prodigy Math Game.

The **primary implementation example** for these guidelines is:
[Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588)

---

## 0. DDD Scope: What a DDD Covers vs. Does _Not_ Cover

**A DDD _does_**:

- Describe **what needs to be measured** for a feature:
    - Core **product/UX questions** and **success metrics**.
    - The **specific events** and **properties** required to answer them.
- Reuse and extend **existing Segment events and tracking plans**:
    - e.g., [Segment Event Definitions](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3494445057)
    - Domain pages like:
        - [User Interface Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3158835840)
        - [Player Identity & Avatar Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3194979621)
        - [Progression Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3158835812)
        - [Membership and Conversion Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3218800725)
        - [Economy Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3494445057/Segment+Event+Definitions#Economy-Events)
        - [Common Event Log Schema](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6101434383)
- Specify **event tables** that:
    - Use the standard **Priority / New-or-existing / Index / event_text / event / Key fields** pattern.
    - Call out **P0/P1/P2** priorities.
    - Clearly link **events to questions/metrics**.
- Call out **edge cases, suppressions, and guardrails** (e.g., tutorial flows, battle metric contamination, experiment guardrails).

**A DDD _does not_**:

- Duplicate **full technical design** or implementation detail (TDD / GDD remain source for mechanics and architecture).
- Specify **dbt model code** or column-level warehouse schema (that belongs in analytics/ETL design).
- Try to cover **every possible analysis**—it focuses on the **minimum telemetry** needed to answer **core questions and guardrails**.
- Replace global tracking plan docs (Segment tracking plans remain the canonical definition for each event family).

---

## 1. General Meta

Every DDD starts with a compact meta section.

**Required elements:**

- **Title:** `[Feature Name] DDD`
- **One-line description:** What the feature is and why we care (link inline to GDD/PRD).
- **Author & Date:** Use a date node for latest update.
- **Related docs (inline cards, not raw URLs):**
    - GDD / PRD
    - Relevant TDD
    - UXR readouts (if they influence hypotheses)
    - Canonical tracking docs:
        - [Common Event Log Schema](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6101434383)
        - [Segment Event Definitions](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3494445057)
        - These guidelines

**Example:** see the meta section in [Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588).

---

## 2. Scope and Purpose

Clarify **what this DDD covers**, and how it fits into the broader feature.

**Must include:**

- **Feature overview:**
    - 2–3 paragraphs max, summarizing:
        - What the feature does in player terms.
        - What is _special_ about this feature analytically (e.g., "purely cosmetic", "tutorial-like scripted flow", "side-mode combat loop").
        - **Phase:** briefly note whether this is a **beta / killswitch release** (discovery & comprehension focused, e.g. [Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588)) or a full **v1** (expected to move business KPIs).
    - Link to GDD/TDD where deeper design details live.
- **Feature performance / evaluation design:**
    - Explicitly state **how** the feature's effect on audience behavior will be estimated:
        - A/B test (control vs treatment; which segment, which timeframe).
        - Pre/post comparison or [difference‑in‑differences (DID)](https://docs.google.com/presentation/d/1qu4GTnNtFen6SyZqc5EfirNBv1_G9FuLI5aZirr4q38/edit#slide=id.g27651de2d4c_0_0) when there is no experiment (see examples in [Puppet Master's Revenge (PMR) & Rifts DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/4397891585), [Spell Effects DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5108105217), and [Combat Formula DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5250514946)).
    - Call out **time windows** and **limitations**:
        - Seasonality / other concurrent releases.
        - If DID is used, when DID assumptions are particularly fragile.
- **Out-of-scope note:**
    - E.g., "Direct costume purchases will be added in v1; this DDD only covers beta (no direct economy events)."

**Reference:** Section 1 in [Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588).

---

## 3. Key Analytical Questions & Success Metrics

This is the **why** of telemetry. It should be tight but explicit.

**3.1 Hypotheses (clusters)**

- 3–5 **hypothesis clusters**, each:
    - Names a theme (e.g., **Discoverability & usability**, **Comprehension of "cosmetic only"**, **Engagement & retention**, **Monetization potential**).
    - Ties to:
        - GDD intent.
        - UXR concerns/findings (e.g., confusion around stats, entry point discoverability issues).
    - _**It is important to address the potential negative outcomes even if they are undesirable if there are reasons to believe they are plausible as effects of this change.**_

**3.2 Key questions**

- Group key questions under a few **recurring themes**. Common patterns from previous DDDs include:
    - **Discoverability & usability**
        - "What proportion of eligible players ever open the Costumes UI?" ([Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588))
        - "What pct of active users start Spell Effects tutorial, and what pct complete it?" ([Spell Effects Tutorial DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5580947466))
        - "Progression through the Rift feature funnel (active → received first Rift key → opened Rift Selection Menu → started first Rift run → …)." ([PMR & Rifts DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/4397891585))
    - **Comprehension / mental model**
        - "After equipping a costume, do players remove it before battles?" (misunderstanding 'cosmetic‑only'). ([Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588))
        - "After equipping a costume, do players remove it before battles (misunderstanding 'cosmetic‑only') or show spikes in gear swapping / costume removal consistent with 'searching for lost stats'?" ([Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588))
        - "Do players understand that Magicoin is required to rescue pets?" (via tutorial completion + Magicoin spend) ([First Pet Rescue DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5478481921)).
    - **Engagement, depth & repeat usage**
        - "Are spells that have effects being used more? Are pets who have effects being used more? Do players use them once or repeatedly?" ([Spell Effects DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5108105217))
        - "Depth of progression and amount of repetition to advance through Rift tiers (max tier reached, repeats per tier, number of Dragons defeated)." ([PMR & Rifts DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/4397891585))
        - "Fraction of players who equip at least one costume within X days of exposure; fraction that change costumes on multiple distinct days." ([Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588))
    - **Mechanical changes & game health**
        - "Win rate, pct of one‑shot kills, attacks‑to‑kill, rate of dodged and critical attacks." ([Combat Formula DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5250514946))
        - "Avg level difference of completed battles; pct of users who pick easy / appropriate / hard battles." ([Battle Reward Scaling DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5133402932))
    - **Monetization & economy**
        - "Did week‑0 cash per activation change?" ([First Pet Rescue DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5478481921), Magicoin tutorial).
        - "Subscription conversion rate, OTP conversion rate/spend (OTP is currently switched off in product); did reward scaling harm conversions?" ([Battle Reward Scaling DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5133402932))
        - "Do members prefer member‑locked costumes over free ones? Does interest in member‑locked cosmetics translate into membership funnel engagement?" ([Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588))

**3.3 Success metrics & guardrails**

Different experiments can have different targets and guardrails, need to consider context of the test each time. Also, phase determines goals as well - beta versions usually are not expected to produce full effect in terms of engagement or monetization yet, their objectives may be more focused around discovery, reach and usability compared to v1, which will likely focus more on business bottom line metrics like conversions or paid retention.

- **Primary metrics:** reach, adoption, depth, persistence, engagement, retention, monetization, etc.
- **Standard guardrail pack:**
    - **Engagement and retention:**
        - pct users with a battle, avg battles per user, avg playtime per user, avg playtime per member
          (e.g., [Combat Formula DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5250514946), [Battle Reward Scaling DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5133402932)).
        - pct of users with homeplay, avg home playtime per user
        - D1 or D7 retention
    - **Monetization:**
        - subscription conversion rate, overall OEC (eLTV approximation: sales price x estimated paid retention defined per license type - assumes no changes in paid retention)
        - "do‑no‑harm" thresholds to be called out when appropriate
    - **Progression:**
        - tutorial completion (for changes affecting FTUE), new user retention
        - avg level gain split by level range; ensure late‑game progression is not slowed excessively (see [Battle Reward Scaling DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5133402932)).
            - would only act as guardrail on tests where it is affected and the change is important
- **Mechanics‑heavy examples:**
    - Win rate, pct one‑shot kills, attacks‑to‑kill, dodge/crit rates ([Combat Formula DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5250514946)).
    - Reward scaler distribution and difficulty choice mix ([Battle Reward Scaling DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5133402932)).
- **Segmentation required:**
    - Member vs non-member
    - Level bands (e.g., 1–5, 6–30, 31–70, 71–90, 91–100, 100+)
    - Home vs school / play context
    - Additional segments relevant to the feature (e.g., class-code vs non–class-code if relevant).
    - These segments are captured in general math game tracking and do not need to be added as separate fields to the events covered by the DDD.

**Reference:** Section 2 in [Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588).

---

## 4. Feature Mechanics, User Flow, and Edge Cases

This section gives just enough **product context** for telemetry to make sense.

**4.1 Core mechanics**

- Short narrative describing:
    - How the feature behaves functionally (from the player's POV).
    - What it _overrides_ or depends on (e.g., costumes override visuals but not stats).
- For **tutorial / FTUE‑like experiences**, include a short "Goals of this feature" block:
    - e.g., "Teach players that Magicoin is needed to rescue pets" and "Associate Magicoin with membership" in [First Pet Rescue DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5478481921).
    - This is especially important when the tutorial changes core mental models (currency, combat, side modes).

**4.2 Entry points & flow**

- Bullet list or brief flow describing:
    - Entry points into the feature.
    - Key states (menus, tabs, slots, modals, videos, etc.).
    - How the player exits back to core play.
- For scripted flows, map key narrative steps to **Funnel Advanced** steps (see:
    - Rifts feature funnel FA1–FA9 in [PMR & Rifts DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/4397891585).
    - Spell Effects tutorial funnel FA1–FA5 in [Spell Effects Tutorial DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5580947466).

**4.3 Edge cases / constraints**

- Overlaps with other systems (e.g., Morph Marbles overriding avatar visuals).
- Offline/degraded behavior if relevant.
- Any **suppression rules** for events in these states.
- **Tutorial / scripted battles:**
    - When a battle is used purely as a scripted tutorial sequence (e.g., Spell Effects tutorial battle), **suppress normal combat events** and rely on funnels instead, to avoid contaminating aggregate battle metrics (see [Spell Effects Tutorial DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5580947466)).
- **Cross‑mode / cross‑loop interactions:**
    - Consider how the feature interacts with:
        - Main quest progression (e.g., Rifts as a potential distraction vs core loop in [PMR & Rifts DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/4397891585)).
        - Other systems that touch the same surface (e.g., Morph Marbles vs Costumes visuals in [Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588)).

**Reference:** Sections 1.1, 1.2, and 3 in [Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588).

---

## 5. Event & Telemetry Requirements

Telemetry tables are the **heart** of the DDD. They must:

- Reuse **existing** [Segment events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3494445057) whenever possible.
- Be organized by **event domain**, with **linked section headers**.
- _**Introduce new events only when there is no adequate existing one.**_

### 5.0 Global conventions

- **Standard fields note (required):**
  Add a short callout near the start of section 5:

    _In addition to fields specified in this DDD, all events should include standard fields per_ [Common Event Log Schema](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6101434383) _(e.g.,_ `zone`, `map`, `level`, `session_uuid`, timestamp, player identifiers).

- **Priority levels:**
    - **P0** – must-have for launch; required to answer core questions and guardrails.
    - **P1** – strongly desired near launch; supports tuning and iteration but not blocking.
    - **P2** – nice-to-have; improves completeness and debugging, or aligns with global telemetry consistency.
- **Table structure rules:**
    - One table per **event group** following the same structure as domain pages in [Segment Event Definitions](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3494445057).
    - Each table row has at least:

        | Priority | New / existing | Implemented? | Index | Description | event_text | event | Key properties / fields |

    - **No links in header row.** Headers are plain bold text only.
    - Links go:
        - In **section headers** (the domain names, linking to tracking plan pages).
        - In `event_text` cells (linking to specific event definitions in Segment tracking docs).
        - Optionally in **Description** or **Key properties** cells as inline cards.
- **Index column:**
    - Short, human-stable codes:
        - `UI#` for UI events.
        - `IA#` for identity/avatar events.
        - `FA#` for funnel steps.
        - `C#` for conversion events.
        - etc.
- **New events:**
    - Only when no existing Segment event fits (e.g., `Costume Previewed`).
    - Must follow Segment naming and schema conventions.
    - Clearly labeled as `New` in the table.

---

### 5.1 [User Interface Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3158835840)

Use this section for **interfaces, buttons, and tabs**.

- **Section header is a link** to the domain tracking plan:
    - `### [User Interface Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3158835840/User+Interface+Events)`
- **Example row pattern** (inspired by Costumes DDD):

| Priority | New / existing | Implemented? | Index | Description | event_text | event | Key properties / fields |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P0 | Existing | N | UI1 | Player opens the Costumes menu from any entry point. | [Interface Opened](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3494445057/Segment+Event+Definitions#InterfaceOpened) | interface_opened | interface_name, interface_type, instance_id, origin_type, origin_id |

**Reference:** Table 4.1 in [Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588).

---

### 5.2 [Player Identity & Avatar Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3194979621)

Use this section for **item equips/unequips, avatar updates, identity changes**.

- Examples:
    - `Item Equipped`, `Item Unequipped`, `Item Equip Failed`, `Player Avatar Updated`.
- For cosmetic systems like Costumes:
    - Use `item_type = "costume"` and reuse these events.

**Example row pattern:**

| Priority | New / existing | Implemented? | Index | Description | event_text | event | Key properties / fields |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P0 | Existing | N | IA1 | Player equips a costume: visuals are committed and will persist until changed or removed. | [Item Equipped](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3194979621/Player+Identity+Avatar+Events#PlayerIdentity&AvatarEvents-ItemEquipped) | item_equipped | item_name, item_type = "costume", item_id, interaction_id |

**Reference:** Table 4.2 in [Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588).

---

### 5.3 [Progression Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3158835812)

Use `Funnel Advanced` for **feature funnels** (discoverability / FTUE / completion).

- **Section header links** to Progression events.
- Funnel rows use **existing** `funnel_advanced` event:
    - `funnel_name` – feature name (e.g., `"costumes"`).
    - `funnel_type` – `"feature"`, `"tutorial"`, etc.
    - `step_name` / `step_index`.

**Example:**

| Priority | New / existing | Implemented? | Index | Description | event_text | event | Key properties / fields |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P0 | Existing | N | FA2 | Player opens Costumes interface for the first time. | [Funnel Advanced](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3158835812/Progression+Events#FunnelAdvanced) | funnel_advanced | funnel_name = "costumes", funnel_type = "feature", step_name, step_index |

**Key guideline:**
Use funnels for **big steps**, not every click.

**Reference:** Table 4.3 in [Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588).

---

### 5.4 [Membership and Conversion Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3218800725)

Use this section when the feature **opens upsells or purchase funnels**.

- Always reuse:
    - `game_purchase_funnel_entered`
    - `game_purchase_funnel_hand_off`
    - `game_purchase_funnel_complete`
    - `game_purchase_funnel_quit`
    - `game_purchase_funnel_step_error`

**Example:**

| Priority | New / existing | Implemented? | Index | Description | event_text | event | Key properties / fields |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P0 | Existing | N | C1 | Membership prompt is opened after player attempts to wear a member-locked costume. | [Game Purchase Funnel Entered](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3218800725/Membership+and+Conversion+Events#MembershipandConversionEvents-GamePurchaseFunnelEntered) | game_purchase_funnel_entered | trigger, trigger_category, ad_type, funnel_id |

**Reference:** Membership/Conversion table in section 4.5 of [Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588).

---

### 5.5 Economy & Other Domains (as needed)

If the feature has **direct economy interactions**, use the **Economy Events** domain, reusing `Shop Item Viewed`, `Item Removed`, `Item Received`, etc., with appropriate `item_type`, `item_id`, `item_count` and currency fields.

For **video/tutorial content**, reuse **Video Playback Events** as in Costumes DDD (usually P2 priority).

---

### 5.6 [Player Movement & Discovery Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3158835876)

Use this section for **map transitions and interactable objects** (e.g., new zones, portals, key world objects).

- **Section header is a link** to the domain tracking plan:
    - `### [Player Movement & Discovery Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3158835876/Player+Movement+Discovery)`
- Example row pattern (from [PMR & Rifts DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/4397891585)):

| Priority | New / existing | Implemented? | Index | Description | event_text | event | Key properties / fields |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P0 | Existing | ‌ | PM1 | Player visits Dragon Isle | [Map Entered](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3158835876/Player+Movement+Discovery#PlayerMovement&Discovery-MapEntered) | map_entered | instance_type, instance_id, zone, map, previous_map, previous_zone, transition_type, duration |

### 5.7 [Combat Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3340435492)

Use this section when the feature directly affects **battles, spells, damage, rewards, or combat loop**.

- **Section header is a link** to the domain tracking plan:
    - `### [Combat Events](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3340435492/Combat+Events+Revamp)`
- For **new combat events** (e.g., `rift_run_round_started`, `dragon_rift_completed`, `spell_effect_applied`), follow the same pattern (see [PMR & Rifts DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/4397891585) and [Spell Effects DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5108105217)).
- Example: extending existing events (see [Spell Effects DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5108105217), [Combat Formula DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5250514946), [Battle Reward Scaling DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/5133402932)).

| Priority | New / existing | Implemented? | Index | Description | event_text | event | Key properties / fields |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | Existing | ‌ | BA1 | Extend Battle Action Performed with extra fields for new mechanics (e.g., status effects or dodges). | [Battle Action Performed](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3340435492/Combat+Events+Revamp#BattleActionPerformed) | battle_action_performed | All existing fields, plus feature‑specific ones (e.g., round, team, intended_status_effects, status_effects_applied, is_attack_dodged) |
| P1 | Existing | ‌ | BA2 | Extend Battle Completed with `rewards_scaler` for battle reward scaling. | [Battle Completed](https://prodigygame.atlassian.net/wiki/spaces/DGD/pages/3340435492/Combat+Events+Revamp#BattleCompleted) | battle_completed | All existing fields, rewards_scaler |

### 5.8 Exceptions & Suppressions

Every DDD must explicitly call out:

- **Scripted/tutorial flows** where:
    - Normal events would **contaminate combat/engagement metrics**.
    - We prefer a pure funnel-driven view.
- **Boss/special modes** where:
    - Reward scaling should _not_ apply.
    - `instance_type` / `instance_id` must clearly identify the mode for reconstruction.

See **Section 3 and 4.3** in [Wizard Costumes DDD](https://prodigygame.atlassian.net/wiki/spaces/GD/pages/6114541588) for examples of tutorial considerations and Morph Marble interaction.

---

## 6. Authoring Notes & Quick Checklist

**Authoring notes:**

- Start from a **copy of Wizard Costumes DDD** for new features, then:
    - Replace feature-specific context.
    - Adjust domains and events.
- **Prioritize latest design docs**:
    - Use the most recently updated GDD/TDD/UXR as your business context; feature implementation plans may drift, if conflicts arise - confirm the source of truth.
    - When in doubt, align to **current design** even if older drafts differ or better confirm the source of truth.

**Checklist for each new DDD:**

- [ ] Meta section links to GDD/TDD/UXR and Segment definitions.
- [ ] Scope & Purpose clearly state what is and isn't covered.
- [ ] Hypothesis clusters + questions + metrics + guardrails are concise and aligned.
- [ ] Mechanics & flow are minimal but enough for telemetry context.
- [ ] Event sections are organized by domain with **linked headers**.
- [ ] Each event row follows the standard table structure and priority scheme.
- [ ] `event_text` cells link to Segment event definitions where applicable.
- [ ] Standard fields note is present and references the Common Event Log Schema.
- [ ] Suppressions and edge cases are explicitly called out.

---
