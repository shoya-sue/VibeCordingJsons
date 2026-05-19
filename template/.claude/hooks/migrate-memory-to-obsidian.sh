#!/bin/bash
# One-shot migration: move all project memory dirs to Obsidian and symlink them back.
# Usage: bash migrate-memory-to-obsidian.sh [--dry-run]

DRY_RUN=0
[[ "$1" == "--dry-run" ]] && DRY_RUN=1

VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"
OBS_BASE="$VAULT/90_artifacts/claude-code/memory"
USER_NAME="${USER:-$(basename "$HOME")}"

success=0
skipped=0
failed=0

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

while IFS= read -r mem_dir; do
  hash_name=$(basename "$(dirname "$mem_dir")")
  project_name=$(derive_project_name "$hash_name")
  obs_dir="$OBS_BASE/$project_name"

  echo "→ $project_name"

  if [[ -L "$mem_dir" ]]; then
    echo "  [SKIP] already a symlink"
    ((skipped++))
    continue
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "  dst: $obs_dir"
    echo "  [DRY] would migrate $(ls "$mem_dir"/*.md 2>/dev/null | wc -l | tr -d ' ') files"
    continue
  fi

  mkdir -p "$obs_dir" || { echo "  [ERROR] mkdir failed"; ((failed++)); continue; }

  for f in "$mem_dir"/*.md; do
    [[ -f "$f" ]] || continue
    cp "$f" "$obs_dir/$(basename "$f")"
  done

  rm -rf "$mem_dir"
  ln -s "$obs_dir" "$mem_dir"
  echo "  [OK] $(ls "$obs_dir"/*.md 2>/dev/null | wc -l | tr -d ' ') files → symlinked"
  ((success++))

done < <(find "$HOME/.claude/projects" -type d -name "memory" 2>/dev/null | while read d; do
  [ "$(ls "$d"/*.md 2>/dev/null | wc -l)" -gt 0 ] && echo "$d"
done)

echo ""
echo "Done: $success migrated, $skipped already symlinked, $failed failed"
