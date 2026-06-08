#!/bin/bash
# SessionStart hook: Obsidian native MCP + auto-memory の稼働状態をチェックし、
# 結果を additionalContext として Claude に渡す。
#
# 接続先: Local REST API & MCP Server プラグイン内蔵 native MCP
#         (HTTP http://127.0.0.1:27123/mcp/, token は ${OBSIDIAN_API_KEY})
#
# チェック項目 (5):
#   1. Local REST API & MCP Server plugin が vault にインストール済か
#   2. OBSIDIAN_API_KEY が macOS Keychain にあるか (env 展開の source)
#   3. ~/.zshrc が OBSIDIAN_API_KEY を export しているか (${} 展開の wiring)
#   4. native MCP endpoint が live か (HTTP 27123 /mcp/ → 401 = mounted+auth-gated)
#   5. auto-memory ディレクトリが project に存在するか
#
# 失敗してもブロックしない (exit 0)。Claude に状態を可視化するのが目的。

set +e

VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"
CWD="${PWD:-$(pwd)}"
HASH="${CWD//\//-}"
MEM_DIR="$HOME/.claude/projects/${HASH}/memory"
MCP_URL="http://127.0.0.1:27123/mcp/"

LINES=()
OK_COUNT=0
NG_COUNT=0

# 1. Local REST API & MCP Server plugin が vault に存在
if [[ -d "$VAULT/.obsidian/plugins/obsidian-local-rest-api" ]]; then
  LINES+=("- [x] Local REST API & MCP Server plugin installed in vault")
  OK_COUNT=$((OK_COUNT+1))
else
  LINES+=("- [ ] Local REST API & MCP Server plugin **NOT installed** in \`$VAULT\` — fix: Obsidian → Settings → Community plugins → Browse → 'Local REST API' (coddingtonbear)")
  NG_COUNT=$((NG_COUNT+1))
fi

# 2. macOS Keychain に API key (env 展開の source)
if [[ "$OSTYPE" == darwin* ]] && command -v security &>/dev/null; then
  if /usr/bin/security find-generic-password -s 'obsidian-mcp-api-key' -w &>/dev/null; then
    LINES+=("- [x] OBSIDIAN_API_KEY in macOS Keychain (\`obsidian-mcp-api-key\`)")
    OK_COUNT=$((OK_COUNT+1))
  else
    LINES+=("- [ ] OBSIDIAN_API_KEY **NOT in Keychain** — fix: \`security add-generic-password -s 'obsidian-mcp-api-key' -a \"\$USER\" -w 'PASTE_KEY' -U\`")
    NG_COUNT=$((NG_COUNT+1))
  fi
else
  LINES+=("- [ ] macOS Keychain unavailable on this OS")
fi

# 3. ~/.zshrc が OBSIDIAN_API_KEY を export しているか (HTTP MCP の ${} 展開に必須)
if grep -q 'export OBSIDIAN_API_KEY=' "$HOME/.zshrc" 2>/dev/null; then
  LINES+=("- [x] ~/.zshrc exports OBSIDIAN_API_KEY (from Keychain; \`\${OBSIDIAN_API_KEY}\` expands in ~/.mcp.json)")
  OK_COUNT=$((OK_COUNT+1))
else
  LINES+=("- [ ] ~/.zshrc does **NOT** export OBSIDIAN_API_KEY — HTTP MCP header \`Bearer \${OBSIDIAN_API_KEY}\` will be empty → 401. fix: add \`export OBSIDIAN_API_KEY=\"\$(/usr/bin/security find-generic-password -s 'obsidian-mcp-api-key' -w)\"\`")
  NG_COUNT=$((NG_COUNT+1))
fi

# 4. native MCP endpoint が live か (401 = mounted & auth-gated, 正常)
if command -v curl &>/dev/null; then
  CODE=$(/usr/bin/curl -s --max-time 3 -o /dev/null -w "%{http_code}" "$MCP_URL" 2>/dev/null)
  if [[ "$CODE" == "401" || "$CODE" == "200" || "$CODE" == "406" ]]; then
    LINES+=("- [x] Obsidian native MCP live (\`$MCP_URL\` → HTTP $CODE)")
    OK_COUNT=$((OK_COUNT+1))
  else
    LINES+=("- [ ] Obsidian native MCP **NOT reachable** (\`$MCP_URL\` → HTTP ${CODE:-000}) — fix: launch Obsidian + enable MCP in 'Local REST API' plugin settings (Non-encrypted HTTP server on :27123)")
    NG_COUNT=$((NG_COUNT+1))
  fi
fi

# 5. auto-memory ディレクトリ
if [[ -L "$MEM_DIR" ]]; then
  TARGET=$(readlink "$MEM_DIR")
  LINES+=("- [x] auto-memory symlink: \`$MEM_DIR\` → \`$TARGET\`")
  OK_COUNT=$((OK_COUNT+1))
elif [[ -d "$MEM_DIR" ]]; then
  LINES+=("- [x] auto-memory directory: \`$MEM_DIR\` (not yet symlinked to vault)")
  OK_COUNT=$((OK_COUNT+1))
else
  LINES+=("- [ ] auto-memory directory missing for this project: \`$MEM_DIR\`")
  NG_COUNT=$((NG_COUNT+1))
fi

# 結果ヘッダ
if [[ $NG_COUNT -eq 0 ]]; then
  HEADER="## Obsidian MCP & auto-memory healthcheck ✓ ($OK_COUNT/$((OK_COUNT+NG_COUNT)) OK)"
  USAGE="All systems go. Prefer \`mcp__obsidian__vault_*\` tools (vault_read / vault_write / vault_patch / vault_get_document_map / search_query) for vault read/write/patch over raw filesystem Write/Edit when operating on vault notes."
else
  HEADER="## Obsidian MCP & auto-memory healthcheck ⚠ ($NG_COUNT issue(s))"
  USAGE="Some checks failed. Until they are fixed, fall back to \`Write\`/\`Edit\` for vault paths and warn the user once before doing so. See \`~/.claude/rules/obsidian-mcp.md\` for the native Local REST API & MCP Server setup."
fi

# 改行で結合
BODY=$(printf "%s\n" "${LINES[@]}")
CONTEXT="${HEADER}

${BODY}

${USAGE}"

# JSON エスケープして additionalContext として出力
python3 - <<PYEOF
import json, sys
ctx = """${CONTEXT}"""
print(json.dumps({
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ctx
  }
}, ensure_ascii=False))
PYEOF
exit 0
