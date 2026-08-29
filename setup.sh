#!/bin/sh
# One-time setup: configures git hooks, initializes submodules, deploys skills and global config
set -e

# Git config
git config core.hooksPath .githooks
git submodule update --init --recursive

# Symlink skills into global Claude config (live from repo — no re-run needed after skill edits)
echo "Linking skills..."
mkdir -p ~/.claude/skills
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
for skill_dir in "$REPO_DIR"/skills/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$HOME/.claude/skills/$skill_name"
  if [ -e "$target" ] || [ -L "$target" ]; then
    rm -rf "$target"
  fi
  ln -sf "$skill_dir" "$target"
  echo "  Linked $skill_name"
done

# Deploy user-level CLAUDE.md
echo "Deploying global CLAUDE.md..."
cp "$REPO_DIR/CLAUDE.user.md" "$HOME/.claude/CLAUDE.md"
echo "  Installed ~/.claude/CLAUDE.md"

# Enable marketplace plugins
SETTINGS_FILE="$HOME/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
  echo "Configuring plugins..."
  python3 -c "
import json
with open('$SETTINGS_FILE', 'r') as f:
    settings = json.load(f)
plugins = settings.setdefault('enabledPlugins', {})
desired = [
    'claude-md-management@claude-plugins-official',
    'superpowers@claude-plugins-official',
]
changed = False
for p in desired:
    if p not in plugins:
        plugins[p] = True
        changed = True
if changed:
    with open('$SETTINGS_FILE', 'w') as f:
        json.dump(settings, f, indent=2)
        f.write('\n')
    print('  Plugins enabled.')
else:
    print('  Plugins already configured.')
"
else
  echo "  Warning: $SETTINGS_FILE not found. Create it and re-run setup to enable plugins."
fi

echo "Done! Hooks configured, submodules initialized, skills deployed."
