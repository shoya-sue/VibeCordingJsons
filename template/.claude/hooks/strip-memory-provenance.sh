#!/bin/bash
# Stop hook: strip originSessionId frontmatter from auto-memory files.
# Rationale: Claude Code's auto-memory linter injects `originSessionId` into
# frontmatter on every write, violating the `feedback-no-import-provenance` rule.
# Run at session end to clean up before the weekly audit picks it up.
#
# Targets:
#   - $HOME/.claude/projects/*/memory/*.md  (auto-memory source, symlinked)
#   - $VAULT/30_knowledge/claude-code/memory/Public/*.md  (manual memory mirror)
#   - $VAULT/90_artifacts/claude-code/memory/**/*.md  (legacy sync target)

set -uo pipefail

VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"

strip_in_dir() {
    local dir="$1"
    [[ ! -d "$dir" ]] && return 0
    # Remove any "  originSessionId: ..." line that lives inside frontmatter blocks.
    # Conservative awk: only inside the first --- ... --- block of each file.
    find "$dir" -type f -name "*.md" 2>/dev/null | while IFS= read -r f; do
        awk '
            BEGIN { in_fm=0; seen_open=0 }
            /^---$/ {
                if (!seen_open) { in_fm=1; seen_open=1; print; next }
                else if (in_fm) { in_fm=0; print; next }
            }
            in_fm && /^[[:space:]]*originSessionId[[:space:]]*:/ { next }
            { print }
        ' "$f" > "${f}.tmp" && mv "${f}.tmp" "$f"
    done
}

strip_in_dir "$HOME/.claude/projects/-Users-shoya-sue-Public/memory"
strip_in_dir "$VAULT/30_knowledge/claude-code/memory/Public"
strip_in_dir "$VAULT/90_artifacts/claude-code/memory"

exit 0
