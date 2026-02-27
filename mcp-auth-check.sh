#!/bin/bash
# mcp-auth-check.sh - Check which MCP servers need re-authentication
# Usage: bash ~/.claude/mcp-auth-check.sh

CREDS_FILE="$HOME/.claude/.credentials.json"
AUTH_CACHE="$HOME/.claude/mcp-needs-auth-cache.json"
NOW_MS=$(($(date +%s) * 1000))
EXPIRED=()
VALID=()
NO_TOKEN=()

if [ ! -f "$CREDS_FILE" ]; then
  echo "No credentials file found at $CREDS_FILE"
  exit 1
fi

# Extract all MCP OAuth server entries
SERVERS=$(python3 -c "
import json, sys
with open('$CREDS_FILE') as f:
    data = json.load(f)
mcp = data.get('mcpOAuth', {})
for key, val in mcp.items():
    name = val.get('serverName', key.split('|')[0])
    expires = val.get('expiresAt', 0)
    has_token = bool(val.get('accessToken', ''))
    has_refresh = bool(val.get('refreshToken', ''))
    print(f'{name}|{expires}|{has_token}|{has_refresh}')
" 2>/dev/null)

if [ -z "$SERVERS" ]; then
  echo "No MCP servers found in credentials."
  exit 0
fi

echo ""
echo "=== MCP Server Auth Status ==="
echo ""
printf "%-25s %-12s %-10s %s\n" "SERVER" "STATUS" "REFRESH?" "EXPIRES"
printf "%-25s %-12s %-10s %s\n" "-------" "------" "--------" "-------"

while IFS='|' read -r name expires has_token has_refresh; do
  if [ "$has_token" = "False" ] || [ "$expires" -eq 0 ]; then
    status="NO TOKEN"
    NO_TOKEN+=("$name")
  elif [ "$expires" -lt "$NOW_MS" ]; then
    status="EXPIRED"
    EXPIRED+=("$name")
  else
    status="VALID"
    remaining_s=$(( (expires - NOW_MS) / 1000 ))
    VALID+=("$name")
  fi

  if [ "$has_refresh" = "True" ]; then
    refresh_str="yes"
  else
    refresh_str="no"
  fi

  if [ "$expires" -gt 0 ]; then
    if command -v gdate &>/dev/null; then
      exp_date=$(gdate -d @$((expires / 1000)) '+%Y-%m-%d %H:%M' 2>/dev/null || echo "unknown")
    else
      exp_date=$(date -r $((expires / 1000)) '+%Y-%m-%d %H:%M' 2>/dev/null || echo "unknown")
    fi
  else
    exp_date="never authed"
  fi

  # Color coding
  if [ "$status" = "VALID" ]; then
    printf "\033[32m%-25s %-12s %-10s %s\033[0m\n" "$name" "$status" "$refresh_str" "$exp_date"
  elif [ "$status" = "EXPIRED" ]; then
    printf "\033[33m%-25s %-12s %-10s %s\033[0m\n" "$name" "$status" "$refresh_str" "$exp_date"
  else
    printf "\033[31m%-25s %-12s %-10s %s\033[0m\n" "$name" "$status" "$refresh_str" "$exp_date"
  fi
done <<< "$SERVERS"

echo ""

NEED_AUTH=("${NO_TOKEN[@]}" "${EXPIRED[@]}")
if [ ${#NEED_AUTH[@]} -eq 0 ]; then
  echo "All MCP servers are authenticated."
else
  echo "${#NEED_AUTH[@]} server(s) need re-authentication."
  echo ""
  echo "To re-auth in Claude Code, run /mcp for each server:"
  for s in "${NEED_AUTH[@]}"; do
    echo "  /mcp $s"
  done
  echo ""
  echo "Tip: Copy-paste each /mcp command in your Claude Code session."
fi
