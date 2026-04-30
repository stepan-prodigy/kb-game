# syntax=docker/dockerfile:1.7
#
# kb-game: ships a qmd hybrid+rerank search index over the Prodigy game
# knowledge base + procedural skill reference content. Multi-stage so the
# embedding-model layer stays cached across doc-only rebuilds.
#
# Stages:
#   base    — qmd installed globally, native deps compiled.
#   model   — embedding/rerank/expansion model weights downloaded into qmd cache.
#   index   — knowledge/ + skills/*/reference/ embedded into ~/.cache/qmd/index.sqlite.
#   runtime — slim image with prebuilt node_modules + model + index, non-root.
#
# Multi-collection design: each top-level domain gets its own named collection
# so retrieval can be scoped at query time:
#   kb              → knowledge/         (factual reference: schemas, design, profiles)
#   skill-<name>    → skills/<name>/reference/  (per-workflow heuristics + templates)
#
# Adding a new skill = drop a new directory under skills/<name>/reference/.
# No Dockerfile edit required; the index stage discovers them via shell glob.

ARG NODE_VERSION=22.14.0
ARG QMD_VERSION=2.1.0
ARG QMD_EMBED_MODEL=hf:ggml-org/embeddinggemma-300M-GGUF/embeddinggemma-300M-Q8_0.gguf

############################
# Stage: base — qmd install
############################
FROM node:${NODE_VERSION}-bookworm-slim AS base
ARG QMD_VERSION

# Build toolchain for native deps (better-sqlite3, node-llama-cpp, sqlite-vec,
# web-tree-sitter). Cleaned up in this layer so the runtime stage stays slim.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates curl python3 build-essential \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m -u 1001 -s /bin/bash qmd

RUN npm install -g --omit=dev @tobilu/qmd@${QMD_VERSION}

##################################################################
# Stage: model — populate qmd's model cache as its own image layer.
# qmd uses three models: embedding (vsearch), reranking (query),
# and a query-expansion generation model (query, vsearch). All are
# downloaded on first use; baking them keeps the runtime offline.
# A throwaway seed corpus forces qmd through the full embed+query
# code path so each model is fetched into ~/.cache/qmd/models/.
##################################################################
FROM base AS model
ARG QMD_EMBED_MODEL
ENV QMD_EMBED_MODEL=${QMD_EMBED_MODEL}
USER qmd
WORKDIR /home/qmd
RUN mkdir -p /tmp/seed \
 && printf '# seed\nseed corpus to bootstrap model download.\n' > /tmp/seed/seed.md \
 && qmd collection add /tmp/seed --name __seed__ \
 && qmd embed \
 && qmd query "warmup" -n 1 -c __seed__ >/dev/null 2>&1 || true \
 && qmd collection remove __seed__ \
 && rm -rf /tmp/seed /home/qmd/.cache/qmd/index.sqlite

##################################################
# Stage: index — embed the kb-game corpus.
# Two trees:
#   knowledge/         → registered as `kb`
#   skills/*/reference → registered as `skill-<name>` (one collection per skill)
# Arcs and reviews are NOT indexed (proposals, not truth).
##################################################
FROM model AS index
ARG QMD_EMBED_MODEL
ENV QMD_EMBED_MODEL=${QMD_EMBED_MODEL}
USER qmd
WORKDIR /home/qmd
COPY --chown=qmd:qmd ./knowledge /home/qmd/knowledge/
COPY --chown=qmd:qmd ./skills /home/qmd/skills/

# Register the factual `kb` collection plus one `skill-<name>` collection per
# skill that has a reference/ subdir. Smaller --max-docs-per-batch keeps the
# embedding session short so it doesn't expire mid-batch (large default
# batches drop ~1-2% of chunks with "Session expired" errors). A second
# `qmd embed` retries any stragglers — verified to clear all pending docs.
RUN set -e; \
    qmd collection add /home/qmd/knowledge --name kb; \
    qmd context add qmd://kb "Prodigy game knowledge base — event schemas, game design, session profiles"; \
    for skill_ref in /home/qmd/skills/*/reference; do \
        [ -d "$skill_ref" ] || continue; \
        skill_name=$(basename "$(dirname "$skill_ref")"); \
        qmd collection add "$skill_ref" --name "skill-${skill_name}"; \
        qmd context add "qmd://skill-${skill_name}" "Reference for ${skill_name} workflow (templates, heuristics, examples)"; \
    done; \
    qmd embed --max-docs-per-batch 30; \
    qmd embed --max-docs-per-batch 30

##############################################################
# Stage: runtime — slim, no toolchain, non-root, qmd on PATH.
##############################################################
FROM node:${NODE_VERSION}-bookworm-slim AS runtime
ARG QMD_VERSION
ARG QMD_EMBED_MODEL
ENV QMD_VERSION=${QMD_VERSION} \
    QMD_EMBED_MODEL=${QMD_EMBED_MODEL}

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates libgomp1 \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m -u 1001 -s /bin/bash qmd

# qmd's node_modules (better-sqlite3, node-llama-cpp, etc.). The bin entry is
# a symlink that the wrapper script needs in order to resolve the package
# directory — recreate it instead of COPY'ing the bin file (which dereferences
# the symlink and breaks `dirname/..` resolution to the package root).
COPY --from=base /usr/local/lib/node_modules/@tobilu /usr/local/lib/node_modules/@tobilu
RUN ln -s ../lib/node_modules/@tobilu/qmd/bin/qmd /usr/local/bin/qmd

# Local-test workaround: qmd 2.1.0 hardcodes inactivityTimeoutMs=5*60*1000 in
# dist/index.js, with no env override. On CPU hosts, rerank's rankAll() can
# exceed 5 min for queries with enough rerank candidates, causing the
# inactivity timer to dispose the rerank context mid-call →
# DisposedError("Object is disposed"). This patch bumps the constant to 30
# min so the timer doesn't race rerank while we test functionality + content
# shape locally. See proposals/qmd-rerank-disposal-investigation.md.
#
# Sunset: remove this patch once qmd upstream wraps rerank() in
# withLLMSession() (tracked in KB_PENDING.md). The trailing grep -q makes
# the build fail loudly if a future qmd release moves or rephrases the
# constant — that's the cue to delete the patch.
RUN sed -i 's/inactivityTimeoutMs: 5 \* 60 \* 1000/inactivityTimeoutMs: 30 * 60 * 1000/' \
        /usr/local/lib/node_modules/@tobilu/qmd/dist/index.js \
 && grep -q 'inactivityTimeoutMs: 30 \* 60 \* 1000' \
        /usr/local/lib/node_modules/@tobilu/qmd/dist/index.js

# Model cache layer (kept separate so doc-only rebuilds skip re-pulling weights).
COPY --from=index --chown=qmd:qmd /home/qmd/.cache/qmd/models /home/qmd/.cache/qmd/models

# qmd 2.1.0 stores collection state in two places: SQLite (store_collections
# table inside index.sqlite) AND a YAML config under ~/.config/qmd/. The CLI
# commands `collection list`, `collection show`, `collection remove`, and the
# `--collection` query/search flag all resolve names via the YAML; without it
# they report "Collection not found" even though search-by-default works
# against the DB. The MCP server tolerates the missing YAML, but copying it
# keeps the CLI usable for ops/debug from inside the container.
COPY --from=index --chown=qmd:qmd /home/qmd/.config /home/qmd/.config

# Index + corpus. We copy the full skills/ tree (including arcs/ and
# reviews/) so they are filesystem-readable from inside the container even
# though only reference/ is indexed.
COPY --from=index --chown=qmd:qmd /home/qmd/.cache/qmd/index.sqlite /home/qmd/.cache/qmd/index.sqlite
COPY --from=index --chown=qmd:qmd /home/qmd/knowledge /home/qmd/knowledge
COPY --from=index --chown=qmd:qmd /home/qmd/skills /home/qmd/skills

USER qmd
WORKDIR /home/qmd

# Default to the stdio MCP server (qmd's built-in `mcp` subcommand) so
# `docker run -i <image>` is a drop-in stdio MCP transport for Claude Code.
# Other invocations override CMD: `docker run --rm <image> query "..."`,
# `... status`, `... search "..."`, etc.
ENTRYPOINT ["qmd"]
CMD ["mcp"]
