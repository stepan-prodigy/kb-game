# /// script
# requires-python = ">=3.11"
# ///
"""One-shot import from personal memory into kb-game.

Source: /Users/stpn/.claude/projects/-Users-stpn-Documents-repos-dippr/memory/
Target: this repo's knowledge/ and skills/<name>/reference/ subdirs

Adapts each file's frontmatter to the kb-game contract:
  - drops `name`, `description`, `originSessionId` (memory-specific)
  - maps `name` → `title` (or uses an explicit override)
  - maps `as_of` → `as_of_at_import` (preserves provenance)
  - sets `last_modified` to the migration date
  - tags `status: legacy-import` so the to-rewrite list is greppable
  - records `imported_from: memory/<filename>` for traceability

Preserved here for record. Paths reference the user's local memory
directory and won't run in another environment.
"""

from __future__ import annotations

import re
from datetime import date
from pathlib import Path

MEMORY = Path("/Users/stpn/.claude/projects/-Users-stpn-Documents-repos-dippr/memory")
ROOT = Path(__file__).resolve().parent.parent
TODAY = date.today().isoformat()

# (source, target, type, owner, title_override)
MIGRATIONS: list[tuple[str, str, str, str, str]] = [
    # ── skills/ddd-drafting/reference (PROCEDURAL) ───────────────────────────
    (
        "reference_ddd_template.md",
        "skills/ddd-drafting/reference/template_ddd.md",
        "template",
        "data-team",
        "DDD Template (verbatim Confluence source)",
    ),
    (
        "reference_ddd_event_architecture.md",
        "skills/ddd-drafting/reference/ddd_event_architecture.md",
        "architecture-patterns",
        "data-team",
        "DDD Event Architecture Patterns",
    ),

    # ── knowledge/event-schemas ──────────────────────────────────────────────
    (
        "reference_common_event_log_schema.md",
        "knowledge/event-schemas/common_event_log_schema.md",
        "event-schema-contract",
        "data-team",
        "Common Event Log Schema",
    ),
    (
        "project_math_game_event_taxonomy.md",
        "knowledge/event-schemas/math_game_event_taxonomy.md",
        "event-taxonomy",
        "data-team",
        "Math Game Event Taxonomy",
    ),

    # ── knowledge/game-design ────────────────────────────────────────────────
    (
        "project_math_game_product.md",
        "knowledge/game-design/product.md",
        "design-doc",
        "game-team",
        "Math Game — Product",
    ),
    (
        "project_math_game_world.md",
        "knowledge/game-design/world.md",
        "design-doc",
        "game-team",
        "Math Game — World & Progression",
    ),
    (
        "project_math_game_pets.md",
        "knowledge/game-design/pets.md",
        "design-doc",
        "game-team",
        "Math Game — Pets",
    ),
    (
        "project_math_game_combat.md",
        "knowledge/game-design/combat.md",
        "design-doc",
        "game-team",
        "Math Game — Combat",
    ),
    (
        "project_math_game_economy.md",
        "knowledge/game-design/economy.md",
        "design-doc",
        "game-team",
        "Math Game — Economy",
    ),
    (
        "project_math_game_activities.md",
        "knowledge/game-design/activities.md",
        "design-doc",
        "game-team",
        "Math Game — Activities",
    ),
    (
        "project_math_game_analytics_taxonomy.md",
        "knowledge/game-design/analytics_taxonomy.md",
        "analytics-taxonomy",
        "data-team",
        "Math Game — Analytics Taxonomy",
    ),
    (
        "project_math_game_data_quality.md",
        "knowledge/game-design/data_quality.md",
        "data-quality",
        "data-team",
        "Math Game — Data Quality",
    ),
    (
        "project_math_game_corrections_and_ambiguities.md",
        "knowledge/game-design/corrections.md",
        "corrections",
        "data-team",
        "Math Game — Corrections & Ambiguities",
    ),

    # ── knowledge/session-profiles ───────────────────────────────────────────
    (
        "project_math_game_sessions.md",
        "knowledge/session-profiles/sessions.md",
        "design-doc",
        "game-team",
        "Math Game — Sessions",
    ),
    (
        "artifact_session_profile_2026-03-16.md",
        "knowledge/session-profiles/2026-03-16_balanced_sample.md",
        "session-profile",
        "data-team",
        "Session Profile — 2026-03-16 Balanced Sample",
    ),

    # ── knowledge/data-pipeline ──────────────────────────────────────────────
    (
        "artifact_math_game_inventory.md",
        "knowledge/data-pipeline/math_game_inventory.md",
        "models-inventory",
        "data-team",
        "Math Game — Models Inventory (full)",
    ),
    (
        "artifact_game_lineage.md",
        "knowledge/data-pipeline/lineage_full.md",
        "lineage",
        "data-team",
        "Game Models — Full Lineage",
    ),
    (
        "project_game_lineage.md",
        "knowledge/data-pipeline/lineage.md",
        "lineage",
        "data-team",
        "Game Models — Curated Lineage",
    ),
    (
        "project_game_models_inventory.md",
        "knowledge/data-pipeline/models_inventory.md",
        "models-inventory",
        "data-team",
        "Game Models — Inventory (curated)",
    ),
    (
        "project_game_dags.md",
        "knowledge/data-pipeline/game_dags.md",
        "dag-inventory",
        "data-team",
        "Game DAGs",
    ),
    (
        "project_segment_math_game_prod.md",
        "knowledge/data-pipeline/segment_math_game_prod.md",
        "data-source",
        "data-team",
        "segment_math_game_prod (Hub)",
    ),
    (
        "project_canonical_fact_dim.md",
        "knowledge/data-pipeline/fact_dim_coverage.md",
        "fact-dim-coverage",
        "data-team",
        "Canonical Fact/Dim Coverage",
    ),

    # ── knowledge/dippr-platform ─────────────────────────────────────────────
    (
        "project_dippr_overview.md",
        "knowledge/dippr-platform/overview.md",
        "platform-overview",
        "data-platform-team",
        "dippr Platform Overview",
    ),
    (
        "project_dbt_macros.md",
        "knowledge/dippr-platform/dbt_macros.md",
        "dbt-macros",
        "data-platform-team",
        "dippr — Custom dbt Macros",
    ),
    (
        "project_dag_patterns.md",
        "knowledge/dippr-platform/dag_patterns.md",
        "dag-patterns",
        "data-platform-team",
        "dippr — DAG Patterns",
    ),
    (
        "project_devspace_workflow.md",
        "knowledge/dippr-platform/devspace_workflow.md",
        "devspace-workflow",
        "data-platform-team",
        "dippr — Devspace Workflow",
    ),
    (
        "project_utils_modules.md",
        "knowledge/dippr-platform/utils_modules.md",
        "utils-modules",
        "data-platform-team",
        "dippr — utils Modules",
    ),

    # ── knowledge/_meta ──────────────────────────────────────────────────────
    (
        "meta_memory_system.md",
        "knowledge/_meta/kb_structure_legacy.md",
        "kb-structure-legacy",
        "data-team",
        "kb Structure (legacy from personal memory system; rewrite for kb-game)",
    ),
    (
        "meta_eval_system.md",
        "knowledge/_meta/eval_system_legacy.md",
        "eval-system-legacy",
        "data-team",
        "Eval System (legacy from personal memory system; rewrite for kb-game)",
    ),
    (
        "meta_skill_development_methodology.md",
        "knowledge/_meta/skill_development_methodology.md",
        "skill-methodology",
        "data-team",
        "Skill Development Methodology",
    ),
    (
        "project_authoring_gaps.md",
        "knowledge/_meta/authoring_gaps.md",
        "authoring-gaps",
        "data-team",
        "Authoring Gaps — Drafting Templates",
    ),
]

_FM = re.compile(r"^---\n(.*?)\n---\n(.*)$", re.DOTALL)


def parse_old_frontmatter(text: str) -> tuple[dict, str]:
    m = _FM.match(text)
    if not m:
        return {}, text
    front, body = m.group(1), m.group(2)
    fm: dict = {}
    for line in front.splitlines():
        if ":" not in line or line.startswith("  "):
            continue
        k, _, v = line.partition(":")
        fm[k.strip()] = v.strip()
    return fm, body


def _yaml_escape(s: str) -> str:
    if any(ch in s for ch in ":#") or s.startswith(("'", '"', "-", "[", "{")):
        return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'
    return s


def build_new_frontmatter(
    *,
    title: str,
    type_: str,
    owner: str,
    last_modified: str,
    status: str,
    imported_from: str,
    as_of_at_import: str,
) -> str:
    lines = [
        "---",
        f"title: {_yaml_escape(title)}",
        f"type: {type_}",
        f"owner: {owner}",
        f"last_modified: {last_modified}",
        f"status: {status}",
        f"imported_from: {imported_from}",
    ]
    if as_of_at_import:
        lines.append(f"as_of_at_import: {as_of_at_import}")
    lines.append("related:")
    lines.append("---")
    return "\n".join(lines) + "\n"


def main() -> None:
    written = 0
    missing: list[str] = []
    for source, target, type_, owner, title_override in MIGRATIONS:
        src = MEMORY / source
        if not src.exists():
            missing.append(source)
            continue
        text = src.read_text(encoding="utf-8")
        old_fm, body = parse_old_frontmatter(text)
        as_of = old_fm.get("as_of", "")

        new_fm = build_new_frontmatter(
            title=title_override,
            type_=type_,
            owner=owner,
            last_modified=TODAY,
            status="legacy-import",
            imported_from=f"memory/{source}",
            as_of_at_import=as_of,
        )

        target_path = ROOT / target
        target_path.parent.mkdir(parents=True, exist_ok=True)
        target_path.write_text(new_fm + body, encoding="utf-8")
        print(f"wrote {target}")
        written += 1

    print()
    print(f"migrated {written}/{len(MIGRATIONS)} files")
    if missing:
        print(f"MISSING: {missing}")


if __name__ == "__main__":
    main()
