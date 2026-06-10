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

  # Copy subdirectories (skills, agents, rules, scheduled-tasks)
  for dir in skills agents rules scheduled-tasks; do
    if [[ -d "$TEMPLATE/.claude/$dir" ]]; then
      cp -r "$TEMPLATE/.claude/$dir" "$TARGET/.claude/"
    fi
  done

  # Ensure hook scripts and statusline are executable
  # (git may strip executable bit on some platforms; cp -r preserves mode but template-source bit can be lost)
  if [[ -d "$TARGET/.claude/hooks" ]]; then
    find "$TARGET/.claude/hooks" -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) -exec chmod +x {} \;
  fi
  if [[ -f "$TARGET/.claude/statusline.sh" ]]; then
    chmod +x "$TARGET/.claude/statusline.sh"
  fi
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

# Copy .codex/ directory (Codex CLI / IDE extension config)
if [[ -d "$TEMPLATE/.codex" ]]; then
  mkdir -p "$TARGET/.codex"
  cp -r "$TEMPLATE/.codex/"* "$TARGET/.codex/" 2>/dev/null || true

  # Copy hidden files in .codex/ if present
  for f in "$TEMPLATE/.codex/".*; do
    [[ -f "$f" ]] && cp "$f" "$TARGET/.codex/"
  done

  # Ensure Codex hook scripts are executable
  if [[ -d "$TARGET/.codex/hooks" ]]; then
    find "$TARGET/.codex/hooks" -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) -exec chmod +x {} \;
  fi
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

  # Auto-detect installed ECC version and substitute.
  # ECC 2.0.0 renamed the plugin everything-claude-code -> ecc, so the cache
  # dir is .../marketplace(everything-claude-code)/plugin(ecc)/<version>.
  ECC_CACHE="$HOME/.claude/plugins/cache/everything-claude-code/ecc"
  if [[ -d "$ECC_CACHE" ]]; then
    ECC_LATEST=$(ls -1 "$ECC_CACHE" 2>/dev/null | sort -V | tail -1)
    if [[ -n "$ECC_LATEST" ]]; then
      # Replace any hardcoded ECC version in the path with the detected version.
      # Match version followed by either "/" (mid-path) or '"' (end of value).
      sed -i.bak -E "s|/everything-claude-code/ecc/[0-9]+\.[0-9]+\.[0-9]+([/\"])|/everything-claude-code/ecc/${ECC_LATEST}\1|g" "$TARGET/.claude/settings.json"
      echo "ECC version: ${ECC_LATEST} (auto-detected)"
    fi
  fi
  rm -f "$TARGET/.claude/settings.json.bak"
fi

# Post-process .mcp.json: expand ${HOME}
if [[ -f "$TARGET/.mcp.json" ]]; then
  sed -i.bak "s|\${HOME}|${HOME}|g" "$TARGET/.mcp.json"
  rm -f "$TARGET/.mcp.json.bak"
fi

# Post-process Codex config.toml: expand ${HOME}
if [[ -f "$TARGET/.codex/config.toml" ]]; then
  sed -i.bak "s|\${HOME}|${HOME}|g" "$TARGET/.codex/config.toml"
  rm -f "$TARGET/.codex/config.toml.bak"
fi

# Post-process Codex hooks.json: expand placeholders to the install target.
if [[ -f "$TARGET/.codex/hooks.json" ]]; then
  sed -i.bak "s|\${HOME}|${HOME}|g" "$TARGET/.codex/hooks.json"
  sed -i.bak "s|CODEX_HOOKS_DIR|${TARGET}/.codex/hooks|g" "$TARGET/.codex/hooks.json"
  rm -f "$TARGET/.codex/hooks.json.bak"
fi

# Substitute NODEJS_BIN_DIR placeholder in MCP configs
if { [[ -f "$TARGET/.mcp.json" ]] && grep -q 'NODEJS_BIN_DIR' "$TARGET/.mcp.json" 2>/dev/null; } || { [[ -f "$TARGET/.codex/config.toml" ]] && grep -q 'NODEJS_BIN_DIR' "$TARGET/.codex/config.toml" 2>/dev/null; }; then
  NODE_BIN_DIR=""
  if command -v npm &>/dev/null; then
    NODE_BIN_DIR=$(dirname "$(command -v npm)")
  fi
  if [[ -z "$NODE_BIN_DIR" ]]; then
    NODE_BIN_DIR="/opt/homebrew/bin"
  fi
  if [[ -f "$TARGET/.mcp.json" ]]; then
    sed -i.bak "s|NODEJS_BIN_DIR|${NODE_BIN_DIR}|g" "$TARGET/.mcp.json"
    rm -f "$TARGET/.mcp.json.bak"
  fi
  if [[ -f "$TARGET/.codex/config.toml" ]]; then
    sed -i.bak "s|NODEJS_BIN_DIR|${NODE_BIN_DIR}|g" "$TARGET/.codex/config.toml"
    rm -f "$TARGET/.codex/config.toml.bak"
  fi
fi

# ─── Obsidian MCP pre-flight ──────────────────────────────────────────────────
# .mcp.json に obsidian エントリがある場合、Local REST API & MCP Server プラグイン
# 内蔵 native MCP (HTTP 27123 /mcp/) の依存を順次チェックする (fail はしない)
if { [[ -f "$TARGET/.mcp.json" ]] && grep -q '"obsidian"' "$TARGET/.mcp.json" 2>/dev/null; } || { [[ -f "$TARGET/.codex/config.toml" ]] && grep -q 'mcp_servers\.obsidian' "$TARGET/.codex/config.toml" 2>/dev/null; }; then
  echo ""
  echo "── Obsidian MCP pre-flight ────────────────────────────"

  # 1. Obsidian Local REST API & MCP Server plugin (vault 側)
  OBSIDIAN_VAULT_DEFAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian"
  if [[ -d "$OBSIDIAN_VAULT_DEFAULT/.obsidian/plugins/obsidian-local-rest-api" ]]; then
    echo "  ✓ Local REST API & MCP Server plugin found in default vault"
  else
    echo "  ✗ Local REST API & MCP Server plugin not found in $OBSIDIAN_VAULT_DEFAULT"
    echo "    → Obsidian → Settings → Community plugins → Browse → 'Local REST API' (by coddingtonbear)"
    echo "    → obsidian://show-plugin?id=obsidian-local-rest-api"
  fi

  # 2. macOS Keychain に API key が登録されているか
  if [[ "$OSTYPE" == darwin* ]] && command -v security &>/dev/null; then
    if /usr/bin/security find-generic-password -s 'obsidian-mcp-api-key' -w &>/dev/null; then
      echo "  ✓ OBSIDIAN_API_KEY found in macOS Keychain"
    else
      echo "  ✗ OBSIDIAN_API_KEY not in macOS Keychain"
      echo "    1) Local REST API plugin の設定画面で API key をコピー"
      echo "    2) security add-generic-password -s 'obsidian-mcp-api-key' -a \"\$USER\" -w 'PASTE_KEY' -U"
    fi
  fi

  # 3. native MCP endpoint が live か (401 = mounted & auth-gated, 正常)
  if command -v curl &>/dev/null; then
    MCP_CODE=$(/usr/bin/curl -s --max-time 3 -o /dev/null -w "%{http_code}" http://127.0.0.1:27123/mcp/ 2>/dev/null || true)
    if [[ "$MCP_CODE" == "401" || "$MCP_CODE" == "200" || "$MCP_CODE" == "406" ]]; then
      echo "  ✓ native MCP endpoint live (http://127.0.0.1:27123/mcp/ → HTTP $MCP_CODE)"
    else
      echo "  ✗ native MCP endpoint not reachable (HTTP ${MCP_CODE:-000})"
      echo "    → launch Obsidian + enable MCP in 'Local REST API' settings (Non-encrypted HTTP server on :27123)"
    fi
  fi

  echo "  Note: HTTPS 27124 は self-signed cert で Node に拒否されるため、平文 HTTP 27123 を使う"
  echo "  Docs: ${HOME}/.claude/rules/obsidian-mcp.md (native Local REST API & MCP Server 構成)"
  echo "───────────────────────────────────────────────────────"
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

  # 5. ~/.zshrc に OBSIDIAN_API_KEY export を追加 (obsidian MCP が http で
  #    ${OBSIDIAN_API_KEY} を展開するため)。冪等: BEGIN/END ブロックを毎回置換。
  #    Keychain にキーが無ければ空文字 (無害)。
  if { [[ -f "$TARGET/.mcp.json" ]] && grep -q '"obsidian"' "$TARGET/.mcp.json" 2>/dev/null; } || { [[ -f "$TARGET/.codex/config.toml" ]] && grep -q 'mcp_servers\.obsidian' "$TARGET/.codex/config.toml" 2>/dev/null; }; then
    if grep -q "VibeCording: obsidian-key" "$ZSHRC" 2>/dev/null; then
      python3 -c "
import re, sys
with open(sys.argv[1]) as f: c = f.read()
c = re.sub(r'\n?# VibeCording: obsidian-key BEGIN\n.*?# VibeCording: obsidian-key END\n?', '', c, flags=re.DOTALL)
with open(sys.argv[1], 'w') as f: f.write(c)
" "$ZSHRC"
    fi
    cat >> "$ZSHRC" <<'ZSHRC_OBSIDIAN'

# VibeCording: obsidian-key BEGIN
# Obsidian Local REST API & MCP Server key — Keychain から取得し ${OBSIDIAN_API_KEY} を提供
# (~/.mcp.json の Bearer ヘッダで env 展開。平文トークンを config に置かないため)
export OBSIDIAN_API_KEY="$(/usr/bin/security find-generic-password -s 'obsidian-mcp-api-key' -w 2>/dev/null)"
# VibeCording: obsidian-key END
ZSHRC_OBSIDIAN
    echo "  zshrc: Added obsidian-key export to $ZSHRC"
  fi

  echo "Copilot CLI symlink bridge complete."
  echo ""
fi

# ─── Register MCP servers in ~/.claude.json ───────────────────────────────────
# Global install: register all servers in mcpServers (user-level, always loaded)
# Project install: set hasTrustDialogAccepted=true + enabledMcpjsonServers
if command -v python3 &>/dev/null && [[ -f "$HOME/.claude.json" ]] && [[ -f "$TARGET/.mcp.json" ]]; then
  python3 - "$TARGET" "$HOME" << 'PYEOF'
import json, sys

target_dir = sys.argv[1]
home_dir   = sys.argv[2]
claude_json_path = f"{home_dir}/.claude.json"
mcp_json_path    = f"{target_dir}/.mcp.json"

with open(claude_json_path) as f:
    d = json.load(f)

with open(mcp_json_path) as f:
    mcp = json.load(f)

servers      = mcp.get('mcpServers', {})
server_names = list(servers.keys())

if target_dir == home_dir:
    # Global install: populate mcpServers from .mcp.json
    d.setdefault('mcpServers', {})
    for name, config in servers.items():
        if 'url' in config:
            entry = {'type': config.get('type', 'http'), 'url': config['url']}
            if 'headers' in config:
                entry['headers'] = config['headers']
            d['mcpServers'][name] = entry
        else:
            d['mcpServers'][name] = {
                'type': 'stdio',
                'command': config['command'],
                'args':    config.get('args', []),
                'env':     config.get('env', {})
            }
    print(f"Registered {len(servers)} MCP servers in ~/.claude.json")
else:
    # Project install: approve trust dialog + enable .mcp.json servers
    proj = d.setdefault('projects', {}).setdefault(target_dir, {})
    proj['hasTrustDialogAccepted']  = True
    proj['enabledMcpjsonServers']   = server_names
    # Remove stale project-level mcpServers (these shadow global settings)
    proj.pop('mcpServers', None)
    print(f"Enabled {len(server_names)} MCP servers for project: {target_dir}")

with open(claude_json_path, 'w') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
PYEOF
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
find "$TARGET/.codex" -type f 2>/dev/null | sed "s|$TARGET/||" | sort
[[ -f "$TARGET/.mcp.json" ]] && echo ".mcp.json"
[[ -f "$TARGET/CLAUDE.md" ]] && echo "CLAUDE.md"
[[ -f "$TARGET/CLAUDE.local.md" ]] && echo "CLAUDE.local.md"
[[ -f "$TARGET/AGENTS.md" ]] && echo "AGENTS.md"
[[ -f "$TARGET/project.code-workspace" ]] && echo "project.code-workspace"

echo ""
if [[ "$TARGET" == "$HOME" ]]; then
  echo "Done! Global install complete."
  echo "All projects will use these settings automatically."
  echo "Edit ~/.claude/settings.json, ~/.codex/config.toml, and ~/CLAUDE.md to customize."
else
  echo "Done! Edit CLAUDE.md, .claude/settings.json, .codex/config.toml, and project.code-workspace to match your project."
fi
