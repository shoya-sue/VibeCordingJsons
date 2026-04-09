#!/bin/bash
# Claude Code Status Line — Dual Fighting Game HP Gauges
#
# Reads JSON from stdin (provided by Claude Code):
#   .context_window.remaining_percentage  — current session context remaining
#   .rate_limits["5hour"].used_percentage — Claude.ai 5-hour usage
#   .rate_limits["5hour"].resets_at       — next reset time (ISO 8601)

input=$(cat)

# --- Parse stdin JSON ---
CTX_REMAINING=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
RATE_USED=$(echo "$input"     | jq -r '.rate_limits["5hour"].used_percentage // empty')
RESETS_AT=$(echo "$input"     | jq -r '.rate_limits["5hour"].resets_at // empty')

# Cost falls back to env var (Claude Code also passes it as CLAUDE_COST_USD)
COST="${CLAUDE_COST_USD:-}"
[ -z "$COST" ] && COST=$(echo "$input" | jq -r '.cost_usd // empty')

BAR_WIDTH=20
RESET="\033[0m"

# --- Helpers ---
make_bar() {
  local pct=$1
  local filled=$(( pct * BAR_WIDTH / 100 ))
  local empty=$(( BAR_WIDTH - filled ))
  local bar=""
  for _ in $(seq 1 "$filled"); do bar="${bar}█"; done
  for _ in $(seq 1 "$empty");  do bar="${bar}░"; done
  printf "%s" "$bar"
}

color_for() {
  local pct=$1
  if   [ "$pct" -gt 60 ]; then printf "\033[32m"  # green
  elif [ "$pct" -gt 30 ]; then printf "\033[33m"  # yellow
  else                         printf "\033[31m"  # red
  fi
}

# Compute minutes until reset (e.g. "2h30m" or "45m")
time_until() {
  local iso="$1"
  [ -z "$iso" ] && return
  local now reset diff h m
  now=$(date +%s)
  reset=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$iso" +%s 2>/dev/null) \
    || reset=$(date -d "$iso" +%s 2>/dev/null)
  [ -z "$reset" ] && return
  diff=$(( reset - now ))
  [ "$diff" -le 0 ] && { printf "now"; return; }
  h=$(( diff / 3600 ))
  m=$(( (diff % 3600) / 60 ))
  [ "$h" -gt 0 ] && printf "%dh%02dm" "$h" "$m" || printf "%dm" "$m"
}

# --- CONTEXT gauge ---
if [ -n "$CTX_REMAINING" ]; then
  CTX_PCT=$(printf "%.0f" "$CTX_REMAINING")
  CTX_COLOR=$(color_for "$CTX_PCT")
  printf "${CTX_COLOR}CONTEXT [$(make_bar "$CTX_PCT")] %3d%%${RESET}" "$CTX_PCT"
  printf "  "
fi

# --- CLAUDE gauge (5-hour rate limit) ---
if [ -n "$RATE_USED" ]; then
  RATE_PCT=$(( 100 - $(printf "%.0f" "$RATE_USED") ))
  RATE_COLOR=$(color_for "$RATE_PCT")
  RESETS_STR=$(time_until "$RESETS_AT")
  printf "${RATE_COLOR}CLAUDE  [$(make_bar "$RATE_PCT")] %3d%%${RESET}" "$RATE_PCT"
  [ -n "$RESETS_STR" ] && printf " \033[90m(reset: %s)${RESET}" "$RESETS_STR"
  printf "  "
fi

# --- Cost ---
if [ -n "$COST" ]; then
  COST_FMT=$(awk "BEGIN { printf \"%.3f\", $COST }" 2>/dev/null || echo "$COST")
  printf "\033[37m\$%s${RESET}" "$COST_FMT"
fi

echo
