#!/bin/bash

# Two-row statusline for Claude Code
#
# Row 1 (top):  user@host (SSH/root only)  cwd  git  venv
# Row 2 (bottom): [Model]  context-bar  💸: $X.XX  🕰️: Xm Xs

# Read JSON input
input=$(cat)

# ---------------------------------------------------------------------------
# Colours
# ---------------------------------------------------------------------------
grey='\033[38;5;242m'
green='\033[38;2;97;214;97m'
blue='\033[38;2;87;199;255m'
cyan='\033[38;2;154;237;254m'
amber='\033[38;2;255;198;109m'
reset='\033[0m'

# ---------------------------------------------------------------------------
# ROW 1 — directory, git, venv
# ---------------------------------------------------------------------------
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
dir_display=$(echo "$current_dir" | sed "s|^$HOME|~|")

# Context (user@host) — only in SSH sessions or as root
user_host=""
if [ -n "$SSH_CONNECTION" ] || [ "$EUID" -eq 0 ]; then
    user_host="${grey}$(whoami)@$(hostname -s)${reset} "
fi

# Git status (cached — git operations are expensive to run every refresh)
GIT_CACHE_DIR="/tmp/statusline-git-cache"
CACHE_MAX_AGE=5  # seconds
mkdir -p "$GIT_CACHE_DIR"

cache_key=$(printf '%s' "$current_dir" | md5 2>/dev/null || printf '%s' "$current_dir" | md5sum 2>/dev/null | cut -d' ' -f1)
cache_file="${GIT_CACHE_DIR}/${cache_key}"

cache_is_stale() {
    [ ! -f "$cache_file" ] || \
    [ $(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
}

if cache_is_stale; then
    if git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
        branch=$(git -C "$current_dir" --no-optional-locks branch --show-current 2>/dev/null)
        if [ -z "$branch" ]; then
            branch="@$(git -C "$current_dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)"
        fi

        dirty=""
        if ! git -C "$current_dir" --no-optional-locks diff --quiet 2>/dev/null || \
           ! git -C "$current_dir" --no-optional-locks diff --cached --quiet 2>/dev/null || \
           [ -n "$(git -C "$current_dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null)" ]; then
            dirty="*"
        fi

        ahead_behind=""
        upstream=$(git -C "$current_dir" --no-optional-locks rev-parse --abbrev-ref @{upstream} 2>/dev/null)
        if [ -n "$upstream" ]; then
            ahead=$(git -C "$current_dir" --no-optional-locks rev-list --count @{upstream}..HEAD 2>/dev/null)
            behind=$(git -C "$current_dir" --no-optional-locks rev-list --count HEAD..@{upstream} 2>/dev/null)
            if [ "$behind" -gt 0 ] && [ "$ahead" -gt 0 ]; then
                ahead_behind="⇣⇡"
            elif [ "$behind" -gt 0 ]; then
                ahead_behind="⇣"
            elif [ "$ahead" -gt 0 ]; then
                ahead_behind="⇡"
            fi
        fi

        echo "${branch}|${dirty}|${ahead_behind}" > "$cache_file"
    else
        echo "||" > "$cache_file"
    fi
fi

IFS='|' read -r branch dirty ahead_behind < "$cache_file"

git_info=""
if [ -n "$branch" ]; then
    git_info=" ${grey}${branch}${dirty}${ahead_behind}${reset}"
fi

# Python virtual environment
venv_info=""
if [ -n "$VIRTUAL_ENV" ]; then
    venv_name=$(basename "$VIRTUAL_ENV")
    venv_info=" ${grey}${venv_name}${reset}"
fi

# MCP auth status (cached — only re-check every 60s)
MCP_CACHE_DIR="/tmp/statusline-mcp-cache"
MCP_CACHE_MAX_AGE=60
mkdir -p "$MCP_CACHE_DIR"
mcp_cache_file="${MCP_CACHE_DIR}/mcp-auth-status"

mcp_cache_is_stale() {
    [ ! -f "$mcp_cache_file" ] || \
    [ $(($(date +%s) - $(stat -f %m "$mcp_cache_file" 2>/dev/null || stat -c %Y "$mcp_cache_file" 2>/dev/null || echo 0))) -gt $MCP_CACHE_MAX_AGE ]
}

if mcp_cache_is_stale; then
    mcp_expired=$(python3 -c "
import json, time, os
creds = os.path.expanduser('~/.claude/.credentials.json')
if not os.path.exists(creds):
    print('0')
else:
    with open(creds) as f:
        data = json.load(f)
    now_ms = int(time.time() * 1000)
    count = 0
    for key, val in data.get('mcpOAuth', {}).items():
        exp = val.get('expiresAt', 0)
        tok = val.get('accessToken', '')
        if not tok or exp == 0 or exp < now_ms:
            count += 1
    print(count)
" 2>/dev/null || echo "0")
    echo "$mcp_expired" > "$mcp_cache_file"
fi

mcp_expired_count=$(cat "$mcp_cache_file" 2>/dev/null || echo "0")
mcp_info=""
if [ "$mcp_expired_count" -gt 0 ]; then
    red='\033[38;2;255;92;87m'
    mcp_info=" ${red}MCP:${mcp_expired_count}⚠${reset}"
fi

row1="${user_host}${blue}${dir_display}${reset}${git_info}${venv_info}"

# ---------------------------------------------------------------------------
# ROW 2 — [Model]  context-bar  💸: $X.XX  🕰️: Xm Xs
# ---------------------------------------------------------------------------

# -- Model name --
model_name=$(echo "$input" | jq -r '.model.display_name // empty')
model_part=""
if [ -n "$model_name" ]; then
    model_part="${grey}[${reset}${amber}${model_name}${reset}${grey}]${reset}"
fi

# -- Context-window bar (segmented, colourful) --
#   ■ cyan    = cache read
#   ■ magenta = cache create
#   ■ blue    = input
#   ■ yellow  = output
#   ░ dim     = free
context_bar=""
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$ctx_size" ] && [ -n "$used_pct" ] && [ "$ctx_size" -gt 0 ]; then
    pct_int=$(printf "%.0f" "$used_pct")

    cache_read=$(echo "$input"   | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
    cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
    input_tok=$(echo "$input"    | jq -r '.context_window.current_usage.input_tokens // 0')
    output_tok=$(echo "$input"   | jq -r '.context_window.current_usage.output_tokens // 0')

    bar_width=20

    read cr_cells cc_cells in_cells ou_cells free_cells <<< $(
        echo "$cache_read $cache_create $input_tok $output_tok $ctx_size $bar_width" | awk '{
            total = $1 + $2 + $3 + $4
            bw = $6
            if (total == 0) { print 0, 0, 0, 0, bw; exit }
            cr  = int($1 / $5 * bw)
            cc  = int($2 / $5 * bw)
            inp = int($3 / $5 * bw)
            ou  = int($4 / $5 * bw)
            used = cr + cc + inp + ou
            if ($1 > 0 && cr  == 0 && used < bw) { cr  = 1; used++ }
            if ($2 > 0 && cc  == 0 && used < bw) { cc  = 1; used++ }
            if ($3 > 0 && inp == 0 && used < bw) { inp = 1; used++ }
            if ($4 > 0 && ou  == 0 && used < bw) { ou  = 1; used++ }
            free = bw - used
            if (free < 0) free = 0
            print cr, cc, inp, ou, free
        }'
    )

    c_cache_read='\033[38;2;154;237;254m'
    c_cache_create='\033[38;2;200;150;255m'
    c_input='\033[38;2;87;199;255m'
    c_output='\033[38;2;243;249;157m'
    c_free='\033[38;5;240m'
    c_reset='\033[0m'

    seg=""
    for i in $(seq 1 $cr_cells   2>/dev/null); do seg="${seg}${c_cache_read}█";   done
    for i in $(seq 1 $cc_cells   2>/dev/null); do seg="${seg}${c_cache_create}█"; done
    for i in $(seq 1 $in_cells   2>/dev/null); do seg="${seg}${c_input}█";        done
    for i in $(seq 1 $ou_cells   2>/dev/null); do seg="${seg}${c_output}█";       done
    for i in $(seq 1 $free_cells 2>/dev/null); do seg="${seg}${c_free}░";         done

    if [ "$pct_int" -le 50 ]; then
        pct_color='\033[38;2;97;214;97m'
    elif [ "$pct_int" -le 75 ]; then
        pct_color='\033[38;2;243;249;157m'
    else
        pct_color='\033[38;2;255;92;87m'
    fi

    context_bar="${seg}${c_reset} ${pct_color}${pct_int}%${c_reset}"
fi

# -- Cost --
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
cost_fmt=$(printf '%.2f' "$cost_usd")
cost_part="${grey}💸:${reset} ${green}\$${cost_fmt}${reset}"

# -- Duration --
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
duration_sec=$((duration_ms / 1000))
mins=$((duration_sec / 60))
secs=$((duration_sec % 60))
if [ "$mins" -ge 1 ]; then
    duration_val="${mins}m ${secs}s"
else
    duration_val="${secs}s"
fi
duration_part="${grey}🕰️:${reset} ${blue}${duration_val}${reset}"

# Assemble row 2
row2=""
if [ -n "$model_part" ]; then
    row2="${model_part}"
fi
if [ -n "$mcp_info" ]; then
    row2="${row2}${mcp_info}"
fi
if [ -n "$context_bar" ]; then
    row2="${row2} ${context_bar}"
fi
row2="${row2}  ${cost_part}  ${duration_part}"

# ---------------------------------------------------------------------------
# Output: row 1 on its own line, then row 2
# ---------------------------------------------------------------------------
printf "%b\n%b\n" "$row1" "$row2"
