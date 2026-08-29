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
- **Session cost** in green — `💸: $0.01`
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

## Skills

Reusable Claude Code skills that can be shared across workspaces.

### wiki

Obsidian knowledge vault management. Distills session knowledge into a four-bucket vault (Facts, Procedures, Concepts, Questions) with `[[wikilinks]]` for cross-referencing.

**Subcommands:**
- `/wiki:distill-session` — capture session knowledge into the vault
- `/wiki:help` — show usage

### brag

Weekly brag document generator. Run on Fridays with `/brag` to produce a formatted weekly entry from your knowledge vault, ready to paste into your brag doc.

- Scans recent work for highlights with impact-first phrasing
- Groups by theme when there are 4+ items (Incident Response, Engineering, Tooling, etc.)
- Outputs a formatted entry matching the brag doc's week-header + bullet-point style

### Installation

```bash
./setup.sh
```
