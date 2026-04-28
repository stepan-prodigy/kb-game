# kb-game Pending

Repo-level pending work. Distinct from any contributor's personal task list — this is the kb's own todo, gated by user PR review like everything else.

## Migration follow-ups (from initial import 2026-04-28)

- [ ] Re-verify `skills/ddd-drafting/reference/template_ddd.md` against current Confluence (page 6113787907). Last sync was 2026-04-24.
- [ ] Rewrite `knowledge/_meta/kb_structure_legacy.md` for kb-game (current content describes the personal memory system, not this kb).
- [ ] Rewrite `knowledge/_meta/eval_system_legacy.md` for kb-game eval scenarios.
- [ ] Audit all `status: legacy-import` pages — confirm or update claims, then change status to `stable` (`grep -rl "status: legacy-import" knowledge/ skills/`).
- [ ] First arc-review cycle scheduled (target: end of week 1 of usage).
- [ ] First kb-refresh cycle for `knowledge/event-schemas/` against Confluence Segment Event Definitions.

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
