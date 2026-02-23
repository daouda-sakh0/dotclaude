# dotclaude

Personal [Claude Code](https://claude.ai/claude-code) configuration files (`~/.claude`).

## Status Line

A two-row status line with a colorful, information-dense layout.

### Row 1
- Working directory (blue)
- Git branch with dirty/ahead-behind indicators (grey)
- Python venv name (grey, if active)
- `user@host` (grey, only in SSH sessions or as root)

### Row 2
- **Model name** in amber with grey brackets — e.g. `[Claude Opus 4.6]`
- **Context bar** — segmented and color-coded (cyan = cache read, magenta = cache create, blue = input, yellow = output, dim = free) with a percentage that shifts green/yellow/red
- **Session cost** in green — `💸: $0.0124`
- **Session duration** in blue — `🕰️: 3m 17s`

### Installation

```bash
# Copy the status line script
cp statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

Add to your `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  }
}
```
