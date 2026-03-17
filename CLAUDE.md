# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal Claude Code configuration (`~/.claude`) managed as a git repo. Contains a custom status line, reusable skills, a persistent memory system, and the [superpowers](https://github.com/obra/superpowers.git) plugin (git submodule at `plugins/superpowers/`).

## Setup

```bash
./setup.sh
```

This single command: sets git hooks path to `.githooks/`, inits submodules, copies skills to `~/.claude/skills/`, creates the archival memory directory tree, adds memory permission rules to `~/.claude/settings.json`, and enables marketplace plugins (claude-md-management, semgrep, superpowers).

## Repository Structure

```
statusline-command.sh        # Two-row statusline script (reads JSON from stdin, outputs ANSI)
mcp-auth-check.sh            # Diagnostic: shows which MCP OAuth tokens are expired
setup.sh                     # One-time setup (hooks, submodules, skills deploy, memory init)
.githooks/                   # post-checkout + post-merge auto-update submodules
skills/                      # Local skills (deployed to ~/.claude/skills/ by setup.sh)
  skill-author/              # Meta-skill for authoring new skills
  memory/                    # 3-tier persistent memory system (/memory save|recall|maintain|status)
  brag/                      # Weekly brag doc generator from archival memories
plugins/
  superpowers/               # Git submodule — development workflow skills (TDD, planning, debugging, etc.)
```

## Architecture Notes

### Status Line (`statusline-command.sh`)

Reads a JSON blob from stdin (provided by Claude Code) containing `workspace`, `model`, `context_window`, and `cost` fields. Outputs two ANSI-formatted rows via `printf %b`. Uses `/tmp/statusline-git-cache` (5s TTL) and `/tmp/statusline-mcp-cache` (60s TTL) to avoid expensive git and credential-parsing operations on every refresh. Depends on `jq` and `python3`.

### Skills

Skills live in `skills/<name>/SKILL.md` with optional `references/` subdirectories. The `skill-author` skill documents the full authoring conventions:

- SKILL.md files use YAML frontmatter (`name`, `description`, `allowed-tools`)
- Complexity tiers: Minimal (50-150 lines), Standard (150-400), Advanced (400-600)
- Hard limit: SKILL.md should not exceed ~500 lines; extract to `references/` beyond that
- Every step needs: narrative + procedure + interpretation table

### Memory System (`skills/memory/`)

Deployed to `~/.claude/projects/-Users-<username>/memory/`. Three tiers:

- **Tier 1 (Working)**: Native session context
- **Tier 2 (Core)**: `MEMORY.md` — auto-loaded every session, 200-line hard limit
- **Tier 3 (Archival)**: `.md` files with YAML frontmatter in `episodic/`, `semantic/`, `procedural/` dirs, indexed by tags in `archival/index.md`

Memory IDs follow format: `mem_YYYYMMDD_HHMMSS_XXXX` (4 random hex chars). Decay formula: `effective_importance = base_importance - (days_since_last_access / 30)`.

### Superpowers Plugin (`plugins/superpowers/`)

Git submodule from `github.com/obra/superpowers`. Contains workflow skills (TDD, planning, code review, debugging, etc.), a `code-reviewer` agent, slash commands (`/brainstorm`, `/execute-plan`, `/write-plan`), and a session-start hook. Do not edit files inside this submodule — changes belong upstream.

## Conventions

- Shell scripts use `#!/bin/bash` (or `#!/bin/sh` for simple hooks) and `set -e`
- The status line caches expensive operations (git status, MCP auth) in `/tmp/` with TTLs
- Skills reference files use relative links: `[file.md](./references/file.md)`
- Memory permissions are auto-configured in `~/.claude/settings.json` by `setup.sh`
