#!/bin/bash
# Claude Code Status Line — Dual Fighting Game HP Gauges
#
# Reads JSON from stdin (provided by Claude Code):
#   .context_window.remaining_percentage        — context window remaining %
#   .rate_limits.five_hour.used_percentage      — 5-hour usage %
#   .rate_limits.five_hour.resets_at            — reset time (Unix timestamp)
#   .cost.total_cost_usd                        — session total cost

input=$(cat)

# --- Parse stdin JSON ---
CTX_REMAINING=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
RATE_USED=$(echo "$input"     | jq -r '.rate_limits.five_hour.used_percentage // empty')
RESETS_AT=$(echo "$input"     | jq -r '.rate_limits.five_hour.resets_at // empty')
COST=$(echo "$input"          | jq -r '.cost.total_cost_usd // empty')

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

# Compute time until reset from Unix timestamp
time_until() {
  local ts="$1"
  [ -z "$ts" ] && return
  local now diff h m
  now=$(date +%s)
  diff=$(( ts - now ))
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
