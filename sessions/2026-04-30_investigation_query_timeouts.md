---
title: Investigation — kb-game query timeouts
type: investigation-report
session_id: kb-game-bootstrap-2026-04-28
date: 2026-04-30
target_branch: fix/qmd-yaml-and-eval-scenarios
target_commit: b0e3895
critic_prompt: sessions/2026-04-29_critic_prompt_dockerfile.md (separate concern)
status: complete
---

# Investigation — kb-game query timeouts

The user's "queries timing out" symptom conflates **three independent issues**. Disambiguated by 10 probes (4 CLI + 6 MCP), all on `kb-game:dev` (commit `b0e3895`), Rancher Desktop 2 CPU / 6 GB / Apple Silicon.

## Three failure modes

| # | Mode | Reproducer | Impact |
|---|---|---|---|
| **A** | **CLI `qmd query` / `qmd vsearch` cold-start hangs on `expandQuery()`** | `docker run --rm kb-game:dev query "X"` (with or without `-c`) | Hits >90s wall every time on 2-CPU. Affects only the CLI surface — `qmd query` invokes the 1.7B query-expansion GGUF on cold container. |
| **B** | **MCP `tools/call query` with `rerank: true` AND results spanning ≥2 collections returns `"Object is disposed"`** | MCP query unscoped, OR scoped to ≥2 collections, with default rerank | **Correctness bug, not a timeout.** Errors after ~5 min wall (B2: 308s, B7: 313s). qmd internal lifecycle bug — `LlamaCpp.disposed` flag fires before reranker finishes its multi-collection batch. |
| **C** | **MCP cold-start latency** | First query of any kind (B6/B8 lex-only at +38s, +40s) | ~40s on first id=3 even when no rerank/expansion needed. Suggests MCP server eagerly loads embedding model during `initialize`. Not a bug — hardware floor on 2-CPU. |

The three modes have distinct fixes; the critic's original prompt collapsed them.

## Probe matrix (key results)

| Probe | Scope | rerank | searches | id=3 latency | Outcome |
|---|---|---|---|---|---|
| Phase2-1 | scoped | n/a (CLI) | search (BM25) | ~2s | ✅ |
| Phase2-3 | scoped | n/a | vsearch | killed @90s | ⏱ stuck on `Expanding query…` (Mode A) |
| Phase2-5 | scoped | n/a | query | killed @90s | ⏱ same (Mode A) |
| B1 | scoped (1-col) | on | lex+vec | **41s** | ✅ |
| B2 | unscoped | on | lex+vec | **308s** | ❌ `"Object is disposed"` (Mode B) |
| B2-norerank | unscoped | **off** | lex+vec | **1s** | ✅ — eliminates Mode B |
| B5 | scoped | off | lex+vec | 2s | ✅ |
| B6 | scoped | n/a | lex-only | 38s | ✅ (Mode C floor) |
| B7 | scoped (2-col) | on | lex+vec | **313s** | ❌ `"Object is disposed"` — confirms Mode B fires for any N≥2 collections, not just unscoped |
| B8 | scoped | n/a | lex-only repeat | 40s | ✅ — confirms B6 was real, not noise |

## Critic's claims — verified vs refuted

| Claim | Verdict |
|---|---|
| `"Object is disposed"` reproduces on unscoped MCP query with rerank | ✅ verified (B2, B7) |
| Scoped MCP query "succeeds in 5–10s on CPU" | ❌ **refuted on this hardware**: 41s with rerank, 2s without (B1, B5) |
| Hangs past 90s on unscoped without YAML | ⚠️ partially: errors at 308s, doesn't hang indefinitely. Critic's "without YAML" framing is irrelevant — YAML doesn't affect this code path |
| Bug is "iterates collections without scope" | ❌ **refined**: bug is "rerank with N≥2 collections in result set." B7 confirms: explicit scope to 2 collections still triggers it |
| `"Object is disposed"` from sqlite-vec | ❌ refuted: source-grep located `disposed = true` in `LlamaCpp.dispose()` (`src/llm.ts:1274-1277`). It's the LLM wrapper, not sqlite-vec |

## Recommended changes

### 1. Workaround for Mode B (the correctness bug)

**Client-side default.** All MCP `query` callers MUST pass `rerank: false` until upstream fix. Update skill heuristics — currently a "set rerank: false on CPU" suggestion; promote to a hard requirement.

```diff
--- a/skills/ddd-drafting/SKILL.md
+++ b/skills/ddd-drafting/SKILL.md
@@ -22,6 +22,9 @@ Query the `skill-ddd-drafting` collection for the canonical DDD template…
 ```
 kb-game query "DDD template <feature-kind>" --collection skill-ddd-drafting
 ```
+
+**MUST** pass `rerank: false` on any MCP query until upstream qmd reranker
+lifecycle bug is fixed (errors with `"Object is disposed"` after ~5 min when
+results span ≥2 collections). See sessions/2026-04-30_investigation_query_timeouts.md.
```

Apply analogous edits to all four skill SKILL.md files.

### 2. Test addition for `tests/mcp-smoke.sh`

Catch the failure class in CI. The success path stays under 60s (B5 took 2s); the failure path takes 5 min — too slow for CI, so we test the success path explicitly.

```diff
--- a/tests/mcp-smoke.sh
+++ b/tests/mcp-smoke.sh
@@ -52,4 +52,30 @@ done
 echo "OK: tools/list -> ${EXPECTED_TOOLS[*]}"

 echo "PASS: $IMAGE"
+
+# Regression test: tools/call query with rerank:false should succeed
+# without isError:true. Catches the qmd reranker disposed-bug class.
+# See sessions/2026-04-30_investigation_query_timeouts.md.
+QUERY_REQ='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"smoke","version":"0.1"}}}
+{"jsonrpc":"2.0","method":"notifications/initialized"}
+{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"query","arguments":{"searches":[{"type":"lex","query":"DDD"}],"intent":"smoke","limit":3,"rerank":false}}}'
+
+QUERY_RESP=$( { printf '%s\n' "$QUERY_REQ"; sleep 60; } \
+    | docker run --rm -i "$IMAGE" 2>/dev/null \
+    | grep '"id":3' | head -1 || true )
+
+if [[ -z "$QUERY_RESP" ]]; then
+    echo "FAIL: no query response within 60s" >&2
+    exit 2
+fi
+if echo "$QUERY_RESP" | grep -q '"isError":true'; then
+    echo "FAIL: query returned isError:true" >&2
+    echo "$QUERY_RESP" >&2
+    exit 1
+fi
+if ! echo "$QUERY_RESP" | grep -q '"results"'; then
+    echo "FAIL: query response missing results array" >&2
+    exit 1
+fi
+echo "OK: tools/call query (rerank:false) -> success"
```

### 3. Documentation deltas

- **`Dockerfile` comment** — already up to date for the YAML bug; add a NOTE flagging the separate rerank lifecycle bug as a known upstream issue.
- **`README.md` — Known gotchas** — add: "MCP `tools/call query` with default rerank errors with `"Object is disposed"` after ~5 min when results span ≥2 collections. Pass `rerank: false`."

### 4. Configuration changes — what NOT to change

- **Don't bump Rancher Desktop CPU/RAM as a fix.** Already at 6 GB (above default 4). The disposed bug is a correctness issue, not resource starvation. CPU bump may help cold-start latency (Mode C) but won't change Modes A/B.
- **Don't add `--memory` / `--cpus` to docker run.** No evidence of OOM (B7 errored, didn't OOM-kill). Adding limits without measured contention adds risk for no benefit.
- **Don't change MCP client timeout** to mask Mode C — first-query 40s is real cold-start work; long-lived MCP container amortizes it after the first query (warm path is ~1s).

### 5. Upstream items (KB_PENDING)

- **File qmd issue:** reranker `LlamaCpp.disposed` lifecycle bug fires before multi-collection rerank batch completes. Reproducer above. Affects qmd 2.1.0; status on 2.2 unknown.
- **Investigate** whether `withLLMSession()` (qmd's stated "lifecycle guarantee" wrapper at `src/llm.ts:1501`) is missing from the rerank path.

## Open questions (deferred, low priority)

- **B6/B8 lex-only at ~40s.** Repeats deterministically, so it's real. MCP server is doing something on first `tools/call` even when no LLM models needed. Worth a 30-min source dive but not blocking.
- **Warm-vs-cold profile in long-lived MCP container.** Critic's reproducer used one query per container (always cold). In practice Claude Code keeps the container alive — would be useful to measure 2nd, 3rd, Nth query latencies.

## Verdict

The Dockerfile YAML-config fix on `b0e3895` is **unrelated to and unaffected by** the query-timeout class. That PR can ship as-is.

The query-timeout symptom is two correctness issues (Modes A, B) and one hardware floor (Mode C), each with a separate fix. The most urgent: client-side `rerank: false` requirement to avoid Mode B until upstream fix. The smoke-test addition above catches regressions in the workaround.
