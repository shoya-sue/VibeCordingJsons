#!/bin/bash
# PostToolUse: Write/Edit to memory/*.md → mirror to Obsidian (fallback for non-symlinked projects)
FILE=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty' 2>/dev/null)

[[ -z "$FILE" ]] && exit 0
[[ "$FILE" != *"/memory/"* ]] && exit 0
[[ "$FILE" != *.md ]] && exit 0
[[ "$(basename "$FILE")" == "MEMORY.md" ]] && exit 0

# If the memory dir is already a symlink to Obsidian, write already went there
MEM_DIR="$(dirname "$FILE")"
[[ -L "$MEM_DIR" ]] && exit 0

VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"
DEST="$VAULT/Claude Code/memory"
mkdir -p "$DEST" 2>/dev/null || true
cp "$FILE" "$DEST/$(basename "$FILE")" 2>/dev/null || true
