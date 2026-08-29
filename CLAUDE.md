# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal Claude Code configuration (`~/.claude`) managed as a git repo. Contains a custom status line, reusable skills, and the [superpowers](https://github.com/obra/superpowers.git) plugin (git submodule at `plugins/superpowers/`).

## Setup

```bash
./setup.sh
```

This single command: sets git hooks path to `.githooks/`, inits submodules, symlinks skills to `~/.claude/skills/`, and enables marketplace plugins (claude-md-management, superpowers).

## Repository Structure

```
CLAUDE.user.md               # User-level global instructions (deployed to ~/.claude/CLAUDE.md)
statusline-command.sh        # Two-row statusline script (reads JSON from stdin, outputs ANSI)
mcp-auth-check.sh            # Diagnostic: shows which MCP OAuth tokens are expired
setup.sh                     # One-time setup (hooks, submodules, skills deploy)
.githooks/                   # post-checkout + post-merge auto-update submodules
skills/                      # Local skills (deployed to ~/.claude/skills/ by setup.sh)
  brag/                      # Weekly brag doc generator
  wiki/                      # Obsidian vault management (/wiki:distill-session, future: recall, organize)
plugins/
  superpowers/               # Git submodule — development workflow skills (TDD, planning, debugging, etc.)
```

## Architecture Notes

### Status Line (`statusline-command.sh`)

Reads a JSON blob from stdin (provided by Claude Code) containing `workspace`, `model`, `context_window`, and `cost` fields. Outputs two ANSI-formatted rows via `printf %b`. Uses `/tmp/statusline-git-cache` (5s TTL) and `/tmp/statusline-mcp-cache` (60s TTL) to avoid expensive git and credential-parsing operations on every refresh. Depends on `jq` and `python3`.

### Skills

Skills live in `skills/<name>/SKILL.md` with optional `references/` subdirectories:

- SKILL.md files use YAML frontmatter (`name`, `description`, `allowed-tools`)
- Hard limit: SKILL.md should not exceed ~500 lines; extract to `references/` beyond that

### Superpowers Plugin (`plugins/superpowers/`)

Git submodule from `github.com/obra/superpowers`. Contains workflow skills (TDD, planning, code review, debugging, etc.), a `code-reviewer` agent, slash commands (`/brainstorm`, `/execute-plan`, `/write-plan`), and a session-start hook. Do not edit files inside this submodule — changes belong upstream.

## Conventions

- Shell scripts use `#!/bin/bash` (or `#!/bin/sh` for simple hooks) and `set -e`
- The status line caches expensive operations (git status, MCP auth) in `/tmp/` with TTLs
- Skills reference files use relative links: `[file.md](./references/file.md)`
