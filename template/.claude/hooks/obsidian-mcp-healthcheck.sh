#!/bin/bash
# SessionStart hook: Obsidian MCP + auto-memory の稼働状態をチェックし、
# 結果を additionalContext として Claude に渡す。
#
# チェック項目:
#   1. obsidian-mcp-server (cyanheads) バイナリ
#   2. OBSIDIAN_API_KEY が macOS Keychain にあるか
#   3. Local REST API plugin が vault にインストール済か
#   4. Obsidian アプリの HTTPS port (27124) が reachable か
#   5. auto-memory ディレクトリが project に存在するか
#
# 失敗してもブロックしない (exit 0)。Claude に状態を可視化するのが目的。

set +e

VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"
CWD="${PWD:-$(pwd)}"
HASH="${CWD//\//-}"
MEM_DIR="$HOME/.claude/projects/${HASH}/memory"

LINES=()
OK_COUNT=0
NG_COUNT=0

# 1. obsidian-mcp-server バイナリ
if command -v obsidian-mcp-server &>/dev/null; then
  BIN=$(command -v obsidian-mcp-server)
  LINES+=("- [x] obsidian-mcp-server (cyanheads): \`$BIN\`")
  OK_COUNT=$((OK_COUNT+1))
else
  LINES+=("- [ ] obsidian-mcp-server **MISSING** — fix: \`npm i -g obsidian-mcp-server\`")
  NG_COUNT=$((NG_COUNT+1))
fi

# 2. macOS Keychain に API key
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

# 3. Local REST API plugin が vault に存在
if [[ -d "$VAULT/.obsidian/plugins/obsidian-local-rest-api" ]]; then
  LINES+=("- [x] Local REST API plugin installed in vault")
  OK_COUNT=$((OK_COUNT+1))
else
  LINES+=("- [ ] Local REST API plugin **NOT installed** in \`$VAULT\` — fix: Obsidian → Settings → Community plugins → Browse → 'Local REST API' (coddingtonbear)")
  NG_COUNT=$((NG_COUNT+1))
fi

# 4. Obsidian アプリ HTTPS port reachability (= app 起動中)
if command -v curl &>/dev/null; then
  if /usr/bin/curl -ks --max-time 2 https://127.0.0.1:27124 -o /dev/null 2>/dev/null; then
    LINES+=("- [x] Obsidian app running (HTTPS 27124 reachable)")
    OK_COUNT=$((OK_COUNT+1))
  else
    LINES+=("- [ ] Obsidian app **NOT reachable** at HTTPS 27124 — fix: launch Obsidian app")
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
  USAGE="All systems go. Prefer \`mcp__obsidian__obsidian_*\` tools for vault read/write/patch over raw filesystem Write/Edit when operating on vault notes."
else
  HEADER="## Obsidian MCP & auto-memory healthcheck ⚠ ($NG_COUNT issue(s))"
  USAGE="Some checks failed. Until they are fixed, fall back to \`Write\`/\`Edit\` for vault paths and warn the user once before doing so. See vault note \`30_knowledge/claude-code/obsidian-mcp-cyanheads-setup.md\` for setup."
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
