#!/bin/bash
# Write session end entry to Obsidian 90_artifacts/claude-code/sessions/YYYY-MM.md
# Called by Stop hook; runs quickly, no errors to block Claude

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
YEAR_MONTH=$(date +%Y-%m)
VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"
DIR="$VAULT/90_artifacts/claude-code/sessions"
FILE="$DIR/$YEAR_MONTH.md"

mkdir -p "$DIR" 2>/dev/null || true

PROJECT=$(basename "$(pwd)" 2>/dev/null || echo "unknown")
BRANCH=$(git branch --show-current 2>/dev/null || echo "N/A")

if [ ! -f "$FILE" ]; then
  printf -- "---\ncreated: %s\ntags: [claude-code, session-log]\n---\n\n# Claude Code セッションログ - %s\n\n" \
    "$DATE" "$YEAR_MONTH" > "$FILE"
fi

printf -- "- %s %s | [[20_projects/shoya-sue/%s|%s]] | branch: \`%s\`\n" \
  "$DATE" "$TIME" "$PROJECT" "$PROJECT" "$BRANCH" >> "$FILE"
