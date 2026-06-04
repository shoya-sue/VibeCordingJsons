#!/bin/bash
# Codex Stop hook: append a compact session marker to the Obsidian session log.
# This is intentionally Codex-only and does not call Claude Code/ECC hooks.

set +e

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
YEAR_MONTH=$(date +%Y-%m)
VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"
DIR="$VAULT/10_daily/sessions"
FILE="$DIR/$YEAR_MONTH.md"

mkdir -p "$DIR" 2>/dev/null || exit 0

PROJECT=$(basename "$(pwd)" 2>/dev/null || echo "unknown")
BRANCH=$(git branch --show-current 2>/dev/null || echo "N/A")
PROJECT_LINK="${OBSIDIAN_PROJECT_LINK_PREFIX:-20_projects}/${PROJECT}"

if [ ! -f "$FILE" ]; then
  printf -- "---\ntype: daily\ncreated: %s\ntags:\n  - daily\n  - codex\n  - session-log\n---\n\n# Codex セッションログ - %s\n\n" \
    "$DATE" "$YEAR_MONTH" > "$FILE" 2>/dev/null || exit 0
fi

printf -- "- %s %s | [[%s|%s]] | codex | branch: \`%s\`\n" \
  "$DATE" "$TIME" "$PROJECT_LINK" "$PROJECT" "$BRANCH" >> "$FILE" 2>/dev/null || true
exit 0
