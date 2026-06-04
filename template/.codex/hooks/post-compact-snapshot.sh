#!/bin/bash
# Codex PostCompact hook: record a compaction marker in Obsidian.
# Fail-open by design; hook failures must not interrupt Codex turns.

set +e

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
YEAR_MONTH=$(date +%Y-%m)
VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"
DIR="$VAULT/10_daily/sessions"
FILE="$DIR/$YEAR_MONTH.md"

mkdir -p "$DIR" 2>/dev/null || exit 0

if [ ! -f "$FILE" ]; then
  printf -- "---\ntype: daily\ncreated: %s\ntags:\n  - daily\n  - codex\n  - session-log\n---\n\n# Codex セッションログ - %s\n\n" \
    "$DATE" "$YEAR_MONTH" > "$FILE" 2>/dev/null || exit 0
fi

printf -- "\n---\n**[Codex compaction at %s]** - Context was summarized\n\n" "$TIME" >> "$FILE" 2>/dev/null || true
exit 0
