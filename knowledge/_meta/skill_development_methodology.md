---
title: Skill Development Methodology
type: skill-methodology
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/meta_skill_development_methodology.md
as_of_at_import: 2026-04-25
related:
---
Captured from a multi-day arc that produced two composable skills (`/confluence-research`, `/draft-ddd`), a living architecture addendum (v2 → v6), and 7 features tested. ~2-2.4M tokens spent; ~50% load-bearing, ~50% optimizable. The methodology generalizes; the specific skills don't.

## When to load this file

- Designing a new skill expected to be invoked many times
- Iterating on an existing skill after real-output comparison reveals gaps
- Considering whether to invest heavy testing in a skill (cost-benefit)
- Mid-arc course correction
- Retrospecting after a skill arc completes

Skip for: one-off scripts, simple skills with low blast radius, well-documented domains where conventions are mature.

## Three meta-principles

### 1. Verification is the discipline that prevents silent errors

Every failure class — single-source trust, sub-agent overconfidence, scope mismatch, iteration coupling, premature standardization — has a verification gap at its root. A procedure without explicit verification steps is an error-shipping machine.

Verification looks concrete: cross-reference multiple sources, spot-check before codifying, regression-test after fixes, reality-check structural claims. Each step is cheap; none are optional.

### 2. Real-output comparison + exemplar reading are the cheapest paths to truth

Plausibility tests pass on bad output. The only reliable test is comparison to ground truth.

Most patterns visible in real artifacts are also visible in upfront exemplar reads. **The single highest-leverage optimization is reading 3-4 exemplars before iteration starts.** ~200k tokens upfront saves ~600-1000k of discovery iteration. 3-5× ROI.

What you can't get from exemplars: edge cases that surface only when running the procedure (tooling bugs, cross-source drift, real-data quirks). These need iteration. Combine: exemplars to seed, iteration to discover edge cases.

### 3. Composable skills + living memory compound learning

Two skills with clean contracts > one monolithic skill. Each can iterate without destabilizing the other.

Memory files that grow with each iteration's lesson > static reference docs. Subsequent sub-agent runs inherit the latest discipline.

Together: each iteration adds discipline that compounds for all future runs. The 14th iteration is cheaper and better than the 1st because the addendum + skills carry the prior 13's lessons.

## Five practices

1. **Multi-source cross-reference, not single-source trust.** For any "is X documented / shipped / current?" check, cross-reference at least two sources. When sources disagree, flag the discrepancy explicitly for human review. Don't dogmatically pick one.

2. **Spot-check sub-agent claims before codifying.** Sub-agent reports are proposals, not facts. Especially when the claim is structural ("X is broken", "Y doesn't exist"), do one independent verification before writing it into a procedure document.

3. **Cache primary inputs and exemplars across iterations.** Pre-fetch primary docs once into scratch files (`~/Documents/claude/<arc>-inputs/`); pass paths to sub-agents. Cache exemplars once per arc. A re-fetch costs ~30-50k; ~12+ re-fetches across an arc is real money.

4. **Build small regression suites; use targeted micro-tests for rule fixes.** When fixing a single classification rule, test just that rule (~20k tokens). Don't run the full pipeline (~150k+) when only one decision matters. After fixes accumulate, run a small canary suite to catch regressions.

5. **Structured Reviewer Notes appendix, not boilerplate checklists.** For artifacts requiring human review, append a structured section capturing: design decisions, source provenance, doc inconsistencies, open questions, confidence flags, post-draft fixes. Gives the reviewer a real roadmap.

6. **Discriminative micro-test before full pipeline runs.** When iterating on a skill that grades or measures other skills/artifacts (eval, review, drift detector), validate its discrimination on a known case before scaling. Synthetic injection with explicit revert is cheap (~5-10% of full cycle) and bounded — if the skill can't tell good from bad on a known case, it won't on unknown cases. Confirmed in eval-skill arc 2026-04-25: synthetic drift + revert caught a target-file detection failure mode in ~75k tokens vs ~1.6M for a full cycle.

## Four anti-patterns

1. **Empty tooling response misread as data absence.** When a tool returns nothing, the failure modes are: tool can't render, query is wrong, content really absent. Try a second method before concluding "absent." Empty markdown body could be macro rendering failure; empty CQL hits could be wrong query.

2. **Single-source dogmatic classification.** Replacing "trust source A" with "trust source B" doesn't fix the underlying disease. Both can be wrong; both can disagree. Default to multi-source verification + explicit disagreement flagging.

3. **Premature standardization.** Applying one template structure to all feature classes over-engineers minimal-instrumentation features. Detect feature class at research stage; tune output shape to match. Standardization is for downstream parseability, not uniformity.

4. **Permissive test criteria hide drift.** Lower-bound expected criteria (e.g., "approximately N+") satisfy any value above the bound. If reality drifts upward and the artifact drifts to match the new reality, a permissive grader still passes — validating drift as if it were correctness. Pin specific facts when testing for drift; reserve lower-bounds for catastrophic-regression sentinels only. (eval-skill arc 2026-04-25: a Q&A claiming "34+ refs" satisfied both stale memory and current 59-ref reality, hiding a 73% inflation.)

## User-side principles

The user is not just a director — they're the **reality anchor**. Sub-agents can't see the visible world; Claude can confidently propagate wrong findings; only the user can verify "does this claim correspond to actual reality?"

Highest-leverage user moves:
- **North Star framing in one sentence at arc kickoff** — resolves dozens of subsequent micro-decisions.
- **Reality-check structural claims** — *"give me a link"*. The single most valuable intervention class.
- **Causal correction over binary correction** — tell Claude *why* something's wrong; let Claude derive the fix.
- **Synthesis prompts at arc boundaries** — multiple focused reflections produce reusable artifacts.

User defaults:
- **On:** sequential approval for first 2-3 steps; skeptical first review of plans; rough budget at kickoff.
- **Off:** trusting "X is broken" without verification; accepting full re-runs when targeted tests would suffice; letting iteration run unbounded.

## Five-phase playbook

| Phase | Time | Tokens | Activities |
|---|---|---:|---|
| **0. Setup** | ~30 min | ~5k | North Star property of output (one sentence); rough token budget; worktree + memory file location |
| **1. Exemplar study** | 2-3 hrs | ~200-300k | Read 3-4 real exemplar artifacts; note recurring patterns + structural conventions; seed skill + addendum from exemplars; sanity-check with 1-2 real-output comparisons |
| **2. Generalization** | varies | ~500-700k | Test on 3-5 features spanning feature classes; compare each draft to its real artifact; each iteration adds 1-2 fixes max; codify in addendum (memory compounds) |
| **3. Verification + regression** | varies | ~200-400k | Build small regression suite (~1-3 scenarios per feature class); run after each addendum change; targeted micro-tests for rule fixes |
| **4. Productionize + reflect** | ~1 hr | ~50-100k | Adopt skill as production baseline; write reflective documents; document open gaps |

**Total budget for a well-disciplined arc: ~1.0-1.5M tokens.**

A naive arc (no exemplar-first, no caching, full re-runs) consumes ~2-2.4M for the same outcome. The savings come from exemplar-first, input/exemplar caching, targeted micro-tests, and regression suites baked in from day one.

## When this investment is justified

| Skill class | Investment level |
|---|---|
| Many users, many invocations, drives engineering work | High — full arc per playbook |
| Regular use, low-stakes outputs | Medium — 2-3 iterations + small golden test |
| One-shot or 1-2 users | Low — confirm immediate correctness only |
| Highly stable / well-documented domains | Low — established patterns minimize discovery |

Specific signal: the artifact this skill produces drives downstream engineering work that's expensive to redo. If yes, heavy-duty arc justified. If no, lighter investment.

## Memorable in one line

> Real-output comparison is the only reliable test. Exemplar reading is the cheapest path to it. Multi-source verification is the discipline that prevents silent errors. Living memory + composable skills compound the learning. The user is the reality anchor.

Everything else is implementation detail.

## Extended reflections (deep dives)

For specific dimensions, read these reflective documents in `~/Documents/claude/wc-drafts/`:

- [final-synthesis-2026-04-24.md](~/Documents/claude/wc-drafts/final-synthesis-2026-04-24.md) — capstone (this file is its memory-resident summary)
- [retrospective-skill-development-2026-04-24.md](~/Documents/claude/wc-drafts/retrospective-skill-development-2026-04-24.md) — what worked, what could be better, when this investment is justified
- [failure-modes-analysis-2026-04-24.md](~/Documents/claude/wc-drafts/failure-modes-analysis-2026-04-24.md) — five classes of failure, how to identify, how to address
- [token-cost-reflection-2026-04-24.md](~/Documents/claude/wc-drafts/token-cost-reflection-2026-04-24.md) — where tokens went, optimization patterns, cost budgets
- [ops-wisdom-reflection-2026-04-24.md](~/Documents/claude/wc-drafts/ops-wisdom-reflection-2026-04-24.md) — model choice, parallelism, sub-agents, file vs prompt handoff, 12 levers
- [user-side-reflection-2026-04-24.md](~/Documents/claude/wc-drafts/user-side-reflection-2026-04-24.md) — what the user did well, gaps, killer-move pattern (reality anchor)
- [eval-skill-arc-2026-04-25.md](~/Documents/claude/wc-drafts/eval-skill-arc-2026-04-25.md) — applying the methodology recursively to a memory-eval skill; structural eval-design lessons (loop closure as N3, permissive criteria, cross-file drift detection limits, drift in the eval not just in the memory)

Plus the produced skills + reference:
- `~/.claude/commands/confluence-research.md` — generic feature-doc research (template for future research skills)
- `~/.claude/commands/draft-ddd.md` — DDD authoring (template for future drafting skills)
- `reference_ddd_event_architecture.md` — living discipline reference (template for future authoring-contract files)
