#!/bin/bash
# obsidian-auto-capture.sh — Stop hook
# Extracts noteworthy candidates from the session transcript via Haiku 4.5
# and appends them to 90_artifacts/claude-code/auto-captures/YYYY-MM.md.
# Promotion to themes/memory/decisions is left to humans or /obsidian-synthesis.
#
# OAuth-compatible: does NOT use --bare (which would require ANTHROPIC_API_KEY).
# Recursion-safe: sets CLAUDE_HOOK_AUTO_CAPTURE_RUNNING=1 in env. Child claude
# processes inherit it; this hook checks the var at entry and exits early.
# Fire-and-forget: Haiku extraction runs in background, hook returns immediately.

set -uo pipefail

# Recursion guard
[ "${CLAUDE_HOOK_AUTO_CAPTURE_RUNNING:-}" = "1" ] && exit 0

OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"
AUTO_CAPTURE_DIR="$OBSIDIAN_VAULT/90_artifacts/claude-code/auto-captures"

# Preconditions
[ -d "$OBSIDIAN_VAULT" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0
command -v claude >/dev/null 2>&1 || exit 0

# Portable timeout (macOS lacks `timeout`)
if command -v timeout >/dev/null 2>&1; then
  TIMEOUT_PREFIX="timeout 90"
elif command -v gtimeout >/dev/null 2>&1; then
  TIMEOUT_PREFIX="gtimeout 90"
else
  TIMEOUT_PREFIX=""
fi

# Read Stop hook stdin
INPUT=$(cat 2>/dev/null || echo '{}')
SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || echo "")
TRANSCRIPT_PATH=$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")

[ -z "$TRANSCRIPT_PATH" ] && exit 0
[ -f "$TRANSCRIPT_PATH" ] || exit 0

# Skip trivial sessions
TRANSCRIPT_SIZE=$(wc -c < "$TRANSCRIPT_PATH" 2>/dev/null | tr -d ' ' || echo 0)
[ "$TRANSCRIPT_SIZE" -lt 5000 ] && exit 0

mkdir -p "$AUTO_CAPTURE_DIR" 2>/dev/null || exit 0
AUTO_CAPTURE_FILE="$AUTO_CAPTURE_DIR/$(date +%Y-%m).md"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
PROJECT=$(basename "${CWD:-$(pwd)}")

# Initialize monthly file with frontmatter if missing
if [ ! -f "$AUTO_CAPTURE_FILE" ]; then
  cat > "$AUTO_CAPTURE_FILE" <<EOF
---
created: $DATE
tags: [claude-code, auto-capture, artifact]
type: artifact
---

# Auto-captures — $(date +%Y-%m)

> Claude Code Stop hook + Haiku 4.5 が抽出した promotion 候補集（append-only、INBOX には書かない）。\`/obsidian-synthesis\` または手動で themes/memory/decisions に昇格する。

関連: [[30_knowledge/claude-code/INDEX]] / [[30_knowledge/claude-code/themes/Obsidian書き込み多重化方針]]

EOF
fi

# Always append a marker entry first (provenance even if Haiku fails)
MARKER_TAG="<!-- session ${SESSION_ID:0:8} marker, awaiting extraction -->"
{
  printf '\n## %s %s — session %s (%s)\n\n' "$DATE" "$TIME" "${SESSION_ID:0:8}" "$PROJECT"
  printf -- '- **transcript**: \`%s\` (%s bytes)\n' "$TRANSCRIPT_PATH" "$TRANSCRIPT_SIZE"
  printf '%s\n' "$MARKER_TAG"
} >> "$AUTO_CAPTURE_FILE"

# Background extraction
(
  # Compress JSONL → clean text (drop tool_use/tool_result metadata, last 200 turns, cap 80KB)
  TEXT=$(tail -200 "$TRANSCRIPT_PATH" \
    | jq -r 'select(.type=="user" or .type=="assistant") | .message.content | if type=="string" then . else (map(select(.type=="text").text // .) | join("\n")) end' 2>/dev/null \
    | tail -c 80000)

  if [ -z "$TEXT" ]; then
    if command -v sed >/dev/null 2>&1; then
      sed -i.bak "s|$MARKER_TAG|<!-- SKIP — empty transcript text -->|" "$AUTO_CAPTURE_FILE" 2>/dev/null
      rm -f "$AUTO_CAPTURE_FILE.bak" 2>/dev/null
    fi
    exit 0
  fi

  PROMPT="以下は Claude Code セッション transcript の抽出テキストです。次のカテゴリに該当する内容のみを抽出してください:

- ## トラブルシュート: 問題→解決ペア（自明なものは除外）
- ## feedback: ユーザーからの訂正・好み表明
- ## 環境設定: settings/config 変更
- ## MCP変更: MCP server install/remove/change
- ## 設計判断: アーキテクチャ/技術選定の判断と理由（ADR 化すべきもの）
- ## 実装マイルストーン: 機能完成・リリース・重要実装の節目（リポジトリ/PR を明記）
- ## 学び: 再発見にコストがかかる非自明な知見・テクニック

各項目は 1-2 文サマリ + 昇格先候補 wikilink を付ける。
昇格先候補は以下から選ぶ:
- [[30_knowledge/claude-code/themes/トラブルシュート集]]
- [[30_knowledge/claude-code/themes/feedback集約]]
- [[30_knowledge/claude-code/環境設定]]
- [[30_knowledge/claude-code/themes/MCPサーバー全リスト]]
- [[50_decisions/index]]
- [[20_projects/index]]
- [[40_learning/index]]

抽出基準: 「将来の自分や他者が再発見にコストを払う情報」を優先。単なる作業ログ・git log で追える内容・その場限りのデバッグ出力は除外。
該当なしなら 'SKIP' とだけ出力。前置きや説明は不要、抽出内容のみ markdown で出力。

---transcript---
${TEXT}
---end---"

  # Call Haiku via OAuth (no --bare). --strict-mcp-config skips MCP load without needing a config file.
  # shellcheck disable=SC2086
  RESULT=$(CLAUDE_HOOK_AUTO_CAPTURE_RUNNING=1 \
    $TIMEOUT_PREFIX claude \
    -p "$PROMPT" \
    --model claude-haiku-4-5 \
    --output-format text \
    --max-budget-usd 0.30 \
    --no-session-persistence \
    --disable-slash-commands \
    --strict-mcp-config \
    2>/dev/null) || RESULT=""

  CLEAN=$(printf '%s' "$RESULT" | tr -d '[:space:]')

  if [ -z "$CLEAN" ] || [ "$CLEAN" = "SKIP" ]; then
    # Replace marker with SKIP note
    if command -v sed >/dev/null 2>&1; then
      sed -i.bak "s|$MARKER_TAG|<!-- SKIP — Haiku found nothing noteworthy -->|" "$AUTO_CAPTURE_FILE" 2>/dev/null
      rm -f "$AUTO_CAPTURE_FILE.bak" 2>/dev/null
    fi
    exit 0
  fi

  # Replace marker with extracted content
  # Use python3 (always present on macOS) to avoid BSD awk's "newline in -v" limitation
  if command -v python3 >/dev/null 2>&1; then
    RESULT_FILE=$(mktemp)
    printf '%s' "$RESULT" > "$RESULT_FILE"
    MARKER_TAG="$MARKER_TAG" RESULT_FILE="$RESULT_FILE" python3 - "$AUTO_CAPTURE_FILE" <<'PYEOF' 2>/dev/null
import os, sys
ac_file = sys.argv[1]
marker = os.environ["MARKER_TAG"]
with open(ac_file, encoding="utf-8") as f:
    content = f.read()
with open(os.environ["RESULT_FILE"], encoding="utf-8") as f:
    extracted = f.read().rstrip()
replacement = extracted + "\n\n<!-- 未処理 — `/obsidian-synthesis` または手動で promotion -->"
with open(ac_file, "w", encoding="utf-8") as f:
    f.write(content.replace(marker, replacement))
PYEOF
    rm -f "$RESULT_FILE"
  fi
) &
disown
exit 0
