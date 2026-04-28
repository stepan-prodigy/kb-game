---
title: Session Profile — 2026-03-16 Balanced Sample
type: session-profile
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/artifact_session_profile_2026-03-16.md
as_of_at_import: 2026-04-24
related:
---
## Sampling caveat (READ BEFORE USING ANY NUMBER)

- **Sample:** 3,000 sessions from 2,833 users on **2026-03-16** (a weekday — Monday), ~779K events.
- **Sampling method: balanced across level band × home/school × member/non-member.** Engineered for coverage — NOT representative of production population.
- **Source tables:** `production.silver.segment_math_game_prod`; session pool `adhoc.game.stepan__session_pool_standard`; segmentation `fivetran.google_sheets.game_event_segmentation`.
- **Critical warning:** Do not use any number in this file as a production estimate. Balanced-sample figures require reweighting by the actual production distribution before they represent reality. Numbers here are valid as directional signals within this sample and as baselines for re-sampling.
- **Scope of caveat:** applies to ALL numbers below unless explicitly labelled otherwise (e.g., the "Business KPIs (Apr-2026 snapshot)" section sources production KPIs, and experiment effect sizes come from longitudinal experiments Oct 2025 – Apr 2026, NOT this balanced sample).

---

## 1. Sample composition

| Metric | Value |
| --- | ---: |
| Sessions | 3,000 |
| Distinct users | 2,833 |
| Events total (approx) | ~779,000 |
| Member session share | 47.2% |
| School/home split (weekday) | ~50/50 |
| Distinct event types observed | 182 |

*Source: existing KB § Key Product Numbers and § 1 Product Identity preamble.*

---

## 2. Core loop volumes

| Event | Count | Session coverage |
| --- | ---: | --- |
| `Map Entered` | 13,383 | 2,990 / 3,000 sessions |
| `Battle` | 186,583 | — |
| `Battle QI` | 101,892 | — |
| `Item Received` | 47,813 | — |
| `Player Progression Advanced` | 12,779 | — |
| `Quest Progression` | 1,197 | — |
| Answers submitted (math QI) | 23,503 | 1,994 sessions (66.5% answer ≥1 question) |

- Battle + Battle QI = **37.0% of all events**.
- Median answers per answering session: **8**; **p90: 27**.
- Average QI correctness: **71.4%**.

*Source: existing KB § 2 Core Gameplay Loop.*

---

## 3. Math integration

### Adaptive algorithm share (of answers)

| Algorithm | Share |
| --- | ---: |
| `default-strand-clusters` | 76.1% |
| `placement-by-strand-test` | 17.8% |
| `assignment` | 4.2% |
| `game-challenge` | 1.9% |

### Correctness & grade targeting

- System targets **~65% first-attempt correctness** (Zone of Proximal Development).
- **Grades 1–4 = 83.2% of all answers.**
- **Grade 5 accuracy: 53.7%** (notable difficulty cliff).

### Support-tool usage (% of answering sessions)

| Tool | Share |
| --- | ---: |
| Hints | 36.4% |
| Drawing tools | 8.7% |
| TTS | 6.0% |
| Manipulatives | 1.9% |

### Platform split

- **Desktop: 89.6%** of answers.

### Science education

- `Education Question Viewed/Answered` with `subject="SCIENCE"` appears in **~87 sessions**.

*Source: existing KB § 2 Math Integration Details.*

---

## 4. World & progression

### Boss medians (player level at boss completion)

| Zone | Boss | Median boss level |
| --- | --- | ---: |
| Firefly Forest | Gerald | 38 |
| Shiverchill Mountains | Ice Wyrm | 61 |
| Bonfire Spire | Cebollini | 73 |
| Shipwreck Shore | Old One | 79 |
| Skywatch | Cloud Boss | 89 |

Hard-mode mirrors of these bosses observed at: forest_hard 98, shiverchill_hard 111, bonfire_spire_hard 127, shipwreck_shore_hard 135, skywatch_hard 141.

### Level-gain observations

- Members gain **1.5–2.5× more levels** at early-mid game than non-members.
- Near-zero level gains at late game (levels 76–100) — the "XP wall".
- Festival Battler archetype consistently produces highest level gains.

*Source: existing KB § 3 Main Story Progression and § 4 Player Level.*

---

## 5. Pets

| Metric | Value |
| --- | ---: |
| Median roster — members | 47 pets |
| Median roster — non-members | 24 pets |
| Tutorial pets — members | 3 (incl. Gearsite evo2 bonus) |
| Tutorial pets — non-members | 2 |
| Rescue events | 9,278 |
| Capture events | 1,722 |
| Evo2+ capture member share | ≥95% |
| Evolution member:non-member ratio | **8.4 : 1** |
| Evolution cancellation rate | **89%** |
| Base pets at levels 101+ | 32% of roster; 100% member-only captures |
| #1 Magicoin-insufficiency sink: pet-rescue | 347 events (> all non-pet sinks combined) |

- Pet XP: members generate **2.2× more** pet-XP events than non-members.
- **77% of `level_capped` events are non-member** — core friction point.
- Experiment: reducing pet costs yields **+80% evolving, +20% Magicoin spenders**.

*Source: existing KB § 4 Pet Progression and § 5 Pet System.*

---

## 6. Combat

- Dragon Rift boss-type loss rates: **physicalDragon 0%** vs **astralDragon 80%** (difficulty extremes).
- Reward scaling observed range: level-disadvantage up to **150–200%** rewards; level-advantage down to **50–33%** rewards.
- Member battle bonuses (constant, but measured applied): Gold +50%, Zone currency +50%, LiveOps currency +100%, XP +10%.

(Win-rate, one-shot-kill, attacks-to-kill, dodge/crit distributions are called out as key analytics in the combat DDD but specific numeric distributions were not captured in the v4.1 digest — see "Numbers explicitly NOT captured".)

*Source: existing KB § 6 Combat Mechanics and § 8 Dragon Rifts.*

---

## 7. Economy & monetization

### Conversion-event volume (home vs school)

| Context | Conversion events per session |
| --- | ---: |
| Home | 2.20 |
| School | 0.91 |

- **Member-Jar** post-battle impressions at home: **1,539**.

### Membership tier pricing (MC caps)

| Tier | Monthly price | Magicoin cap |
| --- | ---: | ---: |
| Free | $0 | — |
| Core | ~$4.91 | 350 MC |
| Plus | ~$7.41 | 720 MC |
| Ultra | ~$9.91 | 1,600 MC |

### Experiment effect sizes (longitudinal, Oct 2025 – Apr 2026)

| Experiment | Effect |
| --- | --- |
| Hard Lock Magicoin (initial) | +19.4% conversion |
| Hard Lock Magicoin (after Member Videos launched) | effect diminished |
| Member Videos | +17.9% conversion |
| Festival removal | −7.5% conversion, −3% home play |
| Wizard Bank | ↑ core purchases, ↓ ASP (direction only) |
| Linear Campaign | +7% reaching level 60, +24% rift engagement |
| Pet-cost reduction | +80% evolving, +20% Magicoin spenders |
| Shadow Nasty Cloud / PM difficulty reduction | ↑ completion, core metrics unchanged (direction only) |
| Member Locked Gold Rift | +0.5% WHAS, +5% member home battles |
| After School Widget | +3.75% WHAS, +5.37% home time |

*Experiment effect sizes are NOT from the 2026-03-16 sample.*

*Source: existing KB § 4 Quest Progression, § 5 Pet System, § 7 Economy and Monetization, § 8 Dragon Isle and Rifts, § 10 School vs Home.*

---

## 8. Activities

| Activity | Measured metric |
| --- | --- |
| Dark Tower | **70.3% member session share** |
| Treasure Track | Members claim **4× more rewards** than non-members; engagement scales with level **10.8% → 45.8%** |
| Wizard Dash | **52% completion** |
| Festival Battler archetype | 8% of sessions, **69% member** |

(Rift engagement levels by band beyond the Linear Campaign experiment delta and Treasure Track level-band curve endpoints were not itemized in the digest — see gaps list.)

*Source: existing KB § 8 Game Modes and Activities.*

---

## 9. Session structure

### Duration

| Segment | Value |
| --- | ---: |
| Median session | 9.2 min |
| Average session | 17.5 min (right-skewed) |
| Stabilizes at | ~18–19 min from level 21+ |
| Members at home (avg) | 23.1 min |
| School compression | 17–26% shorter than home |
| School median | 7.7 min |
| Home median | 9.9 min |

### Archetype percentages — Light/Heavy split

| Tier | Share |
| --- | ---: |
| Light | **63%** |
| Heavy | **37%** |

### Detailed archetypes

| Archetype | Tier | Share | Notes |
| --- | --- | ---: | --- |
| Single Battle | Light | 26% | — |
| Casual Battler | Light | 15% | — |
| Non-Combat | Light | 11% | — |
| Explorer + Battle | Heavy | 22% | — |
| Festival Battler | Heavy | 8% | 69% member |
| Battle Grinder | Heavy | 8% | — |
| Dueler | Heavy | 7% | Most balanced archetype |
| Rift Runner | Heavy | 3% | — |

### Short-session sub-archetypes (of the 25.8% short-session bucket)

| Sub-archetype | Share | Interpretation |
| --- | ---: | --- |
| Daily check-in | 54% | Healthy |
| Quick battle | 26% | — |
| Onboarding failure | 10% | Red flag |
| (Other) | ~10% | — |

### First-session / tutorial funnel

- Tutorial is a **multi-session commitment** — **no first session completes it**.

*Source: existing KB § 2 Core Loop (session medians), § 9 Onboarding and Session Structure, § 10 School vs Home.*

---

## 10. School vs home asymmetry

| Metric | Home | School |
| --- | ---: | ---: |
| Conversion events / session | 2.20 | 0.91 |
| Median session duration | 9.9 min | 7.7 min |

- All-user Home Rate: ~**22.4%** (−13% YoY, trending down).
- Member Home Rate: ~**60.5%** (stable).
- After-School Widget: **+3.75% WHAS**, **+5.37% home time** (experiment, not sample).

*Source: existing KB § 7 Business Metrics, § 10 School vs Home.*

---

## 11. Business KPIs (Apr-2026 snapshot, production KPI — NOT balanced-sample)

| KPI | Value | YoY delta | Trend |
| --- | ---: | ---: | --- |
| Week-0 Conversion | ~0.70% | +60% | up |
| 4-week Cash / Activation | $0.73 | +33% | up |
| M1 Renewal | ~73% | −6% | down |
| 4-week Retention (all users) | ~17.6% | −15% | down |
| Home Rate (all users) | ~22.4% | −13% | down |
| Member Home Rate | ~60.5% | — | stable |
| Member Stickiness | ~58% | +3% | up |

*Source: existing KB § 7 Overall Business Metrics (as of Apr 2026).*

---

## 12. Data quality observations

| Observation | Value |
| --- | ---: |
| Suspect-session prevalence | **37 sessions (1.2%)** of the 3,000 |
| Suspect-session signatures | shorter, fewer events, zero captures |
| Gold — clean p99 | 65K |
| Gold — dirty max (cheat) | 10M |
| Pet roster — dirty max | 3,482 |
| Magicoin | server-secured; no inflation observed |

### Recommended filters

- Exclude `gold > 200K` and `roster > 500` for resource analyses.
- No filtering needed for engagement analyses.

(Null-level-player prevalence was not quantified in the digest — see gaps.)

*Source: existing KB § 14 Data Quality.*

---

## Numbers explicitly NOT captured

The following topics appear in v4.1 KB or the new file scope but lack extractable numerics in the 280-line digest used as the primary source. The raw v4.1 Confluence page (id 6101106740) was not re-fetched — it is ~167KB and carries non-trivial token-limit risk; all below would need that re-fetch (or a re-query of the balanced sample) to populate.

- **Per-level-band full session-duration distributions** (only medians and the 18–19 min stabilization point are captured).
- **Per-level-band full archetype distributions** (only top-line archetype percentages captured, not per-band breakouts).
- **Per-band Treasure Track engagement curve** beyond endpoints 10.8% → 45.8%.
- **Rift engagement rates by level band** beyond the Linear Campaign +24% experiment delta.
- **Combat win rate, one-shot-kill rate, attacks-to-kill, dodge/crit distributions by member × level** (called out as key analytics; no values in digest).
- **Reward-scalar distribution histogram** (only extremes 150–200% / 50–33% captured).
- **Boss-level p10 / p90** (only medians captured).
- **XP / level-gain magnitudes** beyond the "1.5–2.5× member multiplier" and the "near-zero at 76–100" qualitative descriptor.
- **Capture-to-rescue ratio** is derivable (1,722 / 9,278 ≈ 18.6%) but a cleaner per-segment breakdown was not in the digest.
- **Pet-merge participation rates** (digest says "comparable member/non-member" with no numbers).
- **Null-level-player prevalence** and per-archetype cheater prevalence.
- **Dyno Dig, House, Titans engagement percentages** — called out as activities with "tracking gaps".
- **POTW early-game conversion effect size** (digest says "negative" without a number).
- **Full v4.1 KB raw-page content** (~167KB). Only the 280-line existing digest was used as the primary source for this artifact.
