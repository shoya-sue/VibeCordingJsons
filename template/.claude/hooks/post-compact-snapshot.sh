#!/bin/bash
# PostCompact hook: write a marker into Obsidian Sessions log when context
# compaction occurs, so long sessions in 1M-context mode are still traceable
# in the second-brain knowledge graph.
# Fails silently; never blocks Claude.

set +e

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
YEAR_MONTH=$(date +%Y-%m)
VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"
DIR="$VAULT/Claude Code/Sessions"
FILE="$DIR/$YEAR_MONTH.md"

mkdir -p "$DIR" 2>/dev/null || true

if [ ! -f "$FILE" ]; then
  printf -- "---\ncreated: %s\ntags: [claude-code, session-log]\n---\n\n# Claude Code セッションログ - %s\n\n" \
    "$DATE" "$YEAR_MONTH" > "$FILE"
fi

printf -- "\n---\n**[Compaction occurred at %s]** - Context was summarized\n\n" "$TIME" >> "$FILE"
exit 0
