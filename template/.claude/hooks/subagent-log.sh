#!/bin/bash
# SubagentStop hook: append a single-line summary of the subagent's result to
# Obsidian Claude Code/Sessions/YYYY-MM.md so the "second brain" captures
# subagent work, not just main-session activity.
# Fails silently; never blocks Claude.

set +e

INPUT=$(cat 2>/dev/null || true)
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)
YEAR_MONTH=$(date +%Y-%m)
VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian}"
DIR="$VAULT/Claude Code/Sessions"
FILE="$DIR/$YEAR_MONTH.md"

mkdir -p "$DIR" 2>/dev/null || true

# Extract agent name + short result via python (handles missing fields).
# Use process substitution so stdin (INPUT JSON) reaches python uncontested.
LINE=$(printf '%s' "$INPUT" | python3 <(cat <<'PY'
import sys, json
try:
    d = json.loads(sys.stdin.read() or "{}")
except Exception:
    print(""); sys.exit(0)
agent = d.get("subagent_type") or d.get("agent_type") or d.get("agent") or "subagent"
desc = (d.get("description") or "").strip()
result = (d.get("result") or d.get("stop_reason") or "").strip()
# Keep total line short.
desc = desc.replace("\n", " ")[:60]
result = result.replace("\n", " ")[:40]
out = f"{agent}"
if desc:
    out += f" — {desc}"
if result and result not in (desc, agent):
    out += f" [{result}]"
print(out[:160])
PY
) 2>/dev/null)

if [ -z "$LINE" ]; then
  exit 0
fi

if [ ! -f "$FILE" ]; then
  printf -- "---\ncreated: %s\ntags: [claude-code, session-log]\n---\n\n# Claude Code セッションログ - %s\n\n" \
    "$DATE" "$YEAR_MONTH" > "$FILE"
fi

printf -- "  - %s %s | subagent: %s\n" "$DATE" "$TIME" "$LINE" >> "$FILE"
exit 0
