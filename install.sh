#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$SCRIPT_DIR/template"
TARGET="${1:-$HOME}"

# Expand ~ in TARGET
TARGET="${TARGET/#\~/$HOME}"

if [[ ! -d "$TEMPLATE" ]]; then
  echo "Error: template/ directory not found in $SCRIPT_DIR"
  exit 1
fi

echo "Target: $TARGET"
echo ""

# Copy .claude/ directory
if [[ -d "$TEMPLATE/.claude" ]]; then
  mkdir -p "$TARGET/.claude"
  cp -r "$TEMPLATE/.claude/"* "$TARGET/.claude/" 2>/dev/null || true

  # Copy hidden files in .claude/ (settings.local.json etc)
  for f in "$TEMPLATE/.claude/".*.json; do
    [[ -f "$f" ]] && cp "$f" "$TARGET/.claude/"
  done

  # Copy subdirectories (skills, agents, rules)
  for dir in skills agents rules; do
    if [[ -d "$TEMPLATE/.claude/$dir" ]]; then
      cp -r "$TEMPLATE/.claude/$dir" "$TARGET/.claude/"
    fi
  done
fi

# Copy .github/ directory (Copilot CLI: instructions, skills, agents)
if [[ -d "$TEMPLATE/.github" ]]; then
  mkdir -p "$TARGET/.github"
  cp -r "$TEMPLATE/.github/"* "$TARGET/.github/" 2>/dev/null || true

  # Copy subdirectories (skills, agents)
  for dir in skills agents; do
    if [[ -d "$TEMPLATE/.github/$dir" ]]; then
      cp -r "$TEMPLATE/.github/$dir" "$TARGET/.github/"
    fi
  done
fi

# Copy root-level files
for file in .mcp.json CLAUDE.md CLAUDE.local.md AGENTS.md; do
  if [[ -f "$TEMPLATE/$file" ]]; then
    cp "$TEMPLATE/$file" "$TARGET/$file"
  fi
done

# Copy workspace file (skip for global install)
if [[ -f "$TEMPLATE/project.code-workspace" && "$TARGET" != "$HOME" ]]; then
  cp "$TEMPLATE/project.code-workspace" "$TARGET/project.code-workspace"
fi

# Post-process settings.json: expand ${HOME} and detect ECC version
if [[ -f "$TARGET/.claude/settings.json" ]]; then
  # Expand ${HOME} literal to actual home directory
  sed -i.bak "s|\${HOME}|${HOME}|g" "$TARGET/.claude/settings.json"

  # Auto-detect installed ECC version and substitute
  ECC_CACHE="$HOME/.claude/plugins/cache/everything-claude-code/everything-claude-code"
  if [[ -d "$ECC_CACHE" ]]; then
    ECC_LATEST=$(ls -1 "$ECC_CACHE" 2>/dev/null | sort -V | tail -1)
    if [[ -n "$ECC_LATEST" ]]; then
      # Replace any hardcoded ECC version in the path with the detected version
      # Match version followed by either "/" (mid-path) or '"' (end of value)
      sed -i.bak -E "s|/everything-claude-code/[0-9]+\.[0-9]+\.[0-9]+([/\"])|/everything-claude-code/${ECC_LATEST}\1|g" "$TARGET/.claude/settings.json"
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

  # 3. プロジェクトメモリ: ~/.github/claude-projects → ~/.claude/projects/ (グローバルシンボリックリンク)
  rm -rf "$GITHUB_HOME/claude-projects"
  ln -sfn "$CLAUDE_HOME/projects" "$GITHUB_HOME/claude-projects"
  echo "  projects: $GITHUB_HOME/claude-projects -> $CLAUDE_HOME/projects"

  # 4. ~/.zshrc に precmd フックを追加 (冪等: 旧形式・新形式ともに置き換え)
  ZSHRC="$HOME/.zshrc"

  # 既存の VibeCording copilot-sync ブロックを除去 (BEGIN/END 形式と旧形式の両方に対応)
  if grep -q "VibeCording: copilot-sync" "$ZSHRC" 2>/dev/null; then
    python3 -c "
import re, sys
with open(sys.argv[1], 'r') as f:
    c = f.read()
# 新形式 (BEGIN/END マーカー)
c = re.sub(r'\n?# VibeCording: copilot-sync BEGIN\n.*?# VibeCording: copilot-sync END\n?', '', c, flags=re.DOTALL)
# 旧形式 (END マーカーなし、末尾に追記されていた)
c = re.sub(r'\n# VibeCording: copilot-sync\n.*\$', '', c, flags=re.DOTALL)
with open(sys.argv[1], 'w') as f:
    f.write(c)
" "$ZSHRC" && echo "  zshrc: Removed old copilot-sync block"
  fi

  # 新しいブロックを末尾に追加
  cat >> "$ZSHRC" <<'ZSHRC_BLOCK'

# VibeCording: copilot-sync BEGIN
# cd するだけで COPILOT_CUSTOM_INSTRUCTIONS_DIRS を自動更新 (手動 sync 不要)
_update_copilot_dirs() {
  local base="$HOME/.github/instructions"
  local projects="$HOME/.github/claude-projects"
  local hash
  hash=$(echo "$PWD" | sed 's|/|-|g; s|\.|-|g')
  local dirs="$base"
  local mem="${projects}/${hash}/memory"
  [[ -d "$mem" ]] && dirs="${dirs}:${mem}"
  export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="$dirs"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _update_copilot_dirs
# VibeCording: copilot-sync END
ZSHRC_BLOCK
  echo "  zshrc: Added copilot-sync to $ZSHRC"

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
