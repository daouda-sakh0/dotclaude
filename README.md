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

### skill-author

Meta-skill for designing and writing high-quality Claude Code skills. Guides you through a step-by-step authoring workflow with embedded patterns, templates, and anti-patterns drawn from production-grade skill development.

### memory

3-tier persistent memory system for Claude Code. Stores distilled session insights in a local archival file store with tag-based retrieval.

**Subcommands:**
- `/memory save` — distill current session insights into archival memory
- `/memory recall [topic]` — retrieve relevant memories by topic
- `/memory maintain` — run decay, merge, prune, rebuild index
- `/memory status` — show memory stats (count by type, MEMORY.md usage)

**Architecture:**
- **Tier 1 (Working)**: Native session context (no changes needed)
- **Tier 2 (Core)**: `MEMORY.md` auto-loaded every session (200-line limit)
- **Tier 3 (Archival)**: Local `.md` files with YAML frontmatter in `episodic/`, `semantic/`, `procedural/` subdirectories, indexed by tags

**Retrieval**: Tag match against `index.md`, with full-text grep fallback. No embeddings required.

**Decay**: `effective_importance = base_importance - (days_since_last_access / 30)`. Memories at zero are candidates for eviction during `/memory maintain`.

### Permissions

The memory skill needs Read/Edit/Write access to the memory directory without permission prompts. Setup automatically adds these rules to `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Read(~/.claude/projects/-Users-<username>/memory/**)",
      "Edit(~/.claude/projects/-Users-<username>/memory/**)",
      "Write(~/.claude/projects/-Users-<username>/memory/**)"
    ]
  }
}
```

### Installation

```bash
# Run setup to deploy all skills and create memory directories
./setup.sh
```
