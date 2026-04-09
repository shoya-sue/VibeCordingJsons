#!/bin/bash
# Claude Code Status Line — Fighting Game Health Bar
# Displays context window usage as a depleting HP gauge

# --- Env vars provided by Claude Code ---
COST="${CLAUDE_COST_USD:-0}"
INPUT="${CLAUDE_INPUT_TOKENS:-0}"
OUTPUT="${CLAUDE_OUTPUT_TOKENS:-0}"
CACHE="${CLAUDE_CACHE_READ_TOKENS:-0}"

# --- Config ---
MAX_TOKENS=200000   # Sonnet / Opus 200k context window
BAR_WIDTH=20

# --- Calculate total tokens & percentage used ---
TOTAL=$(( INPUT + OUTPUT + CACHE ))
if [ "$TOTAL" -gt "$MAX_TOKENS" ]; then TOTAL=$MAX_TOKENS; fi
PCT_USED=$(( TOTAL * 100 / MAX_TOKENS ))
PCT_HP=$(( 100 - PCT_USED ))

# --- Build bar (fills from left, depletes as context is consumed) ---
FILLED=$(( PCT_HP * BAR_WIDTH / 100 ))
EMPTY=$(( BAR_WIDTH - FILLED ))

BAR=""
for _ in $(seq 1 "$FILLED");  do BAR="${BAR}█"; done
for _ in $(seq 1 "$EMPTY");   do BAR="${BAR}░"; done

# --- Color: green > 60%, yellow 30–60%, red < 30% ---
if   [ "$PCT_HP" -gt 60 ]; then COLOR="\033[32m"   # green
elif [ "$PCT_HP" -gt 30 ]; then COLOR="\033[33m"   # yellow
else                             COLOR="\033[31m"   # red
fi
RESET="\033[0m"

# --- Format cost (3 decimal places) ---
COST_FMT=$(awk "BEGIN { printf \"%.3f\", $COST }" 2>/dev/null || echo "$COST")

# --- Output ---
printf "${COLOR}CLAUDE [${BAR}] %3d%% HP  \$${COST_FMT}${RESET}\n" "$PCT_HP"
