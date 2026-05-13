#!/bin/bash
# UserPromptSubmit hook: derive a sessionTitle from the first user prompt.
# Outputs JSON { hookSpecificOutput.sessionTitle: "..." } so Claude Code (v2.1.94+)
# can label the session by its topic. Only emits on the FIRST prompt of a session,
# so subsequent prompts don't flap the title. Fails open: any error -> "{}".

set +e

python3 <(cat <<'PY'
import sys, json, re

raw = sys.stdin.read() or "{}"
try:
    d = json.loads(raw)
except Exception:
    print("{}"); sys.exit(0)

# Only emit title on first prompt of session (message_count 0 or 1, or absent).
mc = (d.get("session") or {}).get("message_count")
if mc not in (None, 0, 1):
    print("{}"); sys.exit(0)

prompt = (d.get("prompt") or d.get("user_prompt") or "").strip()
prompt = re.sub(r"\s+", " ", prompt)
title = prompt[:50]
if not title:
    print("{}"); sys.exit(0)

print(json.dumps({"hookSpecificOutput": {"sessionTitle": title}}))
PY
) 2>/dev/null || echo "{}"
