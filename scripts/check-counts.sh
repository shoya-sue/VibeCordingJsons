#!/usr/bin/env bash
# check-counts.sh — verify documented counts match the actual filesystem.
#
# The template documents counts (skills, rules, languages, hooks, MCP servers,
# agents) in several parallel files. Those are maintained by hand and drift every
# release. Run this before cutting a release (and ideally from CI) to catch drift.
#
#   bash scripts/check-counts.sh   # exits 0 if consistent, 1 on drift
#
# When the template intentionally grows (e.g. a language is added), update the
# EXP_* constants below AND the docs in the same commit.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
fail=0

# ---- actual counts from the filesystem (source of truth) ----
SKILLS=$(find template/.claude/skills -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
LANGS=$(find template/.claude/rules/ecc -maxdepth 1 -mindepth 1 -type d ! -name common 2>/dev/null | wc -l | tr -d ' ')
COMMON=$(find template/.claude/rules/ecc/common -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
ECC_RULES=$((COMMON + LANGS * 5))
CUSTOM=$(find template/.claude/rules -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
COP_SKILLS=$(find template/.github/skills -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
COP_AGENTS=$(find template/.github/agents -maxdepth 1 -name '*.agent.md' 2>/dev/null | wc -l | tr -d ' ')
HOOKS=$(python3 -c "import json;print(len(json.load(open('template/.claude/settings.json')).get('hooks',{})))")
MCP=$(python3 -c "import json;print(len(json.load(open('template/.mcp.json')).get('mcpServers',{})))")

echo "== Actual filesystem counts =="
printf '  local skills        : %s\n' "$SKILLS"
printf '  rule languages      : %s\n' "$LANGS"
printf '  ECC rules (10+L*5)  : %s\n' "$ECC_RULES"
printf '  custom rules        : %s\n' "$CUSTOM"
printf '  copilot skill pkgs  : %s\n' "$COP_SKILLS"
printf '  copilot agents      : %s\n' "$COP_AGENTS"
printf '  configured hooks    : %s\n' "$HOOKS"
printf '  MCP servers         : %s\n' "$MCP"
echo

# ---- expected (update when the template intentionally grows) ----
EXP_SKILLS=10; EXP_LANGS=9; EXP_ECC=55; EXP_CUSTOM=3
EXP_COP_SKILLS=2; EXP_COP_AGENTS=4; EXP_HOOKS=10; EXP_MCP=7
chk() { if [ "$2" != "$3" ]; then echo "DRIFT: $1 = $2 (expected $3 — update docs + EXP_* in this script)"; fail=1; fi; }
chk skills "$SKILLS" "$EXP_SKILLS"
chk languages "$LANGS" "$EXP_LANGS"
chk ecc_rules "$ECC_RULES" "$EXP_ECC"
chk custom_rules "$CUSTOM" "$EXP_CUSTOM"
chk copilot_skills "$COP_SKILLS" "$EXP_COP_SKILLS"
chk copilot_agents "$COP_AGENTS" "$EXP_COP_AGENTS"
chk hooks "$HOOKS" "$EXP_HOOKS"
chk mcp "$MCP" "$EXP_MCP"

# ---- stale strings that must never reappear in live docs ----
# (docs/ is dated history and is intentionally excluded)
LIVE="README.md AGENTS.md CLAUDE.md template/README.md template/AGENTS.md template/CLAUDE.md"
STALE=(
  "install.sh full" "install.sh minimal" "install.sh standard"
  "8 languages × 5" "50 rules" "50 ECC"
  "47 agents" "30 agents" "181 skills" "60 commands"
  "26 hooks" "27 event hooks"
  # ECC 1.10.0 counts — stale since the 2.0.0 (ecc) migration (now 64/261/84)
  "38 agents" "156 skills" "72 commands"
  "everything-claude-code@everything-claude-code"
)
for s in "${STALE[@]}"; do
  hits=$(grep -rlnF "$s" $LIVE 2>/dev/null || true)
  if [ -n "$hits" ]; then
    echo "STALE STRING '$s' found in:"
    echo "$hits" | sed 's/^/    /'
    fail=1
  fi
done

# ---- hook matcher idiom guard ----
# Claude Code evaluates a hook matcher as a JS regex when it contains any char
# outside [A-Za-z0-9_ ,|]. A bare-glob like "mcp__obsidian__*" then means the
# regex `mcp__obsidian_` + `_*` — it only matches by accident. The idiomatic
# form is "mcp__obsidian__.*". This guard fails on any matcher that contains '*'
# but is neither the match-all "*" nor a proper ".*" regex.
MATCHER_BAD=$(python3 - <<'PY'
import json
d=json.load(open('template/.claude/settings.json'))
bad=[]
for ev,arr in d.get('hooks',{}).items():
    if not isinstance(arr,list): continue
    for g in arr:
        if not isinstance(g,dict): continue
        m=g.get('matcher')
        if not isinstance(m,str): continue
        if m.strip()=='*': continue          # match-all is fine
        if '*' in m and '.*' not in m:        # bare glob — non-idiomatic
            bad.append(f"{ev}: {m!r}")
print("\n".join(bad))
PY
)
if [ -n "$MATCHER_BAD" ]; then
  echo "NON-IDIOMATIC HOOK MATCHER (bare '*' glob — use exact string or '.*' regex):"
  echo "$MATCHER_BAD" | sed 's/^/    /'
  fail=1
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "✓ counts consistent"
else
  echo "✗ count drift detected — fix docs (and EXP_* if the growth is intentional)"
fi
exit "$fail"
