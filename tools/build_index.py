# /// script
# requires-python = ">=3.11"
# ///
"""Build INDEX.md (categorized, dated, summarized) and pages.json for knowledge/.

Run from anywhere — paths are resolved relative to this file.

  uv run tools/build_index.py
"""

from __future__ import annotations

import json
import re
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
KB = ROOT / "knowledge"

# ---------------------------------------------------------------------------
# frontmatter + body parsing
# ---------------------------------------------------------------------------

_FM = re.compile(r"^---\n(.*?)\n---\n(.*)$", re.DOTALL)


def parse_md(path: Path) -> tuple[dict, str]:
    text = path.read_text(encoding="utf-8")
    m = _FM.match(text)
    if not m:
        return {}, text
    front, body = m.group(1), m.group(2)
    fm: dict = {}
    cur_list_key = None
    for line in front.splitlines():
        if not line.strip():
            continue
        if line.startswith("  - ") and cur_list_key:
            fm[cur_list_key].append(_yaml_val(line[4:].strip()))
            continue
        if ":" in line:
            k, _, v = line.partition(":")
            k = k.strip()
            v = v.strip()
            if v == "":
                fm[k] = []
                cur_list_key = k
            else:
                fm[k] = _yaml_val(v)
                cur_list_key = None
    return fm, body


def _yaml_val(s: str) -> str:
    if s.startswith('"') and s.endswith('"'):
        return s[1:-1].replace('\\"', '"').replace("\\\\", "\\")
    return s


# ---------------------------------------------------------------------------
# summary extraction
# ---------------------------------------------------------------------------

_ANCHOR_ONLY = re.compile(r"^\s*-\s*\[.*?\]\(#[^)]*\)\s*$")
_HEADING = re.compile(r"^#{1,6}\s")
_LIST_ITEM = re.compile(r"^\s*(-|\*|\d+\.)\s+")
_INLINE_LINK = re.compile(r"\[([^\]]+)\]\([^)]+\)")
_MD_FORMATTING = re.compile(r"[*_`~]+")


def extract_summary(body: str, max_chars: int = 220) -> str:
    """First paragraph of real prose; skip title, TOC, tables, blockquotes, code."""
    lines = body.splitlines()
    i = 0
    while i < len(lines) and (lines[i].startswith("# ") or lines[i].strip() == ""):
        i += 1
    while i < len(lines) and (_ANCHOR_ONLY.match(lines[i]) or lines[i].strip() == ""):
        i += 1

    in_fence = False
    fallback_bullet: str | None = None
    paragraph: list[str] = []
    j = i
    while j < len(lines):
        s = lines[j].rstrip()
        if s.startswith("```"):
            in_fence = not in_fence
            j += 1
            continue
        if in_fence:
            j += 1
            continue
        if not s:
            if paragraph:
                break
            j += 1
            continue
        if _HEADING.match(s) or s.startswith(("|", ">", "    ")):
            if paragraph:
                break
            j += 1
            continue
        if _LIST_ITEM.match(s):
            if paragraph:
                break
            if fallback_bullet is None:
                fallback_bullet = _LIST_ITEM.sub("", s)
            j += 1
            continue
        paragraph.append(s)
        j += 1

    if not paragraph and fallback_bullet:
        paragraph = [fallback_bullet]

    text = " ".join(paragraph).strip()
    text = _INLINE_LINK.sub(r"\1", text)
    text = _MD_FORMATTING.sub("", text)
    text = re.sub(r"\s+", " ", text)
    if len(text) > max_chars:
        text = text[: max_chars - 1].rsplit(" ", 1)[0] + "…"
    return text


# ---------------------------------------------------------------------------
# date parsing
# ---------------------------------------------------------------------------


def parse_date(s: str) -> datetime | None:
    if not s:
        return None
    for fmt in ("%Y-%m-%d", "%b %d, %Y", "%B %d, %Y"):
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            pass
    return None


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

_META_FILES = {"README.md", "INDEX.md", "CLAUDE.md"}


def main():
    pages = []
    for p in sorted(KB.rglob("*.md")):
        rel = p.relative_to(KB).as_posix()
        if p.name in _META_FILES:
            continue
        fm, body = parse_md(p)

        related = fm.get("related") or []
        if not isinstance(related, list):
            related = [related]

        title = fm.get("title", p.stem)
        # Category derived from the first folder under knowledge/ (e.g. event-schemas,
        # game-design, session-profiles). Pages at the knowledge/ root land in "(root)".
        parts = rel.split("/")
        category = parts[0] if len(parts) > 1 else "(root)"

        page = {
            "file": rel,
            "title": title,
            "type": fm.get("type", ""),
            "category": category,
            "owner": fm.get("owner", ""),
            "last_modified": fm.get("last_modified", ""),
            "status": fm.get("status", ""),
            "related": related,
            "summary": extract_summary(body),
        }
        d = parse_date(page["last_modified"])
        page["_modified_iso"] = d.date().isoformat() if d else ""
        pages.append(page)

    out_json = [{k: v for k, v in p.items() if not k.startswith("_")} for p in pages]
    (KB / "pages.json").write_text(
        json.dumps(out_json, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

    categories: dict[str, list[dict]] = {}
    for p in pages:
        categories.setdefault(p["category"], []).append(p)
    types: dict[str, list[dict]] = {}
    for p in pages:
        if p["type"]:
            types.setdefault(p["type"], []).append(p)

    lines = [
        "# kb-game — Knowledge Index",
        "",
        f"Indexed {len(pages)} pages across {len(categories)} top-level categories.",
        "",
        "Structured data: [pages.json](pages.json).",
        "",
        "## Contents",
        "",
    ]

    def cat_sort(k: str) -> tuple[int, str]:
        return (0 if k == "(root)" else 1, k.lower())

    cat_order = sorted(categories.keys(), key=cat_sort)
    for cat in cat_order:
        slug = re.sub(r"[^a-z0-9]+", "-", cat.lower()).strip("-")
        lines.append(f"- [{cat}](#{slug}) ({len(categories[cat])})")
    lines.append("")

    if types:
        lines.append("## By type")
        lines.append("")
        for t in sorted(types.keys(), key=str.lower):
            slug = re.sub(r"[^a-z0-9]+", "-", t.lower()).strip("-")
            lines.append(f"- **{t}** ({len(types[t])}) — see [#type-{slug}](#type-{slug})")
        lines.append("")

    dated = [p for p in pages if p["_modified_iso"]]
    dated.sort(key=lambda p: p["_modified_iso"], reverse=True)
    if dated:
        lines.append("## Recently modified")
        lines.append("")
        for p in dated[:25]:
            t = f" · {p['type']}" if p["type"] else ""
            lines.append(
                f"- {p['_modified_iso']} — [{p['title']}]({p['file']}) "
                f"_{p['category']}{t}_"
            )
        lines.append("")

    for cat in cat_order:
        pages_in = sorted(categories[cat], key=lambda p: p["title"].lower())
        slug = re.sub(r"[^a-z0-9]+", "-", cat.lower()).strip("-")
        lines.append(f'<a id="{slug}"></a>')
        lines.append(f"## {cat}")
        lines.append("")
        for p in pages_in:
            bits = [f"**[{p['title']}]({p['file']})**"]
            meta = []
            if p["type"]:
                meta.append(p["type"])
            if p["status"]:
                meta.append(p["status"])
            if p["_modified_iso"]:
                meta.append(p["_modified_iso"])
            if p["owner"]:
                meta.append(p["owner"])
            if meta:
                bits.append(" · ".join(meta))
            lines.append("- " + " — ".join(bits))
            if p["summary"]:
                lines.append(f"  {p['summary']}")
        lines.append("")

    if types:
        for t in sorted(types.keys(), key=str.lower):
            slug = re.sub(r"[^a-z0-9]+", "-", t.lower()).strip("-")
            items = sorted(
                types[t],
                key=lambda p: (p["_modified_iso"] or "", p["title"].lower()),
                reverse=True,
            )
            lines.append(f'<a id="type-{slug}"></a>')
            lines.append(f"## By type: {t} ({len(items)})")
            lines.append("")
            for p in items:
                date = p["_modified_iso"] or "—"
                lines.append(f"- {date} — [{p['title']}]({p['file']})")
            lines.append("")

    (KB / "INDEX.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {KB/'INDEX.md'} and {KB/'pages.json'}")
    print(f"categories: {', '.join(cat_order)}")


if __name__ == "__main__":
    main()
