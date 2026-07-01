#!/usr/bin/env bash
# guard-git-identity.sh — PreToolUse (matcher: Bash) guard.
#
# Blocks any Bash command that mutates the GLOBAL or SYSTEM git identity
# (user.name / user.email). Exit code 2 blocks the tool and shows the
# message to Claude.
#
# WHY: On 2026-07-01 a leaking test harness (a third-party / CI default
# identity) overwrote ~/.gitconfig with "Test User <test@test.com>",
# silently mis-attributing commits — and it fired even on a customer
# project. Claude (main or subagent) must never clobber the machine-level
# git identity while working inside a project. Legitimate machine setup is a
# human action; the user can still run it manually via a `!` bang command,
# which does not pass through PreToolUse hooks.
#
# Detection strategy: flatten whitespace, then STRIP QUOTED SPANS before
# matching. Stripping quotes removes commit messages / echo text / docs that
# merely *mention* these commands (avoiding false positives) while keeping
# the command keywords and flags of a real invocation (which live outside
# quotes) intact. Any global/system identity write is blocked regardless of
# the value, so no brittle test-identity string matching is needed here — the
# git-identity-sentinel.sh SessionStart hook is the backstop for values that
# reached the config through paths this hook cannot see.
set -uo pipefail

input="$(cat 2>/dev/null || true)"
[ -z "$input" ] && exit 0

# Extract the Bash command from the hook payload (jq preferred, python3 fallback).
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
elif command -v python3 >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | python3 -c 'import sys,json
try:
    print(json.load(sys.stdin).get("tool_input",{}).get("command",""))
except Exception:
    pass' 2>/dev/null || true)"
else
  cmd="$input"
fi
[ -z "$cmd" ] && exit 0

# Flatten newlines/tabs to spaces and squeeze, THEN remove quoted spans so
# that text inside "..."/'...' (commit messages, echo args, docs) is ignored.
flat="$(printf '%s' "$cmd" | tr '\n\t' '  ' | tr -s ' ')"
stripped="$(printf '%s' "$flat" | sed "s/\"[^\"]*\"//g; s/'[^']*'//g")"

deny() {
  echo "🚫 BLOCKED by guard-git-identity: $1" >&2
  exit 2
}

# Block any global/system git identity write (any flag order), outside quotes.
if printf '%s' "$stripped" | grep -Eiq 'git[[:space:]]+config' \
   && printf '%s' "$stripped" | grep -Eq -- '(--global|--system)' \
   && printf '%s' "$stripped" | grep -Eiq 'user\.(name|email)'; then
  deny "git のグローバル/システム identity (user.name/user.email) の変更は禁止です。プロジェクト単位なら '--local' を使用してください。マシン全体の設定変更が本当に必要なら、ユーザー自身がターミナルで手動実行してください（'!' 前置きの bang コマンドはこのガードを通りません）。[2026-07-01 の ~/.gitconfig 汚染事故の再発防止]"
fi

exit 0
