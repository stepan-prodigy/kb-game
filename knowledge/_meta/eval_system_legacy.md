---
title: Eval System (legacy from personal memory system; rewrite for kb-game)
type: eval-system-legacy
owner: data-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/meta_eval_system.md
as_of_at_import: 2026-04-25
related:
---
**Purpose:** Authoritative reference for the memory-eval architecture. Built to detect memory drift, routing misfires, and content inaccuracy before they degrade sessions. Read this before touching hooks, scenarios, skills, or reports under the eval system.

## What the system measures

| Dimension | Question | Mechanism |
|---|---|---|
| Routing | Does the right memory file load for this task? | Golden scenarios + access log |
| Content | Are memory claims still true? | Contradiction check in `/memory-review` + LLM-as-judge on golden Q&A |
| Coverage | Are we missing topics? | Access-log gaps: sessions whose prompts match no memory trigger |
| Cost | Is context consumption reasonable? | Static size-per-session scenario in `/memory-review` |
| Correctness | Does Claude give the right answer to canonical questions? | Content eval with LLM-as-judge |
| Meta-health | Is the eval system itself working? | Cycle duration, token spend, pass-rate trends |

## Architecture — six components

### 1. Instrumentation (always on)

- **Stop hook** fires after every turn; writes one JSONL line to `~/Documents/claude/memory_access.log`.
- Each line: timestamp, session id, first user prompt (for context), memory files Read, skills invoked, turn number.
- Append-only. Parseable with `jq` or any JSONL tool.
- Configured in `~/.claude/settings.json` via `update-config` skill.

### 2. Continuous monitoring (inside `/memory-review`)

`/memory-review` reads the last 30 days of access log and flags:
- Dead memory: files with 0 reads → deprecate candidate.
- Miscued routing: sessions with domain keywords where the expected file wasn't Read → trigger-wording issue.
- Over-triggering: files Read when their trigger's domain didn't apply → trigger too broad.

### 3. Scheduled routing eval

- **Config:** `~/.claude/evals/memory-routing.yaml` — **93 scenarios** (31 triggers across MEMORY.md and MEMORY_math_game.md × 3 archetypes).
- Archetypes: **direct** (literal trigger match), **indirect** (natural task phrasing), **edge** (ambiguous/adjacent).
- **Runs:** 3 per scenario. Pass threshold: 2/3 match `expect_read`.
- Mechanism: `/memory-eval` spawns fresh sub-agents with each scenario prompt, captures which memory files they Read, grades against expectations.
- Parallelism: 6 concurrent sub-agents.

### 4. Scheduled content eval (with LLM-as-judge)

- **Config:** `~/.claude/evals/answer-correctness.yaml` (**26 Q&A pairs**) + `~/.claude/evals/judge-rubric.md`.
- Each pair has expected key points and a grading mode (`all_points_required` / `majority` / `specific_minimum`).
- **Runs:** 3 per Q&A pair. Each run grades `pass` / `partial` / `fail`.
- Judge: Claude itself in a fresh sub-agent with the rubric. Neutral prompt framing to reduce self-bias.

### 5. Meta-eval (health of the eval system)

Tracked per cycle, appended to `~/Documents/claude/evals/_trends.jsonl`:

| Metric | Why it matters |
|---|---|
| Cycle duration | Spike → sub-agent loops or parallelism issue |
| Token cost | Spike → prompt bloat or repeated work |
| Pass rates (routing + content) | Drop >10% vs. 4-week baseline → routing or memory broke |
| Scenario flakiness | Consistent 1/3 or 2/3 → trigger ambiguous; 0/3 → truly broken |
| Cycle completion | Didn't finish → hook, rate limit, or scheduler issue |

Flakiness tracked separately at `_flaky_scenarios.md`.

### 6. Documentation

This file (architecture), plus:
- `/memory-eval` skill (procedure)
- YAML scenarios (configuration)
- Dated eval reports (output)

## Storage layout

    ~/Documents/claude/
      memory_access.log              # JSONL, append-only, every session
      evals/
        YYYY-MM-DD/
          summary.md                 # cycle overview
          routing.md                 # per-scenario table, pass/fail
          routing.jsonl              # raw per-run data
          content.md                 # Q&A + judge grades
          content.jsonl              # raw Q&A run data
          health.md                  # meta-eval summary
        _trends.jsonl                # historical metrics, one line per cycle
        _flaky_scenarios.md          # scenarios inconsistent over multiple cycles

Config lives at `~/.claude/evals/` (user-scoped until stable):

    ~/.claude/evals/
      memory-routing.yaml
      answer-correctness.yaml
      judge-rubric.md

## Scheduling

- **Daily** via `CronCreate` trigger. Prompt: `/memory-eval`.
- Single skill invocation runs all layers (routing + content + meta-health) and writes the full dated report directory.
- Same skill is user-invokable ad-hoc — useful after editing a memory trigger or adding a new file.
- Move to **weekly** once pass rates stabilize and memory size grows. Revisit cadence every 3 months.

## Cost and performance expectations

| Metric | Per daily cycle |
|---|---|
| Routing runs | 279 (93 × 3) |
| Content runs | 78 (26 × 3) |
| Judge runs | 78 |
| Total sub-agent spawns | ~435 |
| Avg tokens per run | ~4k |
| **Tokens per cycle** | **~1.6M** |
| Wall-clock time | 30–60 min at 6-concurrent |

Meta-eval monitors cost. Budget alerts fire if a single cycle exceeds 2× baseline.

## Design principles

1. **Observability before evaluation.** Instrumentation (Layer 1) precedes everything else.
2. **Log ground truth, not self-report.** Hook captures actual Read calls. Self-reporting is only accepted from LLM-as-judge because it's bounded by a rubric.
3. **Separate continuous from scheduled.** Continuous catches drift cheaply; scheduled gives sharp pass/fail signal.
4. **Golden scenarios over A/B.** At this scale (~20 memory files), curated scenarios cover more than split testing.
5. **Variance-aware.** 3 runs per scenario. Flag inconsistency only when it persists across cycles.
6. **Single source of truth, dual invocation.** Daily cron and user-invoked path share the same skill body.
7. **Stay inside the existing stack.** Hooks + skills + memory + logs. No third-party eval platforms.
8. **Meta-eval as a peer, not a bolt-on.** The eval system monitors itself from day one.

## Known caveats

### 1. Sub-agents don't inherit parent memory context (routing/content eval)

Sub-agents spawned via the `Agent` tool are fresh sessions; they do NOT auto-load `CLAUDE.md` / `MEMORY.md` the way the main Claude session does. If the eval prompt does not tell them memory exists, they answer from training knowledge and report zero files read — the eval then measures "does the sub-agent discover memory in a vacuum," not "does routing work."

**Current resolution:** inline the full contents of `MEMORY.md` into every eval sub-agent prompt (Steps 3 and 7 of `/memory-eval`). The sub-agent sees the router verbatim and decides which files to Read from there.

**Trade-off this accepts:** the eval no longer tests whether a sub-agent would *find* `MEMORY.md` on its own. It tests only "given the router, does the sub-agent pick and Read the right files for this prompt." In real user sessions the harness handles auto-loading `MEMORY.md`, so this asymmetry is a test artifact, not a user-facing gap.

**What remains measurable:** trigger wording quality, sub-router discovery (sub-routers are NOT inlined — the sub-agent must still Read them on its own if the router points there), and content loading/correctness once routing succeeds.

**Revisit when:** cross-model judges land (different model as sub-agent may behave differently), or harness changes allow sub-agents to auto-inherit parent memory context.

### 2. Implicit routing infrastructure is not logged as "read"

`MEMORY.md` and `MEMORY_*.md` sub-routers are treated as implicit routing infrastructure. Sub-agent eval reports are instructed NOT to list them. Scenarios in `memory-routing.yaml` do not include them in `expect_read`. This keeps grading focused on the substantive memory files, not on router plumbing.

## Failure modes and mitigations

| Risk | Mitigation |
|---|---|
| Hook silently breaks (path change, missing deps) | Smoke-test after any Claude Code version bump; `SessionStart` health check tails the log to confirm writes |
| Scenario YAML drifts from memory triggers | `/memory-review` checks every MEMORY.md entry has ≥1 scenario |
| Sub-agent rate limiting | Parallelism tuneable; retry on transient failure, mark `error` if persistent |
| Judge bias (Claude grading Claude) | Neutral rubric; expected key points explicit; option to swap judge model later |
| Cost escalation | Meta-eval tracks tokens per cycle; budget alerts |
| Scenario flakiness | 2/3 pass threshold tolerates some noise; persistently flaky scenarios surface in `_flaky_scenarios.md` |
| Over-fitting to scenarios | Scenarios are a subset of real usage. Continuous monitoring (Layer 2) catches gaps the scheduled eval misses |

## Integration with `/memory-review`

`/memory-review` is the consumer of this system's outputs:
- Reads `memory_access.log` for the continuous-monitoring step.
- Reads latest `evals/YYYY-MM-DD/` for trend context.
- Fix plan may include scenario updates, trigger adjustments, or memory-content corrections driven by eval findings.

## Promotion path (future)

- Current: user-scoped (`~/.claude/evals/`, `~/.claude/commands/`).
- Next: project-scoped (committed to repo) once the system is stable and other DIPPR contributors want to use it.
- Later: plugin-packaged if the pattern generalizes beyond DIPPR.

## Compounding metrics (N4 infrastructure)

Beyond per-cycle health, the eval system needs longitudinal signal that memory itself is becoming more useful over time. **N4 is "memory as documented compounding asset"** — the question is *what evidence would convince us memory is compounding?*

Six metrics; each computed by either the Stop hook + access log, `/memory-review` Step 6, or `_trends.jsonl` aggregation. None require new infrastructure beyond what's already in place — they're additive analytical passes.

| Metric | Source | Signal of compounding |
|---|---|---|
| **Session memory-hit rate** | Access log: % of sessions where ≥1 non-router memory file is Read | Increasing → memory is matching real work; not increasing → triggers too narrow or memory not relevant |
| **Routing pass-rate stability** | `_trends.jsonl`: weekly mean of routing pass rate | Stable ≥85% → memory routing is robust to memory growth; drop → drift |
| **Content pass-rate stability** | `_trends.jsonl`: weekly mean of content pass rate | Same — drop signals memory factual content drifted |
| **Drift mean-time-to-fix (MTTF)** | `_trends.jsonl` cross-cycle: median time from `fail` cycle to `pass` cycle for same scenario | Decreasing → fix loop is getting faster (process compounding) |
| **Coverage-gap rate** | Access log: sessions where `first_prompt` contains DIPPR domain keywords but no memory file is Read | Decreasing → memory covers more of the actual question space |
| **Net file change rate** | File mtime + git/log: additions and deletions per week | Stable / declining → memory architecture is settling. Large additions still happening → still in growth phase. |

### Sparse-data caveat

As of 2026-04-25, access log has 4 deduped session_ids — well under the 10-session threshold `/memory-review` requires for routing-effectiveness signal. **First meaningful longitudinal read needs ~4 weeks of daily eval cycles + ~2-3 sessions/week of real DIPPR work.** Until then, treat all longitudinal numbers as directional, not authoritative.

### Compounding milestones (when to declare N4 in-hand)

- **Month 1 (after schedule live):** baseline established. First 4-week pass-rate baseline computed. First MTTF data point recorded if any drift caught and fixed.
- **Month 2:** trend data sufficient to flag any pass-rate drop >10pp vs baseline. Coverage-gap rate stabilizing.
- **Month 3:** at least one drift-detect-and-fix cycle visible in MTTF. Memory-hit rate trend interpretable.
- **At that point:** N4 is documented compounding evidence. The reflective doc (anchor: `wc-drafts/eval-skill-arc-2026-04-25.md`) provides the methodology; the trend data provides the proof.

### What's not measured by these metrics

- **Whether memory is causally improving session quality** (vs. just being read more often). Causal claim would need controlled comparisons or per-task time-to-completion data we don't currently capture.
- **Cross-file consistency.** No metric here measures it; `/memory-review` Step 4 (manual contradiction spot-check) is the complement.
- **Subjective quality** of memory content. The eval grades correctness against fixed expected_points; doesn't grade clarity, pedagogy, or maintainability.

These gaps are honest limits, not failures of the design — knowing what the metrics don't measure is part of trusting what they do.

## Revision triggers for this file

Update whenever:
- A new eval layer is added (e.g., synthetic user-flow tests).
- Scheduling cadence changes.
- Storage layout changes.
- Judge model or rubric meaningfully changes.
- Meta-eval surfaces a structural issue that requires an architectural change (not just a scenario tweak).
