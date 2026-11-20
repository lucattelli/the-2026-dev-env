#!/bin/bash
# Claude Code status line:
#   model | dir + git branch + lines +/- | context bar (threshold-colored, smooth Unicode) |
#   weekly usage limit + reset | session cost | session duration

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')

RESET=$'\033[0m'; DIM=$'\033[2m'; BOLD=$'\033[1m'
RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'
BLUE=$'\033[34m'; MAGENTA=$'\033[35m'; CYAN=$'\033[36m'
SEP="${DIM} | ${RESET}"

segments=()

# --- Model ---
segments+=("${BOLD}${MAGENTA}🧠 ${model}${RESET}")

# --- Directory + git branch + uncommitted changes in the repo ---
# +added/-removed: tracked changes vs HEAD (staged and unstaged).
# ?N: untracked files. Both hidden when the working tree is clean.
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  dir_seg="${CYAN}📁 $(basename "$cwd")${RESET}"
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dir_seg="${dir_seg} ${DIM}⎇${RESET} ${BLUE}${branch}${RESET}"
    read -r la lr <<<"$(git -C "$cwd" diff HEAD --numstat 2>/dev/null |
      awk '{a+=$1; r+=$2} END {print a+0, r+0}')"
    untracked=$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    if [ "${la:-0}" != "0" ] || [ "${lr:-0}" != "0" ]; then
      dir_seg="${dir_seg} ${GREEN}+${la}${RESET}${DIM}/${RESET}${RED}-${lr}${RESET}"
    fi
    [ "${untracked:-0}" != "0" ] && dir_seg="${dir_seg} ${YELLOW}?${untracked}${RESET}"
  fi
  segments+=("$dir_seg")
fi

# --- Context usage: smooth Unicode bar, colored by threshold ---
used_int=$(printf '%.0f' "$used")
[ "$used_int" -lt 0 ] 2>/dev/null && used_int=0
[ "$used_int" -gt 100 ] 2>/dev/null && used_int=100

if   [ "$used_int" -lt 50 ]; then bar_color=$GREEN
elif [ "$used_int" -lt 80 ]; then bar_color=$YELLOW
else                              bar_color=$RED
fi

bar_width=10
partials=("" "▏" "▎" "▍" "▌" "▋" "▊" "▉")
eighths=$(( used_int * bar_width * 8 / 100 ))
full=$(( eighths / 8 ))
rem=$(( eighths % 8 ))

bar=""
for ((i = 0; i < full; i++)); do bar="${bar}█"; done
[ "$rem" -gt 0 ] && bar="${bar}${partials[$rem]}"
pad=$(( bar_width - full - (rem > 0 ? 1 : 0) ))
for ((i = 0; i < pad; i++)); do bar="${bar}░"; done

segments+=("${bar_color}${bar} ${used_int}%${RESET}")

# --- Weekly usage limit with reset time ---
if [ -n "$week_pct" ]; then
  wp=$(printf '%.0f' "$week_pct")
  if   [ "$wp" -lt 50 ]; then wc=$GREEN
  elif [ "$wp" -lt 80 ]; then wc=$YELLOW
  else                        wc=$RED
  fi
  seg="${wc}7d: ${wp}%${RESET}"
  if [ -n "$week_reset" ]; then
    # GNU date (Debian) takes -d @epoch; BSD date (macOS) takes -r epoch.
    reset_fmt=$(date -d "@$week_reset" '+%a %b %d %H:%M' 2>/dev/null || date -r "$week_reset" '+%a %b %d %H:%M')
    seg="${seg}${DIM} (resets ${reset_fmt})${RESET}"
  fi
  segments+=("$seg")
fi

# --- Session cost, colored by spend ---
if [ -n "$cost" ] && [ "$cost" != "null" ]; then
  cost_fmt=$(awk -v c="$cost" 'BEGIN{ if (c < 0.1) printf "%.4f", c; else printf "%.2f", c }')
  cost_color=$(awk -v c="$cost" -v g="$GREEN" -v y="$YELLOW" -v r="$RED" \
    'BEGIN{ if (c < 2) print g; else if (c < 10) print y; else print r }')
  segments+=("${cost_color}💰 \$${cost_fmt}${RESET}")
fi

# --- Session duration ---
if [ -n "$duration_ms" ] && [ "$duration_ms" != "null" ]; then
  mins=$(( duration_ms / 60000 ))
  if [ "$mins" -ge 60 ]; then
    dur="$(( mins / 60 ))h $(( mins % 60 ))m"
  else
    dur="${mins}m"
  fi
  [ "$mins" -ge 1 ] && segments+=("${DIM}⏱ ${dur}${RESET}")
fi

# --- Join segments ---
out=""
for s in "${segments[@]}"; do
  if [ -z "$out" ]; then out="$s"; else out="${out}${SEP}${s}"; fi
done
printf "%s" "$out"
