---
title: kb-game query "timeouts" — root cause and mitigations
type: investigation
owner: stepan
last_modified: 2026-04-30
status: stable
related:
  - Dockerfile
  - tests/mcp-smoke.sh
  - tests/mcp-rerank-budget.sh
---

# kb-game query "timeouts": root cause and mitigations

## TL;DR

Queries against `kb-game:dev` over stdio MCP fail with
`{"isError":true, content[0].text:"Object is disposed"}` after roughly 5
minutes whenever the rerank step is slow enough to outlast qmd 2.1.0's
hardcoded 5-minute inactivity timer. None of the three originally
hypothesized causes (sqlite-vec lifecycle bug, Rancher VM RAM pressure,
MCP client cold-start timeout) are the proximate fault. The actual
fault is a **CPU-throughput vs. inactivity-timeout race** between
node-llama-cpp's long-running `rankAll()` and qmd's idle-resource
unloader, both holding the same context handle.

The fault reproduces at the **5-minute cliff**, not at any particular
candidate count. On a 2-CPU Rancher Desktop VM:

| Probe | Result | Wall time |
|---|---|---|
| scoped: `skill-arc-review` (1 doc, 1 chunk) | ✅ pass | 24 s |
| scoped: `skill-kb-eval` (10 docs, 11 chunks) | ✅ pass | 23 s |
| scoped: `skill-ddd-drafting` (3 docs, 29 chunks) | ✅ pass | 56 s |
| scoped: `kb` (30 docs, 105 chunks), candidateLimit=1 | ✅ pass (just barely) | **303 s** |
| scoped: `kb`, candidateLimit=3 | ✅ pass | 287 s |
| scoped: `kb`, candidateLimit=5 | ❌ "Object is disposed" | **317 s** |
| unscoped (defaults to all 5), candidateLimit=1 | ❌ "Object is disposed" | 307 s |
| unscoped, candidateLimit=3 | ❌ "Object is disposed" | 307 s |
| unscoped, **rerank=false** | ✅ pass | **1.9 s** |
| scoped: `kb`, rerank=false | ✅ pass | <2 s |

The 287 s ↔ 317 s cliff is the smoking gun: it is exactly the
hardcoded `inactivityTimeoutMs = 5 * 60 * 1000` plus warmup overhead.

## Root cause

### Where the error string comes from

Inside the running container:

```
/usr/local/lib/node_modules/@tobilu/qmd/node_modules/lifecycle-utils/dist/DisposedError.js
  → super("Object is disposed")
```

`lifecycle-utils.DisposedError` is thrown by node-llama-cpp 3.18.1
whenever a method is called on a disposed model / context / sequence.
The string is never produced by qmd, sqlite-vec, or better-sqlite3
directly. (`grep -rln "Object is disposed"` in the qmd source returns
zero hits; in node_modules, only the `lifecycle-utils` file matches.)

### What disposes the object mid-query

`@tobilu/qmd@2.1.0/dist/index.js` line 86 (in `createStore`):

```js
const llm = new LlamaCpp({
    embedModel: ..., generateModel: ..., rerankModel: ...,
    inactivityTimeoutMs: 5 * 60 * 1000,        // ← hardcoded 5 min, no env override
    disposeModelsOnInactivity: true,            // ← also disposes models, not just contexts
});
```

`LlamaCpp.touchActivity()` is called at the *start* of `rerank()`
(llm.js line 848) and inside the setup helpers (`ensureRerankModel`,
`ensureRerankContexts`), but **never inside the long-running
`rankAll(query, chunks)` Promise.all** at line 892. When the 5-minute
timer fires, `unloadIdleResources()` runs `await ctx.dispose()` on
every rerank/embed context and then disposes the models themselves.
The in-flight `rankAll` then throws `DisposedError`. The MCP SDK's
tool-handler wrapper catches that and converts it to
`{content:[{type:"text",text:"Object is disposed"}], isError:true}`.

The session manager's `_inFlightOperations` counter would gate
`canUnload()` against this — but `rerank()` is **not** wrapped in
`withLLMSession`, so it never increments that counter. The disposal
proceeds even while rerank is mid-flight.

### Why some queries trip it

The bottleneck is **rerank inference throughput**, which is dominated
by:

- Reranker model: `Qwen3-Reranker-0.6B-Q8_0` (610 MB on disk).
- Per-chunk forward pass: ~900 prompt tokens through a 0.6B Q8 model
  on 2 CPU threads ≈ 25–60 s per chunk on this VM (CPU was pinned at
  ~190/200% throughout failing probes; memory peaked at 1.25/5.78
  GiB = 22%, never close to OOM).
- Cold path adds ~5–10 s rerank-model load + context creation.

The math:
- 1 chunk on `kb` → ~300 s total (right at the cliff)
- 3 chunks on `kb` → ~287 s (still passes, just)
- 5 chunks on `kb` → ~317 s (fails)
- Many chunks across small skill collections → 1 small chunk each → fast

`searchVec` itself is pure SQL (~1 ms per call) — the multi-collection
fan-out in unscoped mode is **not** the cost. The cost is whichever
collection contributes large/numerous enough candidates to push rerank
past 5 minutes. In the current corpus that is the `kb` collection
(30 docs, 105 chunks).

## Hypothesis verdict

| # | Hypothesis | Verdict |
|---|---|---|
| 1 | sqlite-vec / better-sqlite3 lifecycle bug on unscoped queries | ❌ Disproven. The string lives in `lifecycle-utils` (used by node-llama-cpp). `searchVec` runs in <1 ms whether scoped or not. |
| 2 | Rancher Desktop VM resource limits (default 2 CPU / 4 GB) | ⚠️ Partial. VM is already at 6 GB / 2 CPU on this host. Memory peaked at 22%; **CPU is the bottleneck**. Bumping CPU to 4+ would push most workloads under the timer but doesn't durably fix it. |
| 3 | First-query model-load latency vs. MCP client timeout | ⚠️ Independent issue, currently moot. The user has **no `mcp.json` and no `mcpServers` entry** in `~/.claude.json` — this image is not yet wired into Claude Code. The "timeouts" they observed were from manual `docker run -i` testing where there is no client timeout. Once wired up, the cold-start + rerank budget will exceed Claude Code's default tool timeout regardless of the disposal bug. |
| **4** | **5-min inactivity-timer-vs-rerank race in qmd 2.1.0** | ✅ **This is the actual fault.** |

## Configuration changes (recommended, in priority order)

### 1. Always pass `rerank: false` from clients on CPU hosts

The only change that makes queries reliable in **all** scope/corpus
configurations. RRF-only results return in <2 s and are good enough
for most knowledge lookups. Costs reranker quality.

For Claude Code stdio MCP, the `query` tool input takes `rerank`
directly — the caller can opt in/out per call. There is no global
default to flip.

### 2. Patch qmd's hardcoded inactivity timeout (recommended for the image)

qmd does not expose an env var for `inactivityTimeoutMs`. Patch in
place at build time in the `runtime` stage of `Dockerfile`:

```dockerfile
# qmd 2.1.0 hardcodes inactivityTimeoutMs=5*60*1000 in dist/index.js, with no
# env override. On 2-CPU CPU hosts, rerank's rankAll() routinely exceeds 5 min
# for ≥5-chunk workloads on the kb collection, causing the inactivity timer to
# dispose the rerank context mid-call → DisposedError("Object is disposed").
# Patch the constant to 30 minutes so the timer can no longer race rerank on
# our corpus. Upstream fix would be to wrap rerank in withLLMSession (which
# increments _inFlightOperations and gates canUnload()); this is the build-
# time mitigation until that lands.
USER root
RUN sed -i 's/inactivityTimeoutMs: 5 \* 60 \* 1000/inactivityTimeoutMs: 30 * 60 * 1000/' \
        /usr/local/lib/node_modules/@tobilu/qmd/dist/index.js \
 && grep -q 'inactivityTimeoutMs: 30 \* 60 \* 1000' \
        /usr/local/lib/node_modules/@tobilu/qmd/dist/index.js
USER qmd
```

The trailing `grep -q` makes the build fail loudly if a future qmd
release moves or rephrases the constant, instead of silently no-op-ing
the `sed`.

### 3. Bump Rancher Desktop VM to 4 CPU

```sh
rdctl set --virtual-machine.number-c-p-us 4
# (Rancher will restart the VM; memory does not need bumping)
```

Roughly halves rerank wall time; brings most workloads under the timer
even without the patch above. Not sufficient on its own as the corpus
grows.

### 4. Document MCP-client-side budget

When this image is finally wired into Claude Code via `mcpServers`,
the cold-start budget on 2 CPU is:

- ~700 ms initialize
- ~5 s embed-model load (first vec query)
- ~3 s rerank-model load (first rerank)
- ~25–60 s rerank inference per chunk
- Total cold first query: 30 s – 5 min depending on candidate count

Two mitigations: pass `rerank: false` per call (covered above) or
warm the container (note: `docker run -i` exits when stdin closes, so
a true persistent warm container requires a different lifecycle than
the current per-invocation `docker run`).

### 5. Container-level `--cpus` / `--memory`

Not useful. The container only used 1.25 GiB; setting `--memory`
lower constrains nothing useful. Setting `--cpus` higher than the VM
has is a no-op.

## What about the unscoped-query "workaround"?

The original brief proposed `qmd collection exclude <name>` to flip
`includeByDefault=false` on N-1 collections, making the unscoped
default implicitly scoped. This **does not help**: the issue is not
"unscoped vs scoped" — `kb`-only scoped with `candidateLimit≥5` fails
identically. Whichever path produces enough rerank work to exceed the
timer fails. The durable fixes are options 1 and 2 above.

## Tests added in this worktree

### `tests/mcp-smoke.sh` (modified)

Extended with a fast (`rerank: false`) `tools/call query` assertion
that runs in <30 s. This catches:

- Any future regression where `query` returns `isError: true`
  (including, but not limited to, "Object is disposed").
- Index/embed regressions that produce zero results.
- Server hangs past the timeout.

It does **not** catch the slow-rerank disposal race directly, because
that path is too slow for a smoke test on CPU.

### `tests/mcp-rerank-budget.sh` (new)

Slow companion: runs an unscoped `rerank=true` query with a 10-min
timeout and asserts no `isError`. Designed to be run manually (or in
a slow CI lane) and to fail loudly with the exact diagnosis if "Object
is disposed" comes back. Skip-flag (`MCP_RERANK_BUDGET_SKIP=1`)
provided so a default CI can no-op it.

## What is not in scope for this report

- Applying the Dockerfile patch in option 2. The original brief
  explicitly forbade rebuilding the image during the investigation;
  the diff is provided here for the next person to apply.
- Filing an upstream qmd PR. The proper upstream fix is to wrap
  `rerank()` (and any other long-running LLM op) in `withLLMSession`
  so `_inFlightOperations` gates `canUnload()`. That is its own task.
- The "MCP server tolerates the missing YAML" comment elsewhere in
  `Dockerfile` — separate issue, unrelated to this fault.

## Reproducer (for future debugging)

The exact probe used. Substitute `unscoped`/`scoped` and tune
`candidateLimit` to walk the cliff:

```bash
ARGS='{"searches":[{"type":"vec","query":"DDD template scope"}],"intent":"smoke","limit":3}'
# (or add ,"collections":["kb"] / ,"candidateLimit":5 / ,"rerank":false)

REQ=$(cat <<JSON
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"probe","version":"0.1"}}}
{"jsonrpc":"2.0","method":"notifications/initialized"}
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"query","arguments":${ARGS}}}
JSON
)

START=$(date +%s%N)
{ printf '%s\n' "$REQ"; sleep 360; } | docker run --rm -i kb-game:dev 2>/dev/null \
  | while IFS= read -r line; do
      NOW=$(date +%s%N)
      ELAPSED_MS=$(( (NOW - START) / 1000000 ))
      [[ "$line" == *'"id":3'* ]] && echo "[+${ELAPSED_MS}ms] ${line:0:200}"
    done
```

Run `docker stats` against the probe container in another shell to
confirm the CPU-bound, memory-cold pattern (~190% CPU / 22% mem).
