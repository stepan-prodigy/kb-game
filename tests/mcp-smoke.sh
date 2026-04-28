#!/usr/bin/env bash
# Smoke test for the kb-game image's stdio MCP server.
#
# Pipes JSON-RPC `initialize` + `tools/list` to `docker run -i <image>`
# and asserts the responses:
#   - `initialize` reports serverInfo.name = "qmd"
#   - `tools/list` includes the four expected tool names
#
# Usage:
#   tests/mcp-smoke.sh                # uses kb-game:dev
#   tests/mcp-smoke.sh kb-game:<sha>  # against a tagged image
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

echo "PASS: $IMAGE"
