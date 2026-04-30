# kb-game Pending

Repo-level pending work. Distinct from any contributor's personal task list — this is the kb's own todo, gated by user PR review like everything else.

## Migration follow-ups (from initial import 2026-04-28)

- [ ] Re-verify `skills/ddd-drafting/reference/template_ddd.md` against current Confluence (page 6113787907). Last sync was 2026-04-24.
- [ ] Rewrite `knowledge/_meta/kb_structure_legacy.md` for kb-game (current content describes the personal memory system, not this kb).
- [ ] Rewrite `knowledge/_meta/eval_system_legacy.md` for kb-game eval scenarios.
- [ ] Audit all `status: legacy-import` pages — confirm or update claims, then change status to `stable` (`grep -rl "status: legacy-import" knowledge/ skills/`).
- [ ] First arc-review cycle scheduled (target: end of week 1 of usage).
- [ ] First kb-refresh cycle for `knowledge/event-schemas/` against Confluence Segment Event Definitions.

## qmd reranker disposal mitigation (added 2026-04-30)

- [ ] **Tier 4 — File qmd upstream issue.** Reranker bug: `rerank()` is not wrapped in `withLLMSession()`, so the hardcoded 5-min `inactivityTimeoutMs` in `qmd 2.1.0/dist/index.js:86` races with the un-wrapped `rankAll()` Promise.all → `DisposedError("Object is disposed")`. Reproducer + source line refs in `proposals/qmd-rerank-disposal-investigation.md`.
- [ ] **Tier 2.1 sunset condition.** Delete the Dockerfile sed-patch (bumps `inactivityTimeoutMs` 5 min → 30 min) once qmd upstream fix lands and is consumed via an `ARG QMD_VERSION` bump. The `grep -q` guard in the Dockerfile will fail the build loudly when the constant moves — that's the deletion cue.
- [ ] **Mode A re-probe.** Verify CLI `qmd query` / `qmd vsearch` cold-start hang (>90 s on 2 vCPU pre-bump) is also fixed by Tier 2.1. Hypothesis: same root cause — `expandQuery()` un-wrapped the same way as `rerank()`. Re-test on 6 vCPU after Tier 2.1 patch is in.

## Real-workflow validation (added 2026-04-30)

kb-game architecture is being tested locally before being seeded to a production KB repo. Assume same architecture; experiments to vary it happen on branches afterward.

- [ ] **First DDD draft end-to-end.** Wire kb-game into `~/.claude/mcp.json`; install skills (e.g. symlink `kb-game/skills/<name>/SKILL.md` into `~/.claude/skills/`); run `/draft-ddd` against a real Math Game feature. Evaluate:
  - Retrieval relevance (did the right `kb` and `skill-ddd-drafting` chunks surface?)
  - Chunk quality (right boundary + size for grounding?)
  - Corpus shape (is `knowledge/` taxonomy useful, or does it need reshaping?)
  - First arc lands in `skills/ddd-drafting/arcs/`.
- [ ] **Architecture verdict.** Based on the first DDD draft, decide: ship same architecture to production KB, OR branch experiments (chunking strategy, frontmatter contract, collection split, retrieval defaults).
- [ ] **rerank quality eval.** Once a real DDD draft exists, run the 7 kb-eval scenarios (and any new ones derived from arcs) with `rerank: true` AND `rerank: false`; compare recall/precision; document in an `evals/` report. Informs whether per-skill rerank defaults should ever be set.

## Open architectural questions

- [ ] Cadence for kb-refresh per section — stored as `refresh_cadence` field in section meta or globally?
- [ ] When to split `kb-dippr` out of kb-game (current trigger candidates: dippr-platform stabilizes; Game Island scope grows enough to dilute).
- [ ] Plugin distribution for skills (currently symlink-based; revisit when 3+ skills are stable).
- [ ] Should `_meta/` be its own qmd collection (`meta`) or stay under `kb`? Decision deferred — first see whether `_meta` content pollutes kb queries.
- [ ] Where do non-procedural proposals live: repo-root `proposals/knowledge/` (current) vs per-section `knowledge/<section>/_proposals/`? Current default is repo-root.

## Ideas worth keeping visible

- [ ] `dbt-model-drafting` skill — from Gap 1 in `knowledge/_meta/authoring_gaps.md` (highest priority among unfilled drafting templates).
- [ ] `dq-test-drafting` skill — from Gap 2.
- [ ] Game Island content migration (after Math Game stabilizes).
- [ ] Cross-skill shared content directory `skills/_shared/` if duplication appears across workflows.
- [ ] GPU-based embed for faster rebuilds (defer until CPU embed time bites).
- [ ] Web-fetch hook in `kb-refresh` for sources beyond Confluence.

## Done

- 2026-04-28 — Initial scaffold (Dockerfile, build_index.py, smoke test, ddd-drafting skeleton).
- 2026-04-28 — Migration from personal memory: 31 files imported into `knowledge/` and `skills/ddd-drafting/reference/`. All tagged `status: legacy-import`.
- 2026-04-28 — `arc-review`, `kb-refresh`, `kb-eval` skill skeletons added.
- 2026-04-28 — `KB_PENDING.md` created.
- 2026-04-30 — YAML config CLI fix landed (commit `b0e3895`).
- 2026-04-30 — qmd reranker disposal-race investigation (3 passes) → root cause in `proposals/qmd-rerank-disposal-investigation.md`.
- 2026-04-30 — Tier 2.1 Dockerfile sed-patch lands (bumps `inactivityTimeoutMs` to 30 min).
