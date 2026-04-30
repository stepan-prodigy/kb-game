---
title: Handoff to YAML PR thread — what we found, what to ship
type: handoff
date: 2026-04-30
target_branch: fix/qmd-yaml-and-eval-scenarios
target_commit: b0e3895
references:
  - sessions/2026-04-30_investigation_query_timeouts.md
  - proposals/qmd-rerank-disposal-investigation.md
status: complete
audience: Original thread that produced the b0e3895 YAML fix
---

# Handoff: YAML PR is sound; here's what we learned about the rest

## TL;DR for picking up where you left off

1. **The YAML PR (`b0e3895`) is correct. Ship it.** Two side investigations
   confirmed the fix is unrelated to the unrelated query-timeout symptoms.
   The comment is technically accurate. Apply the smoke-test patch below
   and merge.

2. **The "queries time out" symptom you saw is a separate bug** in qmd 2.1.0:
   a hardcoded 5-min `inactivityTimeoutMs` racing with un-wrapped
   `rankAll()` in the reranker. Three diagnostic passes traced it to
   `dist/index.js:86` and `node_modules/lifecycle-utils/dist/DisposedError.js`.
   The "Object is disposed" string is from `lifecycle-utils`, not from
   sqlite-vec.

3. **A VM CPU bump from 2 → 6 makes the bug latent on the current corpus.**
   All previously-failing probes now pass in 140–180 s (was 287–317 s + error).
   Verified on 2026-04-30 against `kb-game:dev` at commit `b0e3895`.

4. **Context update from the user**: this machine is for testing only. Prod
   won't run here. Don't worry about scale limits as long as math game +
   game island testing fits. That makes the corpus-growth cliff a non-issue
   for this machine; the recommendations below are scoped accordingly.

---

## What you (the original thread) already did

You correctly identified that `qmd 2.1.0` writes collection metadata in
two places — SQLite (`store_collections` in `index.sqlite`) and YAML
(`~/.config/qmd/index.yml`) — and that the runtime stage was missing the
YAML copy, breaking `qmd collection list` and `--collection X` flag
resolution from inside the container. Your fix:

```dockerfile
COPY --from=index --chown=qmd:qmd /home/qmd/.config /home/qmd/.config
```

…with a comment block explaining the YAML/SQLite split. That's all correct
and stays as-is.

## What's been done since you handed off

Three independent passes investigated whether the comment's claim that
"MCP server tolerates the missing YAML" was true, and whether the
"Object is disposed" symptom you reported was related to your fix or
something separate.

### Pass 1 — adversarial critic review (my prior pass)

- ✅ Verified your fix works. Reproduced the CLI bug with YAML deleted from
  a running container; confirmed CLI commands fail without YAML, MCP
  succeeds without YAML for explicitly-scoped queries.
- ✅ Verified `~/.config/` contents are exactly one 897-byte YAML file. No
  unwanted state copied.
- ✅ Verified the YAML survives `qmd embed` retry runs by architecture
  (only `saveConfig()` writes YAML; embed never calls it; sourced from
  `qmd/dist/collections.js`).
- ❌ **Misattributed the "Object is disposed" error to sqlite-vec.** Wrong
  layer entirely. (Corrected by Pass 3.)
- ❌ **Co-varied probe axes** (with-yaml ↔ no-yaml + scoped ↔ unscoped),
  producing evidence that fit any hypothesis. (Refined by Pass 2 then
  corrected by Pass 3.)

### Pass 2 — first investigation (`sessions/2026-04-30_investigation_query_timeouts.md`)

Disambiguated the symptom into three failure modes with a 10-probe matrix:

- **Mode A**: CLI `qmd query`/`vsearch` cold-start hangs on `expandQuery()`
  >90 s. Affects only the CLI surface.
- **Mode B**: MCP `tools/call query` with `rerank: true` AND results spanning
  ≥2 collections returns `"Object is disposed"` after ~5 min. Tagged as
  a correctness bug, not a timeout.
- **Mode C**: MCP cold-start latency ~40 s on first id=3, even lex-only.
  Hardware floor on 2 vCPU.

Recommended `rerank: false` as workaround. Wrote a smoke-test patch to
catch regressions on the success path. Got the trigger condition for
Mode B partially wrong — said "rerank with N≥2 collections," which was
a confound; see Pass 3.

### Pass 3 — root-cause investigation (`proposals/qmd-rerank-disposal-investigation.md`)

Traced the actual mechanism:

- `grep -rln "Object is disposed"` in `node_modules/` returned **only**
  `lifecycle-utils/dist/DisposedError.js`. `lifecycle-utils.DisposedError`
  is thrown by node-llama-cpp 3.18.1 when a method is called on a disposed
  model/context/sequence. `qmd` source has zero matches; sqlite-vec has
  zero matches.
- `@tobilu/qmd@2.1.0/dist/index.js:86` hardcodes
  `inactivityTimeoutMs: 5 * 60 * 1000` and `disposeModelsOnInactivity: true`
  in the `LlamaCpp` constructor inside `createStore`. No env override.
- `LlamaCpp.touchActivity()` is called at the start of `rerank()` but
  **not inside the long-running `rankAll(query, chunks)` Promise.all**.
  When the 5-min timer fires, `unloadIdleResources()` runs `await ctx.dispose()`
  on every rerank/embed context, the in-flight `rankAll` throws
  `DisposedError`, the MCP wrapper converts it to
  `{isError:true, content:[{text:"Object is disposed"}]}`.
- `_inFlightOperations` would gate `canUnload()`, but `rerank()` is **not**
  wrapped in `withLLMSession()`, so the counter never increments.
- The cliff is a hard timer race. Probes on 2 vCPU showed it as a sharp
  287 s ↔ 317 s discontinuity (passes vs. fails by ~30 s either side of
  the 300 s timer + warmup).

Refined Pass 2's framing: the trigger isn't "rerank + N≥2 collections,"
it's **rerank wall time exceeding 5 min**. N≥2 collections was a confound —
those probes happened to land near the cliff because of slightly more
fixed work; single-collection scoped probes with enough chunks fail
identically (e.g. `kb` only with `candidateLimit≥5` was confirmed).

### Pass 4 — VM bump retest (today, 2026-04-30, this conversation)

User asked "do we need more CPUs?" — I bumped Rancher VM 2 → 6 vCPU and
reran a focused probe matrix. Results:

| Probe | Scope | candLim | 2 vCPU baseline | 6 vCPU result | Speedup |
|---|---|---|---|---|---|
| sanity | `skill-arc-review` | 5 | 24 s ✅ | **6 s** ✅ | 4.0× |
| A | `kb` | 5 | **317 s ❌ disposed** | **139 s ✅** | 2.3× |
| B | `kb` | 10 | (extrapolated past cliff) | **145 s ✅** | – |
| C | `kb` | 20 | (extrapolated past cliff) | **148 s ✅** | – |
| D | unscoped | 5 | **307 s ❌ disposed** | **179 s ✅** | 1.7× |
| E | unscoped | **50** (max) | (would fail badly) | **178 s ✅** | – |

CPU saturation during rerank: ~563–592% (was ~190%). Memory: 1.24 GiB / 5.79
GiB (21%, no pressure). Two unexpected findings:

1. **`candidateLimit` is not the dominant cost axis.** cand=5/10/20/50
   all completed in 139–178 s. Query work is dominated by query expansion
   (1.7B GGUF) + embedding model + per-chunk rerank, but rerank only
   actually processes the high-RRF candidates, which for "DDD template
   scope" against `kb` is a small fixed number regardless of nominal
   `candidateLimit`. This means Pass 2's table that walks `candidateLimit
   = 1, 3, 5` happens to land all three probes within ±15 s of each other
   on 2 vCPU because the actual rerank work was nearly identical — the
   variable that mattered was wall-clock proximity to the timer, not
   candidate count.
2. **The bug is now latent, not absent.** The 5-min timer still exists
   in `dist/index.js:86`. On *this hardware* with *this corpus*, no probe
   I could provoke comes within 100 s of the cliff. With Game Island
   content arriving (corpus likely doubles), worst-case wall time on
   6 vCPU could approach 360 s — back over the cliff for unscoped queries.
   On a smaller-CPU CI runner or a different dev's machine, the cliff is
   closer.

## What you should ship — concrete checklist

Given the user's update that **this machine is for testing only and won't
run prod**, the recommendations split into two tiers.

### Tier 1 — must do, ships in this PR

These are necessary regardless of hardware. The YAML fix on `b0e3895`
plus the smoke-test addition. No other source changes.

**1.1 — keep `b0e3895` Dockerfile change as-is.** No edits needed. The
comment's "MCP server tolerates the missing YAML" claim is verified
correct on the MCP code path (it reads collections from SQLite via
`storeListCollections(db)`, not YAML).

**1.2 — apply the smoke-test patch from Pass 2.** Verbatim from
`sessions/2026-04-30_investigation_query_timeouts.md` lines 87–108.
Adds a `tools/call query` assertion with `lex` + `rerank:false` so the
test catches regressions where a future change breaks the success path.
Stays under 30 s on any hardware. Uses `rerank: false` deliberately —
the slow rerank-true path is too flaky to assert on inside a smoke test.

### Tier 2 — separate PR (rerank-disposal mitigation)

Defense in depth. Not blocking the YAML PR. Ship next week or whenever
convenient. Use a new branch.

**2.1 — Dockerfile sed patch** (verbatim from Pass 3 report). Bumps the
hardcoded timer from 5 min to 30 min. Defensive — your testing on 6 vCPU
won't hit the cliff anyway, but the patch makes the image portable to:
- Other developers' machines (might still be on 2 vCPU)
- CI runners (often 2 vCPU on free tiers)
- Anyone who clones the repo and runs `docker build`

```dockerfile
USER root
RUN sed -i 's/inactivityTimeoutMs: 5 \* 60 \* 1000/inactivityTimeoutMs: 30 * 60 * 1000/' \
        /usr/local/lib/node_modules/@tobilu/qmd/dist/index.js \
 && grep -q 'inactivityTimeoutMs: 30 \* 60 \* 1000' \
        /usr/local/lib/node_modules/@tobilu/qmd/dist/index.js
USER qmd
```

The trailing `grep -q` is a fail-loud guard: if a future qmd release
renames the constant, the build fails noisily instead of silently
no-op'ing the `sed`. This is the signal to delete the patch (because
upstream fixed it, see Tier 4).

**2.2 — `rerank: false` as default in skills.** Promote from "consider"
note to hard requirement in all four `skills/<name>/SKILL.md` files. On
6 vCPU you get ~1 s `rerank:false` queries vs ~140 s `rerank:true`. For
agent retrieval workflows (which is what these skills drive), 1 s
beats reranker-quality every time.

Not because you'll hit the cliff on this machine — you won't — but
because reranker quality on a 0.6 B model isn't worth 100×+ latency for
agent use cases. Pure UX win.

**2.3 — `tests/mcp-rerank-budget.sh`** from Pass 3 report. Slow companion
to the smoke test. Default-skipped via `MCP_RERANK_BUDGET_SKIP=1`. Run
manually before any qmd version bump or model swap. With Tier 2.1's
patch and 6 vCPU, this completes in ~3 min instead of ~10.

### Tier 3 — keep current

**3.1 — Rancher VM at 6 vCPU.** Already done by me on 2026-04-30. Don't
revert. The 4× speedup on small probes (24 s → 6 s for skill-arc-review)
is meaningful for interactive testing.

```bash
rdctl set --virtual-machine.number-cpus 6
```

If for some reason this gets reset, run that to restore. Memory stays at
the default 6 GiB — probes show only 21% used at peak.

**3.2 — VM stays at 6 vCPU even though prod won't run here.** The user's
constraint is "must support math game + game island testing." On 6 vCPU
with the Tier 2.1 timer patch, even an unrealistic worst-case unscoped
rerank query against a doubled corpus stays well inside the 30-min timer.
No reason to push higher.

### Tier 4 — upstream

**4.1 — File qmd PR.** The proper fix is wrapping `rerank()` (and likely
`expandQuery()` too — see the Mode A note below) in `withLLMSession()`
so `_inFlightOperations` increments and `canUnload()` gates correctly.
Reproducer is in Pass 3's report (`proposals/qmd-rerank-disposal-investigation.md`),
including exact source line refs to `qmd/src/llm.ts:1274-1277` and `:1501`.
Once merged in qmd 2.2+ and consumed via an `ARG QMD_VERSION` bump, the
Tier 2.1 sed patch becomes vestigial — the `grep -q` will then fail-loud
the build, which is the cue to delete the patch.

## What is *not* a problem (red herrings to stop chasing)

To save the next reader's time, here's what we eliminated:

- ❌ **sqlite-vec lifecycle bug.** Disproven. The "Object is disposed"
  string lives in `lifecycle-utils`, not sqlite-vec. `searchVec` runs in
  <1 ms whether scoped or unscoped.
- ❌ **Multi-collection iteration is the trigger.** Disproven. Single-
  collection `kb` scoped at `candidateLimit ≥ 5` failed identically on
  2 vCPU. Cross-collection traversal is not the cost.
- ❌ **Rancher VM RAM pressure.** Memory peaked at 1.25 GiB / 5.79 GiB
  (21%). Never close to OOM. CPU is the bottleneck, not RAM. Don't bump
  `--virtual-machine.memory-in-gb`.
- ❌ **MCP YAML config affects query behavior.** Disproven. The MCP
  query path reads collections from SQLite. Your YAML fix doesn't touch
  MCP behavior; it only enables the CLI surface inside the container.
- ❌ **OOM kill.** No evidence. Failures throw `DisposedError` cleanly.
- ❌ **Container-level `--cpus` / `--memory` flags.** No effect — the
  container only used what was already available; constraining it would
  make things worse, not better.

## Mode A — open question (low priority for this thread)

The CLI `qmd query` / `qmd vsearch` cold-start hang on `expandQuery()`
(>90 s on 2 vCPU) is unverified after the VM bump. Prior investigation
reproduced it; current investigation didn't probe it. **Hypothesis**: same
underlying mechanism — `expandQuery()` is also un-wrapped in `withLLMSession()`
so the inactivity timer can race against the 1.7 B query-expansion model
just like it does against the reranker.

**Recommendation**: re-probe Mode A on the 6 vCPU VM after the Tier 2.1
patch is applied. If it goes away (because the patch extends the timer
past whatever query-expansion takes), it's confirmed same root cause and
the upstream qmd PR fixes both. If it persists, it's a separate bug and
needs its own report.

This is **not blocking anything** — kb-game uses the MCP path, not the
CLI path. The CLI is for ops/debug from inside the container, which is
exactly what your YAML fix enables.

## Files to read in order

If you want to dive into details, the reading order is:

1. **This handoff** (you're here).
2. `proposals/qmd-rerank-disposal-investigation.md` — Pass 3 report,
   the canonical root-cause analysis. Has the source line refs and
   the reproducer.
3. `sessions/2026-04-30_investigation_query_timeouts.md` — Pass 2 report,
   for the original failure-mode taxonomy and the smoke-test patch.
4. The qmd source itself if you want to verify:
   - `/Users/stpn/Documents/repos/qmd/src/llm.ts:1274-1277` (`disposed`
     flag in `LlamaCpp.dispose()`)
   - `/Users/stpn/Documents/repos/qmd/src/llm.ts:1501` (`withLLMSession`
     wrapper)
   - `/Users/stpn/Documents/repos/qmd/src/index.ts` (createStore;
     dist version was at line 86)

## What needs verification before you merge

- [ ] Run `tests/mcp-smoke.sh` against `kb-game:dev` on the 6 vCPU VM
      → must pass quickly (<30 s).
- [ ] Run `tests/mcp-smoke.sh` against `kb-game:no-config` (a build with
      the `~/.config` COPY removed) → must FAIL on the new query
      assertion. If it passes, the assertion isn't tight enough.
- [ ] Confirm `rdctl list-settings | jq '.virtualMachine'` reports
      `numberCPUs: 6, memoryInGB: 6, type: "vz", mount.type: "virtiofs"`.
- [ ] Once Tier 2.1 patch is applied (separate PR), `docker history
      kb-game:dev` should show one new tiny layer between the
      `RUN ln -s ... /usr/local/bin/qmd` line and the model-cache COPY.

## Summary in one paragraph

Your YAML fix (`b0e3895`) is correct and ships. The "queries time out"
symptom you saw is a separate, traceable bug — `inactivityTimeoutMs:
5 * 60 * 1000` in qmd 2.1.0's `LlamaCpp` racing against an un-wrapped
`rankAll()`. The CPU bump from 2 to 6 makes it latent on this hardware
+ current corpus, and since this machine is testing-only, no further
hardware changes are needed. Apply the smoke-test patch (Tier 1.2)
in this PR; ship the Dockerfile sed patch + skill `rerank:false`
defaults + slow-CI test in a follow-up PR (Tier 2). File the upstream
qmd issue (Tier 4). The 6 vCPU VM stays. That's the full picture.

---

## Probe matrix (for reproducers)

The probe script lives at `/tmp/mcp-rerank-probe.sh` (in this worktree's
running session — port to `tests/mcp-probe.sh` if it's worth keeping).
Usage:

```bash
/tmp/mcp-rerank-probe.sh <image> <scope> <candidateLimit> <rerank> <stype> <hold-s>

# Examples:
/tmp/mcp-rerank-probe.sh kb-game:dev kb 5 true vec 400          # was failing on 2 vCPU
/tmp/mcp-rerank-probe.sh kb-game:dev unscoped 50 true vec 500   # max plausible workload
/tmp/mcp-rerank-probe.sh kb-game:dev kb 5 false vec 30          # fast sanity
```

The script reports response-arrival latency (not container-exit time),
kills only the targeted container by ID via `--cidfile`, and emits both
human-readable stderr and a tab-separated stdout row for table assembly.

For docker-stats during a probe (run in another terminal):

```bash
docker stats --no-stream --format '{{.Name}} {{.CPUPerc}} {{.MemUsage}}' \
    | grep -v "k8s_"
```

You'll see ~580% CPU pinned during rerank on 6 vCPU.
