#!/bin/sh
# One-time setup: configures git hooks, initializes submodules, and deploys skills
set -e

# Git config
git config core.hooksPath .githooks
git submodule update --init --recursive

# Deploy skills to global Claude config
echo "Deploying skills..."
mkdir -p ~/.claude/skills
cp -r skills/ ~/.claude/skills/

# Create local memory directory structure (not git-tracked)
MEMORY_ROOT="$HOME/.claude/projects/-Users-$(whoami)/memory"
echo "Setting up memory system at $MEMORY_ROOT..."
mkdir -p "$MEMORY_ROOT/archival/episodic"
mkdir -p "$MEMORY_ROOT/archival/semantic"
mkdir -p "$MEMORY_ROOT/archival/procedural"

# Create archival index if it doesn't exist
if [ ! -f "$MEMORY_ROOT/archival/index.md" ]; then
  cat > "$MEMORY_ROOT/archival/index.md" << 'EOF'
# Archival Memory Index

> Auto-generated tag-to-file lookup. Rebuilt by `/memory maintain`.

## Tag Index

_No memories stored yet._

## By Type

### Episodic
_None_

### Semantic
_None_

### Procedural
_None_

## Stats
- Total memories: 0
- Last rebuilt: never
EOF
  echo "  Created archival index."
fi

# Create MEMORY.md template if it doesn't exist
if [ ! -f "$MEMORY_ROOT/MEMORY.md" ]; then
  cat > "$MEMORY_ROOT/MEMORY.md" << 'EOF'
# Core Memory

> Auto-loaded into every session. Keep under 200 lines.
> Detailed knowledge lives in `archival/` — use `/memory recall` to retrieve.

## User Profile

- Name: (your name)
- Platform: macOS (Darwin)
- Shell: zsh

## Preferences

_Accumulates over sessions._

## Active Projects

_None yet._

## Conventions

_Accumulates over sessions._

## Archival Memory Pointer

See [archival/index.md](archival/index.md) for tag-based lookup into long-term memory.
EOF
  echo "  Created MEMORY.md template."
fi

echo "Done! Submodules initialized, hooks configured, skills deployed, memory system ready."
