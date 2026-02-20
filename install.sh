#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PATTERN="${1:-}"
TARGET="${2:-.}"

usage() {
  cat <<'USAGE'
Usage: ./install.sh <pattern> [target]

Patterns:
  minimal    読み取り専用（コードレビュー・探索向け）
  standard   日常開発（推奨）
  full       全機能（Agent Teams / Sandbox / Hooks / Skills / Agents）

Target:
  .          現在のプロジェクトにインストール（デフォルト）
  ~          ホームディレクトリにグローバルインストール

Examples:
  ./install.sh standard              # カレントディレクトリにインストール
  ./install.sh full .                # カレントディレクトリにインストール
  ./install.sh standard ~/my-project # 指定プロジェクトにインストール
  ./install.sh full ~                # グローバル設定としてインストール

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

# Copy .copilot/ directory
if [[ -d "$SCRIPT_DIR/$PATTERN/.copilot" ]]; then
  mkdir -p "$TARGET/.copilot"
  cp -r "$SCRIPT_DIR/$PATTERN/.copilot/"* "$TARGET/.copilot/" 2>/dev/null || true

  # Copy hidden files in .copilot/
  for f in "$SCRIPT_DIR/$PATTERN/.copilot/".*; do
    [[ -f "$f" ]] && cp "$f" "$TARGET/.copilot/"
  done
fi

# Copy root-level files
for file in .mcp.json CLAUDE.md CLAUDE.local.md AGENTS.md; do
  if [[ -f "$SCRIPT_DIR/$PATTERN/$file" ]]; then
    cp "$SCRIPT_DIR/$PATTERN/$file" "$TARGET/$file"
  fi
done

# Add CLAUDE.local.md and settings.local.json to .gitignore if exists
if [[ -f "$TARGET/.gitignore" ]]; then
  for entry in "CLAUDE.local.md" ".claude/settings.local.json" ".claude/*.local.*" ".copilot/*.local.*"; do
    if ! grep -qF "$entry" "$TARGET/.gitignore" 2>/dev/null; then
      echo "$entry" >> "$TARGET/.gitignore"
    fi
  done
fi

echo "Installed files:"
echo ""

# List installed files
find "$TARGET/.claude" -type f 2>/dev/null | sed "s|$TARGET/||" | sort
find "$TARGET/.copilot" -type f 2>/dev/null | sed "s|$TARGET/||" | sort
[[ -f "$TARGET/.mcp.json" ]] && echo ".mcp.json"
[[ -f "$TARGET/CLAUDE.md" ]] && echo "CLAUDE.md"
[[ -f "$TARGET/CLAUDE.local.md" ]] && echo "CLAUDE.local.md"
[[ -f "$TARGET/AGENTS.md" ]] && echo "AGENTS.md"

echo ""
echo "Done! Edit CLAUDE.md and settings.json to match your project."
