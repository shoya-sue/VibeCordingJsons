#!/bin/bash
# obsidian-auto-capture.sh — Stop hook
# Extracts noteworthy candidates from the session transcript via Haiku 4.5
# and appends them to 90_artifacts/claude-code/auto-captures/YYYY-MM.md.
# Promotion to themes/memory/decisions is left to humans or /obsidian-synthesis.
#
# Recursion-safe: invokes `claude --bare` which skips hooks/LSP/plugins/CLAUDE.md.
# Fire-and-forget: Haiku extraction runs in background, hook returns immediately.

set -uo pipefail

OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"
AUTO_CAPTURE_DIR="$OBSIDIAN_VAULT/90_artifacts/claude-code/auto-captures"

# Preconditions
[ -d "$OBSIDIAN_VAULT" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0
command -v claude >/dev/null 2>&1 || exit 0

# Read Stop hook stdin
INPUT=$(cat 2>/dev/null || echo '{}')
SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || echo "")
TRANSCRIPT_PATH=$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")

[ -z "$TRANSCRIPT_PATH" ] && exit 0
[ -f "$TRANSCRIPT_PATH" ] || exit 0

# Skip trivial sessions (< 5KB transcript = unlikely to contain promotion candidates)
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

# Background extraction — non-blocking, --bare skips all hooks so no recursion
(
  PROMPT='以下の Claude Code セッション transcript (JSONL) から、次のカテゴリに該当する内容のみを抽出してください:

- ## トラブルシュート: 問題→解決ペア（自明なものは除外）
- ## feedback: ユーザーからの訂正・好み表明
- ## 環境設定: settings/config 変更
- ## MCP変更: MCP server install/remove/change

各項目は 1-2 文サマリ + 昇格先候補 wikilink を付ける。
昇格先候補は以下から選ぶ:
- [[30_knowledge/claude-code/themes/トラブルシュート集]]
- [[30_knowledge/claude-code/themes/feedback集約]]
- [[30_knowledge/claude-code/環境設定]]
- [[30_knowledge/claude-code/themes/MCPサーバー全リスト]]

該当なしなら "SKIP" とだけ出力。
前置きや説明は不要、抽出内容のみ markdown で出力。'

  RESULT=$(timeout 90 claude \
    --bare \
    -p "$PROMPT" \
    --model claude-haiku-4-5 \
    --output-format text \
    --max-budget-usd 0.10 \
    --no-session-persistence \
    < "$TRANSCRIPT_PATH" 2>/dev/null) || exit 0

  [ -z "$RESULT" ] && exit 0
  CLEAN=$(printf '%s' "$RESULT" | tr -d '[:space:]')
  [ "$CLEAN" = "SKIP" ] && exit 0
  [ "$CLEAN" = "ERROR" ] && exit 0

  # Append entry to monthly file
  {
    printf '\n## %s %s — session %s (%s)\n\n' "$DATE" "$TIME" "${SESSION_ID:0:8}" "$PROJECT"
    printf '%s\n\n' "$RESULT"
    printf '<!-- 未処理 — `/obsidian-synthesis` または手動で promotion -->\n\n'
  } >> "$AUTO_CAPTURE_FILE"
) &
disown
exit 0
