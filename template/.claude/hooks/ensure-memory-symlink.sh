#!/bin/bash
# SessionStart hook: ensure the current project's auto-memory dir is symlinked
# to the user's Obsidian vault. New projects get symlinked on first session
# open — no manual migration needed.
# Fails silently; never blocks Claude.

set +e

VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"
OBS_BASE="$VAULT/90_artifacts/claude-code/memory"
USER_NAME="${USER:-$(basename "$HOME")}"

CWD="${PWD:-$(pwd)}"
[[ -z "$CWD" ]] && exit 0

# Claude Code encodes project paths by replacing / with -.
HASH="${CWD//\//-}"
MEM_DIR="$HOME/.claude/projects/${HASH}/memory"

# Already a symlink → nothing to do.
[[ -L "$MEM_DIR" ]] && exit 0

# Derive a short project name by stripping common path prefixes.
derive_project_name() {
  local hash="$1"
  local name="$hash"
  name="${name#-Users-$USER_NAME-Public-$USER_NAME-}"
  if [[ "$name" == "$hash" ]]; then
    name="${name#-Users-$USER_NAME-Public-}"
  fi
  if [[ "$name" == "$hash" ]]; then
    name="${name#-Users-$USER_NAME-Desktop-}"
  fi
  if [[ "$name" == "$hash" ]]; then
    name="${name#-Users-$USER_NAME-}"
  fi
  echo "$name"
}

PROJECT_NAME=$(derive_project_name "$HASH")
OBS_DIR="$OBS_BASE/$PROJECT_NAME"

mkdir -p "$OBS_DIR" 2>/dev/null || exit 0

# Migrate existing files if memory dir already has content.
if [[ -d "$MEM_DIR" && ! -L "$MEM_DIR" ]]; then
  for f in "$MEM_DIR"/*.md; do
    [[ -f "$f" ]] && cp "$f" "$OBS_DIR/$(basename "$f")"
  done
  rm -rf "$MEM_DIR"
fi

mkdir -p "$(dirname "$MEM_DIR")" 2>/dev/null
ln -s "$OBS_DIR" "$MEM_DIR" 2>/dev/null || true
exit 0
