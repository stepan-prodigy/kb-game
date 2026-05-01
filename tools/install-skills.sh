#!/usr/bin/env bash
# Install kb-game skills into ~/.claude/skills via symlinks.
#
# Each skill is a directory under kb-game/skills/<name>/. This script creates
# a symlink at ~/.claude/skills/<name> -> kb-game/skills/<name>, so Claude
# Code finds the SKILL.md when it walks the skills directory at startup.
#
# Idempotent: safe to re-run after `git pull`. Existing symlinks are
# replaced; non-symlink files at the target path are refused (safety).
#
# Default scope: only `ddd-drafting`. The operator skills (arc-review,
# kb-refresh, kb-eval) are useful for maintainers of kb-game itself, not
# for users consuming it. Pass --all to install them too.
#
# Usage:
#   tools/install-skills.sh                       # install ddd-drafting
#   tools/install-skills.sh ddd-drafting          # explicit single
#   tools/install-skills.sh ddd-drafting kb-eval  # multiple by name
#   tools/install-skills.sh --all                 # all skills under skills/
#   tools/install-skills.sh --uninstall           # remove kb-game symlinks
#
# After install: restart Claude Code so the skills get registered.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="${REPO_ROOT}/skills"
TARGET_DIR="${HOME}/.claude/skills"

DEFAULT_SKILLS=(ddd-drafting)

# --- arg parsing ---
mode="install"
skills=()
for arg in "$@"; do
    case "$arg" in
        --uninstall) mode="uninstall" ;;
        --all)
            for d in "$SKILLS_SRC"/*/; do
                [ -d "$d" ] || continue
                skills+=("$(basename "$d")")
            done
            ;;
        --help|-h)
            sed -n '2,22p' "$0"
            exit 0
            ;;
        --*)
            echo "unknown flag: $arg" >&2
            exit 1
            ;;
        *) skills+=("$arg") ;;
    esac
done

if [ ${#skills[@]} -eq 0 ]; then
    skills=("${DEFAULT_SKILLS[@]}")
fi

# dedupe
skills=($(printf '%s\n' "${skills[@]}" | awk '!seen[$0]++'))

mkdir -p "$TARGET_DIR"

count=0

if [ "$mode" = "uninstall" ]; then
    # Remove only symlinks pointing into our SKILLS_SRC; leave other user skills alone.
    for link in "$TARGET_DIR"/*; do
        [ -L "$link" ] || continue
        target=$(readlink "$link")
        case "$target" in
            "$SKILLS_SRC"/*)
                rm "$link"
                echo "removed: $link"
                count=$((count + 1))
                ;;
        esac
    done
    echo
    echo "$count kb-game skill symlink(s) removed."
    exit 0
fi

# install mode
for skill in "${skills[@]}"; do
    src="$SKILLS_SRC/$skill"
    dst="$TARGET_DIR/$skill"

    if [ ! -d "$src" ]; then
        echo "skip: $skill — not found at $src" >&2
        continue
    fi

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "skip: $dst exists and is not a symlink (refusing to clobber)" >&2
        continue
    fi

    [ -L "$dst" ] && rm "$dst"
    ln -s "$src" "$dst"
    echo "installed: $dst -> $src"
    count=$((count + 1))
done

echo
echo "$count skill(s) installed at $TARGET_DIR/."
echo "Restart Claude Code for the skills to register."
