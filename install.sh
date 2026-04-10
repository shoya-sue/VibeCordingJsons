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

# Post-process full pattern settings.json: expand ${HOME} and detect ECC version
if [[ "$PATTERN" == "full" && -f "$TARGET/.claude/settings.json" ]]; then
  # Expand ${HOME} literal to actual home directory
  sed -i.bak "s|\${HOME}|${HOME}|g" "$TARGET/.claude/settings.json"

  # Auto-detect installed ECC version and substitute
  ECC_CACHE="$HOME/.claude/plugins/cache/everything-claude-code/everything-claude-code"
  if [[ -d "$ECC_CACHE" ]]; then
    ECC_LATEST=$(ls -1 "$ECC_CACHE" 2>/dev/null | sort -V | tail -1)
    if [[ -n "$ECC_LATEST" ]]; then
      # Replace any hardcoded ECC version in the path with the detected version
      sed -i.bak "s|/everything-claude-code/[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*/|/everything-claude-code/${ECC_LATEST}/|g" "$TARGET/.claude/settings.json"
      echo "ECC version: ${ECC_LATEST} (auto-detected)"
    fi
  fi
  rm -f "$TARGET/.claude/settings.json.bak"
fi

# ─── Copilot CLI symlink bridge ───────────────────────────────────────────────
# グローバルインストール時のみ: ~/.claude/ のルール・スキルを ~/.github/ にシンボリックリンク
# Claude Code が使えない場合でも Copilot CLI が同一設定・メモリを参照できるようにする
if [[ "$TARGET" == "$HOME" ]]; then
  CLAUDE_HOME="$HOME/.claude"
  GITHUB_HOME="$HOME/.github"

  echo "Setting up Copilot CLI symlinks..."

  # 1. 共有スキル: ~/.github/skills/<name> → ~/.claude/skills/<name>
  SHARED_SKILLS=(create-issue dependency-audit explain-code fix-issue generate-changelog review-pr)
  for skill in "${SHARED_SKILLS[@]}"; do
    src="$CLAUDE_HOME/skills/$skill"
    dst="$GITHUB_HOME/skills/$skill"
    if [[ -d "$src" ]]; then
      rm -rf "$dst"
      ln -sfn "$src" "$dst"
      echo "  skill: $dst -> $src"
    fi
  done

  # 2. ルール → ~/.github/instructions/ (ディレクトリシンボリックリンク)
  mkdir -p "$GITHUB_HOME/instructions"

  # 共通ルールファイル (ファイル単位)
  for rule_file in subagent-delegation.md team-coordination.md; do
    src="$CLAUDE_HOME/rules/$rule_file"
    dst="$GITHUB_HOME/instructions/$rule_file"
    if [[ -f "$src" ]]; then
      rm -f "$dst"
      ln -sf "$src" "$dst"
      echo "  rule: $dst -> $src"
    fi
  done

  # ECC 共通ルール + 言語別ルール (ディレクトリ単位)
  # bash 3.2 (macOS) では declare -A 非対応のため parallel 配列で対応
  RULE_LINK_NAMES=(claude-common claude-lang-golang claude-lang-typescript claude-lang-python claude-lang-rust claude-lang-java claude-lang-kotlin claude-lang-cpp claude-lang-php claude-lang-swift)
  RULE_LINK_SRCS=(
    "$CLAUDE_HOME/rules/ecc/common"
    "$CLAUDE_HOME/rules/ecc/golang"
    "$CLAUDE_HOME/rules/ecc/typescript"
    "$CLAUDE_HOME/rules/ecc/python"
    "$CLAUDE_HOME/rules/ecc/rust"
    "$CLAUDE_HOME/rules/ecc/java"
    "$CLAUDE_HOME/rules/ecc/kotlin"
    "$CLAUDE_HOME/rules/ecc/cpp"
    "$CLAUDE_HOME/rules/ecc/php"
    "$CLAUDE_HOME/rules/ecc/swift"
  )
  for i in "${!RULE_LINK_NAMES[@]}"; do
    link_name="${RULE_LINK_NAMES[$i]}"
    src="${RULE_LINK_SRCS[$i]}"
    dst="$GITHUB_HOME/instructions/$link_name"
    if [[ -d "$src" ]]; then
      rm -rf "$dst"
      ln -sfn "$src" "$dst"
      echo "  rules: $dst -> $src"
    fi
  done

  # 3. ~/.zshrc に precmd フックと copilot-sync-memory 関数を追加 (冪等)
  ZSHRC="$HOME/.zshrc"
  MARKER="# VibeCording: copilot-sync"
  if ! grep -qF "$MARKER" "$ZSHRC" 2>/dev/null; then
    cat >> "$ZSHRC" <<'ZSHRC_BLOCK'

# VibeCording: copilot-sync
# プロジェクト切替時に COPILOT_CUSTOM_INSTRUCTIONS_DIRS を自動更新
_update_copilot_dirs() {
  local base="$HOME/.github/instructions"
  if [[ -d "$PWD/.github/claude-memory" ]]; then
    export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="${base}:${PWD}/.github/claude-memory"
  else
    export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="$base"
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _update_copilot_dirs

# プロジェクトの Claude メモリを Copilot CLI にリンクするコマンド
# 使い方: copilot-sync-memory [project_path]
copilot-sync-memory() {
  local project_path="${1:-$PWD}"
  local hash
  hash=$(echo "$project_path" | sed 's|/|-|g; s|\.|-|g')
  local memory_dir="$HOME/.claude/projects/${hash}/memory"
  if [[ ! -d "$memory_dir" ]]; then
    echo "Claude memory not found: $memory_dir"
    echo "Available projects (matching basename):"
    ls "$HOME/.claude/projects/" | grep "$(basename "$project_path")" || echo "  (none matched)"
    return 1
  fi
  mkdir -p "${project_path}/.github"
  local link="${project_path}/.github/claude-memory"
  [[ -L "$link" ]] && rm "$link"
  ln -s "$memory_dir" "$link"
  echo "Linked: $link"
  echo "  -> $memory_dir"
  local gitignore="${project_path}/.gitignore"
  if [[ -f "$gitignore" ]] && ! grep -qF '.github/claude-memory' "$gitignore"; then
    echo '.github/claude-memory' >> "$gitignore"
    echo "Added .github/claude-memory to .gitignore"
  fi
}
ZSHRC_BLOCK
    echo "  zshrc: Added copilot-sync to $ZSHRC"
  fi

  echo "Copilot CLI symlink bridge complete."
  echo ""
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
