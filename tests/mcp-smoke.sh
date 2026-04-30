#!/usr/bin/env bash
# Smoke test for the kb-game image's stdio MCP server.
#
# Pipes JSON-RPC `initialize` + `tools/list` to `docker run -i <image>`
# and asserts the responses:
#   - `initialize` reports serverInfo.name = "qmd"
#   - `tools/list` includes the four expected tool names
#   - `tools/call query` with `rerank:false` returns results (no isError)
#     within MCP_SMOKE_QUERY_TIMEOUT_S. This guards against the qmd 2.1.0
#     "Object is disposed" failure mode where the 5-minute inactivity
#     timer fires mid-rerank and disposes node-llama-cpp contexts on
#     CPU-only hosts (e.g. Rancher Desktop @ 2 CPU). The test deliberately
#     uses rerank:false so the assertion stays sub-30s on CPU and so the
#     test fails *fast* if the MCP query path becomes broken in any
#     other way (search returning isError, malformed JSON, etc.).
#
# Usage:
#   tests/mcp-smoke.sh                # uses kb-game:dev
#   tests/mcp-smoke.sh kb-game:<sha>  # against a tagged image
#
# Env vars:
#   MCP_SMOKE_TIMEOUT_S        — initialize/tools/list cap (default: 30)
#   MCP_SMOKE_QUERY_TIMEOUT_S  — query call cap (default: 60). Bump on
#                                first cold run; warm reruns are <5s.
#   MCP_SMOKE_QUERY_TEXT       — search query text (default: a phrase
#                                that hits the bundled corpus)
#   MCP_SMOKE_EXTRA_ARG        — extra docker-run args (e.g. --memory)
#
# Exit codes:
#   0 — assertions pass
#   1 — assertion failure
#   2 — docker invocation failed / no response within timeout
#
# Dependencies: docker, jq.

set -euo pipefail

IMAGE="${1:-kb-game:dev}"
TIMEOUT_S="${MCP_SMOKE_TIMEOUT_S:-30}"
QUERY_TIMEOUT_S="${MCP_SMOKE_QUERY_TIMEOUT_S:-60}"
QUERY_TEXT="${MCP_SMOKE_QUERY_TEXT:-DDD template scope}"
EXPECTED_TOOLS=(query get multi_get status)

read -r -d '' REQUESTS <<'EOF' || true
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"smoke","version":"0.1"}}}
{"jsonrpc":"2.0","method":"notifications/initialized"}
{"jsonrpc":"2.0","id":2,"method":"tools/list"}
EOF

EXTRA_ARG="${MCP_SMOKE_EXTRA_ARG:-}"

RESPONSE=$( { printf '%s\n' "$REQUESTS"; sleep "$TIMEOUT_S"; } \
    | docker run --rm -i "$IMAGE" ${EXTRA_ARG} 2>/dev/null \
    | head -2 || true )

if [[ -z "$RESPONSE" ]]; then
    echo "FAIL: no response from MCP server within ${TIMEOUT_S}s" >&2
    exit 2
fi

init_response=$(echo "$RESPONSE" | grep '"id":1' | head -1 || true)
list_response=$(echo "$RESPONSE" | grep '"id":2' | head -1 || true)

if [[ -z "$init_response" ]]; then
    echo "FAIL: no initialize response (id=1)" >&2
    echo "got:" >&2
    echo "$RESPONSE" >&2
    exit 1
fi

server_name=$(echo "$init_response" | jq -r '.result.serverInfo.name // empty')
if [[ "$server_name" != "qmd" ]]; then
    echo "FAIL: expected serverInfo.name='qmd', got '$server_name'" >&2
    exit 1
fi
echo "OK: initialize -> serverInfo.name=qmd"

if [[ -z "$list_response" ]]; then
    echo "FAIL: no tools/list response (id=2)" >&2
    exit 1
fi

actual_tools=$(echo "$list_response" | jq -r '.result.tools[].name' | sort | tr '\n' ' ')
for tool in "${EXPECTED_TOOLS[@]}"; do
    if ! echo " $actual_tools" | grep -q " $tool "; then
        echo "FAIL: expected tool '$tool' missing from tools/list" >&2
        echo "got: $actual_tools" >&2
        exit 1
    fi
done
echo "OK: tools/list -> ${EXPECTED_TOOLS[*]}"

# ---------------------------------------------------------------------------
# Query smoke: tools/call query with rerank:false (defaults-collections path).
#
# What this catches:
#   - qmd MCP search returning {"isError":true} with any payload (notably
#     "Object is disposed" from node-llama-cpp's lifecycle-utils when the
#     5-min inactivity timer fires mid-rerank — see investigation notes).
#   - Search returning zero results against the bundled corpus, which
#     would indicate index/embed regression.
#   - Server hanging past QUERY_TIMEOUT_S without emitting id=3.
#
# Why rerank:false: keeps wall time deterministic (<5s warm, <30s cold)
# and below typical MCP client timeouts. The disposal regression also
# manifests against rerank:true on the largest collection (`kb`) at
# >300s, but that path is too slow for a smoke test on CPU. Run
# tests/mcp-rerank-budget.sh (see report) for the slower regression.
# ---------------------------------------------------------------------------
QUERY_ARGS=$(jq -nc --arg q "$QUERY_TEXT" '{searches:[{type:"vec",query:$q}],intent:"smoke",limit:3,rerank:false}')

read -r -d '' QUERY_REQUESTS <<EOF || true
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"smoke","version":"0.1"}}}
{"jsonrpc":"2.0","method":"notifications/initialized"}
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"query","arguments":${QUERY_ARGS}}}
EOF

QUERY_RESPONSE=$( { printf '%s\n' "$QUERY_REQUESTS"; sleep "$QUERY_TIMEOUT_S"; } \
    | docker run --rm -i "$IMAGE" ${EXTRA_ARG} 2>/dev/null \
    | awk 'index($0,"\"id\":3,") || index($0,"\"id\":3}")' \
    | head -1 || true )

if [[ -z "$QUERY_RESPONSE" ]]; then
    echo "FAIL: no tools/call query response (id=3) within ${QUERY_TIMEOUT_S}s" >&2
    echo "      either the server is hanging or it died silently;" >&2
    echo "      rerun with MCP_SMOKE_EXTRA_ARG='-it' and the same REQUESTS" >&2
    echo "      to see stderr." >&2
    exit 2
fi

if echo "$QUERY_RESPONSE" | jq -e '.result.isError == true' >/dev/null 2>&1; then
    err_text=$(echo "$QUERY_RESPONSE" | jq -r '.result.content[0].text // "(no text)"')
    echo "FAIL: tools/call query returned isError=true: $err_text" >&2
    if [[ "$err_text" == "Object is disposed" ]]; then
        echo "      This is the qmd 2.1.0 inactivity-timer-vs-rerank race." >&2
        echo "      Workarounds: pass rerank:false from clients, set" >&2
        echo "      candidateLimit<=3 on small collections, or patch" >&2
        echo "      LlamaCpp({inactivityTimeoutMs:...}) in qmd's index.js." >&2
    fi
    exit 1
fi

result_count=$(echo "$QUERY_RESPONSE" | jq '.result.structuredContent.results | length' 2>/dev/null || echo 0)
if [[ "$result_count" -lt 1 ]]; then
    echo "FAIL: tools/call query returned 0 results for '$QUERY_TEXT'" >&2
    echo "      query response: $QUERY_RESPONSE" >&2
    exit 1
fi
echo "OK: tools/call query -> ${result_count} result(s) (rerank=false)"

echo "PASS: $IMAGE"
