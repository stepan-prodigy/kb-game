#!/usr/bin/env bash
# Rerank-budget regression test for the kb-game image's stdio MCP server.
#
# This is the slow companion to tests/mcp-smoke.sh. It exercises the
# *rerank* path (which the smoke test deliberately bypasses with
# rerank:false) and asserts that an unscoped query against the full
# bundled corpus returns successfully without hitting the qmd 2.1.0
# "Object is disposed" failure mode.
#
# Background:
#   qmd 2.1.0 hardcodes inactivityTimeoutMs=300_000 (5 min) in
#   dist/index.js. While rerank's `rankAll(query, chunks)` is in flight
#   on CPU, no `touchActivity()` calls are made, so the timer fires and
#   `unloadIdleResources()` disposes the rerank context. The in-flight
#   call then throws DisposedError ("Object is disposed") from
#   lifecycle-utils. On a Rancher Desktop 2-CPU VM this trips when:
#     - rerank candidateLimit >= ~5 from the kb collection, OR
#     - unscoped queries that fan out across all 5 collections.
#
# What this asserts:
#   1. tools/call query (rerank=true, default candidateLimit) over the
#      full unscoped corpus returns within MCP_RERANK_TIMEOUT_S without
#      isError=true.
#   2. The text payload does not equal "Object is disposed".
#
# This test is skipped by default in CI because it takes 5+ min on CPU.
# Run manually: tests/mcp-rerank-budget.sh
# Force-skip:   MCP_RERANK_BUDGET_SKIP=1 tests/mcp-rerank-budget.sh
#
# Usage:
#   tests/mcp-rerank-budget.sh                # uses kb-game:dev
#   tests/mcp-rerank-budget.sh kb-game:<sha>  # against a tagged image
#
# Env vars:
#   MCP_RERANK_TIMEOUT_S       — total wall-clock cap (default: 600 = 10 min)
#   MCP_RERANK_QUERY_TEXT      — search query (default: "DDD template scope")
#   MCP_RERANK_CANDIDATE_LIMIT — qmd query candidateLimit (default: 3 — keeps
#                                rerank workload small enough for typical CPU)
#   MCP_RERANK_BUDGET_SKIP     — set to 1 to no-op (for CI gates)
#
# Exit codes:
#   0 — query returned non-error result
#   1 — query returned isError=true (regression)
#   2 — query timed out / no response

set -euo pipefail

if [[ "${MCP_RERANK_BUDGET_SKIP:-0}" == "1" ]]; then
    echo "SKIP: MCP_RERANK_BUDGET_SKIP=1"
    exit 0
fi

IMAGE="${1:-kb-game:dev}"
TIMEOUT_S="${MCP_RERANK_TIMEOUT_S:-600}"
QUERY_TEXT="${MCP_RERANK_QUERY_TEXT:-DDD template scope}"
CANDIDATE_LIMIT="${MCP_RERANK_CANDIDATE_LIMIT:-3}"

# Build the args. Note: NO `collections` field — defaults to all 5,
# which is exactly the path that triggers the disposal race.
QUERY_ARGS=$(jq -nc \
    --arg q "$QUERY_TEXT" \
    --argjson cl "$CANDIDATE_LIMIT" \
    '{searches:[{type:"vec",query:$q}],intent:"smoke",limit:3,candidateLimit:$cl}')

read -r -d '' REQUESTS <<EOF || true
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"rerank-budget","version":"0.1"}}}
{"jsonrpc":"2.0","method":"notifications/initialized"}
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"query","arguments":${QUERY_ARGS}}}
EOF

echo "Running unscoped rerank query against $IMAGE (timeout=${TIMEOUT_S}s, candidateLimit=$CANDIDATE_LIMIT)..."
START=$(date +%s)
RESPONSE=$( { printf '%s\n' "$REQUESTS"; sleep "$TIMEOUT_S"; } \
    | docker run --rm -i "$IMAGE" 2>/dev/null \
    | awk 'index($0,"\"id\":3,") || index($0,"\"id\":3}")' \
    | head -1 || true )
END=$(date +%s)
ELAPSED=$((END - START))

if [[ -z "$RESPONSE" ]]; then
    echo "FAIL: no tools/call query response (id=3) within ${TIMEOUT_S}s" >&2
    exit 2
fi

if echo "$RESPONSE" | jq -e '.result.isError == true' >/dev/null 2>&1; then
    err_text=$(echo "$RESPONSE" | jq -r '.result.content[0].text // "(no text)"')
    echo "FAIL: tools/call query returned isError=true after ${ELAPSED}s: $err_text" >&2
    if [[ "$err_text" == "Object is disposed" ]]; then
        echo "" >&2
        echo "REGRESSION: qmd 2.1.0 inactivity-timer-vs-rerank race re-introduced." >&2
        echo "  Likely cause: rerank workload now exceeds the 5-min hardcoded" >&2
        echo "  inactivityTimeoutMs in node_modules/@tobilu/qmd/dist/index.js." >&2
        echo "" >&2
        echo "  Investigate: did the kb corpus grow? did candidateLimit default" >&2
        echo "  change? did the rerank model swap to a slower one? has the" >&2
        echo "  Rancher VM CPU count dropped? did node-llama-cpp regress?" >&2
        echo "" >&2
        echo "  Workaround at the call site: pass rerank:false in client" >&2
        echo "  query args, or set candidateLimit<=3 with explicit collections." >&2
    fi
    exit 1
fi

result_count=$(echo "$RESPONSE" | jq '.result.structuredContent.results | length' 2>/dev/null || echo 0)
echo "OK: tools/call query (rerank=true) returned ${result_count} result(s) in ${ELAPSED}s"
echo "PASS: $IMAGE"
