#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATTERN="${1:-}"
TARGET="${2:-.}"

usage() {
  cat <<'USAGE'
Usage: ./install.sh <pattern> [target]

Patterns:
  minimal    Read-only (for code review and exploration)
  standard   Everyday development (recommended)
  full       All features (Agent Teams / Hooks / Skills / Agents)

Target:
  .          Install to current project (default)
  ~          Global install to home directory (recommended for personal use)

Examples:
  ./install.sh full ~                # Global settings (auto-applies to all projects)
  ./install.sh standard .            # Install to current directory
  ./install.sh standard ~/my-project # Install to specified project

USAGE
  exit 1
}

if [[ -z "$PATTERN" ]]; then
  usage
fi

if [[ ! -d "$SCRIPT_DIR/$PATTERN" ]]; then
  echo "Error: Pattern '$PATTERN' not found."
  echo "Choose: minimal, standard, full"
  exit 1
fi

# Expand ~ in TARGET
TARGET="${TARGET/#\~/$HOME}"

echo "Pattern:  $PATTERN"
echo "Target:   $TARGET"
echo ""

# Copy .claude/ directory
if [[ -d "$SCRIPT_DIR/$PATTERN/.claude" ]]; then
  mkdir -p "$TARGET/.claude"
  cp -r "$SCRIPT_DIR/$PATTERN/.claude/"* "$TARGET/.claude/" 2>/dev/null || true

  # Copy hidden files in .claude/ (settings.local.json etc)
  for f in "$SCRIPT_DIR/$PATTERN/.claude/".*.json; do
    [[ -f "$f" ]] && cp "$f" "$TARGET/.claude/"
  done

  # Copy subdirectories (skills, agents, rules)
  for dir in skills agents rules; do
    if [[ -d "$SCRIPT_DIR/$PATTERN/.claude/$dir" ]]; then
      cp -r "$SCRIPT_DIR/$PATTERN/.claude/$dir" "$TARGET/.claude/"
    fi
  done
fi

# Copy .github/ directory (Copilot CLI: instructions, skills, agents)
if [[ -d "$SCRIPT_DIR/$PATTERN/.github" ]]; then
  mkdir -p "$TARGET/.github"
  cp -r "$SCRIPT_DIR/$PATTERN/.github/"* "$TARGET/.github/" 2>/dev/null || true

  # Copy subdirectories (skills, agents)
  for dir in skills agents; do
    if [[ -d "$SCRIPT_DIR/$PATTERN/.github/$dir" ]]; then
      cp -r "$SCRIPT_DIR/$PATTERN/.github/$dir" "$TARGET/.github/"
    fi
  done
fi

# Copy root-level files
for file in .mcp.json CLAUDE.md CLAUDE.local.md AGENTS.md; do
  if [[ -f "$SCRIPT_DIR/$PATTERN/$file" ]]; then
    cp "$SCRIPT_DIR/$PATTERN/$file" "$TARGET/$file"
  fi
done

# Copy workspace file (skip for global install)
if [[ -f "$SCRIPT_DIR/$PATTERN/project.code-workspace" && "$TARGET" != "$HOME" ]]; then
  cp "$SCRIPT_DIR/$PATTERN/project.code-workspace" "$TARGET/project.code-workspace"
fi

# Add CLAUDE.local.md and settings.local.json to .gitignore if exists
if [[ -f "$TARGET/.gitignore" ]]; then
  for entry in "CLAUDE.local.md" ".claude/settings.local.json" ".claude/*.local.*"; do
    if ! grep -qF "$entry" "$TARGET/.gitignore" 2>/dev/null; then
      echo "$entry" >> "$TARGET/.gitignore"
    fi
  done
fi

echo "Installed files:"
echo ""

# List installed files
find "$TARGET/.claude" -type f 2>/dev/null | sed "s|$TARGET/||" | sort
find "$TARGET/.github" -type f 2>/dev/null | sed "s|$TARGET/||" | sort
[[ -f "$TARGET/.mcp.json" ]] && echo ".mcp.json"
[[ -f "$TARGET/CLAUDE.md" ]] && echo "CLAUDE.md"
[[ -f "$TARGET/CLAUDE.local.md" ]] && echo "CLAUDE.local.md"
[[ -f "$TARGET/AGENTS.md" ]] && echo "AGENTS.md"
[[ -f "$TARGET/project.code-workspace" ]] && echo "project.code-workspace"

echo ""
if [[ "$TARGET" == "$HOME" ]]; then
  echo "Done! Global install complete."
  echo "All projects will use these settings automatically."
  echo "Edit ~/.claude/settings.json and ~/CLAUDE.md to customize."
else
  echo "Done! Edit CLAUDE.md, settings.json, and project.code-workspace to match your project."
fi
